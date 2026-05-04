import '../../../domain/models/personality/eq_trait_profile.dart';

final Map<String, EqTraitProfile> eqTraits = {
  "self_awareness": EqTraitProfile(
    name: {"en": "Self Awareness", "th": "การตระหนักรู้ในตนเอง"},

    description: {
      "en": "The ability to recognize and understand your own emotions.",

      "th": "ความสามารถในการรับรู้และเข้าใจอารมณ์ของตนเอง",
    },
  ),

  // ------------------------------------------------------
  "self_regulation": EqTraitProfile(
    name: {"en": "Self Regulation", "th": "การควบคุมอารมณ์"},

    description: {
      "en": "The ability to manage emotional reactions effectively.",

      "th": "ความสามารถในการควบคุมและจัดการอารมณ์ของตนเอง",
    },
  ),

  // ------------------------------------------------------
  "empathy": EqTraitProfile(
    name: {"en": "Empathy", "th": "ความเห็นอกเห็นใจ"},

    description: {
      "en": "The ability to understand and share the feelings of others.",

      "th": "ความสามารถในการเข้าใจและรับรู้ความรู้สึกของผู้อื่น",
    },
  ),

  // ------------------------------------------------------
  "social_skills": EqTraitProfile(
    name: {"en": "Social Skills", "th": "ทักษะทางสังคม"},

    description: {
      "en": "The ability to build and maintain healthy relationships.",

      "th": "ความสามารถในการสร้างและรักษาความสัมพันธ์",
    },
  ),
};
