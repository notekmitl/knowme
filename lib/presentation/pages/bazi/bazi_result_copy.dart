import 'package:knowme/data/models/bazi_chart_model.dart';

abstract final class BaziResultCopy {
  static String pageTitle(String lang) =>
      lang == 'th' ? 'มุมมองจากปาจื้อ' : 'BaZi Lens';

  static String heroSubtitle(String lang) =>
      lang == 'th' ? 'แกนตัวตน (Day Master)' : 'Day Master';

  static String bigThreeTitle(String lang) =>
      lang == 'th' ? 'Chinese Big 3' : 'Chinese Big 3';

  static String fourPillarsTitle(String lang) =>
      lang == 'th' ? '四柱 · Four Pillars' : 'Four Pillars';

  static String elementBalanceTitle(String lang) =>
      lang == 'th' ? 'ธาตุทั้งห้า · Element Balance' : 'Element Balance';

  static String metadataTitle(String lang) =>
      lang == 'th' ? 'รายละเอียดทางเทคนิค' : 'Technical details';

  static String metadataVersionLabel(String lang) =>
      lang == 'th' ? 'เวอร์ชันข้อมูล' : 'Data Version';

  static String metadataEngineLabel(String lang) =>
      lang == 'th' ? 'เวอร์ชันระบบคำนวณ' : 'Engine Version';

  static String metadataGeneratedAtLabel(String lang) =>
      lang == 'th' ? 'วันที่สร้างผลลัพธ์' : 'Generated At';

  static String coreSelfTitle(String lang) =>
      lang == 'th' ? 'แก่นในตัวคุณ' : 'Core Self';

  static String strengthsTitle(String lang) =>
      lang == 'th' ? 'จุดแข็งที่มักเห็นในตัวคุณ' : 'Strengths';

  static String growthAreasTitle(String lang) =>
      lang == 'th' ? 'มุมที่อาจอยากสังเกต' : 'Growth Areas';

  static String summaryCardTitle(String lang) =>
      lang == 'th' ? 'ภาพรวมจากมุมมองดวงจีน' : 'Overall Chinese Lens Summary';

  static String detailedDataTitle(String lang) =>
      lang == 'th' ? 'ข้อมูลเชิงลึก' : 'In-depth data';

  static String dominantHighlightTitle(String lang) =>
      lang == 'th' ? 'สิ่งที่โดดเด่นในดวงนี้' : 'Chart emphasis';

  static String chineseTraditionLabel(String lang) =>
      lang == 'th' ? 'ในศาสตร์จีน' : 'In Chinese tradition';

  static String chineseElementAssociation(String lang) =>
      lang == 'th'
          ? 'ธาตุนี้มักเกี่ยวข้องกับ'
          : 'This element is often associated with';

  static String dayMasterLabel(String lang) =>
      lang == 'th' ? 'Day Master' : 'Day Master';

  static String yearAnimalLabel(String lang) =>
      lang == 'th' ? 'Year Animal' : 'Year Animal';

  static String dominantElementLabel(String lang) =>
      lang == 'th' ? 'Dominant Element' : 'Dominant Element';

  static String pillarRole(String role, String lang) {
    if (lang == 'th') {
      return switch (role) {
        'year' => '年 · ปี',
        'month' => '月 · เดือน',
        'day' => '日 · วัน',
        'hour' => '时 · ชั่วโมง',
        _ => role,
      };
    }
    return switch (role) {
      'year' => 'Year',
      'month' => 'Month',
      'day' => 'Day',
      'hour' => 'Hour',
      _ => role,
    };
  }

  static String dayMasterTitle(BaziDayMaster dm, String lang) {
    final polarity = polarityLabel(dm.polarity, lang);
    final element = elementLabel(dm.element, lang);
    return '$polarity $element';
  }

  static String polarityLabel(String polarity, String lang) {
    if (lang == 'th') {
      return polarity == 'yang' ? 'หยาง' : 'หยิน';
    }
    return polarity == 'yang' ? 'Yang' : 'Yin';
  }

  static String elementLabel(String element, String lang) {
    if (lang == 'th') {
      return switch (element) {
        'wood' => 'ไม้',
        'fire' => 'ไฟ',
        'earth' => 'ดิน',
        'metal' => 'ทอง',
        'water' => 'น้ำ',
        _ => element,
      };
    }
    return switch (element) {
      'wood' => 'Wood',
      'fire' => 'Fire',
      'earth' => 'Earth',
      'metal' => 'Metal',
      'water' => 'Water',
      _ => element,
    };
  }

  static String emptyMessage(String lang) => lang == 'th'
      ? 'ยังไม่มีข้อมูล BaZi สำหรับบัญชีนี้'
      : 'No BaZi chart saved for this account yet.';

  static String errorTitle(String lang) =>
      lang == 'th' ? 'โหลดข้อมูลไม่สำเร็จ' : 'Could not load BaZi chart';

  static String disclosure(String lang) => lang == 'th'
      ? 'นี่เป็นมุมมองหนึ่งจากปาจื้อ ไม่ใช่ข้อสรุปสุดท้ายเกี่ยวกับตัวคุณ'
      : 'This is one BaZi perspective — not a final verdict about you.';

  static String zodiacPersonalityTitle(String lang) =>
      lang == 'th' ? 'บุคลิกจากปีนักษัตร' : 'Year Zodiac Personality';

  static String zodiacCoreTraitsTitle(String lang) =>
      lang == 'th' ? 'ลักษณะเด่น' : 'Core Traits';

  static String zodiacWorkStyleTitle(String lang) =>
      lang == 'th' ? 'รูปแบบการทำงาน' : 'Work Style';

  static String zodiacRelationshipStyleTitle(String lang) =>
      lang == 'th' ? 'รูปแบบความสัมพันธ์' : 'Relationship Style';

  static String zodiacStrengthsTitle(String lang) =>
      lang == 'th' ? 'จุดแข็ง' : 'Strengths';

  static String zodiacChallengesTitle(String lang) =>
      lang == 'th' ? 'จุดที่ควรระวัง' : 'Challenges';

  static String zodiacGrowthSuggestionsTitle(String lang) =>
      lang == 'th' ? 'แนวทางเติบโต' : 'Growth Suggestions';
}
