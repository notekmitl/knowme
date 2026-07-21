import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/home_cohesion/application/home_mvp_assembler.dart';
import 'package:knowme/features/home_cohesion/application/home_mvp_scenario_mapper.dart';
import 'package:knowme/features/home_cohesion/domain/home_experience_blueprint.dart';
import 'package:knowme/features/home_cohesion/domain/home_screen_contract.dart';
import 'package:knowme/features/home_cohesion/presentation/home_explore_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_journey_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_reflections_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v1.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v1_models.dart';
import 'package:knowme/features/home_cohesion/validation/home_surface_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_surface_golden_scenario.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  group('HomeMvpAssembler', () {
    test('empty user hides reflections in contract', () {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      expect(data.contract.stateMode, HomeUserStateMode.emptyUser);
      expect(
        data.contract.hiddenSectionTypes,
        contains(HomeExperienceSectionType.reflections),
      );
      expect(data.reflections.tiles, isEmpty);
    });

    test('partial user exposes reflection tiles', () {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.partialUser,
      );

      expect(data.contract.stateMode, HomeUserStateMode.partialUser);
      expect(data.reflections.section.visible, isTrue);
      expect(data.reflections.tiles, isNotEmpty);
    });

    test('advanced user exposes grouped explore items', () {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.advancedUser,
      );

      expect(data.contract.stateMode, HomeUserStateMode.advancedUser);
      expect(data.explore.groups, isNotEmpty);
      expect(
        data.explore.groups.expand((group) => group.items),
        isNotEmpty,
      );
    });

    test('everything ready keeps all sections visible', () {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.everythingReady,
      );

      expect(data.contract.visibleSectionTypes.length, 3);
      expect(data.contract.aboveFoldSections.length, 2);
      expect(data.contract.belowFoldSections.length, 1);
    });

    test('assembler aligns with HomeSurfaceGoldenFixtures contract', () {
      for (final scenario in HomeSurfaceGoldenScenario.values) {
        final data = HomeMvpAssembler.fromGolden(scenario);
        final contract = HomeSurfaceGoldenFixtures.build(scenario);

        expect(data.contract.stateMode, contract.stateMode);
        expect(
          data.contract.visibleSectionTypes,
          contract.visibleSectionTypes,
        );
      }
    });
  });

  group('HomeMvpScenarioMapper', () {
    test('maps no entry signals to empty user', () {
      expect(
        HomeMvpScenarioMapper.fromEntrySignals(),
        HomeSurfaceGoldenScenario.emptyUser,
      );
    });
  });

  group('HomeScreenV1 layout', () {
    testWidgets('empty user renders journey and explore only', (tester) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      await tester.pumpWidget(wrap(HomeScreenV1(data: data)));

      expect(find.byType(HomeJourneySection), findsOneWidget);
      expect(find.byType(HomeReflectionsSection), findsNothing);
      expect(find.byType(HomeExploreSection), findsOneWidget);
      expect(find.text('เริ่มสำรวจตัวเอง'), findsOneWidget);
    });

    testWidgets('partial user renders reflections above explore', (
      tester,
    ) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.partialUser,
      );

      await tester.pumpWidget(wrap(HomeScreenV1(data: data)));

      expect(find.byType(HomeReflectionsSection), findsOneWidget);
      expect(find.text('มุมสะท้อนของคุณ'), findsOneWidget);

      final journeyOffset = tester.getTopLeft(find.byType(HomeJourneySection));
      final reflectionsOffset =
          tester.getTopLeft(find.byType(HomeReflectionsSection));
      final exploreOffset = tester.getTopLeft(find.byType(HomeExploreSection));

      expect(journeyOffset.dy, lessThan(reflectionsOffset.dy));
      expect(reflectionsOffset.dy, lessThan(exploreOffset.dy));
    });

    testWidgets('advanced user renders grouped explore cards', (tester) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.advancedUser,
      );

      await tester.pumpWidget(wrap(HomeScreenV1(data: data)));

      expect(find.text('สำรวจเพิ่มเติม'), findsOneWidget);
      expect(find.byType(HomeExploreSection), findsOneWidget);
      expect(data.explore.groups.length, greaterThan(1));
    });

    testWidgets('everything ready renders all three sections', (tester) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.everythingReady,
      );

      await tester.pumpWidget(wrap(HomeScreenV1(data: data)));

      expect(find.byType(HomeJourneySection), findsOneWidget);
      expect(find.byType(HomeReflectionsSection), findsOneWidget);
      expect(find.byType(HomeExploreSection), findsOneWidget);
    });
  });

  group('Home MVP copy guardrails', () {
    testWidgets('empty user avoids funnel wording', (tester) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      await tester.pumpWidget(wrap(HomeScreenV1(data: data)));

      expect(find.textContaining('complete this now', findRichText: true),
          findsNothing);
      expect(find.textContaining('คุณควร'), findsNothing);
      expect(find.textContaining('แนะนำให้'), findsNothing);
    });

    test('explore items never include locked surfaces', () {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.advancedUser,
      );

      for (final group in data.explore.groups) {
        for (final item in group.items) {
          expect(item.availability, isNot(DiscoveryAvailability.locked));
        }
      }
    });
  });

  group('Home section widgets', () {
    testWidgets('journey section hides when contract hidden', (tester) async {
      final data = HomeMvpAssembler.fromGolden(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      await tester.pumpWidget(
        wrap(
          HomeJourneySection(
            data: data.journey.copyWithHidden(),
          ),
        ),
      );

      expect(find.byType(HomeJourneySection), findsOneWidget);
      expect(find.text('เริ่มสำรวจตัวเอง'), findsNothing);
    });
  });
}

extension _TestHelpers on HomeJourneySectionData {
  HomeJourneySectionData copyWithHidden() {
    return HomeJourneySectionData(
      section: HomeSectionSurfaceContract(
        type: section.type,
        purpose: section.purpose,
        requiredData: section.requiredData,
        visible: false,
        surfaceState: HomeSectionSurfaceState.hidden,
        region: section.region,
        priority: section.priority,
        experienceSectionId: section.experienceSectionId,
        visibleChildCount: 0,
      ),
      headline: headline,
      body: body,
      hint: hint,
    );
  }
}
