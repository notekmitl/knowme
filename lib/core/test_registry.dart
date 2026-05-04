import 'package:flutter/material.dart';
import 'package:knowme/tests/mbti/mbti_test_page.dart';

class TestMeta {
  final String id;
  final String title;
  final Widget Function() builder;

  TestMeta({required this.id, required this.title, required this.builder});
}

final List<TestMeta> testRegistry = [
  TestMeta(
    id: "mbti",
    title: "MBTI Personality Test",
    builder: () => const MbtiTestPage(),
  ),
];
