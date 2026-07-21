import '../../models/thai_mirror_section_id.dart';

/// Fusion section card view state for Thai Mirror Result Page.
class ThaiMirrorSectionCardState {
  const ThaiMirrorSectionCardState({
    required this.id,
    required this.titleTh,
    required this.titleEn,
    required this.summary,
    required this.themeChips,
    required this.evidenceCount,
    required this.isExpandedDefault,
  });

  final ThaiMirrorSectionId id;
  final String titleTh;
  final String titleEn;
  final String? summary;
  final List<String> themeChips;
  final int evidenceCount;
  final bool isExpandedDefault;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorSectionCardState &&
        other.id == id &&
        other.titleTh == titleTh &&
        other.titleEn == titleEn &&
        other.summary == summary &&
        other.evidenceCount == evidenceCount &&
        other.isExpandedDefault == isExpandedDefault &&
        _listEquals(other.themeChips, themeChips);
  }

  @override
  int get hashCode => Object.hash(
        id,
        titleTh,
        titleEn,
        summary,
        evidenceCount,
        isExpandedDefault,
        Object.hashAll(themeChips),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
