// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'KnowMe';

  @override
  String get mbti_p1_q1 => 'You feel energized after being around people';

  @override
  String get mbti_p1_q2 => 'You prefer being alone';

  @override
  String get mbti_option_strongly_agree => 'Strongly Agree';

  @override
  String get mbti_option_agree => 'Agree';

  @override
  String get mbti_option_neutral => 'Neutral';

  @override
  String get mbti_option_disagree => 'Disagree';

  @override
  String get mbti_option_strongly_disagree => 'Strongly Disagree';
}
