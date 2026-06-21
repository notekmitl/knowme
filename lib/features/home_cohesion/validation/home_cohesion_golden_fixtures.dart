import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/exploration_overview/application/exploration_overview_builder.dart';
import 'package:knowme/features/exploration_overview/application/discovery_builder.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_scenario.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_scenario.dart';

import '../application/home_snapshot_builder.dart';
import '../domain/home_fusion_summary.dart';
import '../domain/home_mirror_summary.dart';
import '../domain/home_snapshot.dart';
import 'home_cohesion_golden_scenario.dart';

/// Deterministic Home Cohesion golden inputs (HC-F0).
abstract final class HomeCohesionGoldenFixtures {
  static HomeCohesionInputPair load(HomeCohesionGoldenScenario scenario) {
    return switch (scenario) {
      HomeCohesionGoldenScenario.emptyUser => emptyUser(),
      HomeCohesionGoldenScenario.overviewOnly => overviewOnly(),
      HomeCohesionGoldenScenario.discoveryOnly => discoveryOnly(),
      HomeCohesionGoldenScenario.mirrorReady => mirrorReady(),
      HomeCohesionGoldenScenario.fusionReady => fusionReady(),
      HomeCohesionGoldenScenario.everythingReady => everythingReady(),
    };
  }

  static HomeSnapshot build(HomeCohesionGoldenScenario scenario) {
    final pair = load(scenario);
    return HomeSnapshotBuilder.build(
      overview: pair.overview,
      discoveryItems: pair.discoveryItems,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }

  static HomeCohesionInputPair emptyUser() {
    return _fromExploration(ExplorationOverviewGoldenScenario.emptyUser);
  }

  static HomeCohesionInputPair overviewOnly() {
    return _fromExploration(ExplorationOverviewGoldenScenario.profileOnly);
  }

  static HomeCohesionInputPair discoveryOnly() {
    return _fromDiscovery(DiscoveryGoldenScenario.emptyUser);
  }

  static HomeCohesionInputPair mirrorReady() {
    return _fromDiscovery(DiscoveryGoldenScenario.astrologyReady);
  }

  static HomeCohesionInputPair fusionReady() {
    return _fromDiscovery(DiscoveryGoldenScenario.fusionReady);
  }

  static HomeCohesionInputPair everythingReady() {
    return _fromDiscovery(DiscoveryGoldenScenario.everythingReady);
  }

  static HomeCohesionInputPair _fromExploration(
    ExplorationOverviewGoldenScenario scenario,
  ) {
    final pair = ExplorationOverviewGoldenFixtures.load(scenario);
    final overview = ExplorationOverviewBuilder.build(
      profile: pair.profile,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
    final discoveryItems = DiscoveryBuilder.build(
      overview: overview,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );

    return HomeCohesionInputPair(
      overview: overview,
      discoveryItems: discoveryItems,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }

  static HomeCohesionInputPair _fromDiscovery(DiscoveryGoldenScenario scenario) {
    final pair = DiscoveryGoldenFixtures.load(scenario);
    final discoveryItems = DiscoveryBuilder.build(
      overview: pair.overview,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );

    return HomeCohesionInputPair(
      overview: pair.overview,
      discoveryItems: discoveryItems,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }
}

class HomeCohesionInputPair {
  const HomeCohesionInputPair({
    required this.overview,
    required this.discoveryItems,
    this.astrologySnapshot,
    this.personalitySnapshot,
    this.globalFusionSnapshot,
  });

  final ExplorationOverview overview;
  final List<DiscoveryItem> discoveryItems;
  final AstrologyFusionSnapshot? astrologySnapshot;
  final PersonalityMirrorSnapshot? personalitySnapshot;
  final GlobalFusionSnapshot? globalFusionSnapshot;
}

/// Expected invariants per Home Cohesion golden scenario.
abstract final class HomeCohesionGoldenExpectations {
  static List<String> verify(
    HomeCohesionGoldenScenario scenario,
    HomeSnapshot snapshot,
  ) {
    final issues = <String>[];

    if (snapshot.version != HomeSnapshot.versionId) {
      issues.add('expected version ${HomeSnapshot.versionId}');
    }

    if (snapshot.discoveryItems.isEmpty) {
      issues.add('expected non-empty discovery catalog');
    }

    if (snapshot.discoveryItems.length != 10) {
      issues.add(
        'expected 10 discovery items got ${snapshot.discoveryItems.length}',
      );
    }

    _assertNoRecommendationFields(snapshot, issues);

    switch (scenario) {
      case HomeCohesionGoldenScenario.emptyUser:
        _expectMirror(snapshot.mirrorSummary.astrology, available: false, issues: issues);
        _expectMirror(snapshot.mirrorSummary.personality, available: false, issues: issues);
        _expectFusion(snapshot.fusionSummary, available: false, ready: false, issues: issues);
        _expectDiscoveryAvailable(snapshot, greaterThan: 0, issues: issues);
      case HomeCohesionGoldenScenario.overviewOnly:
        _expectProfile(
          snapshot,
          ExplorationProfileStatus.birthProfileComplete,
          issues,
        );
        _expectFusion(snapshot.fusionSummary, available: false, ready: false, issues: issues);
        _expectDiscoveryAvailable(snapshot, greaterThan: 0, issues: issues);
      case HomeCohesionGoldenScenario.discoveryOnly:
        _expectDiscoveryAvailable(snapshot, greaterThan: 2, issues: issues);
        _expectFusion(snapshot.fusionSummary, available: false, ready: false, issues: issues);
      case HomeCohesionGoldenScenario.mirrorReady:
        _expectMirror(
          snapshot.mirrorSummary.astrology,
          available: true,
          ready: false,
          issues: issues,
        );
        _expectReflectionCount(
          snapshot.mirrorSummary.astrology,
          greaterThan: 0,
          issues: issues,
        );
      case HomeCohesionGoldenScenario.fusionReady:
        _expectFusion(snapshot.fusionSummary, available: true, ready: true, issues: issues);
        _expectFusionReflectionCount(snapshot, greaterThan: 0, issues: issues);
        expectConfidenceBandPresent(snapshot, issues);
      case HomeCohesionGoldenScenario.everythingReady:
        _expectMirror(
          snapshot.mirrorSummary.astrology,
          available: true,
          ready: true,
          issues: issues,
        );
        _expectMirror(
          snapshot.mirrorSummary.personality,
          available: true,
          ready: true,
          issues: issues,
        );
        _expectFusion(snapshot.fusionSummary, available: true, ready: true, issues: issues);
        _expectFusionReflectionCount(snapshot, greaterThan: 0, issues: issues);
        expectConfidenceBandPresent(snapshot, issues);
    }

    return issues;
  }

  static void _assertNoRecommendationFields(
    HomeSnapshot snapshot,
    List<String> issues,
  ) {
    for (final item in snapshot.discoveryItems) {
      for (final phrase in const ['คุณควร', 'แนะนำให้', 'Next Action']) {
        if (item.title.contains(phrase) || item.description.contains(phrase)) {
          issues.add('forbidden recommendation copy in ${item.id}');
        }
      }
    }
  }

  static void _expectProfile(
    HomeSnapshot snapshot,
    ExplorationProfileStatus expected,
    List<String> issues,
  ) {
    if (snapshot.overview.profileStatus != expected) {
      issues.add(
        'profileStatus expected $expected got ${snapshot.overview.profileStatus}',
      );
    }
  }

  static void _expectMirror(
    HomeMirrorEntrySummary mirror, {
    required bool available,
    bool? ready,
    required List<String> issues,
  }) {
    if (mirror.available != available) {
      issues.add('mirror available expected $available got ${mirror.available}');
    }
    if (ready != null && mirror.ready != ready) {
      issues.add('mirror ready expected $ready got ${mirror.ready}');
    }
  }

  static void _expectReflectionCount(
    HomeMirrorEntrySummary mirror, {
    required int greaterThan,
    required List<String> issues,
  }) {
    if (mirror.reflectionCount <= greaterThan) {
      issues.add(
        'mirror reflectionCount expected > $greaterThan got ${mirror.reflectionCount}',
      );
    }
  }

  static void _expectFusion(
    HomeFusionSummary fusion, {
    required bool available,
    required bool ready,
    required List<String> issues,
  }) {
    if (fusion.available != available) {
      issues.add('fusion available expected $available got ${fusion.available}');
    }
    if (fusion.ready != ready) {
      issues.add('fusion ready expected $ready got ${fusion.ready}');
    }
  }

  static void _expectFusionReflectionCount(
    HomeSnapshot snapshot, {
    required int greaterThan,
    required List<String> issues,
  }) {
    if (snapshot.fusionSummary.reflectionCount <= greaterThan) {
      issues.add(
        'fusion reflectionCount expected > $greaterThan '
        'got ${snapshot.fusionSummary.reflectionCount}',
      );
    }
  }

  static void expectConfidenceBandPresent(
    HomeSnapshot snapshot,
    List<String> issues,
  ) {
    if (snapshot.fusionSummary.confidenceBand == null) {
      issues.add('expected fusion confidenceBand when fusion ready');
    }
  }

  static void _expectDiscoveryAvailable(
    HomeSnapshot snapshot, {
    required int greaterThan,
    required List<String> issues,
  }) {
    final count = snapshot.discoveryItems
        .where((item) => item.availability == DiscoveryAvailability.available)
        .length;
    if (count <= greaterThan) {
      issues.add(
        'expected more than $greaterThan available discovery items got $count',
      );
    }
  }
}
