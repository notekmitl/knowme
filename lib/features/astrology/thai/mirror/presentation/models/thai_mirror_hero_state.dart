/// Hero section view state for Thai Mirror Result Page.
class ThaiMirrorHeroState {
  const ThaiMirrorHeroState({
    required this.titleTh,
    required this.titleEn,
    required this.reflectionSummary,
    required this.topThemeNames,
  });

  static const defaultTitleTh = 'กระจกสะท้อนตัวตน';
  static const defaultTitleEn = 'Your Thai Mirror';
  static const fallbackReflectionSummary =
      'กระจกนี้สะท้อนรูปแบบบางส่วนจากข้อมูลเกิดของคุณ';

  final String titleTh;
  final String titleEn;
  final String reflectionSummary;
  final List<String> topThemeNames;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorHeroState &&
        other.titleTh == titleTh &&
        other.titleEn == titleEn &&
        other.reflectionSummary == reflectionSummary &&
        _listEquals(other.topThemeNames, topThemeNames);
  }

  @override
  int get hashCode => Object.hash(
        titleTh,
        titleEn,
        reflectionSummary,
        Object.hashAll(topThemeNames),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
