import 'package:knowme/domain/models/test_module.dart';

final List<TestModule> testModules = [
  /// =========================
  /// BIG FIVE
  /// =========================
  TestModule(
    id: 'bigfive_mini',

    titleKey: 'bigfive_mini_title',
    descriptionKey: 'bigfive_mini_description',

    questionCount: 10,
  ),

  TestModule(
    id: 'bigfive_short',

    titleKey: 'bigfive_short_title',
    descriptionKey: 'bigfive_short_description',

    questionCount: 44,
  ),

  TestModule(
    id: 'bigfive_accurate',

    titleKey: 'bigfive_accurate_title',
    descriptionKey: 'bigfive_accurate_description',

    questionCount: 120,
  ),

  /// =========================
  /// EQ
  /// =========================
  TestModule(
    id: 'eq_awareness',

    titleKey: 'eq_awareness_title',
    descriptionKey: 'eq_awareness_description',

    questionCount: 20,
  ),

  TestModule(
    id: 'eq_regulation',

    titleKey: 'eq_regulation_title',
    descriptionKey: 'eq_regulation_description',

    questionCount: 20,
  ),

  TestModule(
    id: 'eq_empathy',

    titleKey: 'eq_empathy_title',
    descriptionKey: 'eq_empathy_description',

    questionCount: 20,
  ),

  TestModule(
    id: 'eq_social',

    titleKey: 'eq_social_title',
    descriptionKey: 'eq_social_description',

    questionCount: 20,
  ),

  TestModule(
    id: 'eq_stress',

    titleKey: 'eq_stress_title',
    descriptionKey: 'eq_stress_description',

    questionCount: 20,
  ),

  TestModule(
    id: 'eq_decision',

    titleKey: 'eq_decision_title',
    descriptionKey: 'eq_decision_description',

    questionCount: 20,
  ),

  /// =========================
  /// MBTI
  /// =========================
  TestModule(
    id: 'mbti_mini',

    titleKey: 'mbti_mini_title',
    descriptionKey: 'mbti_mini_description',

    questionCount: 16,
  ),

  TestModule(
    id: 'mbti_short',

    titleKey: 'mbti_short_title',
    descriptionKey: 'mbti_short_description',

    questionCount: 40,
  ),

  TestModule(
    id: 'mbti_accurate',

    titleKey: 'mbti_accurate_title',
    descriptionKey: 'mbti_accurate_description',

    questionCount: 80,
  ),
];
