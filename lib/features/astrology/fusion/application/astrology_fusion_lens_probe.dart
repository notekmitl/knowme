import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_input_fingerprint.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/services/astrology_firestore_service.dart';
import 'package:knowme/services/bazi_firestore_service.dart';
import 'package:knowme/services/profile_service.dart';

import '../domain/entities/astrology_lens.dart';
import '../domain/models/astrology_fusion_real_input.dart';

class AstrologyFusionLensProbeResult {
  const AstrologyFusionLensProbeResult({
    required this.completedLensIds,
    required this.input,
  });

  final List<String> completedLensIds;
  final AstrologyFusionRealInput input;
}

/// Probes lens availability and builds real fusion input.
abstract class AstrologyFusionLensProbe {
  Future<AstrologyFusionLensProbeResult> probe(String uid);
}

class FirestoreAstrologyFusionLensProbe extends AstrologyFusionLensProbe {
  FirestoreAstrologyFusionLensProbe({
    AstrologyFirestoreService? westernService,
    BaziFirestoreService? baziService,
    ProfileService? profileService,
  }) : _westernService = westernService ?? AstrologyFirestoreService(),
       _baziService = baziService ?? BaziFirestoreService(),
       _profileService = profileService ?? ProfileService();

  final AstrologyFirestoreService _westernService;
  final BaziFirestoreService _baziService;
  final ProfileService _profileService;

  @override
  Future<AstrologyFusionLensProbeResult> probe(String uid) async {
    final profile = await _profileService.loadProfileForUid(uid);
    final fullProfileReady = BirthProfileReadiness.isComplete(profile);
    final baziProfileReady = BirthProfileReadiness.isBaziCompatible(profile);

    // A saved Western/Thai result can depend on a birth time that the current
    // profile no longer knows. Keep those lenses out of Fusion until the full
    // profile is complete again, so Unknown-time cannot reveal stale output.
    final western = fullProfileReady
        ? await _westernService.getWesternNatalChart(uid)
        : null;
    final candidateBazi = baziProfileReady
        ? await _baziService.getChineseBaziChart(uid)
        : null;
    final bazi = isBaziFreshForProfile(candidateBazi, profile)
        ? candidateBazi
        : null;
    final thai = fullProfileReady ? _loadThaiMirror(profile) : null;

    final completed = <String>[];
    if (western != null) {
      completed.add(AstrologyLens.westernNatal.lensId);
    }
    if (bazi != null) {
      completed.add(AstrologyLens.chineseBazi.lensId);
    }
    if (thai != null) {
      completed.add(AstrologyLens.thaiAstrology.lensId);
    }

    return AstrologyFusionLensProbeResult(
      completedLensIds: completed,
      input: AstrologyFusionRealInput(western: western, bazi: bazi, thai: thai),
    );
  }

  static bool isBaziFreshForProfile(
    BaziChartModel? chart,
    ProfileModel? profile,
  ) {
    if (chart == null || !BirthProfileReadiness.isBaziCompatible(profile)) {
      return false;
    }
    return chart.inputHash == BaziInputFingerprint.forProfile(profile!);
  }

  ThaiMirrorResult? _loadThaiMirror(ProfileModel? profile) {
    final birthData = thaiBirthDataFromProfile(profile);
    if (birthData == null) return null;

    final pipeline = ThaiMirrorPipeline.generate(birthData);
    return pipeline.mirrorResult;
  }

  static ThaiBirthData? thaiBirthDataFromProfile(ProfileModel? profile) {
    if (profile == null) return null;
    return ThaiEngineAdapter.fromProfileMap(profile.toMap());
  }
}
