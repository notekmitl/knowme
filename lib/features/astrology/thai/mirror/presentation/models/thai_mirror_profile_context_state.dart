/// Profile context banner view state for Thai Mirror Result Page.
class ThaiMirrorProfileContextState {
  const ThaiMirrorProfileContextState({
    required this.hasBirthTime,
    required this.warningMessages,
    required this.calculationStandardVersion,
  });

  static const empty = ThaiMirrorProfileContextState(
    hasBirthTime: true,
    warningMessages: [],
    calculationStandardVersion: 'v1.1',
  );

  final bool hasBirthTime;
  final List<String> warningMessages;
  final String calculationStandardVersion;

  bool get hasWarnings => warningMessages.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorProfileContextState &&
        other.hasBirthTime == hasBirthTime &&
        other.calculationStandardVersion == calculationStandardVersion &&
        _listEquals(other.warningMessages, warningMessages);
  }

  @override
  int get hashCode => Object.hash(
        hasBirthTime,
        calculationStandardVersion,
        Object.hashAll(warningMessages),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
