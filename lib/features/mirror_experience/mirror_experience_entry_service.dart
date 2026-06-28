import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/services/profile_service.dart';

import 'mirror_experience_input.dart';

/// P3 — loads the chart anchor (birth date) the experience needs.
///
/// This only reads profile data; it performs **no reasoning** (reasoning is the
/// Fusion Runtime's job, reached later by the experience). It reuses the existing
/// profile loader + birth-data probe rather than duplicating either.
class MirrorExperienceEntryService {
  MirrorExperienceEntryService({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;

  /// Returns the experience input for the current profile, or null when birth
  /// data is missing (the entry surface then prompts to complete the profile).
  Future<MirrorExperienceInput?> loadInput() async {
    final profile = await _profileService.loadProfile();
    final birthData =
        FirestoreAstrologyFusionLensProbe.thaiBirthDataFromProfile(profile);
    if (birthData == null) return null;

    final local = birthData.localDateTime;
    return MirrorExperienceInput(
      birthDate: DateTime(local.year, local.month, local.day),
    );
  }
}
