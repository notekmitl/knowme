import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

final List<TestQuestion> eqCore60 = List.generate(60, (index) {
  final id = index + 1;

  String dimension = "awareness";

  if (id <= 10)
    dimension = "awareness";
  else if (id <= 20)
    dimension = "regulation";
  else if (id <= 30)
    dimension = "empathy";
  else if (id <= 40)
    dimension = "social";
  else if (id <= 50)
    dimension = "stress";
  else
    dimension = "decision";

  return TestQuestion(
    id: "EQ$id",
    moduleId: "eq",
    text: {"en": "EQ statement $id", "th": "คำถาม EQ ข้อที่ $id"},
    trait: dimension,
    options: [
      {
        "text": {"en": "Strongly disagree", "th": "ไม่เห็นด้วยอย่างยิ่ง"},
        "score": 1,
      },
      {
        "text": {"en": "Disagree", "th": "ไม่เห็นด้วย"},
        "score": 2,
      },
      {
        "text": {"en": "Neutral", "th": "ปานกลาง"},
        "score": 3,
      },
      {
        "text": {"en": "Agree", "th": "เห็นด้วย"},
        "score": 4,
      },
      {
        "text": {"en": "Strongly agree", "th": "เห็นด้วยอย่างยิ่ง"},
        "score": 5,
      },
    ],
  );
});
