import 'package:knowme/domain/models/personality_question.dart';

const List<PersonalityQuestion> personalityQuestions = [
  // ===== OPENNESS =====
  PersonalityQuestion(id: "q1", text: "ฉันชอบลองสิ่งใหม่ ๆ", trait: "openness"),
  PersonalityQuestion(id: "q2", text: "ฉันมีจินตนาการสูง", trait: "openness"),
  PersonalityQuestion(
    id: "q3",
    text: "ฉันสนใจศิลปะหรือความคิดสร้างสรรค์",
    trait: "openness",
  ),
  PersonalityQuestion(
    id: "q4",
    text: "ฉันไม่ชอบการเปลี่ยนแปลง",
    trait: "openness",
    reverseScored: true,
  ),

  // ===== CONSCIENTIOUSNESS =====
  PersonalityQuestion(
    id: "q5",
    text: "ฉันวางแผนก่อนลงมือทำ",
    trait: "conscientiousness",
  ),
  PersonalityQuestion(
    id: "q6",
    text: "ฉันทำงานจนเสร็จแม้จะเบื่อ",
    trait: "conscientiousness",
  ),
  PersonalityQuestion(
    id: "q7",
    text: "ฉันเป็นคนจัดระเบียบ",
    trait: "conscientiousness",
  ),
  PersonalityQuestion(
    id: "q8",
    text: "ฉันทำงานตามอารมณ์มากกว่าตามแผน",
    trait: "conscientiousness",
    reverseScored: true,
  ),

  // ===== EXTRAVERSION =====
  PersonalityQuestion(
    id: "q9",
    text: "ฉันรู้สึกมีพลังเมื่ออยู่กับผู้คน",
    trait: "extraversion",
  ),
  PersonalityQuestion(
    id: "q10",
    text: "ฉันชอบเป็นจุดสนใจ",
    trait: "extraversion",
  ),
  PersonalityQuestion(
    id: "q11",
    text: "ฉันเริ่มบทสนทนาได้ง่าย",
    trait: "extraversion",
  ),
  PersonalityQuestion(
    id: "q12",
    text: "ฉันชอบอยู่เงียบ ๆ คนเดียว",
    trait: "extraversion",
    reverseScored: true,
  ),

  // ===== AGREEABLENESS =====
  PersonalityQuestion(
    id: "q13",
    text: "ฉันเห็นใจผู้อื่นได้ง่าย",
    trait: "agreeableness",
  ),
  PersonalityQuestion(
    id: "q14",
    text: "ฉันพยายามหลีกเลี่ยงความขัดแย้ง",
    trait: "agreeableness",
  ),
  PersonalityQuestion(
    id: "q15",
    text: "ฉันช่วยเหลือผู้อื่นโดยไม่หวังผลตอบแทน",
    trait: "agreeableness",
  ),
  PersonalityQuestion(
    id: "q16",
    text: "ฉันมักวิจารณ์ผู้อื่นอย่างรุนแรง",
    trait: "agreeableness",
    reverseScored: true,
  ),

  // ===== NEUROTICISM =====
  PersonalityQuestion(id: "q17", text: "ฉันกังวลบ่อย", trait: "neuroticism"),
  PersonalityQuestion(
    id: "q18",
    text: "ฉันอารมณ์เปลี่ยนง่าย",
    trait: "neuroticism",
  ),
  PersonalityQuestion(
    id: "q19",
    text: "ฉันเครียดกับเรื่องเล็ก ๆ ได้ง่าย",
    trait: "neuroticism",
  ),
  PersonalityQuestion(
    id: "q20",
    text: "ฉันควบคุมอารมณ์ได้ดี",
    trait: "neuroticism",
    reverseScored: true,
  ),
];
