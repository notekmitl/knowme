import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_fixtures.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../application/exploration_overview_builder.dart';
import '../domain/exploration_lens_id.dart';
import '../domain/exploration_mirror_id.dart';
import '../domain/exploration_overview.dart';
import '../domain/exploration_profile_input.dart';
import 'exploration_overview_golden_scenario.dart';

/// Deterministic inputs for Exploration Overview golden validation.
abstract final class ExplorationOverviewGoldenFixtures {
  static const _loader = GlobalFusionInputLoader();

  static ExplorationOverviewInputPair load(
    ExplorationOverviewGoldenScenario scenario,
  ) {
    return switch (scenario) {
      ExplorationOverviewGoldenScenario.emptyUser => emptyUser(),
      ExplorationOverviewGoldenScenario.profileOnly => profileOnly(),
      ExplorationOverviewGoldenScenario.astrologyOnly => astrologyOnly(),
      ExplorationOverviewGoldenScenario.personalityOnly => personalityOnly(),
      ExplorationOverviewGoldenScenario.bothMirrors => bothMirrors(),
      ExplorationOverviewGoldenScenario.globalFusionReady =>
        globalFusionReady(),
      ExplorationOverviewGoldenScenario.mixedPartialState =>
        mixedPartialState(),
    };
  }

  static ExplorationOverview build(
    ExplorationOverviewGoldenScenario scenario,
  ) {
    final pair = load(scenario);
    return ExplorationOverviewBuilder.build(
      profile: pair.profile,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }

  static ExplorationOverviewInputPair emptyUser() {
    return const ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.empty,
    );
  }

  static ExplorationOverviewInputPair profileOnly() {
    return const ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.birthComplete,
    );
  }

  static ExplorationOverviewInputPair astrologyOnly() {
    final pair = GlobalFusionGoldenFixtures.scenarioA();
    return ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.birthComplete,
      astrologySnapshot: pair.astrology,
    );
  }

  static ExplorationOverviewInputPair personalityOnly() {
    final pair = GlobalFusionGoldenFixtures.scenarioB();
    return ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.birthComplete,
      personalitySnapshot: pair.personality,
    );
  }

  static ExplorationOverviewInputPair bothMirrors() {
    final pair = GlobalFusionGoldenFixtures.scenarioC();
    return ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.birthComplete,
      astrologySnapshot: pair.astrology,
      personalitySnapshot: pair.personality,
    );
  }

  static ExplorationOverviewInputPair globalFusionReady() {
    final pair = GlobalFusionGoldenFixtures.scenarioC();
    final input = _loader.load(
      astrologySnapshot: pair.astrology,
      personalitySnapshot: pair.personality,
    );
    final snapshot = GlobalFusionBuilder.build(input);

    return ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.birthComplete,
      astrologySnapshot: pair.astrology,
      personalitySnapshot: pair.personality,
      globalFusionSnapshot: snapshot,
    );
  }

  static ExplorationOverviewInputPair mixedPartialState() {
    final pair = GlobalFusionGoldenFixtures.scenarioA();
    return ExplorationOverviewInputPair(
      profile: ExplorationProfileInput.basic,
      astrologySnapshot: pair.astrology,
      personalitySnapshot: GlobalFusionGoldenFixtures.scenarioB().personality,
    );
  }
}

class ExplorationOverviewInputPair {
  const ExplorationOverviewInputPair({
    required this.profile,
    this.astrologySnapshot,
    this.personalitySnapshot,
    this.globalFusionSnapshot,
  });

  final ExplorationProfileInput profile;
  final AstrologyFusionSnapshot? astrologySnapshot;
  final PersonalityMirrorSnapshot? personalitySnapshot;
  final GlobalFusionSnapshot? globalFusionSnapshot;
}

/// Expected invariants per golden scenario.
abstract final class ExplorationOverviewGoldenExpectations {
  static List<String> verify(
    ExplorationOverviewGoldenScenario scenario,
    ExplorationOverview overview,
  ) {
    final issues = <String>[];

    switch (scenario) {
      case ExplorationOverviewGoldenScenario.emptyUser:
        _expectProfile(overview, ExplorationProfileStatus.noBirthProfile, issues);
        _expectFusion(overview, ExplorationFusionReadiness.unavailable, issues);
        _expectExploredCount(overview, issues: issues, count: 0);
        _expectAvailableMirrors(overview, 0, issues);
      case ExplorationOverviewGoldenScenario.profileOnly:
        _expectProfile(
          overview,
          ExplorationProfileStatus.birthProfileComplete,
          issues,
        );
        _expectFusion(overview, ExplorationFusionReadiness.unavailable, issues);
        _expectExploredCount(overview, issues: issues, count: 0);
      case ExplorationOverviewGoldenScenario.astrologyOnly:
        _expectMirror(
          overview,
          ExplorationMirrorId.astrologyMirror,
          ExplorationMirrorReadiness.partial,
          issues,
        );
        _expectMirror(
          overview,
          ExplorationMirrorId.personalityMirror,
          ExplorationMirrorReadiness.unavailable,
          issues,
        );
        _expectFusion(overview, ExplorationFusionReadiness.limited, issues);
        _expectExploredCount(overview, issues: issues, greaterThan: 0);
      case ExplorationOverviewGoldenScenario.personalityOnly:
        _expectMirror(
          overview,
          ExplorationMirrorId.personalityMirror,
          ExplorationMirrorReadiness.partial,
          issues,
        );
        _expectMirror(
          overview,
          ExplorationMirrorId.astrologyMirror,
          ExplorationMirrorReadiness.unavailable,
          issues,
        );
        _expectFusion(overview, ExplorationFusionReadiness.limited, issues);
      case ExplorationOverviewGoldenScenario.bothMirrors:
        _expectFusion(overview, ExplorationFusionReadiness.ready, issues);
        _expectAvailableMirrors(overview, 2, issues);
        _expectExploredCount(overview, issues: issues, greaterThan: 0);
      case ExplorationOverviewGoldenScenario.globalFusionReady:
        _expectFusion(overview, ExplorationFusionReadiness.ready, issues);
        _expectReflectionCount(overview, greaterThan: 2, issues: issues);
      case ExplorationOverviewGoldenScenario.mixedPartialState:
        _expectProfile(overview, ExplorationProfileStatus.basicProfile, issues);
        _expectMirror(
          overview,
          ExplorationMirrorId.astrologyMirror,
          ExplorationMirrorReadiness.partial,
          issues,
        );
        _expectMirror(
          overview,
          ExplorationMirrorId.personalityMirror,
          ExplorationMirrorReadiness.partial,
          issues,
        );
        _expectFusion(overview, ExplorationFusionReadiness.ready, issues);
    }

    if (overview.lensStatuses.length != ExplorationLensId.all.length) {
      issues.add('expected ${ExplorationLensId.all.length} lens statuses');
    }

    return issues;
  }

  static void _expectProfile(
    ExplorationOverview overview,
    ExplorationProfileStatus expected,
    List<String> issues,
  ) {
    if (overview.profileStatus != expected) {
      issues.add('profileStatus expected $expected got ${overview.profileStatus}');
    }
  }

  static void _expectFusion(
    ExplorationOverview overview,
    ExplorationFusionReadiness expected,
    List<String> issues,
  ) {
    if (overview.fusionStatus.readiness != expected) {
      issues.add(
        'fusion readiness expected $expected got ${overview.fusionStatus.readiness}',
      );
    }
  }

  static void _expectMirror(
    ExplorationOverview overview,
    ExplorationMirrorId mirrorId,
    ExplorationMirrorReadiness expected,
    List<String> issues,
  ) {
    final actual = overview.mirror(mirrorId).readiness;
    if (actual != expected) {
      issues.add('mirror $mirrorId expected $expected got $actual');
    }
  }

  static void _expectExploredCount(
    ExplorationOverview overview, {
    int? count,
    int? greaterThan,
    required List<String> issues,
  }) {
    if (count != null && overview.coverage.exploredLensCount != count) {
      issues.add(
        'exploredLensCount expected $count got ${overview.coverage.exploredLensCount}',
      );
    }
    if (greaterThan != null &&
        overview.coverage.exploredLensCount <= greaterThan) {
      issues.add(
        'exploredLensCount expected > $greaterThan got ${overview.coverage.exploredLensCount}',
      );
    }
  }

  static void _expectAvailableMirrors(
    ExplorationOverview overview,
    int count,
    List<String> issues,
  ) {
    if (overview.coverage.availableMirrorCount != count) {
      issues.add(
        'availableMirrorCount expected $count got ${overview.coverage.availableMirrorCount}',
      );
    }
  }

  static void _expectReflectionCount(
    ExplorationOverview overview, {
    required int greaterThan,
    required List<String> issues,
  }) {
    if (overview.coverage.availableReflectionCount <= greaterThan) {
      issues.add(
        'availableReflectionCount expected > $greaterThan '
        'got ${overview.coverage.availableReflectionCount}',
      );
    }
  }
}
