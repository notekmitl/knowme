import 'package:knowme/domain/models/personality_profile.dart';
import 'package:knowme/domain/models/personality_archetype.dart';

class ArchetypeService {
  static PersonalityArchetype detect(PersonalityProfile profile) {
    /// Visionary
    if ((profile.traits["openness"] ?? 0) > 4 &&
        (profile.traits["growth"] ?? 0) > 4) {
      return PersonalityArchetype(
        id: "visionary",
        icon: "🔮",
        name: {"en": "The Visionary", "th": "นักมองการณ์ไกล"},
        description: {
          "en": "Creative and future-oriented thinker.",
          "th": "นักคิดสร้างสรรค์ที่มองเห็นอนาคต",
        },
      );
    }

    /// Strategic Empath
    if ((profile.traits["agreeableness"] ?? 0) > 4 &&
        (profile.traits["empathy"] ?? 0) > 4) {
      return PersonalityArchetype(
        id: "strategic_empath",
        icon: "🤝",
        name: {"en": "Strategic Empath", "th": "นักเข้าใจผู้อื่นเชิงกลยุทธ์"},
        description: {
          "en": "Understands people deeply and builds strong relationships.",
          "th": "เข้าใจผู้อื่นลึกซึ้งและสร้างความสัมพันธ์ที่แข็งแรง",
        },
      );
    }

    /// Insightful Analyst
    if ((profile.traits["awareness"] ?? 0) > 4 &&
        (profile.traits["openness"] ?? 0) > 3.5) {
      return PersonalityArchetype(
        id: "analyst",
        icon: "🧠",
        name: {"en": "Insightful Analyst", "th": "นักวิเคราะห์เชิงลึก"},
        description: {
          "en": "Analytical thinker who enjoys solving complex problems.",
          "th": "นักคิดวิเคราะห์ที่ชอบแก้ปัญหาที่ซับซ้อน",
        },
      );
    }

    /// Driven Achiever
    if ((profile.traits["achievement"] ?? 0) > 4) {
      return PersonalityArchetype(
        id: "achiever",
        icon: "🏆",
        name: {"en": "Driven Achiever", "th": "นักพิชิตเป้าหมาย"},
        description: {
          "en": "Highly motivated and goal-oriented.",
          "th": "มีแรงผลักดันสูงและมุ่งมั่นสู่ความสำเร็จ",
        },
      );
    }

    /// Default
    return PersonalityArchetype(
      id: "balanced",
      icon: "🌱",
      name: {"en": "Balanced Explorer", "th": "นักสำรวจสมดุล"},
      description: {
        "en": "Balanced personality with adaptability.",
        "th": "บุคลิกสมดุลและปรับตัวเก่ง",
      },
    );
  }
}
