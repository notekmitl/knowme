import 'thai_mirror_lens_source.dart';

/// One traceable content contribution supporting Mirror themes in a section.
///
/// Every item must map to a published content key from the Thai Content Library.
/// Assembly must not invent lens sources or keys.
class ThaiMirrorEvidence {
  const ThaiMirrorEvidence({
    required this.lensSource,
    required this.contentKey,
    required this.contribution,
    this.contentTitle,
    this.supportedThemeIds = const [],
  });

  final ThaiMirrorLensSource lensSource;

  /// Canonical key from [ThaiContentKeys] / [ThaiContentRegistry].
  final String contentKey;

  /// Human-readable title from content section (optional until assembly).
  final String? contentTitle;

  /// Weighted contribution to theme aggregation for this evidence row.
  final double contribution;

  /// Theme ids this content row supports within the parent section.
  final List<String> supportedThemeIds;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorEvidence &&
        other.lensSource == lensSource &&
        other.contentKey == contentKey &&
        other.contentTitle == contentTitle &&
        other.contribution == contribution &&
        _listEquals(other.supportedThemeIds, supportedThemeIds);
  }

  @override
  int get hashCode => Object.hash(
        lensSource,
        contentKey,
        contentTitle,
        contribution,
        Object.hashAll(supportedThemeIds),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
