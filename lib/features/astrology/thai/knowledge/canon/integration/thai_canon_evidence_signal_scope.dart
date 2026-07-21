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
      return 'Runtime mahabhuta_thaya (ทายะ) is OUT_OF_CANON_SCOPE; '
          'internal mahabhuta_khumsap maps to Canon mahabhutPosition.khumsap '
          '(ขุมทรัพย์) — equivalence not inferred';
    }
    return 'Signal outside frozen Mahabhut Canon scope';
  }

  /// Khumsap internal runtime key — in Canon scope (distinct from thaya).
  static bool isInternalKhumsapRuntimeKey(String contentKey) {
    return contentKey == 'mahabhuta_khumsap';
  }

  /// Mahabhut runtime keys that are in Canon scope (six public + internal khumsap).
  static bool isInCanonScopeMahabhutKey(String contentKey) {
    if (isInternalKhumsapRuntimeKey(contentKey)) return true;
    return ThaiContentKeys.allMahabhutaPosition.contains(contentKey) &&
        !isOutOfCanonScope(contentKey);
  }
}
