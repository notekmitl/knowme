import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
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
  })  : _westernService = westernService ?? AstrologyFirestoreService(),
        _baziService = baziService ?? BaziFirestoreService(),
        _profileService = profileService ?? ProfileService();

  final AstrologyFirestoreService _westernService;
  final BaziFirestoreService _baziService;
  final ProfileService _profileService;

  @override
  Future<AstrologyFusionLensProbeResult> probe(String uid) async {
    final western = await _westernService.getWesternNatalChart(uid);
    final bazi = await _baziService.getChineseBaziChart(uid);
    final profile = await _profileService.loadProfile();
    final thai = _loadThaiMirror(profile);

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
      input: AstrologyFusionRealInput(
        western: western,
        bazi: bazi,
        thai: thai,
      ),
    );
  }

  ThaiMirrorResult? _loadThaiMirror(ProfileModel? profile) {
    final birthData = thaiBirthDataFromProfile(profile);
    if (birthData == null) return null;

    final pipeline = ThaiMirrorPipeline.generate(birthData);
    return pipeline.mirrorResult;
  }

  static ThaiBirthData? thaiBirthDataFromProfile(ProfileModel? profile) {
    if (profile == null) return null;
    if (profile.birthDate.trim().isEmpty) return null;

    final date = DateTime.tryParse(profile.birthDate.trim());
    if (date == null) return null;

    final timeParts = profile.birthTime.split(':');
    final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 12 : 12;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    final hasBirthTime = profile.birthTime.trim().isNotEmpty;

    return ThaiBirthData(
      localDateTime: DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      ),
      timeZoneOffset: _timeZoneOffset(profile.timezone),
      latitude: profile.latitude,
      longitude: profile.longitude,
      hasBirthTime: hasBirthTime,
    );
  }

  static Duration _timeZoneOffset(String timezone) {
    if (timezone.contains('Bangkok') || timezone == 'Asia/Bangkok') {
      return const Duration(hours: 7);
    }
    return const Duration(hours: 7);
  }
}
