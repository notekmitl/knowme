import 'package:knowme/domain/models/test_module.dart';

final List<TestModule> testRegistry = [
  TestModule(
    id: "mbti",

    titleKey: "mbti_title",
    descriptionKey: "mbti_description",

    questionCount: 80,
  ),

  TestModule(
    id: "bigfive",

    titleKey: "bigfive_title",
    descriptionKey: "bigfive_description",

    questionCount: 50,
  ),

  TestModule(
    id: "eq",

    titleKey: "eq_title",
    descriptionKey: "eq_description",

    questionCount: 40,
  ),
];
