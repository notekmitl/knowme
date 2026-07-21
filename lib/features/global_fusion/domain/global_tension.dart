import 'global_lens_id.dart';

/// Cross-mirror divergence on a curated theme pair (GF-F1).
class GlobalTension {
  const GlobalTension({
    required this.id,
    required this.primaryThemeId,
    required this.secondaryThemeId,
    required this.supportingMirrors,
    required this.reason,
  });

  final String id;
  final String primaryThemeId;
  final String secondaryThemeId;
  final List<GlobalLensId> supportingMirrors;
  final String reason;

  static String idForPair(String themeA, String themeB) {
    final sorted = [themeA, themeB]..sort();
    return 'tension:${sorted[0]}:${sorted[1]}';
  }
}
