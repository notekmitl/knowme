import 'package:knowme/domain/models/compatibility_result.dart';
import 'package:knowme/domain/models/personality_core_result.dart';
import '../astrology/models/astrology_result.dart';

class CompatibilityService {
  static CompatibilityResult calculate({
    required PersonalityCoreResult you,
    required PersonalityCoreResult partner,
    required AstrologyResult yourAstro,
    required AstrologyResult partnerAstro,
  }) {
    double score = 50;
    List<String> reasons = [];

    /// Personality match
    double diffExtraversion = (you.extraversion - partner.extraversion).abs();

    if (diffExtraversion < 20) {
      score += 10;
      reasons.add("คุณทั้งสองมีระดับการเข้าสังคมใกล้เคียงกัน");
    }

    /// Agreeableness
    if (you.agreeableness > 60 && partner.agreeableness > 60) {
      score += 10;
      reasons.add("คุณทั้งคู่มีความเข้าใจผู้อื่นสูง");
    }

    /// Element compatibility
    if (yourAstro.element == partnerAstro.element) {
      score += 10;
      reasons.add("ธาตุดวงของคุณทั้งสองสอดคล้องกัน");
    }

    /// Emotional balance
    double diffNeuro = (you.neuroticism - partner.neuroticism).abs();

    if (diffNeuro < 20) {
      score += 10;
      reasons.add("ระดับอารมณ์ของคุณทั้งสองใกล้เคียงกัน");
    }

    score = score.clamp(0, 100);

    return CompatibilityResult(score: score, reasons: reasons);
  }
}
