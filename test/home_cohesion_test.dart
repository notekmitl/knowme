import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/application/discovery_builder.dart';
import 'package:knowme/features/exploration_overview/application/exploration_overview_builder.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_scenario.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence_band.dart';
import 'package:knowme/features/home_cohesion/application/home_snapshot_builder.dart';
import 'package:knowme/features/home_cohesion/domain/home_snapshot.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_validation_harness.dart';

void main() {
  group('HomeSnapshot model', () {
    test('version id is home_snapshot.v1', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.emptyUser,
      );
      expect(snapshot.version, HomeSnapshot.versionId);
    });

    test('combines overview discovery mirrors and fusion', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.fusionReady,
      );

      expect(snapshot.overview, isNotNull);
      expect(snapshot.discoveryItems, isNotEmpty);
      expect(snapshot.mirrorSummary.astrology, isNotNull);
      expect(snapshot.mirrorSummary.personality, isNotNull);
      expect(snapshot.fusionSummary, isNotNull);
    });
  });

  group('HomeSnapshotBuilder mirror summary', () {
    test('empty user mirrors are unavailable', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.emptyUser,
      );

      expect(snapshot.mirrorSummary.astrology.available, isFalse);
      expect(snapshot.mirrorSummary.personality.available, isFalse);
      expect(snapshot.mirrorSummary.astrology.reflectionCount, 0);
    });

    test('mirror ready scenario exposes astrology reflections', () {
      final pair = HomeCohesionGoldenFixtures.mirrorReady();
      final snapshot = HomeSnapshotBuilder.build(
        overview: pair.overview,
        discoveryItems: pair.discoveryItems,
        astrologySnapshot: pair.astrologySnapshot,
      );

      expect(snapshot.mirrorSummary.astrology.available, isTrue);
      expect(snapshot.mirrorSummary.astrology.ready, isFalse);
      expect(snapshot.mirrorSummary.astrology.reflectionCount, greaterThan(0));
    });

    test('personality mirror reflections count lens themes', () {
      final pair = DiscoveryGoldenFixtures.personalityReady();
      final discoveryItems = DiscoveryBuilder.build(
        overview: pair.overview,
        personalitySnapshot: pair.personalitySnapshot,
      );
      final snapshot = HomeSnapshotBuilder.build(
        overview: pair.overview,
        discoveryItems: discoveryItems,
        personalitySnapshot: pair.personalitySnapshot,
      );

      expect(snapshot.mirrorSummary.personality.available, isTrue);
      expect(snapshot.mirrorSummary.personality.reflectionCount, greaterThan(0));
    });

    test('everything ready marks both mirrors ready', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.everythingReady,
      );

      expect(snapshot.mirrorSummary.astrology.ready, isTrue);
      expect(snapshot.mirrorSummary.personality.ready, isTrue);
    });
  });

  group('HomeSnapshotBuilder fusion summary', () {
    test('empty user fusion is unavailable', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.emptyUser,
      );

      expect(snapshot.fusionSummary.available, isFalse);
      expect(snapshot.fusionSummary.ready, isFalse);
      expect(snapshot.fusionSummary.reflectionCount, 0);
      expect(snapshot.fusionSummary.confidenceBand, isNull);
    });

    test('overview only keeps fusion unavailable', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.overviewOnly,
      );

      expect(snapshot.fusionSummary.available, isFalse);
      expect(snapshot.fusionSummary.confidenceBand, isNull);
    });

    test('fusion ready exposes confidence band and reflections', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.fusionReady,
      );

      expect(snapshot.fusionSummary.available, isTrue);
      expect(snapshot.fusionSummary.ready, isTrue);
      expect(snapshot.fusionSummary.reflectionCount, greaterThan(0));
      expect(snapshot.fusionSummary.confidenceBand, isNotNull);
    });

    test('fusion ready confidence band is a valid enum value', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.fusionReady,
      );

      expect(
        GlobalConfidenceBand.values,
        contains(snapshot.fusionSummary.confidenceBand),
      );
    });
  });

  group('HomeSnapshotBuilder discovery integration', () {
    test('preserves discovery catalog without reordering', () {
      final pair = HomeCohesionGoldenFixtures.discoveryOnly();
      final snapshot = HomeSnapshotBuilder.build(
        overview: pair.overview,
        discoveryItems: pair.discoveryItems,
      );

      expect(
        snapshot.discoveryItems.map((item) => item.id).toList(),
        DiscoveryCatalogIds.catalogOrder,
      );
    });

    test('discovery only scenario has available personality lenses', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.discoveryOnly,
      );

      final mbti = snapshot.discoveryItems.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.mbti,
      );
      expect(mbti.availability, DiscoveryAvailability.available);
    });
  });

  group('HomeSnapshotBuilder overview integration', () {
    test('overview only carries birth complete profile status', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.overviewOnly,
      );

      expect(
        snapshot.overview.profileStatus,
        ExplorationProfileStatus.birthProfileComplete,
      );
    });

    test('overview reference matches builder input', () {
      final pair = HomeCohesionGoldenFixtures.fusionReady();
      final snapshot = HomeSnapshotBuilder.build(
        overview: pair.overview,
        discoveryItems: pair.discoveryItems,
        astrologySnapshot: pair.astrologySnapshot,
        personalitySnapshot: pair.personalitySnapshot,
        globalFusionSnapshot: pair.globalFusionSnapshot,
      );

      expect(snapshot.overview.fusionStatus.readiness,
          ExplorationFusionReadiness.ready);
    });
  });

  group('HomeCohesionValidationHarness', () {
    for (final scenario in HomeCohesionGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final snapshot = HomeCohesionValidationHarness.run(scenario);
        final issues = HomeCohesionGoldenExpectations.verify(scenario, snapshot);
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(HomeCohesionValidationHarness.runAllPassing(), isTrue);
    });
  });
}
