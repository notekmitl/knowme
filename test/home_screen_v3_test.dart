import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';
import 'package:knowme/features/home_cohesion/presentation/home_astrology_hub_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_compact_profile_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_hero_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_knowme_insight_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_knowme_signature_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_profile_completion_bar.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v38_identity_copy.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_psychology_tests_section.dart';
import 'package:knowme/features/home_cohesion/validation/home_v2_golden_scenario.dart';

void main() {
  Widget wrap(HomeScreenV3Data data) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HomeScreenV3(
            data: data,
            callbacks: HomeScreenV3Callbacks(
              onViewAstrologyResult: () {},
              onViewFullInsight: () {},
              onEditProfile: () {},
              onPsychologyTest: (_) {},
              onMoreItem: (_) {},
              onUnlockDeepProfile: () {},
              onContinueDiscovering: () {},
              onOpenAstrologySystem: (_) {},
              onOpenCrossSystemFusion: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('HomeV3Assembler V3.8 presentation', () {
    test('advanced user exposes identity hero and meaning-first cards', () {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);

      expect(data.hero.isAvailable, isTrue);
      expect(data.hero.identity, isNotEmpty);
      expect(data.hero.identity, isNot(startsWith('หลายศาสตร์')));
      expect(data.hero.identity, isNot(startsWith('คุณอาจ')));
      expect(data.signature.isVisible, isTrue);
      expect(data.signature.themeLabels.length, lessThanOrEqualTo(3));
      expect(data.insight.cards.length, lessThanOrEqualTo(3));
      for (final card in data.insight.cards) {
        expect(card.humanMeaning, isNotEmpty);
        expect(card.supportingExplanation, isNotEmpty);
        expect(card.humanMeaning.toLowerCase(), isNot(contains('adaptability')));
        expect(card.humanMeaning.toLowerCase(), isNot(contains('structure')));
      }
    });

    test('empty user keeps hero empty state', () {
      final data = HomeV3Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);

      expect(data.hero.isAvailable, isFalse);
      expect(data.signature.isVisible, isFalse);
      expect(data.insight.cards, isEmpty);
    });
  });

  group('HomeV38IdentityCopy', () {
    test('rewrites report-style headline to identity style', () {
      final headline = HomeV38IdentityCopy.headline(
        'หลายศาสตร์สะท้อนว่าคุณอาจให้ความสำคัญกับการตัดสินใจ',
      );
      expect(headline, isNot(contains('หลายศาสตร์')));
      expect(headline, isNot(contains('คุณอาจ')));
      expect(headline, contains('คุณ'));
    });
  });

  group('HomeScreenV3.8 visual hierarchy', () {
    testWidgets('hero → astrology hub → signature → insight → profile order',
        (tester) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      final heroTop = tester.getTopLeft(find.byType(HomeHeroSection)).dy;
      final hubTop =
          tester.getTopLeft(find.byType(HomeAstrologyHubSection)).dy;
      final signatureTop =
          tester.getTopLeft(find.byType(HomeKnowMeSignatureSection)).dy;
      final insightTop =
          tester.getTopLeft(find.byType(HomeKnowMeInsightSection)).dy;
      final profileTop =
          tester.getTopLeft(find.byType(HomeCompactProfileSection)).dy;

      expect(heroTop, lessThan(hubTop));
      expect(hubTop, lessThan(signatureTop));
      expect(signatureTop, lessThan(insightTop));
      expect(insightTop, lessThan(profileTop));
    });

    testWidgets('signature shows normalized theme labels', (tester) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(
        find.textContaining('หลายมุมมองสะท้อนตรงกัน'),
        findsOneWidget,
      );
      expect(find.textContaining('driven'), findsNothing);
      expect(find.textContaining('autonomy'), findsNothing);
    });

    testWidgets('hero shows gold CTA button', (tester) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text(HomeV3Copy.viewFullAstrology), findsOneWidget);
    });

    testWidgets('insight renders meaning-first cards not technical labels', (
      tester,
    ) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.textContaining('structure'), findsNothing);
      expect(find.textContaining('reflection'), findsNothing);
      expect(find.textContaining('adaptability'), findsNothing);
      expect(find.text('จากดวงของคุณ'), findsNothing);
    });

    test('advanced user exposes astrology hub systems', () {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);

      expect(data.astrologyHub.systems.length, 3);
      expect(
        data.astrologyHub.systems.any((s) => s.id == 'thai' && s.isAvailable),
        isTrue,
      );
    });

    test('profile formats birth date and preserves birth time field', () {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.partialUser);

      expect(data.profile.birthDate, '15/5/1990');
      expect(data.profile.birthTime, '09:30');
    });

    test('profile formats legacy ISO birthDate without losing birthTime', () {
      final base =
          HomeV2Assembler.bundleFromGolden(HomeV2GoldenScenario.partialUser);
      final data = HomeV3Assembler.fromSources(
        HomeV2SourceBundle(
          profileInput: base.profileInput,
          profileFields: {
            'name': 'Test',
            'birthDate': '1982-06-06T00:00:00.000',
            'birthTime': '00:35',
            'birthPlace': 'Bangkok',
          },
          astrologyFusion: base.astrologyFusion,
          astrologyEntry: base.astrologyEntry,
          personalityEntry: base.personalityEntry,
          globalFusionEntry: base.globalFusionEntry,
          personalityNarrative: base.personalityNarrative,
          personalityCoverage: base.personalityCoverage,
          globalReflections: base.globalReflections,
          astrologySnapshot: base.astrologySnapshot,
          personalitySnapshot: base.personalitySnapshot,
          globalFusionSnapshot: base.globalFusionSnapshot,
        ),
      );

      expect(data.profile.birthDate, '6/6/1982');
      expect(data.profile.birthTime, '00:35');
    });

    testWidgets('profile strip shows birth time when available', (
      tester,
    ) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.partialUser);
      await tester.pumpWidget(wrap(data));

      expect(find.textContaining('09:30'), findsOneWidget);
      expect(find.textContaining('T00:00:00'), findsNothing);
    });

    testWidgets('astrology hub renders Thai BaZi Western titles', (
      tester,
    ) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text(HomeV3Copy.thaiAstrologyTitle), findsOneWidget);
      expect(find.text(HomeV3Copy.baziTitle), findsOneWidget);
      expect(find.text(HomeV3Copy.westernAstrologyTitle), findsOneWidget);
    });

    testWidgets('profile strip is compact without birth time row', (
      tester,
    ) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.partialUser);
      await tester.pumpWidget(wrap(data));

      expect(find.byType(HomeCompactProfileSection), findsOneWidget);
    });

    testWidgets('psychology uses card layout section', (tester) async {
      final data = HomeV3Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);
      await tester.pumpWidget(wrap(data));

      expect(find.byType(HomeV3PsychologyTestsSection), findsOneWidget);
      expect(find.byType(HomeProfileCompletionBar), findsOneWidget);
      expect(find.text(HomeV3Copy.profileCompletionTitle), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeV3PsychologyTestsSection),
          matching: find.text(HomeV3Copy.mbtiCardTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no architecture section labels', (tester) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text('Journey'), findsNothing);
      expect(find.text('Astrology Mirror'), findsNothing);
      expect(find.textContaining('คุณควร'), findsNothing);
    });
  });
}
