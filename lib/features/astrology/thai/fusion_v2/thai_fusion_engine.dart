import '../foundation/models/profile_warning.dart';
import '../interpretation/models/thai_interpretation_bundle.dart';
import '../mirror_v2/contracts/thai_mirror_dimension_mapping_contract.dart';
import '../mirror_v2/contracts/thai_mirror_warning_contract.dart';
import '../mirror_v2/enums/thai_mirror_dimension_id.dart';
import '../mirror_v2/enums/thai_mirror_structural_confidence.dart';
import '../mirror_v2/models/thai_mirror_snapshot.dart';
import '../theme/models/thai_theme_confidence_level.dart';
import '../theme_v2/models/thai_theme_bundle.dart';
import '../theme_v2/models/thai_theme_score.dart';
import 'contracts/thai_fusion_engine_contract.dart';
import 'contracts/thai_fusion_warning_contract.dart';
import 'enums/thai_fusion_category_id.dart';
import 'enums/thai_fusion_confidence_level.dart';
import 'enums/thai_fusion_pattern_type.dart';
import 'enums/thai_fusion_source_layer.dart';
import 'models/thai_fusion_agreement.dart';
import 'models/thai_fusion_category_activation.dart';
import 'models/thai_fusion_confidence.dart';
import 'models/thai_fusion_coverage.dart';
import 'models/thai_fusion_evidence.dart';
import 'models/thai_fusion_insight.dart';
import 'models/thai_fusion_snapshot.dart';
import 'models/thai_fusion_source_refs.dart';
import 'models/thai_fusion_tension.dart';
import 'ports/thai_fusion_category_mapper_port.dart';

class ThaiFusionEngineResult {
  const ThaiFusionEngineResult({
    required this.snapshot,
    required this.warnings,
  });

  final ThaiFusionSnapshot snapshot;
  final List<ProfileWarning> warnings;
}

/// Synthesizes cross-layer structural fusion from mirror, theme, and interpretation.
///
/// Synthesis only — no narrative, content text, or upstream signal access.
abstract final class ThaiFusionEngine {
  static const insufficientCoverageCategoryThreshold = 4;

  static ThaiFusionEngineResult synthesize({
    required ThaiMirrorSnapshot mirror,
    required ThaiThemeBundle theme,
    required ThaiInterpretationBundle interpretation,
  }) {
    final warnings = <ProfileWarning>[];
    _validateLineage(
      mirror: mirror,
      theme: theme,
      interpretation: interpretation,
      warnings: warnings,
    );

    final interpretationFactIds = interpretation.facts
        .map((fact) => fact.factId)
        .toSet();
    final groupedThemes = _groupThemesByCategory(theme.themes);
    final categories = _buildCategoryActivations(
      groupedThemes: groupedThemes,
      mirror: mirror,
    );
    final agreements = _detectAgreements(
      groupedThemes: groupedThemes,
      interpretationFactIds: interpretationFactIds,
      mirror: mirror,
    );
    final tensions = _detectTensions();
    final insights = _buildInsights(
      categories: categories,
      agreements: agreements,
      groupedThemes: groupedThemes,
      interpretationFactIds: interpretationFactIds,
      mirror: mirror,
    );
    final hasSparseDimensions = _hasSparseDimensions(mirror);
    final coverage = _buildCoverage(
      categories: categories,
      mirror: mirror,
      interpretation: interpretation,
      hasSparseDimensions: hasSparseDimensions,
    );
    final confidence = _buildConfidence(
      mirror: mirror,
      theme: theme,
      interpretation: interpretation,
    );

    _emitCoverageWarnings(
      warnings: warnings,
      coverage: coverage,
      hasSparseDimensions: hasSparseDimensions,
    );

    warnings.sort((a, b) {
      final fieldCompare = a.affectedFields.first.compareTo(b.affectedFields.first);
      if (fieldCompare != 0) {
        return fieldCompare;
      }
      return a.code.compareTo(b.code);
    });

    insights.sort((a, b) {
      final categoryCompare = a.categoryId.id.compareTo(b.categoryId.id);
      if (categoryCompare != 0) {
        return categoryCompare;
      }
      final patternCompare = a.patternType.id.compareTo(b.patternType.id);
      if (patternCompare != 0) {
        return patternCompare;
      }
      return a.insightId.compareTo(b.insightId);
    });

    final snapshot = ThaiFusionSnapshot(
      fusionSnapshotId: fusionSnapshotId(sourceMirrorSnapshotId: mirror.snapshotId),
      sourceMirrorSnapshotId: mirror.snapshotId,
      sourceThemeBundleId: theme.bundleId,
      sourceInterpretationBundleId: interpretation.bundleId,
      fusionVersion: ThaiFusionEngineContract.fusionVersion,
      generatedAt: mirror.generatedAt.toUtc(),
      categories: List<ThaiFusionCategoryActivation>.unmodifiable(categories),
      insights: List<ThaiFusionInsight>.unmodifiable(insights),
      agreements: List<ThaiFusionAgreement>.unmodifiable(agreements),
      tensions: List<ThaiFusionTension>.unmodifiable(tensions),
      confidence: confidence,
      coverage: coverage,
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );

    return ThaiFusionEngineResult(
      snapshot: snapshot,
      warnings: snapshot.warnings,
    );
  }

  static String fusionSnapshotId({required String sourceMirrorSnapshotId}) {
    return '$sourceMirrorSnapshotId'
        '${ThaiFusionEngineContract.fusionSnapshotIdDelimiter}'
        '${ThaiFusionEngineContract.fusionVersion}';
  }

  static ThaiFusionConfidenceLevel themeLevelConfidence(
    Iterable<ThaiThemeScore> themes,
  ) {
    var hasHigh = false;
    var hasMedium = false;

    for (final theme in themes) {
      if (theme.confidence == ThaiThemeConfidenceLevel.high) {
        hasHigh = true;
      } else if (theme.confidence == ThaiThemeConfidenceLevel.medium) {
        hasMedium = true;
      }
    }

    if (hasHigh) {
      return ThaiFusionConfidenceLevel.high;
    }
    if (hasMedium) {
      return ThaiFusionConfidenceLevel.medium;
    }
    return ThaiFusionConfidenceLevel.low;
  }

  static ThaiFusionConfidenceLevel mirrorLevelConfidence(
    ThaiMirrorSnapshot mirror,
  ) {
    var hasHigh = false;
    var hasMedium = false;

    for (final dimension in mirror.dimensions) {
      if (dimension.confidence == ThaiMirrorStructuralConfidence.high) {
        hasHigh = true;
      } else if (dimension.confidence == ThaiMirrorStructuralConfidence.medium) {
        hasMedium = true;
      }
    }

    if (hasHigh) {
      return ThaiFusionConfidenceLevel.high;
    }
    if (hasMedium) {
      return ThaiFusionConfidenceLevel.medium;
    }
    return ThaiFusionConfidenceLevel.low;
  }

  static ThaiFusionConfidenceLevel interpretationLevelConfidence(int factCount) {
    if (factCount >= 10) {
      return ThaiFusionConfidenceLevel.high;
    }
    if (factCount >= 4) {
      return ThaiFusionConfidenceLevel.medium;
    }
    return ThaiFusionConfidenceLevel.low;
  }

  static ThaiFusionConfidenceLevel overallConfidenceLevel({
    required ThaiFusionConfidenceLevel mirrorLevel,
    required ThaiFusionConfidenceLevel themeLevel,
    required ThaiFusionConfidenceLevel interpretationLevel,
    required int interpretationFactCount,
  }) {
    if (mirrorLevel == ThaiFusionConfidenceLevel.high &&
        themeLevel == ThaiFusionConfidenceLevel.high &&
        interpretationFactCount >= 10) {
      return ThaiFusionConfidenceLevel.high;
    }

    var mediumLayerCount = 0;
    for (final level in [mirrorLevel, themeLevel, interpretationLevel]) {
      if (level == ThaiFusionConfidenceLevel.medium) {
        mediumLayerCount++;
      }
    }

    if (mediumLayerCount >= 2) {
      return ThaiFusionConfidenceLevel.medium;
    }

    return ThaiFusionConfidenceLevel.low;
  }

  static void _validateLineage({
    required ThaiMirrorSnapshot mirror,
    required ThaiThemeBundle theme,
    required ThaiInterpretationBundle interpretation,
    required List<ProfileWarning> warnings,
  }) {
    final themeBundleStartsWithInterpretation =
        theme.bundleId.startsWith(interpretation.bundleId);
    final mirrorThemeMatch = mirror.sourceThemeBundleId == theme.bundleId;

    if (!themeBundleStartsWithInterpretation || !mirrorThemeMatch) {
      warnings.add(
        ProfileWarning(
          code: ThaiFusionWarningContract.inputLineageMismatch,
          severity: ProfileWarningSeverity.high,
          message: 'Fusion input lineage mismatch',
          affectedFields: [
            interpretation.bundleId,
            theme.bundleId,
            mirror.sourceThemeBundleId,
          ],
        ),
      );
    }
  }

  static Map<ThaiFusionCategoryId, List<ThaiThemeScore>> _groupThemesByCategory(
    List<ThaiThemeScore> themes,
  ) {
    final grouped = <ThaiFusionCategoryId, List<ThaiThemeScore>>{};

    for (final theme in themes) {
      final categoryId = ThaiFusionCategoryMapperPort.fusionCategory(theme.category);
      grouped.putIfAbsent(categoryId, () => []).add(theme);
    }

    for (final themesInCategory in grouped.values) {
      themesInCategory.sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.themeId.compareTo(b.themeId);
      });
    }

    return grouped;
  }

  static List<ThaiFusionCategoryActivation> _buildCategoryActivations({
    required Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
    required ThaiMirrorSnapshot mirror,
  }) {
    final activations = <ThaiFusionCategoryActivation>[];

    for (final categoryId in ThaiFusionCategoryId.values) {
      final themes = groupedThemes[categoryId];
      if (themes == null || themes.isEmpty) {
        continue;
      }

      final prominence = themes.fold<double>(0, (total, theme) => total + theme.score);
      final factIds = _distinctFactIds(themes);

      activations.add(
        ThaiFusionCategoryActivation(
          categoryId: categoryId,
          prominence: prominence,
          themeCount: themes.length,
          factCount: factIds.length,
          dimensionRefId: _dimensionRefId(categoryId, mirror),
          confidence: themeLevelConfidence(themes),
        ),
      );
    }

    activations.sort((a, b) => a.categoryId.id.compareTo(b.categoryId.id));
    return activations;
  }

  static List<ThaiFusionAgreement> _detectAgreements({
    required Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
    required Set<String> interpretationFactIds,
    required ThaiMirrorSnapshot mirror,
  }) {
    final agreements = <ThaiFusionAgreement>[];

    for (final categoryId in ThaiFusionCategoryId.values) {
      final themes = groupedThemes[categoryId];
      if (themes == null || themes.isEmpty) {
        continue;
      }

      final themeIds = themes.map((theme) => theme.themeId).toList(growable: false);
      final factIds = _distinctFactIds(themes, interpretationFactIds).toList()
        ..sort();

      if (themeIds.isEmpty || factIds.isEmpty) {
        continue;
      }

      final dimensionRefId = _dimensionRefId(categoryId, mirror);
      agreements.add(
        ThaiFusionAgreement(
          agreementId: _agreementId(categoryId),
          categoryId: categoryId,
          themeIds: themeIds,
          factIds: factIds,
          dimensionIds: dimensionRefId == null ? const [] : [dimensionRefId],
          strength: (themeIds.length + factIds.length).toDouble(),
          confidence: ThaiFusionConfidenceLevel.medium,
        ),
      );
    }

    agreements.sort((a, b) => a.agreementId.compareTo(b.agreementId));
    return agreements;
  }

  static List<ThaiFusionTension> _detectTensions() {
    return const [];
  }

  static List<ThaiFusionInsight> _buildInsights({
    required List<ThaiFusionCategoryActivation> categories,
    required List<ThaiFusionAgreement> agreements,
    required Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
    required Set<String> interpretationFactIds,
    required ThaiMirrorSnapshot mirror,
  }) {
    final insights = <ThaiFusionInsight>[];

    for (final agreement in agreements) {
      insights.add(_crossLayerAgreementInsight(agreement, groupedThemes));
    }

    for (final categoryId in ThaiFusionCategoryId.values) {
      final themes = groupedThemes[categoryId] ?? const <ThaiThemeScore>[];
      final themeIds = themes.map((theme) => theme.themeId).toList(growable: false);
      final factIds = _distinctFactIds(themes, interpretationFactIds).toList()..sort();

      if (themeIds.isEmpty || factIds.isEmpty) {
        insights.add(
          _coverageGapInsight(
            categoryId: categoryId,
            hasThemes: themeIds.isNotEmpty,
            hasFacts: factIds.isNotEmpty,
            themeIds: themeIds,
            factIds: factIds,
            mirror: mirror,
          ),
        );
      }
    }

    insights.addAll(_sparseFusionInsights(mirror, groupedThemes));

    return insights;
  }

  static ThaiFusionInsight _crossLayerAgreementInsight(
    ThaiFusionAgreement agreement,
    Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
  ) {
    final themes = groupedThemes[agreement.categoryId] ?? const <ThaiThemeScore>[];
    final evidence = <ThaiFusionEvidence>[];

    for (final theme in themes) {
      if (!agreement.themeIds.contains(theme.themeId)) {
        continue;
      }
      evidence.add(
        ThaiFusionEvidence(
          sourceLayer: ThaiFusionSourceLayer.theme,
          sourceRefId: theme.themeId,
          categoryId: agreement.categoryId,
          structuralWeight: theme.score,
          confidence: _fusionConfidence(theme.confidence),
        ),
      );
    }

    for (final factId in agreement.factIds) {
      evidence.add(
        ThaiFusionEvidence(
          sourceLayer: ThaiFusionSourceLayer.interpretation,
          sourceRefId: factId,
          categoryId: agreement.categoryId,
          structuralWeight: 1,
          confidence: agreement.confidence,
        ),
      );
    }

    evidence.sort((a, b) {
      final layerCompare = a.sourceLayer.id.compareTo(b.sourceLayer.id);
      if (layerCompare != 0) {
        return layerCompare;
      }
      return a.sourceRefId.compareTo(b.sourceRefId);
    });

    return ThaiFusionInsight(
      insightId: _insightId(
        categoryId: agreement.categoryId,
        patternType: ThaiFusionPatternType.crossLayerAgreement,
        refs: agreement.themeIds,
      ),
      categoryId: agreement.categoryId,
      patternType: ThaiFusionPatternType.crossLayerAgreement,
      structuralWeight: agreement.strength,
      confidence: agreement.confidence,
      evidence: evidence,
      sourceRefs: ThaiFusionSourceRefs(
        dimensionIds: agreement.dimensionIds,
        themeIds: agreement.themeIds,
        factIds: agreement.factIds,
      ),
    );
  }

  static ThaiFusionInsight _coverageGapInsight({
    required ThaiFusionCategoryId categoryId,
    required bool hasThemes,
    required bool hasFacts,
    required List<String> themeIds,
    required List<String> factIds,
    required ThaiMirrorSnapshot mirror,
  }) {
    final evidence = <ThaiFusionEvidence>[
      ThaiFusionEvidence(
        sourceLayer: hasThemes
            ? ThaiFusionSourceLayer.interpretation
            : ThaiFusionSourceLayer.theme,
        sourceRefId: 'coverage_gap:${categoryId.id}',
        categoryId: categoryId,
        structuralWeight: 0,
        confidence: ThaiFusionConfidenceLevel.low,
      ),
    ];

    final dimensionRefId = _dimensionRefId(categoryId, mirror);
    final resolvedThemeIds = themeIds.isNotEmpty
        ? themeIds
        : <String>['category:${categoryId.id}'];
    final resolvedFactIds = factIds.isNotEmpty
        ? factIds
        : <String>['coverage_gap:${categoryId.id}'];

    return ThaiFusionInsight(
      insightId: _insightId(
        categoryId: categoryId,
        patternType: ThaiFusionPatternType.coverageGap,
        refs: [categoryId.id],
      ),
      categoryId: categoryId,
      patternType: ThaiFusionPatternType.coverageGap,
      structuralWeight: 0,
      confidence: ThaiFusionConfidenceLevel.low,
      evidence: evidence,
      sourceRefs: ThaiFusionSourceRefs(
        dimensionIds: dimensionRefId == null ? const [] : [dimensionRefId],
        themeIds: resolvedThemeIds,
        factIds: resolvedFactIds,
      ),
    );
  }

  static List<ThaiFusionInsight> _sparseFusionInsights(
    ThaiMirrorSnapshot mirror,
    Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
  ) {
    final insights = <ThaiFusionInsight>[];

    for (final warning in mirror.warnings) {
      if (warning.code != ThaiMirrorWarningContract.sparseDimension) {
        continue;
      }

      if (warning.affectedFields.length < 2) {
        continue;
      }

      final dimensionId = warning.affectedFields[0];
      final themeId = warning.affectedFields[1];
      final categoryId = _categoryForThemeId(themeId, groupedThemes);
      if (categoryId == null) {
        continue;
      }

      final themes = groupedThemes[categoryId] ?? const <ThaiThemeScore>[];
      final theme = themes.firstWhere(
        (item) => item.themeId == themeId,
        orElse: () => themes.first,
      );

      insights.add(
        ThaiFusionInsight(
          insightId: _insightId(
            categoryId: categoryId,
            patternType: ThaiFusionPatternType.sparseFusionCoverage,
            refs: [dimensionId, themeId],
          ),
          categoryId: categoryId,
          patternType: ThaiFusionPatternType.sparseFusionCoverage,
          structuralWeight: theme.score,
          confidence: ThaiFusionConfidenceLevel.low,
          evidence: [
            ThaiFusionEvidence(
              sourceLayer: ThaiFusionSourceLayer.mirror,
              sourceRefId: dimensionId,
              categoryId: categoryId,
              structuralWeight: theme.score,
              confidence: ThaiFusionConfidenceLevel.low,
            ),
          ],
          sourceRefs: ThaiFusionSourceRefs(
            dimensionIds: [dimensionId],
            themeIds: [themeId],
            factIds: _distinctFactIds([theme]).toList(),
          ),
        ),
      );
    }

    insights.sort((a, b) => a.insightId.compareTo(b.insightId));
    return insights;
  }

  static ThaiFusionConfidence _buildConfidence({
    required ThaiMirrorSnapshot mirror,
    required ThaiThemeBundle theme,
    required ThaiInterpretationBundle interpretation,
  }) {
    final mirrorLevel = mirrorLevelConfidence(mirror);
    final themeLevel = themeLevelConfidence(theme.themes);
    final interpretationFactCount = interpretation.facts.length;
    final interpretationLevel = interpretationLevelConfidence(interpretationFactCount);

    return ThaiFusionConfidence(
      overallLevel: overallConfidenceLevel(
        mirrorLevel: mirrorLevel,
        themeLevel: themeLevel,
        interpretationLevel: interpretationLevel,
        interpretationFactCount: interpretationFactCount,
      ),
      mirrorLevel: mirrorLevel,
      themeLevel: themeLevel,
      interpretationLevel: interpretationLevel,
      distinctSourceFactCount: interpretationFactCount,
    );
  }

  static ThaiFusionCoverage _buildCoverage({
    required List<ThaiFusionCategoryActivation> categories,
    required ThaiMirrorSnapshot mirror,
    required ThaiInterpretationBundle interpretation,
    required bool hasSparseDimensions,
  }) {
    return ThaiFusionCoverage(
      mappedCategoryCount: categories.length,
      totalCategoryCount: ThaiFusionCategoryId.values.length,
      mirrorDimensionCount: mirror.dimensions.length,
      interpretationFactCount: interpretation.facts.length,
      hasSparseDimensions: hasSparseDimensions,
    );
  }

  static void _emitCoverageWarnings({
    required List<ProfileWarning> warnings,
    required ThaiFusionCoverage coverage,
    required bool hasSparseDimensions,
  }) {
    if (coverage.mappedCategoryCount < insufficientCoverageCategoryThreshold) {
      warnings.add(
        ProfileWarning(
          code: ThaiFusionWarningContract.insufficientCoverage,
          severity: ProfileWarningSeverity.medium,
          message: 'Fusion mapped category coverage below threshold',
          affectedFields: [
            coverage.mappedCategoryCount.toString(),
            coverage.totalCategoryCount.toString(),
          ],
        ),
      );
    }

    if (hasSparseDimensions) {
      warnings.add(
        ProfileWarning(
          code: ThaiFusionWarningContract.sparseSynthesis,
          severity: ProfileWarningSeverity.low,
          message: 'Fusion synthesis includes sparse mirror dimensions',
          affectedFields: const ['hasSparseDimensions'],
        ),
      );
    }
  }

  static bool _hasSparseDimensions(ThaiMirrorSnapshot mirror) {
    return mirror.warnings.any(
      (warning) => warning.code == ThaiMirrorWarningContract.sparseDimension,
    );
  }

  static Set<String> _distinctFactIds(
    List<ThaiThemeScore> themes, [
    Set<String>? interpretationFactIds,
  ]) {
    final factIds = <String>{};

    for (final theme in themes) {
      for (final contribution in theme.contributions) {
        if (interpretationFactIds == null ||
            interpretationFactIds.contains(contribution.sourceFactId)) {
          factIds.add(contribution.sourceFactId);
        }
      }
    }

    return factIds;
  }

  static String? _dimensionRefId(
    ThaiFusionCategoryId categoryId,
    ThaiMirrorSnapshot mirror,
  ) {
    final themeCategory = ThaiFusionCategoryMapperPort.themeCategory(categoryId);
    final dimensionId = ThaiMirrorDimensionMappingContract.dimensionForCategory(
      themeCategory,
    );
    if (dimensionId == null) {
      return null;
    }

    for (final dimension in mirror.dimensions) {
      if (dimension.dimensionId == dimensionId) {
        return dimensionId.id;
      }
    }

    return null;
  }

  static ThaiFusionCategoryId? _categoryForThemeId(
    String themeId,
    Map<ThaiFusionCategoryId, List<ThaiThemeScore>> groupedThemes,
  ) {
    for (final entry in groupedThemes.entries) {
      if (entry.value.any((theme) => theme.themeId == themeId)) {
        return entry.key;
      }
    }
    return null;
  }

  static ThaiFusionConfidenceLevel _fusionConfidence(
    ThaiThemeConfidenceLevel confidence,
  ) {
    return switch (confidence) {
      ThaiThemeConfidenceLevel.high => ThaiFusionConfidenceLevel.high,
      ThaiThemeConfidenceLevel.medium => ThaiFusionConfidenceLevel.medium,
      ThaiThemeConfidenceLevel.low => ThaiFusionConfidenceLevel.low,
    };
  }

  static String _agreementId(ThaiFusionCategoryId categoryId) {
    return 'agreement:${categoryId.id}';
  }

  static String _insightId({
    required ThaiFusionCategoryId categoryId,
    required ThaiFusionPatternType patternType,
    required List<String> refs,
  }) {
    return '${categoryId.id}:${patternType.id}:${refs.join(',')}';
  }
}
