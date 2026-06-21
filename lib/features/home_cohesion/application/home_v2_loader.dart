import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_entry_status.dart';
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
    FirebaseFirestore? firestore,
    AstrologyFusionRepository? fusionRepository,
    PersonalityLensLoader? personalityLoader,
    AstrologyFusionEntryService? astrologyEntryService,
    FusionEntryService? fusionEntryService,
    PersonalityMirrorEntryService? personalityEntryService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _fusionRepository = fusionRepository ?? AstrologyFusionRepositoryImpl(),
        _personalityLoader = personalityLoader ?? PersonalityLensLoader(),
        _astrologyEntryService =
            astrologyEntryService ?? AstrologyFusionEntryService(),
        _fusionEntryService = fusionEntryService ?? FusionEntryService(),
        _personalityEntryService =
            personalityEntryService ?? PersonalityMirrorEntryService();

  final FirebaseFirestore _firestore;
  final AstrologyFusionRepository _fusionRepository;
  final PersonalityLensLoader _personalityLoader;
  final AstrologyFusionEntryService _astrologyEntryService;
  final FusionEntryService _fusionEntryService;
  final PersonalityMirrorEntryService _personalityEntryService;

  Future<HomeScreenV2Data> load(String uid) async {
    return HomeV2Assembler.fromSources(await loadBundle(uid));
  }

  Future<HomeV2SourceBundle> loadBundle(String uid) async {
    if (uid.isEmpty) {
      return _emptyBundle();
    }

    final profileDocFuture = _firestore.collection('users').doc(uid).get();
    final fusionSnapshotFuture = _fusionRepository.loadFusion(uid);
    final personalityLoadFuture = _personalityLoader.loadAll(uid);
    final entriesFuture = Future.wait([
      _astrologyEntryService.evaluate(uid),
      _fusionEntryService.evaluate(uid),
      _personalityEntryService.evaluate(uid),
    ]);

    final profileDoc = await profileDocFuture;
    final profileMainDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('main')
        .get();
    final profileData = profileMainDoc.exists && profileMainDoc.data() != null
        ? profileMainDoc.data()
        : profileDoc.data();
    final profileFields = _profileFields(profileData);
    final profileInput = _profileInput(profileData);

    final fusionSnapshot = await fusionSnapshotFuture;
    final fusionResult = fusionSnapshot?.toResult();

    final personalityLoad = await personalityLoadFuture;
    final entries = await entriesFuture;
    final astrologyEntry = entries[0] as AstrologyFusionEntryState;
    final globalFusionEntry = entries[1] as FusionEntryState;
    final personalityEntry = entries[2] as PersonalityMirrorEntryState;

    PersonalityMirrorNarrativeView? personalityNarrative;
    PersonalityMirrorSnapshot? personalitySnapshot;
    GlobalFusionSnapshot? globalFusionSnapshot;
    final globalReflections = <GlobalReflectionUnit>[];

    if (PersonalityMirrorEntryService.canOpenMirror(personalityLoad.coverage)) {
      personalitySnapshot = PersonalityMirrorEngine.build(personalityLoad);
      final confidence = PersonalityConfidenceComposer.analyze(
        load: personalityLoad,
        agreements: personalitySnapshot.agreements,
        tensions: personalitySnapshot.tensions,
      );
      personalityNarrative = PersonalityMirrorNarrativeBuilder.build(
        personalitySnapshot,
        confidenceBreakdown: confidence,
      );

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
    }

    return HomeV2SourceBundle(
      profileInput: profileInput,
      profileFields: profileFields,
      astrologyFusion: fusionResult,
      astrologyEntry: astrologyEntry,
      personalityEntry: personalityEntry,
      globalFusionEntry: globalFusionEntry,
      personalityNarrative: personalityNarrative,
      personalityCoverage: personalityLoad.coverage,
      globalReflections: globalReflections,
      astrologySnapshot: fusionSnapshot,
      personalitySnapshot: personalitySnapshot,
      globalFusionSnapshot: globalFusionSnapshot,
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

  static Map<String, String> _profileFields(Map<String, dynamic>? data) {
    if (data == null) return const {};
    return {
      'name': '${data['name'] ?? ''}',
      'birthDate': '${data['birthDate'] ?? ''}',
      'birthTime': '${data['birthTime'] ?? ''}',
      'birthPlace': '${data['birthPlace'] ?? ''}',
    };
  }

  static ExplorationProfileInput _profileInput(Map<String, dynamic>? data) {
    if (data == null) return ExplorationProfileInput.empty;

    final name = '${data['name'] ?? ''}'.trim();
    final birthDate = '${data['birthDate'] ?? ''}'.trim();
    final birthTime = '${data['birthTime'] ?? ''}'.trim();
    final birthPlace = '${data['birthPlace'] ?? ''}'.trim();
    final latitude = (data['latitude'] as num?)?.toDouble() ?? 0;
    final longitude = (data['longitude'] as num?)?.toDouble() ?? 0;

    return ExplorationProfileInput(
      hasName: name.isNotEmpty,
      hasBirthDate: birthDate.isNotEmpty,
      hasBirthTime: birthTime.isNotEmpty,
      hasBirthPlace: birthPlace.isNotEmpty,
      hasCoordinates: latitude != 0 && longitude != 0,
    );
  }
}
