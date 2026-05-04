import '../../../domain/models/personality/bigfive_trait_profile.dart';

final Map<String, BigFiveTraitProfile> bigFiveTraits = {
  "extraversion": BigFiveTraitProfile(
    name: {"en": "Extraversion", "th": "การเข้าสังคม"},

    high: {
      "en":
          "You tend to feel energized by social interaction and enjoy engaging with people.",

      "th": "คุณมักรู้สึกมีพลังเมื่อได้พบปะผู้คน และสนุกกับการเข้าสังคม",
    },

    medium: {
      "en": "You balance social interaction and personal time comfortably.",

      "th": "คุณสามารถสมดุลระหว่างการเข้าสังคมและเวลาส่วนตัวได้ดี",
    },

    low: {
      "en":
          "You may prefer quiet environments and spending time alone to recharge.",

      "th": "คุณอาจชอบสภาพแวดล้อมที่สงบ และใช้เวลาคนเดียวเพื่อเติมพลัง",
    },
  ),

  // ------------------------------------------------------
  "agreeableness": BigFiveTraitProfile(
    name: {"en": "Agreeableness", "th": "ความเป็นมิตร"},

    high: {
      "en":
          "You are compassionate and cooperative, often prioritizing harmony with others.",

      "th": "คุณเป็นคนเห็นอกเห็นใจและให้ความสำคัญกับความสัมพันธ์กับผู้อื่น",
    },

    medium: {
      "en":
          "You balance empathy with practicality when interacting with others.",

      "th": "คุณสามารถสมดุลระหว่างความเห็นอกเห็นใจและเหตุผลได้ดี",
    },

    low: {
      "en": "You may prioritize logic and honesty over maintaining harmony.",

      "th":
          "คุณอาจให้ความสำคัญกับเหตุผลและความจริงมากกว่าการรักษาความกลมเกลียว",
    },
  ),

  // ------------------------------------------------------
  "conscientiousness": BigFiveTraitProfile(
    name: {"en": "Conscientiousness", "th": "ความมีวินัย"},

    high: {
      "en": "You are organized, disciplined, and focused on achieving goals.",

      "th": "คุณเป็นคนมีระเบียบ มีวินัย และมุ่งมั่นกับเป้าหมาย",
    },

    medium: {
      "en": "You balance planning with flexibility.",

      "th": "คุณสามารถวางแผนและปรับตัวได้ตามสถานการณ์",
    },

    low: {
      "en": "You may prefer spontaneity over strict structure.",

      "th": "คุณอาจชอบความยืดหยุ่นมากกว่าการวางแผนที่เข้มงวด",
    },
  ),

  // ------------------------------------------------------
  "neuroticism": BigFiveTraitProfile(
    name: {"en": "Emotional Stability", "th": "ความมั่นคงทางอารมณ์"},

    high: {
      "en":
          "You may experience emotions intensely and react strongly to stress.",

      "th": "คุณอาจรู้สึกกับอารมณ์อย่างลึก และตอบสนองต่อความเครียดได้มาก",
    },

    medium: {
      "en":
          "You generally manage stress well but may occasionally feel overwhelmed.",

      "th": "โดยทั่วไปคุณจัดการความเครียดได้ดี แม้บางครั้งอาจรู้สึกกดดัน",
    },

    low: {
      "en": "You tend to stay calm and emotionally stable in most situations.",

      "th": "คุณมักสงบและมีความมั่นคงทางอารมณ์ในสถานการณ์ส่วนใหญ่",
    },
  ),

  // ------------------------------------------------------
  "openness": BigFiveTraitProfile(
    name: {"en": "Openness", "th": "การเปิดรับประสบการณ์"},

    high: {
      "en":
          "You enjoy exploring new ideas, creativity, and intellectual curiosity.",

      "th": "คุณชอบสำรวจแนวคิดใหม่ ๆ มีความคิดสร้างสรรค์ และอยากรู้อยากเห็น",
    },

    medium: {
      "en":
          "You appreciate new ideas while still valuing practical approaches.",

      "th": "คุณเปิดรับไอเดียใหม่ แต่ยังคงให้ความสำคัญกับความเป็นจริง",
    },

    low: {
      "en": "You prefer familiarity, tradition, and practical solutions.",

      "th": "คุณมักชอบสิ่งที่คุ้นเคย ประเพณี และวิธีแก้ปัญหาที่ใช้ได้จริง",
    },
  ),
};
