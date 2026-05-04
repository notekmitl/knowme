import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';
import '../../../core/constants/test_options.dart';

List<TestQuestion> eqShort40 = List.generate(40, (i) {
  List<String> traits = [
    "awareness",
    "regulation",
    "empathy",
    "social",
    "stress",
    "decision",
  ];

  String trait = traits[i % 6];

  return TestQuestion(
    id: "EQS${i + 1}",
    moduleId: "eq_short",
    trait: trait,
    text: {
      "en": "EQ short question ${i + 1}",
      "th": "คำถาม EQ ระดับสั้น ${i + 1}",
    },
    options: likert5,
  );
});
