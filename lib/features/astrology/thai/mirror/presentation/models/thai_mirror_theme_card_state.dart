/// Top theme card view state for Thai Mirror Result Page.
class ThaiMirrorThemeCardState {
  const ThaiMirrorThemeCardState({
    required this.rank,
    required this.themeId,
    required this.themeName,
    required this.description,
    required this.confidenceLabel,
    required this.evidenceCount,
  });

  final int rank;
  final String themeId;
  final String themeName;
  final String? description;
  final String confidenceLabel;
  final int evidenceCount;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorThemeCardState &&
        other.rank == rank &&
        other.themeId == themeId &&
        other.themeName == themeName &&
        other.description == description &&
        other.confidenceLabel == confidenceLabel &&
        other.evidenceCount == evidenceCount;
  }

  @override
  int get hashCode => Object.hash(
        rank,
        themeId,
        themeName,
        description,
        confidenceLabel,
        evidenceCount,
      );
}
