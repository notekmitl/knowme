import 'package:flutter/material.dart';

class TestCategory {
  final String id;

  final Map<String, String> title;

  final Map<String, String> description;

  final IconData icon;

  final List<String> modules;

  const TestCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.modules,
  });
}
