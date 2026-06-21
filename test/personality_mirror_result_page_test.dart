import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/personality_mirror/application/narrative/personality_mirror_narrative_builder.dart';
import 'package:knowme/features/personality_mirror/presentation/personality_mirror_result_page.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_golden_scenario.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_validation_harness.dart';

void main() {
  setUp(() {
    AppText.lang = 'th';
  });

  testWidgets('result page renders narrative sections in PF-7 order', (
    tester,
  ) async {
    final validation = PersonalityMirrorValidationHarness.run(
      PersonalityMirrorGoldenScenario.scenarioA,
    );
    final narrative = PersonalityMirrorNarrativeBuilder.build(
      validation.mirror,
      confidenceBreakdown: validation.confidence,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PersonalityMirrorResultPage(
          narrative: narrative,
          showFullExperience: true,
        ),
      ),
    );

    expect(find.text(AppText.t('personality_mirror_result_hero_title')), findsOneWidget);
    expect(
      find.text(AppText.t('personality_mirror_result_contributions_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('personality_mirror_result_patterns_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('cross_mirror_bridge_personality_to_astrology_body')),
      findsOneWidget,
    );
    expect(find.text(narrative.disclosure), findsOneWidget);
    expect(find.text(narrative.depthHint), findsOneWidget);
    expect(
      find.text(AppText.t('personality_mirror_result_partial_hint')),
      findsNothing,
    );

    for (final paragraph in narrative.heroParagraphs) {
      expect(find.text(paragraph), findsOneWidget);
    }

    final heroY = tester.getTopLeft(
      find.text(AppText.t('personality_mirror_result_hero_title')),
    ).dy;
    final contributionsY = tester.getTopLeft(
      find.text(AppText.t('personality_mirror_result_contributions_title')),
    ).dy;
    final patternsY = tester.getTopLeft(
      find.text(AppText.t('personality_mirror_result_patterns_title')),
    ).dy;
    final depthY = tester.getTopLeft(find.text(narrative.depthHint)).dy;

    expect(contributionsY, greaterThan(heroY));
    expect(patternsY, greaterThan(contributionsY));
    expect(depthY, greaterThan(patternsY));
  });
}
