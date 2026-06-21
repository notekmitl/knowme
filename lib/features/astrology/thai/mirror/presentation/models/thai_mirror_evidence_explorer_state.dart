import '../../models/thai_mirror_lens_source.dart';

/// One evidence row in the Evidence Explorer.
class ThaiMirrorEvidenceRowState {
  const ThaiMirrorEvidenceRowState({
    required this.lensSource,
    required this.lensLabelTh,
    required this.contentKey,
    required this.contentTitle,
    required this.supportedThemeIds,
    required this.sectionIdLabel,
  });

  final ThaiMirrorLensSource lensSource;
  final String lensLabelTh;
  final String contentKey;
  final String? contentTitle;
  final List<String> supportedThemeIds;

  /// Section title (TH) where this evidence row originated.
  final String sectionIdLabel;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorEvidenceRowState &&
        other.lensSource == lensSource &&
        other.lensLabelTh == lensLabelTh &&
        other.contentKey == contentKey &&
        other.contentTitle == contentTitle &&
        other.sectionIdLabel == sectionIdLabel &&
        _listEquals(other.supportedThemeIds, supportedThemeIds);
  }

  @override
  int get hashCode => Object.hash(
        lensSource,
        lensLabelTh,
        contentKey,
        contentTitle,
        sectionIdLabel,
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

/// Aggregated evidence explorer view state.
class ThaiMirrorEvidenceExplorerState {
  const ThaiMirrorEvidenceExplorerState({
    required this.totalEvidenceCount,
    required this.lensCounts,
    required this.rows,
  });

  static const empty = ThaiMirrorEvidenceExplorerState(
    totalEvidenceCount: 0,
    lensCounts: {},
    rows: [],
  );

  final int totalEvidenceCount;
  final Map<ThaiMirrorLensSource, int> lensCounts;
  final List<ThaiMirrorEvidenceRowState> rows;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorEvidenceExplorerState &&
        other.totalEvidenceCount == totalEvidenceCount &&
        _mapEquals(other.lensCounts, lensCounts) &&
        _rowListEquals(other.rows, rows);
  }

  @override
  int get hashCode =>
      Object.hash(totalEvidenceCount, Object.hashAll(lensCounts.entries), Object.hashAll(rows));

  static bool _mapEquals(
    Map<ThaiMirrorLensSource, int> a,
    Map<ThaiMirrorLensSource, int> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  static bool _rowListEquals(
    List<ThaiMirrorEvidenceRowState> a,
    List<ThaiMirrorEvidenceRowState> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
