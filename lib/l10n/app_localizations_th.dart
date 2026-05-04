// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get app_title => 'KnowMe';

  @override
  String get mbti_p1_q1 => 'คุณรู้สึกมีพลังหลังจากอยู่กับคนเยอะ ๆ';

  @override
  String get mbti_p1_q2 => 'คุณชอบอยู่คนเดียว';

  @override
  String get mbti_option_strongly_agree => 'เห็นด้วยมาก';

  @override
  String get mbti_option_agree => 'เห็นด้วย';

  @override
  String get mbti_option_neutral => 'เฉย ๆ';

  @override
  String get mbti_option_disagree => 'ไม่เห็นด้วย';

  @override
  String get mbti_option_strongly_disagree => 'ไม่เห็นด้วยมาก';
}
