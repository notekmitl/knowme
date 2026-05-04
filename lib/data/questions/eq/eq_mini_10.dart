import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';
import '../../../core/constants/test_options.dart';

List<TestQuestion> eqMini10 = [
  TestQuestion(
    id: "EQM1",
    moduleId: "eq_mini",
    trait: "awareness",
    text: {"en": "I understand my emotions.", "th": "ฉันเข้าใจอารมณ์ของตัวเอง"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQM2",
    moduleId: "eq_mini",
    trait: "regulation",
    text: {"en": "I stay calm under pressure.", "th": "ฉันสงบเมื่อมีความกดดัน"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQM3",
    moduleId: "eq_mini",
    trait: "empathy",
    text: {
      "en": "I understand how others feel.",
      "th": "ฉันเข้าใจความรู้สึกของผู้อื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM4",
    moduleId: "eq_mini",
    trait: "social",
    text: {
      "en": "I communicate well with people.",
      "th": "ฉันสื่อสารกับผู้อื่นได้ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM5",
    moduleId: "eq_mini",
    trait: "stress",
    text: {
      "en": "I handle stress effectively.",
      "th": "ฉันจัดการความเครียดได้ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM6",
    moduleId: "eq_mini",
    trait: "decision",
    text: {
      "en": "I think before making decisions.",
      "th": "ฉันคิดก่อนตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM7",
    moduleId: "eq_mini",
    trait: "awareness",
    text: {
      "en": "I recognize my emotional reactions.",
      "th": "ฉันรู้ทันปฏิกิริยาทางอารมณ์ของตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM8",
    moduleId: "eq_mini",
    trait: "regulation",
    text: {"en": "I control my emotions well.", "th": "ฉันควบคุมอารมณ์ได้ดี"},
    options: likert5,
  ),

  TestQuestion(
    id: "EQM9",
    moduleId: "eq_mini",
    trait: "empathy",
    text: {
      "en": "I care about others' feelings.",
      "th": "ฉันใส่ใจความรู้สึกของผู้อื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "EQM10",
    moduleId: "eq_mini",
    trait: "social",
    text: {
      "en": "I build positive relationships.",
      "th": "ฉันสร้างความสัมพันธ์ที่ดี",
    },
    options: likert5,
  ),
];
