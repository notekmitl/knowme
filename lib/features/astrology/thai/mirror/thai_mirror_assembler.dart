import '../content/registry/thai_content_registry.dart';
import '../foundation/models/thai_astrology_profile.dart';
import '../theme/models/thai_presented_theme.dart';
import 'models/thai_mirror_evidence.dart';
import 'models/thai_mirror_input.dart';
import 'models/thai_mirror_lens_source.dart';
import 'models/thai_mirror_profile_context.dart';
import 'models/thai_mirror_result.dart';
import 'models/thai_mirror_section.dart';
import 'models/thai_mirror_section_id.dart';
import 'models/thai_mirror_theme_ref.dart';
import 'spec/thai_mirror_contract.dart';
import 'thai_mirror_evidence_balancer.dart';
import 'thai_mirror_section_distribution.dart';
import 'thai_mirror_top_theme_selector.dart';

/// Deterministic structural assembler — V1 Truth Lock.
///
/// Transforms [ThaiMirrorInput] into [ThaiMirrorResult] without AI or narrative.
/// All section themes (including growth areas) come from Theme Engine output only.
abstract final class ThaiMirrorAssembler {
  static const topThemeLimit = 3;

  static const _fusionSectionOrder = <ThaiMirrorSectionId>[
    ThaiMirrorSectionId.coreSelf,
    ThaiMirrorSectionId.thinkingStyle,
    ThaiMirrorSectionId.emotionalWorld,
    ThaiMirrorSectionId.relationships,
    ThaiMirrorSectionId.workAndAmbition,
    ThaiMirrorSectionId.strengths,
    ThaiMirrorSectionId.growthAreas,
    ThaiMirrorSectionId.growthPath,
  ];

  static ThaiMirrorResult assemble(ThaiMirrorInput input) {
    final sorted = _sortThemes(input.presentedThemes);

    return ThaiMirrorResult(
      contractVersion: ThaiMirrorContract.version,
      profileContext: _mapProfileContext(input.profile),
      topThemes: _buildTopThemes(sorted),
      sections: _buildSections(sorted),
      disclaimers: ThaiMirrorContract.defaultDisclaimers,
      narrativeStatus: ThaiMirrorNarrativeStatus.structuralOnly,
    );
  }

  static List<ThaiPresentedTheme> _sortThemes(
    List<ThaiPresentedTheme> themes,
  ) {
    final copy = List<ThaiPresentedTheme>.from(themes);
    copy.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.themeId.compareTo(b.themeId);
    });
    return copy;
  }

  static List<ThaiMirrorThemeRef> _buildTopThemes(
    List<ThaiPresentedTheme> sorted,
  ) {
    return ThaiMirrorTopThemeSelector.select(
      sortedThemes: sorted,
      limit: topThemeLimit,
      toRef: _toThemeRef,
    );
  }

  static List<ThaiMirrorSection> _buildSections(
    List<ThaiPresentedTheme> sorted,
  ) {
    return _fusionSectionOrder
        .map((sectionId) => _buildSection(sectionId, sorted))
        .toList(growable: false);
  }

  static ThaiMirrorSection _buildSection(
    ThaiMirrorSectionId sectionId,
    List<ThaiPresentedTheme> sorted,
  ) {
    final sectionThemes = _themesForSection(
      sectionId: sectionId,
      sortedThemes: sorted,
    );

    return ThaiMirrorSection(
      id: sectionId,
      title: sectionId.titleEn,
      titleTh: sectionId.titleTh,
      supportingThemes: sectionThemes.map(_toThemeRef).toList(growable: false),
      evidence: ThaiMirrorEvidenceBalancer.balance(
        _mergeEvidence(sectionThemes),
      ),
    );
  }

  static List<ThaiPresentedTheme> _themesForSection({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiPresentedTheme> sortedThemes,
  }) {
    return ThaiMirrorSectionDistribution.themesForSection(
      sectionId: sectionId,
      sortedThemes: sortedThemes,
    );
  }

  static ThaiMirrorThemeRef _toThemeRef(ThaiPresentedTheme theme) {
    return ThaiMirrorThemeRef(
      themeId: theme.themeId,
      themeName: theme.themeName,
      score: theme.score,
      confidence: theme.confidence,
      description: theme.description,
    );
  }

  static List<ThaiMirrorEvidence> _mergeEvidence(
    List<ThaiPresentedTheme> sectionThemes,
  ) {
    final accumulators = <String, _EvidenceAccumulator>{};

    for (final theme in sectionThemes) {
      for (final evidence in theme.evidence) {
        final lensSource = ThaiMirrorLensSourceLabels.fromContentType(
          evidence.sourceType,
        );
        if (lensSource == null) continue;

        final accumulator = accumulators.putIfAbsent(
          evidence.contentKey,
          () => _EvidenceAccumulator(
            lensSource: lensSource,
            contentKey: evidence.contentKey,
          ),
        );

        accumulator.contribution += evidence.contribution;
        accumulator.supportedThemeIds.add(theme.themeId);
      }
    }

    final merged = accumulators.values
        .map((accumulator) => accumulator.toEvidence())
        .toList();

    merged.sort((a, b) {
      final contributionCompare = b.contribution.compareTo(a.contribution);
      if (contributionCompare != 0) return contributionCompare;
      return a.contentKey.compareTo(b.contentKey);
    });

    return List<ThaiMirrorEvidence>.unmodifiable(merged);
  }

  static ThaiMirrorProfileContext _mapProfileContext(
    ThaiAstrologyProfile profile,
  ) {
    return ThaiMirrorProfileContext(
      hasBirthTime: profile.hasBirthTime,
      calculationStandardVersion: profile.calculationStandardVersion,
      warnings: profile.warnings,
      lagnaKey: profile.lagnaKey,
      lagnaLordKey: profile.lagnaLordKey,
      myanmarKeyCount: profile.myanmarKeys.length,
      mahabhutaKeyCount: profile.mahabhutaPositionKeys.length,
    );
  }
}

final class _EvidenceAccumulator {
  _EvidenceAccumulator({
    required this.lensSource,
    required this.contentKey,
  });

  final ThaiMirrorLensSource lensSource;
  final String contentKey;
  double contribution = 0;
  final Set<String> supportedThemeIds = {};

  ThaiMirrorEvidence toEvidence() {
    final section = ThaiContentRegistry.resolve(contentKey);
    final themeIds = supportedThemeIds.toList()..sort();

    return ThaiMirrorEvidence(
      lensSource: lensSource,
      contentKey: contentKey,
      contentTitle: section?.title,
      contribution: contribution,
      supportedThemeIds: List<String>.unmodifiable(themeIds),
    );
  }
}
