import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_section_distribution.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';

ThaiPresentedTheme _theme({
  required String id,
  required String name,
  required String category,
  required double score,
  required List<ThaiThemeEvidence> evidence,
}) {
  return ThaiPresentedTheme(
    themeId: id,
    themeName: name,
    category: category,
    score: score,
    confidence: ThaiThemeConfidenceLevel.high,
    description: 'desc',
    evidence: evidence,
  );
}

void main() {
  group('ThaiMirrorSectionDistribution', () {
    test('includes themes mapped via content library category', () {
      final themes = [
        _theme(
          id: 'leadership',
          name: 'Leadership',
          category: 'strengths',
          score: 0.4,
          evidence: const [
            ThaiThemeEvidence(
              contentKey: ThaiContentKeys.lagnaLeo,
              sourceType: ThaiContentType.lagna,
              contribution: 0.5,
            ),
          ],
        ),
        _theme(
          id: 'ambitious',
          name: 'Ambitious',
          category: 'core_self',
          score: 0.9,
          evidence: const [
            ThaiThemeEvidence(
              contentKey: ThaiContentKeys.myanmarSeven1,
              sourceType: ThaiContentType.myanmarSeven,
              contribution: 0.8,
            ),
          ],
        ),
      ];

      final sectionThemes = ThaiMirrorSectionDistribution.themesForSection(
        sectionId: ThaiMirrorSectionId.strengths,
        sortedThemes: themes,
      );

      expect(sectionThemes.map((t) => t.themeId), contains('leadership'));
    });

    test('prioritizes mahabhuta mapping evidence in section relevance', () {
      final themes = [
        _theme(
          id: 'analytical',
          name: 'Analytical',
          category: 'thinking_style',
          score: 0.8,
          evidence: const [
            ThaiThemeEvidence(
              contentKey: ThaiContentKeys.lagnaGemini,
              sourceType: ThaiContentType.lagna,
              contribution: 0.9,
            ),
          ],
        ),
        _theme(
          id: 'reflective',
          name: 'Reflective',
          category: 'thinking_style',
          score: 0.8,
          evidence: const [
            ThaiThemeEvidence(
              contentKey: ThaiContentKeys.mahabhutaPuti,
              sourceType: ThaiContentType.mahabhutaPosition,
              contribution: 0.8,
            ),
          ],
        ),
      ];

      final sectionThemes = ThaiMirrorSectionDistribution.themesForSection(
        sectionId: ThaiMirrorSectionId.thinkingStyle,
        sortedThemes: themes,
      );

      expect(sectionThemes.first.themeId, 'reflective');
    });

    test('registry category still assigns themes without mapping', () {
      final themes = [
        _theme(
          id: 'reflective',
          name: 'Reflective',
          category: 'thinking_style',
          score: 0.8,
          evidence: const [
            ThaiThemeEvidence(
              contentKey: ThaiContentKeys.lagnaCancer,
              sourceType: ThaiContentType.lagna,
              contribution: 0.8,
            ),
          ],
        ),
      ];

      final sectionThemes = ThaiMirrorSectionDistribution.themesForSection(
        sectionId: ThaiMirrorSectionId.thinkingStyle,
        sortedThemes: themes,
      );

      expect(sectionThemes, hasLength(1));
      expect(
        ThemeCategory.thinkingStyle,
        isNotNull,
      );
    });
  });
}
