import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/application/exploration_overview_builder.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_lens_id.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_mirror_id.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_scenario.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_validation_harness.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_fixtures.dart';

void main() {
  const loader = GlobalFusionInputLoader();

  group('ExplorationOverview model', () {
    test('defines six exploration lenses', () {
      expect(ExplorationLensId.all.length, 6);
      expect(ExplorationLensId.astrologyLenses.length, 3);
      expect(ExplorationLensId.personalityLenses.length, 3);
    });

    test('version id is exploration_overview.v1', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.emptyUser,
      );
      expect(overview.version, ExplorationOverview.versionId);
    });
  });

  group('ExplorationOverviewBuilder profile status', () {
    test('empty profile is noBirthProfile', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.empty,
      );
      expect(overview.profileStatus, ExplorationProfileStatus.noBirthProfile);
    });

    test('name-only profile is basicProfile', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.basic,
      );
      expect(overview.profileStatus, ExplorationProfileStatus.basicProfile);
    });

    test('complete birth profile is birthProfileComplete', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.birthComplete,
      );
      expect(
        overview.profileStatus,
        ExplorationProfileStatus.birthProfileComplete,
      );
    });
  });

  group('ExplorationOverviewBuilder lens status', () {
    test('astrology lenses unavailable without birth profile', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.basic,
        astrologySnapshot: GlobalFusionGoldenFixtures.scenarioA().astrology,
      );

      for (final lensId in ExplorationLensId.astrologyLenses) {
        final entry = overview.lens(lensId);
        expect(entry.available, isFalse);
        expect(entry.usable, isFalse);
      }
    });

    test('astrology lenses available with birth profile', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.birthComplete,
        astrologySnapshot: GlobalFusionGoldenFixtures.scenarioA().astrology,
      );

      for (final lensId in ExplorationLensId.astrologyLenses) {
        expect(overview.lens(lensId).available, isTrue);
      }
    });

    test('personality lenses always available', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.empty,
        personalitySnapshot: GlobalFusionGoldenFixtures.scenarioB().personality,
      );

      for (final lensId in ExplorationLensId.personalityLenses) {
        expect(overview.lens(lensId).available, isTrue);
      }
    });

    test('completed lenses appear in explored coverage', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.astrologyOnly,
      );

      expect(overview.coverage.exploredLensCount, greaterThan(0));
      expect(overview.coverage.exploredLenses, isNotEmpty);
    });
  });

  group('ExplorationOverviewBuilder mirror status', () {
    test('astrology mirror unavailable without snapshot', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.birthComplete,
      );

      expect(
        overview.mirror(ExplorationMirrorId.astrologyMirror).readiness,
        ExplorationMirrorReadiness.unavailable,
      );
    });

    test('personality mirror partial with one lens fixture', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.personalityOnly,
      );

      expect(
        overview.mirror(ExplorationMirrorId.personalityMirror).readiness,
        ExplorationMirrorReadiness.partial,
      );
    });

    test('both mirrors available in bothMirrors scenario', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.bothMirrors,
      );

      expect(overview.coverage.availableMirrorCount, 2);
      expect(
        overview.coverage.availableMirrors,
        contains(ExplorationMirrorId.astrologyMirror),
      );
      expect(
        overview.coverage.availableMirrors,
        contains(ExplorationMirrorId.personalityMirror),
      );
    });
  });

  group('ExplorationOverviewBuilder fusion status', () {
    test('unavailable with no mirrors', () {
      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.empty,
      );

      expect(
        overview.fusionStatus.readiness,
        ExplorationFusionReadiness.unavailable,
      );
    });

    test('limited with one mirror', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.astrologyOnly,
      );

      expect(
        overview.fusionStatus.readiness,
        ExplorationFusionReadiness.limited,
      );
    });

    test('ready with both mirrors', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.bothMirrors,
      );

      expect(
        overview.fusionStatus.readiness,
        ExplorationFusionReadiness.ready,
      );
    });

    test('global fusion snapshot drives fusion readiness', () {
      final pair = ExplorationOverviewGoldenFixtures.globalFusionReady();
      final overview = ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
        personalitySnapshot: pair.personalitySnapshot,
        globalFusionSnapshot: pair.globalFusionSnapshot,
      );

      expect(
        overview.fusionStatus.readiness,
        ExplorationFusionReadiness.ready,
      );
    });
  });

  group('ExplorationOverviewBuilder coverage', () {
    test('empty user has zero explored lenses', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.emptyUser,
      );

      expect(overview.coverage.exploredLensCount, 0);
      expect(overview.coverage.unexploredLensCount, 6);
      expect(overview.coverage.availableReflectionCount, 0);
    });

    test('unexplored lenses complement explored lenses', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.bothMirrors,
      );

      expect(
        overview.coverage.exploredLensCount +
            overview.coverage.unexploredLensCount,
        6,
      );
    });

    test('global fusion ready increases available reflections', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.globalFusionReady,
      );

      expect(overview.coverage.availableReflectionCount, greaterThan(2));
    });
  });

  group('ExplorationOverviewBuilder integration', () {
    test('pipeline from global fusion fixtures produces overview', () {
      final pair = GlobalFusionGoldenFixtures.scenarioC();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      final overview = ExplorationOverviewBuilder.build(
        profile: ExplorationProfileInput.birthComplete,
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
        globalFusionSnapshot: snapshot,
      );

      expect(overview.fusionStatus.readiness, ExplorationFusionReadiness.ready);
      expect(overview.lensStatuses.length, 6);
    });
  });

  group('ExplorationOverviewValidationHarness', () {
    for (final scenario in ExplorationOverviewGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final overview = ExplorationOverviewValidationHarness.run(scenario);
        final issues = ExplorationOverviewGoldenExpectations.verify(
          scenario,
          overview,
        );
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(ExplorationOverviewValidationHarness.runAllPassing(), isTrue);
    });
  });
}
