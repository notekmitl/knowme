import 'app_localizations.dart';

extension L10nExtension on AppLocalizations {
  String tr(String key) {
    switch (key) {
      case 'mbti_p1_q1':
        return this.mbti_p1_q1;

      case 'mbti_p1_q2':
        return this.mbti_p1_q2;

      case 'mbti_option_strongly_agree':
        return this.mbti_option_strongly_agree;

      case 'mbti_option_agree':
        return this.mbti_option_agree;

      case 'mbti_option_neutral':
        return this.mbti_option_neutral;

      case 'mbti_option_disagree':
        return this.mbti_option_disagree;

      case 'mbti_option_strongly_disagree':
        return this.mbti_option_strongly_disagree;

      default:
        return key;
    }
  }
}
