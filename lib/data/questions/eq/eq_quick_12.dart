import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';
import '../../../core/constants/test_options.dart';

List<TestQuestion> eqQuick12 = [
  TestQuestion(
    id: "EQ1",
    moduleId: "eq_quick",
    trait: "awareness",
    text: {"en": "I understand my emotions.", "th": "ฉันเข้าใจอารมณ์ของตัวเอง"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQ2",
    moduleId: "eq_quick",
    trait: "regulation",
    text: {"en": "I stay calm under pressure.", "th": "ฉันสงบเมื่อมีความกดดัน"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQ3",
    moduleId: "eq_quick",
    trait: "empathy",
    text: {
      "en": "I understand how others feel.",
      "th": "ฉันเข้าใจความรู้สึกของผู้อื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ4",
    moduleId: "eq_quick",
    trait: "social",
    text: {
      "en": "I communicate clearly with people.",
      "th": "ฉันสื่อสารกับผู้อื่นได้ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ5",
    moduleId: "eq_quick",
    trait: "stress",
    text: {
      "en": "I handle stress effectively.",
      "th": "ฉันจัดการความเครียดได้ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ6",
    moduleId: "eq_quick",
    trait: "decision",
    text: {
      "en": "I think before making decisions.",
      "th": "ฉันคิดก่อนตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ7",
    moduleId: "eq_quick",
    trait: "awareness",
    text: {
      "en": "I recognize my emotional reactions.",
      "th": "ฉันรู้ทันอารมณ์ของตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ8",
    moduleId: "eq_quick",
    trait: "regulation",
    text: {"en": "I control my emotions well.", "th": "ฉันควบคุมอารมณ์ได้ดี"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQ9",
    moduleId: "eq_quick",
    trait: "empathy",
    text: {
      "en": "I care about other people's feelings.",
      "th": "ฉันใส่ใจความรู้สึกของผู้อื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ10",
    moduleId: "eq_quick",
    trait: "social",
    text: {
      "en": "I build good relationships.",
      "th": "ฉันสร้างความสัมพันธ์ที่ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ11",
    moduleId: "eq_quick",
    trait: "stress",
    text: {
      "en": "I stay calm in difficult situations.",
      "th": "ฉันสงบในสถานการณ์ยาก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQ12",
    moduleId: "eq_quick",
    trait: "decision",
    text: {
      "en": "I evaluate decisions carefully.",
      "th": "ฉันพิจารณาการตัดสินใจอย่างรอบคอบ",
    },
    options: likert5,
  ),
];
