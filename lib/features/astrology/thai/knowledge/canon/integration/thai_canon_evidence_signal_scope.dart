import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';

/// Determines whether a runtime content key is inside frozen Mahabhut Canon scope.
abstract final class ThaiCanonEvidenceSignalScope {
  /// Runtime keys with no exact Mahabhut Canon representation.
  ///
  /// These are valid Thai report signals but must not be treated as mapping failures.
  static bool isOutOfCanonScope(String contentKey) {
    if (ThaiContentKeys.allMyanmarSeven.contains(contentKey)) return true;
    if (ThaiContentKeys.allLagna.contains(contentKey)) return true;
    if (contentKey == ThaiContentKeys.mahabhutaThaya) return true;
    return false;
  }

  static bool isOutOfCanonScopeLens(ThaiMirrorLensSource lens) {
    return switch (lens) {
      ThaiMirrorLensSource.lagna ||
      ThaiMirrorLensSource.myanmarSeven =>
        true,
      _ => false,
    };
  }

  /// Deterministic explanation — no inferred Canon equivalence.
  static String outOfCanonScopeReason(String contentKey) {
    if (ThaiContentKeys.allMyanmarSeven.contains(contentKey)) {
      return 'Myanmar seven content key — not represented in frozen Mahabhut Canon';
    }
    if (ThaiContentKeys.allLagna.contains(contentKey)) {
      return 'Lagna sign content key — not represented in frozen Mahabhut Canon';
    }
    if (contentKey == ThaiContentKeys.mahabhutaThaya) {
      return 'Runtime mahabhuta_thaya (ทายะ) has no exact Canon entity; '
          'Canon mahabhutPosition.khumsap (ขุมทรัพย์) is a distinct named '
          'position with no deterministic runtime key — equivalence not inferred';
    }
    return 'Signal outside frozen Mahabhut Canon scope';
  }

  /// Mahabhut runtime keys that are in Canon scope (six mapped positions).
  static bool isInCanonScopeMahabhutKey(String contentKey) {
    return ThaiContentKeys.allMahabhutaPosition.contains(contentKey) &&
        !isOutOfCanonScope(contentKey);
  }
}
