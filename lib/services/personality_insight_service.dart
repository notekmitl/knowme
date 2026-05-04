import 'package:knowme/domain/models/personality_core_result.dart';

class PersonalityInsightService {
  static String generateInsight(PersonalityCoreResult result) {
    final insights = <String>[];

    if (result.openness > 70) {
      insights.add("คุณเป็นคนเปิดรับสิ่งใหม่ ๆ และมีความคิดสร้างสรรค์สูง");
    } else if (result.openness < 40) {
      insights.add(
        "คุณเป็นคนที่ชอบความชัดเจนและสิ่งที่คุ้นเคยมากกว่าการเปลี่ยนแปลง",
      );
    }

    if (result.conscientiousness > 70) {
      insights.add("คุณเป็นคนมีวินัยและสามารถจัดการเป้าหมายในชีวิตได้ดี");
    } else if (result.conscientiousness < 40) {
      insights.add(
        "คุณเป็นคนที่ชอบความยืดหยุ่นและไม่ชอบกรอบที่ตายตัวมากเกินไป",
      );
    }

    if (result.extraversion > 70) {
      insights.add("คุณได้รับพลังจากการอยู่กับผู้คนและการเข้าสังคม");
    } else if (result.extraversion < 40) {
      insights.add("คุณเป็นคนที่ชอบใช้เวลาอยู่กับตัวเองและคิดอย่างลึกซึ้ง");
    }

    if (result.agreeableness > 70) {
      insights.add("คุณเป็นคนที่เข้าใจผู้อื่นและมีความเห็นอกเห็นใจสูง");
    }

    if (result.neuroticism > 70) {
      insights.add("คุณเป็นคนที่รับรู้อารมณ์ได้ลึกและไวต่อความรู้สึก");
    }

    return insights.join("\n\n");
  }
}
