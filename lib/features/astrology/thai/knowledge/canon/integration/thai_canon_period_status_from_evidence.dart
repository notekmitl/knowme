import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';

import 'thai_canon_evidence_ref.dart';

/// Extracts period rise/fall Canon ids from exact markers on life_period evidence.
///
/// Evidence-layer only — does not infer from position, planet, or narrative.
abstract final class ThaiCanonPeriodStatusFromEvidence {
  static const duengKhuenMarker = '[ดวงขึ้น]';
  static const duengTokMarker = '[ดวงตก]';

  static const allowedMarkers = {duengKhuenMarker, duengTokMarker};

  /// Returns a single Canon id when markers are present and unambiguous.
  ///
  /// Returns null when no marker, mixed markers, or both markers on one context.
  static String? canonIdFromLifePeriodRefs(Iterable<ThaiCanonEvidenceRef> refs) {
    String? resolved;
    for (final ref in refs) {
      if (ref.contextType != 'life_period') continue;
      final value = ref.contextValue;
      if (value == null || value.isEmpty) continue;

      final markerId = _canonIdForContextValue(value);
      if (markerId == null) continue;
      if (resolved != null && resolved != markerId) return null;
      resolved = markerId;
    }
    return resolved;
  }

  /// Whether [contextValue] contains an exact, unambiguous marker token.
  static String? canonIdForContextValue(String contextValue) =>
      _canonIdForContextValue(contextValue);

  static String? _canonIdForContextValue(String contextValue) {
    final hasKhuen = contextValue.contains(duengKhuenMarker);
    final hasTok = contextValue.contains(duengTokMarker);
    if (hasKhuen && hasTok) return null;
    if (hasKhuen) return LifePeriodStatusMetadataValues.duengKhuen;
    if (hasTok) return LifePeriodStatusMetadataValues.duengTok;
    return null;
  }
}
