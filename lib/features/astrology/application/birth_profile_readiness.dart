import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/domain/models/profile_model.dart';

/// Canonical birth-profile completeness — single source of truth.
abstract final class BirthProfileReadiness {
  static bool isComplete(ProfileModel? profile) {
    if (profile == null) return false;
    if (profile.birthDate.trim().isEmpty) return false;
    if (profile.birthTime.trim().isEmpty) return false;
    if (profile.birthPlace.trim().isEmpty) return false;
    if (profile.latitude == 0 && profile.longitude == 0) return false;
    return BirthProfileFormat.parseStoredDate(profile.birthDate.trim()) != null;
  }

  static String apiBirthDate(ProfileModel profile) {
    final date = BirthProfileFormat.parseStoredDate(profile.birthDate.trim());
    if (date == null) {
      throw StateError('Invalid birth date on profile');
    }
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
