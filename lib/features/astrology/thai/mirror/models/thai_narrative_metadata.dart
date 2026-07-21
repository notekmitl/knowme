import 'thai_mirror_section_id.dart';

/// Traceability metadata for a generated section summary.
class ThaiNarrativeMetadata {
  const ThaiNarrativeMetadata({
    required this.sectionId,
    required this.themeIdsUsed,
    required this.contentKeysUsed,
  });

  final ThaiMirrorSectionId sectionId;
  final List<String> themeIdsUsed;
  final List<String> contentKeysUsed;

  @override
  bool operator ==(Object other) {
    return other is ThaiNarrativeMetadata &&
        other.sectionId == sectionId &&
        _listEquals(other.themeIdsUsed, themeIdsUsed) &&
        _listEquals(other.contentKeysUsed, contentKeysUsed);
  }

  @override
  int get hashCode => Object.hash(
        sectionId,
        Object.hashAll(themeIdsUsed),
        Object.hashAll(contentKeysUsed),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
