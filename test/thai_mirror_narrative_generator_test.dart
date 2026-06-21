import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/foundation/integration/thai_foundation_resolver_bridge.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_assembler_spec.dart'
    show ThaiMirrorAssemblerSpec;
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_narrative_generator_spec.dart'
    show ThaiMirrorNarrativeGeneratorSpec;
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_narrative_generator.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiPresentedTheme _presented({
  required String themeId,
  required ThemeCategory category,
  required double score,
  List<ThaiThemeEvidence> evidence = const [],
}) {
  final definition = ThemeRegistry.getById(themeId)!;
  return ThaiPresentedTheme(
    themeId: themeId,
    themeName: definition.name,
    category: category.displayName,
    description: definition.description,
    score: score,
    confidence: ThaiThemeConfidenceLevel.high,
    evidence: evidence,
  );
}

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

ThaiMirrorResult _structural({
  List<ThaiPresentedTheme> themes = const [],
  ThaiAstrologyProfile profile = const ThaiAstrologyProfile(),
}) {
  return ThaiMirrorAssembler.assemble(
    ThaiMirrorInput(profile: profile, presentedThemes: themes),
  );
}

void _expectNoBannedTerms(String text) {
  for (final term in ThaiMirrorNarrativeGeneratorSpec.bannedTermsTh) {
    expect(text.contains(term), isFalse, reason: 'contains banned: $term');
  }
  for (final term in ThaiMirrorNarrativeGeneratorSpec.bannedTermsEn) {
    expect(
      text.toLowerCase().contains(term.toLowerCase()),
      isFalse,
      reason: 'contains banned: $term',
    );
  }

  const extraBannedTh = [
    'ชะตา',
    'ฟันธง',
    'รวย',
    'โชค',
    'คู่แท้',
    'เนื้อคู่',
    'จะรวย',
    'จะแต่งงาน',
  ];
  for (final term in extraBannedTh) {
    expect(text.contains(term), isFalse, reason: 'contains banned: $term');
  }
}

void main() {
  group('ThaiMirrorNarrativeGenerator', () {
    test('empty mirror result still produces summaries for all sections', () {
      final structural = _structural();
      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      expect(narrative.sections, hasLength(8));
      expect(narrative.sections.every((s) => s.hasSummary), isTrue);
      expect(narrative.narrativeMetadata, hasLength(8));
    });

    test('top themes list is preserved unchanged', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 10,
          ),
          _presented(
            themeId: 'builder',
            category: ThemeCategory.workAndAmbition,
            score: 8,
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      expect(narrative.topThemes, structural.topThemes);
      expect(
        narrative.sections.any((s) => s.id == ThaiMirrorSectionId.topThemes),
        isFalse,
      );
    });

    test('all fusion sections receive non-empty summaries', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'grounded',
            category: ThemeCategory.coreSelf,
            score: 5,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaTaurus,
                sourceType: ThaiContentType.lagna,
                contribution: 0.9,
              ),
            ],
          ),
          _presented(
            themeId: 'analytical',
            category: ThemeCategory.thinkingStyle,
            score: 4,
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      for (final section in narrative.sections) {
        expect(section.summary, isNotNull);
        expect(section.summary!.trim(), isNotEmpty);
      }
    });

    test('narrativeStatus becomes complete', () {
      final narrative = ThaiMirrorNarrativeGenerator.generate(_structural());

      expect(narrative.narrativeStatus, ThaiMirrorNarrativeStatus.complete);
      expect(narrative.hasNarrative, isTrue);
    });

    test('metadata references theme ids when themes exist', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 6,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaTaurus,
                sourceType: ThaiContentType.lagna,
                contribution: 0.8,
              ),
            ],
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);
      final coreMeta = narrative.narrativeMetadata.firstWhere(
        (m) => m.sectionId == ThaiMirrorSectionId.coreSelf,
      );

      expect(coreMeta.themeIdsUsed, contains('disciplined'));
      expect(coreMeta.contentKeysUsed, contains(ThaiContentKeys.lagnaTaurus));
    });

    test('metadata records content keys from evidence', () {
      const key = ThaiContentKeys.mahabhutaPyadhi;
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'empathetic',
            category: ThemeCategory.emotionalWorld,
            score: 3,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: key,
                sourceType: ThaiContentType.mahabhutaPosition,
                contribution: 0.5,
              ),
            ],
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);
      final meta = narrative.narrativeMetadata.firstWhere(
        (m) => m.sectionId == ThaiMirrorSectionId.emotionalWorld,
      );

      expect(meta.contentKeysUsed, contains(key));
    });

    test('growth areas section uses soft reflective language', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'perfectionism',
            category: ThemeCategory.growthAreas,
            score: 4,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaTaurus,
                sourceType: ThaiContentType.lagna,
                contribution: 0.4,
              ),
            ],
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);
      final summary =
          narrative.sectionById(ThaiMirrorSectionId.growthAreas)!.summary!;

      expect(
        summary.contains('บางครั้ง') || summary.contains('อาจ'),
        isTrue,
      );
      expect(summary.contains('ฟันธง'), isFalse);
      expect(summary.contains('ฟันธง'), isFalse);
    });

    test('summaries do not contain banned fortune-telling terms', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'leadership',
            category: ThemeCategory.strengths,
            score: 7,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaLeo,
                sourceType: ThaiContentType.lagna,
                contribution: 0.7,
              ),
            ],
          ),
          _presented(
            themeId: 'builder',
            category: ThemeCategory.workAndAmbition,
            score: 6,
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      for (final section in narrative.sections) {
        _expectNoBannedTerms(section.summary!);
      }
    });

    test('output is deterministic for the same structural input', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 9,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaCapricorn,
                sourceType: ThaiContentType.lagna,
                contribution: 0.85,
              ),
            ],
          ),
        ],
      );

      final first = ThaiMirrorNarrativeGenerator.generate(structural);
      final second = ThaiMirrorNarrativeGenerator.generate(structural);

      expect(first, second);
    });

    test('does not mutate scores, evidence, or theme order', () {
      final structural = _structural(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 9,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: ThaiContentKeys.lagnaCapricorn,
                sourceType: ThaiContentType.lagna,
                contribution: 0.85,
              ),
            ],
          ),
        ],
      );

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      for (var i = 0; i < structural.sections.length; i++) {
        final before = structural.sections[i];
        final after = narrative.sections[i];

        expect(after.supportingThemes, before.supportingThemes);
        expect(after.evidence, before.evidence);
        expect(after.id, before.id);
      }
      expect(narrative.topThemes, structural.topThemes);
    });

    test('full pipeline Foundation → Narrative', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      final input = ThaiMirrorAssemblerSpec.inputFromProfile(profile);
      final structural = ThaiMirrorAssembler.assemble(input);
      expect(structural.narrativeStatus, ThaiMirrorNarrativeStatus.structuralOnly);

      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      expect(narrative.narrativeStatus, ThaiMirrorNarrativeStatus.complete);
      expect(narrative.sections.every((s) => s.hasSummary), isTrue);
      expect(narrative.narrativeMetadata, hasLength(8));

      final hasReferencedThemes = narrative.narrativeMetadata.any(
        (m) => m.themeIdsUsed.isNotEmpty,
      );
      final hasReferencedContent = narrative.narrativeMetadata.any(
        (m) => m.contentKeysUsed.isNotEmpty,
      );

      expect(hasReferencedThemes, isTrue);
      expect(hasReferencedContent, isTrue);

      final resolverInput = ThaiFoundationResolverBridge.toResolverInput(profile);
      expect(resolverInput.lagnaKey, profile.lagnaKey);
    });
  });
}
