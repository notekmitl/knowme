import '../../../../core/themes/theme_category.dart';
import '../../../../core/themes/theme_registry.dart';
import '../content/models/thai_content_section.dart';
import '../content/models/thai_content_type.dart';
import '../content/models/thai_fusion_theme_category.dart';
import '../content/registry/thai_content_registry.dart';
import '../theme/models/thai_presented_theme.dart';
import '../theme/models/thai_theme_evidence.dart';
import 'models/thai_mirror_evidence.dart';
import 'models/thai_mirror_lens_source.dart';
import 'models/thai_mirror_section_id.dart';

/// Section theme assignment using registry categories plus content mappings.
abstract final class ThaiMirrorSectionDistribution {
  static List<ThaiPresentedTheme> themesForSection({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiPresentedTheme> sortedThemes,
    int maxThemes = 8,
  }) {
    final category = sectionId.themeCategory;
    if (category == null) return const [];

    final selected = <String>{};
    final result = <ThaiPresentedTheme>[];

    for (final theme in sortedThemes) {
      if (result.length >= maxThemes) break;
      if (!_belongsInSection(theme, category)) continue;
      if (!selected.add(theme.themeId)) continue;
      result.add(theme);
    }

    result.sort((a, b) {
      final relevance = _sectionRelevanceScore(
        sectionCategory: category,
        theme: b,
      ).compareTo(
        _sectionRelevanceScore(
          sectionCategory: category,
          theme: a,
        ),
      );
      if (relevance != 0) return relevance;
      return b.score.compareTo(a.score);
    });

    return List<ThaiPresentedTheme>.unmodifiable(result);
  }

  static bool _belongsInSection(
    ThaiPresentedTheme theme,
    ThemeCategory sectionCategory,
  ) {
    if (_registryCategory(theme.themeId) == sectionCategory) {
      return true;
    }

    for (final evidence in theme.evidence) {
      if (_evidenceMapsToSection(
        evidence: evidence,
        themeId: theme.themeId,
        sectionCategory: sectionCategory,
      )) {
        return true;
      }
    }

    return false;
  }

  static bool _evidenceMapsToSection({
    required ThaiThemeEvidence evidence,
    required String themeId,
    required ThemeCategory sectionCategory,
  }) {
    final section = ThaiContentRegistry.resolve(evidence.contentKey);
    if (section == null) return false;

    for (final mapping in section.themeMappings) {
      if (mapping.theme != themeId) continue;
      if (_fusionToThemeCategory(mapping.category) == sectionCategory) {
        return true;
      }
    }

    return false;
  }

  static double _sectionRelevanceScore({
    required ThemeCategory sectionCategory,
    required ThaiPresentedTheme theme,
  }) {
    var score = 0.0;

    if (_registryCategory(theme.themeId) == sectionCategory) {
      score += 1.0;
    }

    for (final evidence in theme.evidence) {
      if (!_evidenceMapsToSection(
        evidence: evidence,
        themeId: theme.themeId,
        sectionCategory: sectionCategory,
      )) {
        continue;
      }

      score += switch (evidence.sourceType) {
        ThaiContentType.mahabhutaPosition => 1.0,
        ThaiContentType.myanmarSeven => 1.1,
        ThaiContentType.lagnaLord => 1.05,
        ThaiContentType.lagna => 1.0,
        ThaiContentType.ramahabhuta => 0.5,
      };
      score += evidence.contribution * 0.2;
    }

    return score;
  }

  static ThemeCategory? _registryCategory(String themeId) {
    return ThemeRegistry.getById(themeId)?.category;
  }

  static ThemeCategory? _fusionToThemeCategory(
    ThaiFusionThemeCategory category,
  ) {
    return switch (category) {
      ThaiFusionThemeCategory.coreSelf => ThemeCategory.coreSelf,
      ThaiFusionThemeCategory.thinkingStyle => ThemeCategory.thinkingStyle,
      ThaiFusionThemeCategory.emotionalWorld => ThemeCategory.emotionalWorld,
      ThaiFusionThemeCategory.relationships => ThemeCategory.relationships,
      ThaiFusionThemeCategory.workAndAmbition => ThemeCategory.workAndAmbition,
      ThaiFusionThemeCategory.strengths => ThemeCategory.strengths,
      ThaiFusionThemeCategory.growthAreas => ThemeCategory.growthAreas,
      ThaiFusionThemeCategory.growthPath => ThemeCategory.growthPath,
    };
  }

  static List<ThaiContentSection> mirrorContentSectionsForNarrative({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiMirrorEvidence> evidence,
    int maxSections = 2,
  }) {
    final category = sectionId.themeCategory;
    if (category == null) return const [];

    final ranked = <_RankedContentSection>[];
    final seen = <String>{};

    for (final item in evidence) {
      if (!seen.add(item.contentKey)) continue;
      final section = ThaiContentRegistry.resolve(item.contentKey);
      if (section == null) continue;

      var priority = item.contribution;
      if (_contentSectionMatchesCategory(section, category)) {
        priority += 10;
      }
      if (item.lensSource == ThaiMirrorLensSource.lagna ||
          item.lensSource == ThaiMirrorLensSource.lagnaLord) {
        priority += 4;
      } else if (item.lensSource == ThaiMirrorLensSource.myanmarSeven) {
        priority += 3;
      } else if (item.lensSource == ThaiMirrorLensSource.mahabhutaPosition) {
        priority += 2;
      }

      ranked.add(_RankedContentSection(section: section, priority: priority));
    }

    ranked.sort((a, b) => b.priority.compareTo(a.priority));
    return ranked
        .take(maxSections)
        .map((item) => item.section)
        .toList(growable: false);
  }

  static List<ThaiContentSection> contentSectionsForNarrative({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiThemeEvidence> evidence,
    int maxSections = 2,
  }) {
    final category = sectionId.themeCategory;
    if (category == null) return const [];

    final mapped = <ThaiContentSection>[];
    final fallback = <ThaiContentSection>[];
    final seen = <String>{};

    for (final item in evidence) {
      if (!seen.add(item.contentKey)) continue;
      final section = ThaiContentRegistry.resolve(item.contentKey);
      if (section == null) continue;

      if (_contentSectionMatchesCategory(section, category)) {
        mapped.add(section);
      } else if (_isNonLagnaLens(section.contentType)) {
        fallback.add(section);
      } else {
        fallback.add(section);
      }
    }

    final ordered = [...mapped, ...fallback];
    return ordered.take(maxSections).toList(growable: false);
  }

  static bool _contentSectionMatchesCategory(
    ThaiContentSection section,
    ThemeCategory category,
  ) {
    for (final mapping in section.themeMappings) {
      if (_fusionToThemeCategory(mapping.category) == category) {
        return true;
      }
    }
    return false;
  }

  static bool _isNonLagnaLens(ThaiContentType type) {
    return type == ThaiContentType.myanmarSeven ||
        type == ThaiContentType.mahabhutaPosition;
  }
}

final class _RankedContentSection {
  const _RankedContentSection({
    required this.section,
    required this.priority,
  });

  final ThaiContentSection section;
  final double priority;
}
