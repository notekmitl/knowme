import 'package:knowme/features/astrology/fusion/domain/entities/fusion_agreement.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_insight.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/reflection_result.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/astrology/fusion/domain/models/source_lens_versions.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_fixtures.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_engine.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/personality_mirror/validation/personality_mirror_fixture_builder.dart';

import '../application/discovery_builder.dart';
import '../application/exploration_overview_builder.dart';
import '../domain/discovery_item.dart';
import '../domain/exploration_overview.dart';
import '../domain/exploration_profile_input.dart';
import 'discovery_golden_scenario.dart';
import 'exploration_overview_golden_fixtures.dart';
import 'exploration_overview_golden_scenario.dart';

/// Deterministic discovery inputs for golden validation (EO-F1).
abstract final class DiscoveryGoldenFixtures {
  static const _loader = GlobalFusionInputLoader();

  static DiscoveryInputPair load(DiscoveryGoldenScenario scenario) {
    return switch (scenario) {
      DiscoveryGoldenScenario.emptyUser => emptyUser(),
      DiscoveryGoldenScenario.profileOnly => profileOnly(),
      DiscoveryGoldenScenario.astrologyReady => astrologyReady(),
      DiscoveryGoldenScenario.personalityReady => personalityReady(),
      DiscoveryGoldenScenario.fusionReady => fusionReady(),
      DiscoveryGoldenScenario.everythingReady => everythingReady(),
    };
  }

  static List<DiscoveryItem> build(DiscoveryGoldenScenario scenario) {
    final pair = load(scenario);
    return DiscoveryBuilder.build(
      overview: pair.overview,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }

  static DiscoveryInputPair emptyUser() {
    final overview = ExplorationOverviewGoldenFixtures.build(
      ExplorationOverviewGoldenScenario.emptyUser,
    );
    return DiscoveryInputPair(overview: overview);
  }

  static DiscoveryInputPair profileOnly() {
    final overview = ExplorationOverviewGoldenFixtures.build(
      ExplorationOverviewGoldenScenario.profileOnly,
    );
    return DiscoveryInputPair(
      overview: overview,
      profile: ExplorationProfileInput.birthComplete,
    );
  }

  static DiscoveryInputPair astrologyReady() {
    final pair = ExplorationOverviewGoldenFixtures.astrologyOnly();
    return DiscoveryInputPair(
      overview: ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
      ),
      astrologySnapshot: pair.astrologySnapshot,
      profile: pair.profile,
    );
  }

  static DiscoveryInputPair personalityReady() {
    final pair = ExplorationOverviewGoldenFixtures.personalityOnly();
    return DiscoveryInputPair(
      overview: ExplorationOverviewBuilder.build(
        profile: pair.profile,
        personalitySnapshot: pair.personalitySnapshot,
      ),
      personalitySnapshot: pair.personalitySnapshot,
      profile: pair.profile,
    );
  }

  static DiscoveryInputPair fusionReady() {
    final pair = ExplorationOverviewGoldenFixtures.globalFusionReady();
    return DiscoveryInputPair(
      overview: ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
        personalitySnapshot: pair.personalitySnapshot,
        globalFusionSnapshot: pair.globalFusionSnapshot,
      ),
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
      profile: pair.profile,
    );
  }

  static DiscoveryInputPair everythingReady() {
    final astrology = _fullAstrologySnapshot();
    final personality = _fullPersonalitySnapshot();
    final input = _loader.load(
      astrologySnapshot: astrology,
      personalitySnapshot: personality,
    );
    final globalFusion = GlobalFusionBuilder.build(input);
    final overview = ExplorationOverviewBuilder.build(
      profile: ExplorationProfileInput.birthComplete,
      astrologySnapshot: astrology,
      personalitySnapshot: personality,
      globalFusionSnapshot: globalFusion,
    );

    return DiscoveryInputPair(
      overview: overview,
      astrologySnapshot: astrology,
      personalitySnapshot: personality,
      globalFusionSnapshot: globalFusion,
      profile: ExplorationProfileInput.birthComplete,
    );
  }

  static AstrologyFusionSnapshot _fullAstrologySnapshot() {
    return AstrologyFusionSnapshot.fromPipeline(
      generatedAt: DateTime.utc(2026, 6, 1),
      signals: const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western', 'bazi', 'thai'],
          supportLevel: FusionSupportLevel.high,
        ),
      ],
      agreements: const [
        FusionAgreement(
          sourceThemeIds: ['structured'],
          supportingLenses: ['western', 'bazi', 'thai'],
          supportLevel: FusionSupportLevel.high,
          family: ThemeFamily.structure,
          familyLevel: true,
        ),
      ],
      tensions: const [],
      reflection: ReflectionResult(
        summary: 'Full discovery fixture.',
        keyInsights: const ['fixture'],
      ),
      fusionInsight: FusionInsightResult(
        primary: FusionInsight(
          title: 'Fixture',
          description: 'Full astrology discovery fixture.',
        ),
      ),
      growthOpportunities: const [],
      futureTendencies: const [],
      sourceLensVersions: const SourceLensVersions(
        westernVersion: 'western_v1_fixture',
        baziVersion: 'bazi_v1_fixture',
        thaiVersion: 'thai_v1_fixture',
      ),
    );
  }

  static PersonalityMirrorSnapshot _fullPersonalitySnapshot() {
    return PersonalityMirrorEngine.build(
      PersonalityLensLoadResult(
        snapshots: {
          for (final lensId in PersonalityLensId.all)
            lensId: PersonalityMirrorFixtureBuilder.lens(
              lensId: lensId,
              themeIds: PersonalityMirrorFixtureBuilder.alignedStructureThemes,
              lensConfidence: 0.7,
            ),
        },
        coverage: PersonalityCoverage(
          availableLensIds: PersonalityLensId.all,
          missingLensIds: const [],
          eqModulesCompleted: PersonalityLensId.eqLenses.length,
          eqModulesExpected: PersonalityLensId.eqLenses.length,
          weightedCoverage: PersonalityMirrorWeights.mbti +
              PersonalityMirrorWeights.bigFive +
              (PersonalityLensId.eqLenses.length *
                  PersonalityMirrorWeights.eqModuleShare),
        ),
      ),
    );
  }
}

class DiscoveryInputPair {
  const DiscoveryInputPair({
    required this.overview,
    this.profile,
    this.astrologySnapshot,
    this.personalitySnapshot,
    this.globalFusionSnapshot,
  });

  final ExplorationOverview overview;
  final ExplorationProfileInput? profile;
  final AstrologyFusionSnapshot? astrologySnapshot;
  final PersonalityMirrorSnapshot? personalitySnapshot;
  final GlobalFusionSnapshot? globalFusionSnapshot;
}

/// Expected invariants per discovery golden scenario.
abstract final class DiscoveryGoldenExpectations {
  static List<String> verify(
    DiscoveryGoldenScenario scenario,
    List<DiscoveryItem> items,
  ) {
    final issues = <String>[];

    if (items.length != DiscoveryCatalogIds.catalogOrder.length) {
      issues.add(
        'expected ${DiscoveryCatalogIds.catalogOrder.length} discovery items '
        'got ${items.length}',
      );
    }

    for (var i = 0; i < DiscoveryCatalogIds.catalogOrder.length; i++) {
      if (i >= items.length) break;
      if (items[i].id != DiscoveryCatalogIds.catalogOrder[i]) {
        issues.add(
          'catalog order mismatch at $i: expected '
          '${DiscoveryCatalogIds.catalogOrder[i]} got ${items[i].id}',
        );
      }
    }

    _assertNoRecommendationCopy(items, issues);

    switch (scenario) {
      case DiscoveryGoldenScenario.emptyUser:
        _expectItem(
          items,
          DiscoveryCatalogIds.westernNatal,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.mbti,
          DiscoveryAvailability.available,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.astrologyMirror,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.explorationOverview,
          DiscoveryAvailability.available,
          issues,
        );
      case DiscoveryGoldenScenario.profileOnly:
        _expectItem(
          items,
          DiscoveryCatalogIds.westernNatal,
          DiscoveryAvailability.available,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectAvailabilityCount(
          items,
          DiscoveryAvailability.available,
          greaterThan: 0,
          issues: issues,
        );
      case DiscoveryGoldenScenario.astrologyReady:
        _expectItem(
          items,
          DiscoveryCatalogIds.astrologyMirror,
          DiscoveryAvailability.available,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.personalityMirror,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectSourceTypeCount(
          items,
          DiscoverySourceType.lens,
          DiscoveryCategory.astrology,
          completedGreaterThan: 0,
          issues: issues,
        );
      case DiscoveryGoldenScenario.personalityReady:
        _expectItem(
          items,
          DiscoveryCatalogIds.personalityMirror,
          DiscoveryAvailability.available,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.astrologyMirror,
          DiscoveryAvailability.locked,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.mbti,
          DiscoveryAvailability.completed,
          issues,
        );
      case DiscoveryGoldenScenario.fusionReady:
        _expectItem(
          items,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.astrologyMirror,
          DiscoveryAvailability.available,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.personalityMirror,
          DiscoveryAvailability.available,
          issues,
        );
      case DiscoveryGoldenScenario.everythingReady:
        _expectItem(
          items,
          DiscoveryCatalogIds.astrologyMirror,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.personalityMirror,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectItem(
          items,
          DiscoveryCatalogIds.explorationOverview,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectAvailabilityCount(
          items,
          DiscoveryAvailability.completed,
          greaterThan: 5,
          issues: issues,
        );
    }

    return issues;
  }

  static void _assertNoRecommendationCopy(
    List<DiscoveryItem> items,
    List<String> issues,
  ) {
    const forbidden = ['คุณควร', 'แนะนำให้', 'Next Test', 'next test'];
    for (final item in items) {
      for (final phrase in forbidden) {
        if (item.title.contains(phrase) || item.description.contains(phrase)) {
          issues.add('forbidden recommendation copy in ${item.id}');
        }
      }
    }
  }

  static void _expectItem(
    List<DiscoveryItem> items,
    String id,
    DiscoveryAvailability expected,
    List<String> issues,
  ) {
    final item = items.where((entry) => entry.id == id).firstOrNull;
    if (item == null) {
      issues.add('missing discovery item $id');
      return;
    }
    if (item.availability != expected) {
      issues.add('$id expected $expected got ${item.availability}');
    }
  }

  static void _expectAvailabilityCount(
    List<DiscoveryItem> items,
    DiscoveryAvailability availability, {
    required int greaterThan,
    required List<String> issues,
  }) {
    final count =
        items.where((item) => item.availability == availability).length;
    if (count <= greaterThan) {
      issues.add(
        'expected more than $greaterThan $availability items got $count',
      );
    }
  }

  static void _expectSourceTypeCount(
    List<DiscoveryItem> items,
    DiscoverySourceType sourceType,
    DiscoveryCategory category, {
    required int completedGreaterThan,
    required List<String> issues,
  }) {
    final count = items
        .where(
          (item) =>
              item.sourceType == sourceType &&
              item.category == category &&
              item.availability == DiscoveryAvailability.completed,
        )
        .length;
    if (count <= completedGreaterThan) {
      issues.add(
        'expected completed $sourceType/$category count > '
        '$completedGreaterThan got $count',
      );
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
