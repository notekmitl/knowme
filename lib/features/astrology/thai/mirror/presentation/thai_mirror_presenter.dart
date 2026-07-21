import '../../theme/models/thai_theme_confidence_level.dart';
import '../models/thai_mirror_lens_source.dart';
import '../models/thai_mirror_profile_context.dart';
import '../models/thai_mirror_result.dart';
import '../models/thai_mirror_section.dart';
import '../models/thai_mirror_section_id.dart';
import 'models/thai_mirror_evidence_explorer_state.dart';
import 'models/thai_mirror_hero_state.dart';
import 'models/thai_mirror_profile_context_state.dart';
import 'models/thai_mirror_section_card_state.dart';
import 'models/thai_mirror_theme_card_state.dart';
import 'thai_mirror_view_state.dart';

/// Maps [ThaiMirrorResult] to [ThaiMirrorViewState] for UI consumption.
///
/// Read-only presentation — no astrology logic, scoring, or reordering.
abstract final class ThaiMirrorPresenter {
  static const _maxThemeChipsPerSection = 5;
  static const _heroSummaryMaxChars = 120;
  static const _heroSummaryMaxSentences = 2;

  static const _expandedByDefault = <ThaiMirrorSectionId>{
    ThaiMirrorSectionId.coreSelf,
    ThaiMirrorSectionId.thinkingStyle,
    ThaiMirrorSectionId.emotionalWorld,
  };

  static ThaiMirrorViewState present(ThaiMirrorResult result) {
    final evidenceExplorer = _buildEvidenceExplorer(result.sections);
    final themeEvidenceCounts = _themeEvidenceCounts(evidenceExplorer.rows);

    return ThaiMirrorViewState(
      hero: _buildHero(result),
      topThemes: _buildTopThemes(result, themeEvidenceCounts),
      sections: _buildSections(result.sections),
      evidenceExplorer: evidenceExplorer,
      profileContext: _buildProfileContext(result.profileContext),
      disclaimers: List<String>.unmodifiable(result.disclaimers),
      narrativeStatus: result.narrativeStatus,
    );
  }

  static ThaiMirrorHeroState _buildHero(ThaiMirrorResult result) {
    final coreSelf = result.sectionById(ThaiMirrorSectionId.coreSelf);
    final reflectionSummary = _heroReflectionSummary(coreSelf?.summary);

    return ThaiMirrorHeroState(
      titleTh: ThaiMirrorHeroState.defaultTitleTh,
      titleEn: ThaiMirrorHeroState.defaultTitleEn,
      reflectionSummary: reflectionSummary,
      topThemeNames: result.topThemes
          .map((theme) => theme.themeName)
          .toList(growable: false),
    );
  }

  static String _heroReflectionSummary(String? coreSelfSummary) {
    if (coreSelfSummary == null || coreSelfSummary.trim().isEmpty) {
      return ThaiMirrorHeroState.fallbackReflectionSummary;
    }
    return _firstSentences(
      coreSelfSummary,
      maxSentences: _heroSummaryMaxSentences,
      maxChars: _heroSummaryMaxChars,
    );
  }

  static List<ThaiMirrorThemeCardState> _buildTopThemes(
    ThaiMirrorResult result,
    Map<String, int> themeEvidenceCounts,
  ) {
    final cards = <ThaiMirrorThemeCardState>[];

    for (var index = 0; index < result.topThemes.length; index++) {
      final theme = result.topThemes[index];
      cards.add(
        ThaiMirrorThemeCardState(
          rank: index + 1,
          themeId: theme.themeId,
          themeName: theme.themeName,
          description: theme.description,
          confidenceLabel: confidenceLabel(theme.confidence),
          evidenceCount: themeEvidenceCounts[theme.themeId] ?? 0,
        ),
      );
    }

    return List<ThaiMirrorThemeCardState>.unmodifiable(cards);
  }

  static List<ThaiMirrorSectionCardState> _buildSections(
    List<ThaiMirrorSection> sections,
  ) {
    return sections
        .map(
          (section) => ThaiMirrorSectionCardState(
            id: section.id,
            titleTh: section.titleTh,
            titleEn: section.title,
            summary: section.summary,
            themeChips: section.supportingThemes
                .take(_maxThemeChipsPerSection)
                .map((theme) => theme.themeName)
                .toList(growable: false),
            evidenceCount: section.evidence.length,
            isExpandedDefault: _expandedByDefault.contains(section.id),
          ),
        )
        .toList(growable: false);
  }

  static ThaiMirrorEvidenceExplorerState _buildEvidenceExplorer(
    List<ThaiMirrorSection> sections,
  ) {
    final rows = <ThaiMirrorEvidenceRowState>[];
    final lensCounts = <ThaiMirrorLensSource, int>{};

    for (final section in sections) {
      for (final evidence in section.evidence) {
        lensCounts[evidence.lensSource] =
            (lensCounts[evidence.lensSource] ?? 0) + 1;

        rows.add(
          ThaiMirrorEvidenceRowState(
            lensSource: evidence.lensSource,
            lensLabelTh: evidence.lensSource.labelTh,
            contentKey: evidence.contentKey,
            contentTitle: evidence.contentTitle,
            supportedThemeIds: List<String>.unmodifiable(
              evidence.supportedThemeIds,
            ),
            sectionIdLabel: section.titleTh,
          ),
        );
      }
    }

    return ThaiMirrorEvidenceExplorerState(
      totalEvidenceCount: rows.length,
      lensCounts: Map<ThaiMirrorLensSource, int>.unmodifiable(lensCounts),
      rows: List<ThaiMirrorEvidenceRowState>.unmodifiable(rows),
    );
  }

  static Map<String, int> _themeEvidenceCounts(
    List<ThaiMirrorEvidenceRowState> rows,
  ) {
    final counts = <String, int>{};

    for (final row in rows) {
      for (final themeId in row.supportedThemeIds) {
        counts[themeId] = (counts[themeId] ?? 0) + 1;
      }
    }

    return counts;
  }

  static ThaiMirrorProfileContextState _buildProfileContext(
    ThaiMirrorProfileContext profileContext,
  ) {
    return ThaiMirrorProfileContextState(
      hasBirthTime: profileContext.hasBirthTime,
      warningMessages: profileContext.warnings
          .map((warning) => warning.message)
          .toList(growable: false),
      calculationStandardVersion: profileContext.calculationStandardVersion,
    );
  }

  /// Maps confidence tier to Thai display label.
  static String confidenceLabel(ThaiThemeConfidenceLevel confidence) {
    return switch (confidence) {
      ThaiThemeConfidenceLevel.high => 'ความชัดเจนสูง',
      ThaiThemeConfidenceLevel.medium => 'ปานกลาง',
      ThaiThemeConfidenceLevel.low => 'บางส่วน',
    };
  }

  static String _firstSentences(
    String text, {
    required int maxSentences,
    required int maxChars,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return ThaiMirrorHeroState.fallbackReflectionSummary;

    final parts = trimmed.split(RegExp(r'(?<=[.。])\s*'));
    final sentences = <String>[];

    for (final part in parts) {
      final sentence = part.trim();
      if (sentence.isEmpty) continue;
      sentences.add(sentence);
      if (sentences.length >= maxSentences) break;
    }

    var result = sentences.isEmpty ? trimmed : sentences.join(' ');

    if (result.length > maxChars) {
      final truncated = result.substring(0, maxChars).trimRight();
      result = truncated.endsWith('…') ? truncated : '$truncated…';
    }

    return result;
  }
}
