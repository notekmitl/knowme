import 'package:knowme/domain/models/test_question.dart';

class TestQuestion {
  final String id;

  final String moduleId;

  final Map<String, String> text;

  final String trait;

  final bool reverse;

  final List<dynamic> options;

  const TestQuestion({
    required this.id,
    required this.moduleId,
    required this.text,
    required this.trait,
    this.reverse = false,
    this.options = const [],
  });
}
