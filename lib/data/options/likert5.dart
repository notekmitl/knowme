import '../../domain/models/answer_option.dart';

const likert5Options = [
  AnswerOption(
    id: "1",
    text: {"en": "Strongly Disagree", "th": "ไม่เห็นด้วยอย่างยิ่ง"},
    score: 1,
  ),

  AnswerOption(
    id: "2",
    text: {"en": "Disagree", "th": "ไม่เห็นด้วย"},
    score: 2,
  ),

  AnswerOption(id: "3", text: {"en": "Neutral", "th": "เฉย ๆ"}, score: 3),

  AnswerOption(id: "4", text: {"en": "Agree", "th": "เห็นด้วย"}, score: 4),

  AnswerOption(
    id: "5",
    text: {"en": "Strongly Agree", "th": "เห็นด้วยอย่างยิ่ง"},
    score: 5,
  ),
];
