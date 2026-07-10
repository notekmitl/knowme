import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

import '../../domain/normalized_birth.dart';
import '../../domain/thai_birth_context.dart';
import '../birth_normalizer.dart';

/// The single adapter from normalized birth data into the Thai **engine model**.
///
/// Ownership boundary:
/// - Birth Normalization owns this adapter (and `ThaiBirthContext`).
/// - Thai owns only its engine model, [ThaiBirthData].
///
/// [ThaiBirthData.localDateTime] keeps the exact civil instant (used by the
/// astronomical lagna and the verified-lunar lookup); [ThaiBirthData.astrologicalDate]
/// carries the sunrise day boundary resolved by normalization.
abstract final class ThaiEngineAdapter {
  /// Maps a resolved [ThaiBirthContext] to the engine input model.
  static ThaiBirthData fromContext(ThaiBirthContext context) {
    return ThaiBirthData(
      localDateTime: context.localDateTime,
      timeZoneOffset: context.timeZoneOffset,
      latitude: context.latitude,
      longitude: context.longitude,
      hasBirthTime: context.hasBirthTime,
      astrologicalDate: context.astrologicalDate,
    );
  }

  /// Convenience: maps the Thai context of a [NormalizedBirth].
  static ThaiBirthData fromNormalized(NormalizedBirth birth) =>
      fromContext(birth.thai);

  /// Profile map (`users/{uid}/profile/main`) → Thai engine input.
  /// Returns null when the profile has no parseable birth date.
  static ThaiBirthData? fromProfileMap(Map<String, dynamic> profile) {
    final result = BirthNormalizer.normalizeProfileMap(profile);
    final birth = result.birth;
    if (!result.isValid || birth == null) return null;
    return fromContext(birth.thai);
  }
}
