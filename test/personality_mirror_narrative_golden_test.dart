import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/personality_mirror/application/narrative/personality_mirror_narrative_builder.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_engine.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_narrative_view.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_golden_fixtures.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_golden_scenario.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_validation_harness.dart';

void main() {
  setUp(() {
    AppText.lang = 'th';
  });

  PersonalityMirrorNarrativeView _narrativeFor(
    PersonalityMirrorGoldenScenario scenario,
  ) {
    final validation = PersonalityMirrorValidationHarness.run(scenario);
    return PersonalityMirrorNarrativeBuilder.build(
      validation.mirror,
      confidenceBreakdown: validation.confidence,
    );
  }

  group('Golden narrative scenarios', () {
    test('scenarioA — agreement patterns, no perspectives', () {
      final narrative = _narrativeFor(PersonalityMirrorGoldenScenario.scenarioA);

      expect(narrative.heroParagraphs, isNotEmpty);
      expect(narrative.patternCards.length, greaterThanOrEqualTo(2));
      expect(narrative.perspectiveCards, isEmpty);
      expect(
        narrative.patternCards.every((c) => c.agreementKindKey == 'theme'),
        isTrue,
      );
      expect(
        narrative.patternCards.map((c) => c.themeId),
        contains(PersonalityCoreThemeIds.structured),
      );
      expect(_forbiddenNumericCopy(narrative), isFalse);
    });

    test('scenarioB — perspective cards with both-and framing', () {
      final narrative = _narrativeFor(PersonalityMirrorGoldenScenario.scenarioB);

      expect(narrative.perspectiveCards, isNotEmpty);
      expect(narrative.heroParagraphs.length, greaterThanOrEqualTo(2));
      expect(
        narrative.heroParagraphs.any(
          (p) => p.contains('บริบท') || p.contains('context'),
        ),
        isTrue,
      );
      expect(_forbiddenConflictWords(narrative), isFalse);
    });

    test('scenarioC — low coverage soft opener', () {
      final narrative = _narrativeFor(PersonalityMirrorGoldenScenario.scenarioC);

      expect(narrative.confidenceToneKey, 'personality_mirror_hero_opener_low');
      expect(
        narrative.heroParagraphs.first,
        AppText.t('personality_mirror_hero_opener_low'),
      );
      expect(narrative.lensContributionLines.length, 1);
      expect(narrative.patternCards.where((c) => c.agreementKindKey == 'theme'),
          isEmpty);
    });

    test('scenarioD — very high tone and full lens contributions', () {
      final narrative = _narrativeFor(PersonalityMirrorGoldenScenario.scenarioD);

      expect(
        narrative.confidenceToneKey,
        'personality_mirror_hero_opener_very_high',
      );
      expect(narrative.lensContributionLines.length, 3);
      expect(
        narrative.patternCards.map((c) => c.themeId),
        contains(PersonalityCoreThemeIds.supportive),
      );
    });
  });

  group('Determinism', () {
    test('same snapshot produces identical narrative', () {
      final load = PersonalityMirrorGoldenFixtures.scenarioA();
      final mirror = PersonalityMirrorEngine.build(load);

      final a = PersonalityMirrorNarrativeBuilder.build(mirror);
      final b = PersonalityMirrorNarrativeBuilder.build(mirror);

      expect(_serialize(a), _serialize(b));
    });

    for (final scenario in PersonalityMirrorGoldenScenario.values) {
      test('${scenario.name} is deterministic', () {
        final first = _narrativeFor(scenario);
        final second = _narrativeFor(scenario);
        expect(_serialize(first), _serialize(second));
      });
    }
  });

  group('PF-5 copy rules', () {
    test('narrative never exposes raw confidence numbers', () {
      for (final scenario in PersonalityMirrorGoldenScenario.values) {
        final narrative = _narrativeFor(scenario);
        expect(_forbiddenNumericCopy(narrative), isFalse);
      }
    });

    test('hero has at most 3 paragraphs', () {
      for (final scenario in PersonalityMirrorGoldenScenario.values) {
        final narrative = _narrativeFor(scenario);
        expect(
          narrative.heroParagraphs.length,
          lessThanOrEqualTo(PersonalityMirrorNarrativeBuilder.maxHeroParagraphs),
        );
      }
    });
  });
}

bool _forbiddenNumericCopy(PersonalityMirrorNarrativeView view) {
  final blob = _allCopy(view);
  if (RegExp(r'\b0\.\d+\b').hasMatch(blob)) return true;
  if (RegExp(r'\b0\.\d+%').hasMatch(blob)) return true;
  if (blob.contains('0.72') || blob.contains('0.85')) return true;
  return false;
}

bool _forbiddenConflictWords(PersonalityMirrorNarrativeView view) {
  final blob = _allCopy(view).toLowerCase();
  const forbidden = ['conflict', 'contradiction', 'error', 'ขัดแย้ง'];
  return forbidden.any(blob.contains);
}

String _allCopy(PersonalityMirrorNarrativeView view) {
  return [
    ...view.heroParagraphs,
    ...view.patternCards.map((c) => '${c.title} ${c.body} ${c.supportingLensesLabel}'),
    ...view.perspectiveCards.map((c) => '${c.title} ${c.body}'),
    ...view.lensContributionLines,
    view.depthHint,
    view.disclosure,
  ].join('\n');
}

Map<String, dynamic> _serialize(PersonalityMirrorNarrativeView view) {
  return {
    'hero': view.heroParagraphs,
    'patterns': view.patternCards
        .map(
          (c) => {
            'title': c.title,
            'body': c.body,
            'lenses': c.supportingLensesLabel,
            'themeId': c.themeId,
            'kind': c.agreementKindKey,
          },
        )
        .toList(),
    'perspectives': view.perspectiveCards
        .map((c) => {'title': c.title, 'body': c.body, 'reason': c.reasonCode})
        .toList(),
    'contributions': view.lensContributionLines,
    'depthHint': view.depthHint,
    'disclosure': view.disclosure,
    'toneKey': view.confidenceToneKey,
  };
}
