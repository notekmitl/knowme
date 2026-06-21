import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/services/profile_service.dart';

import '../runtime/thai_mirror_pipeline.dart';
import '../runtime/thai_mirror_pipeline_result.dart';

/// Production entry for Thai Mirror — profile → pipeline only (no engine changes).
class ThaiMirrorEntryService {
  ThaiMirrorEntryService({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;

  Future<bool> canOpen() async {
    final profile = await _profileService.loadProfile();
    return FirestoreAstrologyFusionLensProbe.thaiBirthDataFromProfile(profile) !=
        null;
  }

  Future<ThaiMirrorPipelineResult> loadResult() async {
    final profile = await _profileService.loadProfile();
    final birthData =
        FirestoreAstrologyFusionLensProbe.thaiBirthDataFromProfile(profile);
    if (birthData == null) {
      return const ThaiMirrorPipelineResult.failure(
        errorMessage:
            'Profile birth data is not available for Thai Astrology.',
      );
    }

    return ThaiMirrorPipeline.generate(birthData);
  }
}
