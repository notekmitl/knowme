import 'package:knowme/domain/models/test_category.dart';
import 'package:flutter/material.dart';

final List<TestCategory> testCategories = [
  /// ==============================
  /// BIG FIVE
  /// ==============================
  TestCategory(
    id: "bigfive",
    title: {
      "en": "Big Five Personality Test",
      "th": "แบบทดสอบบุคลิกภาพ Big Five",
    },
    description: {
      "en": "Analyze your personality traits and behavior patterns",
      "th": "วิเคราะห์ลักษณะนิสัยและพฤติกรรมของคุณจาก 5 มิติบุคลิกภาพ",
    },
    icon: Icons.psychology,
    modules: ["bigfive_mini", "bigfive_short", "bigfive_accurate"],
  ),

  /// ==============================
  /// EQ
  /// ==============================
  TestCategory(
    id: "eq",
    title: {
      "en": "Emotional Intelligence (EQ)",
      "th": "แบบทดสอบความฉลาดทางอารมณ์ (EQ)",
    },
    description: {
      "en": "Measure your ability to understand and manage emotions",
      "th": "วัดความสามารถในการเข้าใจ ควบคุม และจัดการอารมณ์ของตนเองและผู้อื่น",
    },
    icon: Icons.favorite,
    modules: [
      "eq_awareness",
      "eq_regulation",
      "eq_empathy",
      "eq_social",
      "eq_stress",
      "eq_decision",
    ],
  ),

  /// ==============================
  /// MBTI
  /// ==============================
  TestCategory(
    id: "mbti",
    title: {
      "en": "MBTI Personality Type Test",
      "th": "แบบทดสอบประเภทบุคลิกภาพ (MBTI)",
    },
    description: {
      "en": "Discover which of the 16 personality types you are",
      "th": "ค้นหาว่าคุณเป็นคนแบบไหนจาก 16 ประเภทบุคลิกภาพ",
    },
    icon: Icons.person,
    modules: ["mbti_mini", "mbti_short", "mbti_accurate"],
  ),
];
