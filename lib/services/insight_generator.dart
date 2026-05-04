import 'package:knowme/domain/models/personality_profile.dart';

class InsightGenerator {
  static List<String> generate(PersonalityProfile profile) {
    List<String> insights = [];

    if ((profile.traits["openness"] ?? 0) > 70) {
      insights.add("คุณเป็นคนเปิดรับสิ่งใหม่และมีความคิดสร้างสรรค์สูง");
    }

    if ((profile.traits["extraversion"] ?? 0) > 70) {
      insights.add("คุณได้รับพลังจากการอยู่กับผู้คนและการเข้าสังคม");
    }

    if ((profile.traits["agreeableness"] ?? 0) > 70) {
      insights.add("คุณเป็นคนเข้าใจผู้อื่นและมีความเห็นอกเห็นใจสูง");
    }

    if ((profile.traits["neuroticism"] ?? 0) > 60) {
      insights.add("คุณอาจไวต่อความเครียดและอารมณ์ได้ง่าย");
    }

    if ((profile.traits["empathy"] ?? 0) > 70) {
      insights.add("คุณมีความสามารถในการเข้าใจอารมณ์ของผู้อื่นได้ดี");
    }

    if ((profile.traits["secure"] ?? 0) > (profile.traits["anxious"] ?? 0) &&
        (profile.traits["secure"] ?? 0) > (profile.traits["avoidant"] ?? 0)) {
      insights.add("รูปแบบความสัมพันธ์ของคุณมีแนวโน้มแบบ Secure");
    }

    if ((profile.traits["growth"] ?? 0) > 70) {
      insights.add("คุณมีแรงขับในการพัฒนาตัวเองและเติบโตอยู่เสมอ");
    }

    if ((profile.traits["element"] ?? 0) == "fire") {
      insights.add("ธาตุไฟในดวงของคุณบ่งบอกถึงพลัง ความกล้า และความเป็นผู้นำ");
    }

    if ((profile.traits["element"] ?? 0) == "air") {
      insights.add("ธาตุลมทำให้คุณเป็นคนคิดวิเคราะห์เก่งและชอบการสื่อสาร");
    }

    return insights;
  }
}
