import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/shared/thai_content_key_human_label.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';
import 'package:knowme/features/home_cohesion/presentation/home_astrology_summary_card.dart';
import 'package:knowme/features/home_cohesion/presentation/home_compact_profile_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_hero_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_psychology_enhancement_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_psychology_tests_section.dart';
import 'package:knowme/features/home_cohesion/validation/home_v2_golden_scenario.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';

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
              onUnlockDeepProfile: () {},
              onContinueDiscovering: () {},
              onOpenAstrologyCenter: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('HomeV3Assembler', () {
    test('advanced user summary shows ready system count', () {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);

      expect(data.astrologySummary.isLoading, isFalse);
      expect(data.astrologySummary.statusLine, contains('จาก 4 ระบบ'));
      expect(data.astrologySummary.ctaLabel, HomeV3Copy.viewFullAstrology);
    });

    test('empty user summary prompts profile', () {
      final data = HomeV3Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);

      expect(data.astrologySummary.statusLine,
          HomeV3Copy.profileCompletenessEmpty);
    });

    test('profile formats legacy ISO birthDate', () {
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
  });

  group('ThaiContentKeyHumanLabel', () {
    test('maps internal keys to Thai labels', () {
      expect(
        ThaiContentKeyHumanLabel.label(ThaiContentKeys.lagnaVirgo),
        'ลัคนาราศีกันย์',
      );
      expect(
        ThaiContentKeyHumanLabel.label(ThaiContentKeys.lagnaLordMercury),
        isNot(contains('lagna_lord_mercury')),
      );
      expect(
        ThaiContentKeyHumanLabel.label(ThaiContentKeys.mahabhutaPyadhi),
        isNot(contains('mahabhuta_')),
      );
    });
  });

  group('HomeScreenV3 simplified hierarchy', () {
    testWidgets('hero → summary card → psychology → profile', (tester) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      final heroTop = tester.getTopLeft(find.byType(HomeHeroSection)).dy;
      final summaryTop =
          tester.getTopLeft(find.byType(HomeAstrologySummaryCard)).dy;
      final psychologyTop = tester
          .getTopLeft(find.byType(HomePsychologyEnhancementSection))
          .dy;
      final profileTop =
          tester.getTopLeft(find.byType(HomeCompactProfileSection)).dy;

      expect(heroTop, lessThan(summaryTop));
      expect(summaryTop, lessThan(psychologyTop));
      expect(psychologyTop, lessThan(profileTop));
    });

    testWidgets('home does not show per-system astrology tiles', (
      tester,
    ) async {
      final data =
          HomeV3Assembler.fromGolden(HomeV2GoldenScenario.advancedUser);
      await tester.pumpWidget(wrap(data));

      expect(find.text(HomeV3Copy.baziTitle), findsNothing);
      expect(find.text(HomeV3Copy.crossSystemFusionTitle), findsNothing);
      expect(
        find.descendant(
          of: find.byType(HomeAstrologySummaryCard),
          matching: find.text(HomeV3Copy.viewFullAstrology),
        ),
        findsOneWidget,
      );
    });

    testWidgets('psychology separated from astrology summary', (tester) async {
      final data = HomeV3Assembler.fromGolden(HomeV2GoldenScenario.emptyUser);
      await tester.pumpWidget(wrap(data));

      expect(
        find.descendant(
          of: find.byType(HomeAstrologySummaryCard),
          matching: find.text(HomeV3Copy.mbtiCardTitle),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(HomePsychologyEnhancementSection),
          matching: find.text(HomeV3Copy.mbtiCardTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('loading summary shows shimmer not blank box', (tester) async {
      final data = HomeScreenV3Data.empty();
      await tester.pumpWidget(wrap(data));

      expect(data.astrologySummary.isLoading, isTrue);
      expect(find.byType(HomeAstrologySummaryCard), findsOneWidget);
    });
  });
}
