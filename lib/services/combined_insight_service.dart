import 'package:knowme/astrology/models/astrology_result.dart';
import 'package:knowme/domain/models/personality_core_result.dart';

class CombinedInsightService {
  static String generate({
    required AstrologyResult astrology,
    required PersonalityCoreResult personality,
  }) {
    final insights = <String>[];

    /// Example rule 1
    if (astrology.sunSign == "Leo" && personality.extraversion < 40) {
      insights.add(
        "แม้ว่าพลังของ Leo จะทำให้คุณดูมั่นใจและโดดเด่น "
        "แต่บุคลิกภายในของคุณกลับเป็นคนที่ชอบพื้นที่ส่วนตัว "
        "คุณจึงมักเลือกแสดงตัวเฉพาะในสถานการณ์ที่มีความหมายจริง ๆ",
      );
    }

    /// Example rule 2
    if (astrology.element == "Fire" && personality.openness > 70) {
      insights.add(
        "พลังของธาตุไฟทำให้คุณมีแรงผลักดันสูง "
        "และเมื่อรวมกับความเปิดกว้างทางความคิด "
        "คุณจึงเป็นคนที่สามารถสร้างไอเดียใหม่ ๆ ได้ดี",
      );
    }

    /// Example rule 3
    if (personality.neuroticism > 70) {
      insights.add(
        "คุณเป็นคนที่รับรู้อารมณ์ได้ลึก "
        "ทำให้คุณมีความเข้าใจในความรู้สึกของตัวเองและผู้อื่นได้ดี",
      );
    }

    if (insights.isEmpty) {
      insights.add(
        "บุคลิกภาพและพลังดวงของคุณอยู่ในสมดุลที่ดี "
        "คุณสามารถปรับตัวกับสถานการณ์ต่าง ๆ ได้ค่อนข้างดี",
      );
    }

    return insights.join("\n\n");
  }
}
