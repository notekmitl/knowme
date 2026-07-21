import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_entry_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_lens_catalog.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_readiness.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/application/narrative/global_narrative_builder.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/domain/global_reflection_unit.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_confidence_composer.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_engine.dart';
import 'package:knowme/features/personality_mirror/application/narrative/personality_mirror_narrative_builder.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_loader.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_narrative_view.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

import '../presentation/home_screen_v2_models.dart';
import 'home_v2_assembler.dart';

/// Loads live Home source data — widgets never read Firestore directly.
class HomeV2Loader {
  HomeV2Loader({
    AstrologyFusionRepository? fusionRepository,
    PersonalityLensLoader? personalityLoader,
    AstrologyFusionLensProbe? lensProbe,
    CanonicalProfileResolver? profileResolver,
  })  : _fusionRepository = fusionRepository ?? AstrologyFusionRepositoryImpl(),
        _personalityLoader = personalityLoader ?? PersonalityLensLoader(),
        _lensProbe = lensProbe ?? FirestoreAstrologyFusionLensProbe(),
        _profileResolver = profileResolver ?? CanonicalProfileResolver();

  final AstrologyFusionRepository _fusionRepository;
  final PersonalityLensLoader _personalityLoader;
  final AstrologyFusionLensProbe _lensProbe;
  final CanonicalProfileResolver _profileResolver;

  Future<HomeScreenV2Data> load(String uid) async {
    return HomeV2Assembler.fromSources(await loadBundle(uid));
  }

  Future<HomeV2SourceBundle> loadBundle(
    String uid, {
    bool includeHeavyDerivations = true,
  }) async {
    if (uid.isEmpty) {
      return _emptyBundle();
    }

    final profileFuture = _profileResolver.loadCanonicalProfile(uid);
    final fusionSnapshotFuture = _fusionRepository.loadFusion(uid);
    final personalityLoadFuture = _personalityLoader.loadAll(uid);
    final lensProbeFuture = _lensProbe.probe(uid);

    final results = await Future.wait([
      profileFuture,
      fusionSnapshotFuture,
      personalityLoadFuture,
      lensProbeFuture,
    ]);

    final profile = results[0] as ProfileModel?;
    final fusionSnapshot = results[1] as AstrologyFusionSnapshot?;
    final personalityLoad = results[2] as PersonalityLensLoadResult;
    final lensProbe = results[3] as AstrologyFusionLensProbeResult;

    final profileFields = CanonicalProfileResolver.profileFields(profile);
    final profileInput = CanonicalProfileResolver.explorationInput(profile);
    final fusionResult = fusionSnapshot?.toResult();

    final astrologyEntry = _astrologyEntryFromProbe(lensProbe);
    final personalityEntry =
        PersonalityMirrorEntryState.fromCoverage(personalityLoad.coverage);
    final globalFusionEntry = FusionEntryState(
      canOpen: fusionSnapshot != null &&
          (personalityLoad.coverage.hasMbti ||
              personalityLoad.coverage.hasBigFive ||
              personalityLoad.coverage.hasAnyEq),
    );

    var bundle = HomeV2SourceBundle(
      profileInput: profileInput,
      profileFields: profileFields,
      astrologyFusion: fusionResult,
      astrologyEntry: astrologyEntry,
      personalityEntry: personalityEntry,
      globalFusionEntry: globalFusionEntry,
      personalityNarrative: null,
      personalityCoverage: personalityLoad.coverage,
      globalReflections: const [],
      astrologySnapshot: fusionSnapshot,
      personalitySnapshot: null,
      globalFusionSnapshot: null,
    );

    if (includeHeavyDerivations) {
      bundle = enrichBundle(bundle, personalityLoad: personalityLoad);
    }

    return bundle;
  }

  /// Adds mirror / global-fusion derivations without extra Firestore reads.
  HomeV2SourceBundle enrichBundle(
    HomeV2SourceBundle bundle, {
    PersonalityLensLoadResult? personalityLoad,
  }) {
    final load = personalityLoad;
    if (load == null ||
        !PersonalityMirrorEntryService.canOpenMirror(load.coverage)) {
      return bundle;
    }

    final personalitySnapshot = PersonalityMirrorEngine.build(load);
    final confidence = PersonalityConfidenceComposer.analyze(
      load: load,
      agreements: personalitySnapshot.agreements,
      tensions: personalitySnapshot.tensions,
    );
    final personalityNarrative = PersonalityMirrorNarrativeBuilder.build(
      personalitySnapshot,
      confidenceBreakdown: confidence,
    );

    GlobalFusionSnapshot? globalFusionSnapshot;
    final globalReflections = <GlobalReflectionUnit>[];
    final fusionSnapshot = bundle.astrologySnapshot;
    if (fusionSnapshot != null) {
      final globalInput = const GlobalFusionInputLoader().load(
        astrologySnapshot: fusionSnapshot,
        personalitySnapshot: personalitySnapshot,
      );
      globalFusionSnapshot = GlobalFusionBuilder.build(globalInput);
      globalReflections.addAll(
        GlobalNarrativeBuilder.fromSnapshot(globalFusionSnapshot),
      );
    }

    return HomeV2SourceBundle(
      profileInput: bundle.profileInput,
      profileFields: bundle.profileFields,
      astrologyFusion: bundle.astrologyFusion,
      astrologyEntry: bundle.astrologyEntry,
      personalityEntry: bundle.personalityEntry,
      globalFusionEntry: bundle.globalFusionEntry,
      personalityNarrative: personalityNarrative,
      personalityCoverage: bundle.personalityCoverage,
      globalReflections: globalReflections,
      astrologySnapshot: bundle.astrologySnapshot,
      personalitySnapshot: personalitySnapshot,
      globalFusionSnapshot: globalFusionSnapshot,
    );
  }

  static AstrologyFusionEntryState _astrologyEntryFromProbe(
    AstrologyFusionLensProbeResult probe,
  ) {
    final completed = probe.completedLensIds.length;
    final total = AstrologyFusionLensCatalog.totalLensCount;
    final readiness = AstrologyFusionReadiness(
      completedLensCount: completed,
      totalLensCount: total,
      status: AstrologyFusionReadiness.statusForCount(
        completedLensCount: completed,
        totalLensCount: total,
      ),
      completedLensIds: List.unmodifiable(probe.completedLensIds),
    );

    return AstrologyFusionEntryState(
      readiness: readiness,
      canOpen: readiness.canOpenFusion,
    );
  }

  static HomeV2SourceBundle _emptyBundle() {
    return HomeV2SourceBundle(
      profileInput: ExplorationProfileInput.empty,
      profileFields: const {},
      astrologyFusion: null,
      astrologyEntry: const AstrologyFusionEntryState(
        readiness: AstrologyFusionReadiness(
          completedLensCount: 0,
          totalLensCount: 3,
          status: AstrologyFusionEntryStatus.unavailable,
          completedLensIds: [],
        ),
        canOpen: false,
      ),
      personalityEntry: const PersonalityMirrorEntryState(
        canOpen: false,
        canShowFullExperience: false,
        coverage: null,
      ),
      globalFusionEntry: const FusionEntryState(canOpen: false),
      personalityNarrative: null,
      personalityCoverage: null,
      globalReflections: const [],
    );
  }
}
