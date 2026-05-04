import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

final List<TestQuestion> tipiQuestions = [
  /// EXTRAVERSION
  TestQuestion(
    id: "TIPI1",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as extraverted, enthusiastic",
      "th": "ฉันเป็นคนเปิดเผย ชอบเข้าสังคม และมีความกระตือรือร้น",
    },
    trait: "extraversion",
    reverse: false,
  ),

  /// AGREEABLENESS
  TestQuestion(
    id: "TIPI2",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as critical, quarrelsome",
      "th": "ฉันมักวิจารณ์หรือโต้เถียงกับผู้อื่น",
    },
    trait: "agreeableness",
    reverse: true,
  ),

  /// CONSCIENTIOUSNESS
  TestQuestion(
    id: "TIPI3",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as dependable, self-disciplined",
      "th": "ฉันเป็นคนมีความรับผิดชอบและมีวินัยในตัวเอง",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  /// NEUROTICISM
  TestQuestion(
    id: "TIPI4",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as anxious, easily upset",
      "th": "ฉันเป็นคนกังวลง่ายและอารมณ์เสียได้ง่าย",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  /// OPENNESS
  TestQuestion(
    id: "TIPI5",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as open to new experiences",
      "th": "ฉันเปิดรับประสบการณ์และสิ่งใหม่ ๆ",
    },
    trait: "openness",
    reverse: false,
  ),

  /// EXTRAVERSION (reverse)
  TestQuestion(
    id: "TIPI6",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as reserved, quiet",
      "th": "ฉันเป็นคนเงียบ ๆ และค่อนข้างเก็บตัว",
    },
    trait: "extraversion",
    reverse: true,
  ),

  /// AGREEABLENESS
  TestQuestion(
    id: "TIPI7",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as sympathetic, warm",
      "th": "ฉันเป็นคนอบอุ่น เห็นอกเห็นใจ และเข้าใจผู้อื่น",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  /// CONSCIENTIOUSNESS
  TestQuestion(
    id: "TIPI8",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as disorganized, careless",
      "th": "ฉันมักจัดการสิ่งต่าง ๆ ไม่เป็นระเบียบหรือค่อนข้างสะเพร่า",
    },
    trait: "conscientiousness",
    reverse: true,
  ),

  /// NEUROTICISM
  TestQuestion(
    id: "TIPI9",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as calm, emotionally stable",
      "th": "ฉันเป็นคนสงบและควบคุมอารมณ์ได้ดี",
    },
    trait: "neuroticism",
    reverse: true,
  ),

  /// OPENNESS
  TestQuestion(
    id: "TIPI10",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as conventional, uncreative",
      "th": "ฉันเป็นคนคิดแบบเดิม ๆ ไม่ค่อยสร้างสรรค์",
    },
    trait: "openness",
    reverse: true,
  ),
];
