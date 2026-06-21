import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/presentation/home_astrology_summary_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_combined_reflection_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_more_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_profile_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_psychology_tests_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v2.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v2_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v2_copy.dart';
import 'package:knowme/features/home_cohesion/validation/home_v2_golden_scenario.dart';

void main() {
  Widget wrap(HomeScreenV2Data data) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: HomeScreenV2(
            data: data,
            callbacks: HomeScreenV2Callbacks(
              onEditProfile: () {},
              onViewAstrologyResult: () {},
              onViewCombinedReflection: () {},
              onPsychologyTest: (_) {},
              onMoreItem: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('HomeV2Assembler', () {
    test('empty user shows profile anchor without architecture labels', () {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);

      expect(data.profile.isEmpty, isTrue);
      expect(data.astrologySummary.isAvailable, isFalse);
      expect(data.combinedReflection.units, isEmpty);
      expect(data.psychologyTests.tests.length, 3);
    });

    test('partial user exposes astrology hero and psychology section', () {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.partialUser);

      expect(data.profile.name, isNot(HomeV2Copy.profileEmptyName));
      expect(data.astrologySummary.isAvailable, isTrue);
    });

    test('advanced user exposes combined reflections up to three units', () {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);

      expect(data.astrologySummary.isAvailable, isTrue);
      expect(data.combinedReflection.units.length, lessThanOrEqualTo(3));
      expect(data.combinedReflection.units, isNotEmpty);
    });
  });

  group('HomeScreenV2 product surface', () {
    testWidgets('does not show architecture section labels', (tester) async {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text('Journey'), findsNothing);
      expect(find.text('Reflections'), findsNothing);
      expect(find.text('Explore'), findsNothing);
      expect(find.text('Exploration Overview'), findsNothing);
      expect(find.text('Astrology Mirror'), findsNothing);
      expect(find.text('Personality Mirror'), findsNothing);
      expect(find.text('Global Fusion'), findsNothing);
    });

    testWidgets('renders user-centric section order', (tester) async {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.byType(HomeProfileSection), findsOneWidget);
      expect(find.byType(HomeAstrologySummarySection), findsOneWidget);
      expect(find.byType(HomeCombinedReflectionSection), findsOneWidget);
      expect(find.byType(HomePsychologyTestsSection), findsOneWidget);
      expect(find.byType(HomeMoreSection), findsOneWidget);

      final profileTop =
          tester.getTopLeft(find.byType(HomeProfileSection)).dy;
      final astrologyTop =
          tester.getTopLeft(find.byType(HomeAstrologySummarySection)).dy;
      final psychologyTop =
          tester.getTopLeft(find.byType(HomePsychologyTestsSection)).dy;

      expect(profileTop, lessThan(astrologyTop));
      expect(astrologyTop, lessThan(psychologyTop));
    });

    testWidgets('astrology hero appears before psychology tests', (tester) async {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.partialUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text(HomeV2Copy.astrologyTitle), findsOneWidget);
      expect(find.text(HomeV2Copy.psychologyTitle), findsOneWidget);
    });

    testWidgets('psychology section groups MBTI EQ Big Five together', (
      tester,
    ) async {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text('MBTI'), findsOneWidget);
      expect(find.text('EQ'), findsOneWidget);
      expect(find.text('Big Five'), findsOneWidget);
    });

    testWidgets('avoids funnel wording on empty user', (tester) async {
      final data = HomeV2Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);
      await tester.pumpWidget(wrap(data));

      expect(find.textContaining('คุณควร'), findsNothing);
      expect(find.textContaining('complete this now'), findsNothing);
      expect(find.textContaining('Next Best Action'), findsNothing);
    });
  });
}
