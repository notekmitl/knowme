import 'package:knowme/domain/models/test_module.dart';

final List<TestModule> testModules = [
  /// =========================
  /// BIG FIVE
  /// =========================
  TestModule(
    id: 'bigfive_mini',
    title: {"en": "Big Five (Quick Test)", "th": "Big Five แบบสั้น"},
    description: {
      "en": "Quick personality overview",
      "th": "ทดสอบบุคลิกภาพอย่างรวดเร็ว",
    },
    questionCount: 10,
  ),

  TestModule(
    id: 'bigfive_short',
    title: {"en": "Big Five (Standard)", "th": "Big Five มาตรฐาน"},
    description: {
      "en": "Standard personality assessment",
      "th": "วิเคราะห์บุคลิกภาพแบบมาตรฐาน",
    },
    questionCount: 44,
  ),

  TestModule(
    id: 'bigfive_accurate',
    title: {"en": "Big Five (Detailed)", "th": "Big Five แบบละเอียด"},
    description: {
      "en": "Highly accurate personality analysis",
      "th": "วิเคราะห์บุคลิกภาพเชิงลึก",
    },
    questionCount: 120,
  ),

  /// =========================
  /// EQ
  /// =========================
  TestModule(
    id: 'eq_awareness',
    title: {
      "en": "Understanding Your Emotions",
      "th": "การเข้าใจอารมณ์ของตัวเอง",
    },
    description: {
      "en": "Recognize and understand your emotions",
      "th": "ความสามารถในการรับรู้อารมณ์ของตัวเอง",
    },
    questionCount: 20,
  ),

  TestModule(
    id: 'eq_regulation',
    title: {"en": "Emotional Self-Control", "th": "การควบคุมอารมณ์"},
    description: {
      "en": "Control and manage emotional reactions",
      "th": "การจัดการและควบคุมอารมณ์",
    },
    questionCount: 20,
  ),

  TestModule(
    id: 'eq_empathy',
    title: {
      "en": "Understanding Others' Emotions",
      "th": "การเข้าใจอารมณ์ผู้อื่น",
    },
    description: {
      "en": "Recognize how other people feel",
      "th": "ความสามารถในการเข้าใจความรู้สึกของผู้อื่น",
    },
    questionCount: 20,
  ),

  TestModule(
    id: 'eq_social',
    title: {"en": "Relationship Skills", "th": "ทักษะความสัมพันธ์"},
    description: {
      "en": "Build and maintain healthy relationships",
      "th": "การสร้างและรักษาความสัมพันธ์กับผู้อื่น",
    },
    questionCount: 20,
  ),

  TestModule(
    id: 'eq_stress',
    title: {"en": "Handling Stress", "th": "การรับมือกับความเครียด"},
    description: {
      "en": "Stay calm and balanced under pressure",
      "th": "ความสามารถในการจัดการความเครียด",
    },
    questionCount: 20,
  ),

  TestModule(
    id: 'eq_decision',
    title: {"en": "Balanced Decision Making", "th": "การตัดสินใจอย่างสมดุล"},
    description: {
      "en": "Make thoughtful and balanced decisions",
      "th": "การตัดสินใจโดยใช้เหตุผลและอารมณ์ร่วมกัน",
    },
    questionCount: 20,
  ),

  /// =========================
  /// MBTI
  /// =========================
  TestModule(
    id: 'mbti_mini',
    title: {"en": "MBTI (Quick Test)", "th": "MBTI แบบสั้น"},
    description: {
      "en": "Quick overview of your personality type",
      "th": "ค้นหาประเภทบุคลิกภาพอย่างรวดเร็ว",
    },
    questionCount: 16,
  ),

  TestModule(
    id: 'mbti_short',
    title: {"en": "MBTI (Standard)", "th": "MBTI มาตรฐาน"},
    description: {
      "en": "Standard MBTI personality test",
      "th": "แบบทดสอบ MBTI มาตรฐาน",
    },
    questionCount: 40,
  ),

  TestModule(
    id: 'mbti_accurate',
    title: {"en": "MBTI (Detailed)", "th": "MBTI แบบละเอียด"},
    description: {
      "en": "More accurate MBTI personality analysis",
      "th": "วิเคราะห์ MBTI แบบละเอียด",
    },
    questionCount: 80,
  ),
];
