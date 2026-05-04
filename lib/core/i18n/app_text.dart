class AppText {
  static String lang = "th";

  static const Map<String, Map<String, String>> text = {
    /// =========================
    /// GENERAL
    /// =========================
    "personality_tests": {"en": "Personality Tests", "th": "แบบทดสอบบุคลิกภาพ"},

    "start_test": {"en": "Start Test", "th": "เริ่มทำแบบทดสอบ"},

    "questions": {"en": "Questions", "th": "คำถาม"},

    "no_questions": {
      "en": "No questions available for this test",
      "th": "ยังไม่มีคำถามในแบบทดสอบนี้",
    },

    /// =========================
    /// RESULT PAGE
    /// =========================
    "result_title": {"en": "Your Personality", "th": "ผลลัพธ์บุคลิกภาพของคุณ"},

    "traits": {"en": "Personality Traits", "th": "ลักษณะบุคลิกภาพ"},

    "insights": {"en": "Personality Insights", "th": "การวิเคราะห์บุคลิก"},

    "your_type": {"en": "Your Type", "th": "ประเภทบุคลิกของคุณ"},

    "improve_accuracy": {
      "en": "Complete more tests to improve accuracy",
      "th": "ทำแบบทดสอบเพิ่มเติมเพื่อเพิ่มความแม่นยำ",
    },

    /// =========================
    /// PROFILE PAGE
    /// =========================
    "profile_title": {"en": "Personality Profile", "th": "โปรไฟล์บุคลิกภาพ"},

    "personality_analysis": {
      "en": "Personality Analysis",
      "th": "การวิเคราะห์บุคลิกของคุณ",
    },

    /// =========================
    /// TEST CATEGORIES
    /// =========================
    "category_bigfive": {
      "en": "Big Five Personality",
      "th": "บุคลิกภาพ Big Five",
    },

    "category_eq": {
      "en": "Emotional Intelligence",
      "th": "ความฉลาดทางอารมณ์ (EQ)",
    },

    "category_mbti": {"en": "MBTI Personality Type", "th": "บุคลิกภาพแบบ MBTI"},

    /// =========================
    /// BIG FIVE TESTS
    /// =========================
    "bigfive_mini": {
      "en": "Quick Personality Test",
      "th": "แบบทดสอบบุคลิกภาพแบบสั้น",
    },

    "bigfive_short": {
      "en": "Standard Personality Test",
      "th": "แบบทดสอบบุคลิกภาพมาตรฐาน",
    },

    "bigfive_accurate": {
      "en": "In-Depth Personality Test",
      "th": "แบบทดสอบบุคลิกภาพแบบละเอียด",
    },

    /// =========================
    /// BIG FIVE TRAITS
    /// =========================
    "openness": {"en": "Openness", "th": "การเปิดรับประสบการณ์"},

    "conscientiousness": {
      "en": "Conscientiousness",
      "th": "ความมีวินัยและความรับผิดชอบ",
    },

    "extraversion": {"en": "Extraversion", "th": "การเข้าสังคม"},

    "agreeableness": {"en": "Agreeableness", "th": "ความเห็นอกเห็นใจผู้อื่น"},

    "neuroticism": {
      "en": "Emotional Sensitivity",
      "th": "ความอ่อนไหวทางอารมณ์",
    },

    /// =========================
    /// EQ TESTS
    /// =========================
    "eq_awareness": {
      "en": "Understanding Your Emotions",
      "th": "การเข้าใจอารมณ์ของตัวเอง",
    },

    "eq_regulation": {
      "en": "Managing Your Emotions",
      "th": "การควบคุมอารมณ์ของตัวเอง",
    },

    "eq_empathy": {
      "en": "Understanding Others",
      "th": "การเข้าใจความรู้สึกของผู้อื่น",
    },

    "eq_social": {"en": "Social Skills", "th": "ทักษะการเข้าสังคม"},

    "eq_stress": {"en": "Handling Stress", "th": "การรับมือกับความเครียด"},

    "eq_decision": {
      "en": "Emotion & Decision Making",
      "th": "การตัดสินใจภายใต้อารมณ์",
    },

    /// =========================
    /// MBTI TESTS
    /// =========================
    "mbti_mini": {"en": "Quick MBTI Test", "th": "MBTI แบบสั้น"},

    "mbti_short": {"en": "Standard MBTI Test", "th": "MBTI มาตรฐาน"},

    "mbti_accurate": {"en": "Advanced MBTI Test", "th": "MBTI แบบละเอียด"},

    /// =========================
    /// ATTACHMENT
    /// =========================
    "attachment": {"en": "Attachment Style", "th": "รูปแบบความสัมพันธ์"},

    "secure": {"en": "Secure", "th": "ความสัมพันธ์แบบมั่นคง"},

    "anxious": {"en": "Anxious", "th": "ความสัมพันธ์แบบกังวล"},

    "avoidant": {"en": "Avoidant", "th": "ความสัมพันธ์แบบหลีกเลี่ยง"},

    /// =========================
    /// MOTIVATION
    /// =========================
    "motivation": {"en": "Life Motivation", "th": "แรงจูงใจในชีวิต"},

    "growth": {"en": "Growth", "th": "การพัฒนาตัวเอง"},

    "achievement": {"en": "Achievement", "th": "ความสำเร็จ"},

    "purpose": {"en": "Purpose", "th": "เป้าหมายชีวิต"},
  };

  static String t(String key) {
    return text[key]?[lang] ?? text[key]?["en"] ?? key;
  }
}
