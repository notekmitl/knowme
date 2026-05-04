import 'package:flutter/material.dart';
import 'package:knowme/l10n/app_localizations.dart';
import 'package:knowme/l10n/l10n_extension.dart';

import 'mbti_model.dart';
import 'mbti_logic.dart';
import 'mbti_result_page.dart';

import 'questions/part1.dart';
import 'questions/part2.dart';
import 'questions/part3.dart';
import 'questions/part4.dart';

class MbtiTestPage extends StatefulWidget {
  const MbtiTestPage({super.key});

  @override
  State<MbtiTestPage> createState() => _MbtiTestPageState();
}

class _MbtiTestPageState extends State<MbtiTestPage> {
  int currentPart = 0;
  int currentIndex = 0;

  final logic = MbtiLogic();

  late final List<List<MbtiQuestion>> parts = [
    part1Questions,
    part2Questions,
    part3Questions,
    part4Questions,
  ];

  final options = [
    {"key": "mbti_option_strongly_agree", "value": 2},
    {"key": "mbti_option_agree", "value": 1},
    {"key": "mbti_option_neutral", "value": 0},
    {"key": "mbti_option_disagree", "value": -1},
    {"key": "mbti_option_strongly_disagree", "value": -2},
  ];

  void answer(int value) {
    final question = parts[currentPart][currentIndex];

    logic.applyAnswer(question.dimension, value);

    final currentQuestions = parts[currentPart];

    if (currentIndex < currentQuestions.length - 1) {
      setState(() => currentIndex++);
    } else if (currentPart < parts.length - 1) {
      setState(() {
        currentPart++;
        currentIndex = 0;
      });
    } else {
      finishTest();
    }
  }

  void finishTest() {
    final type = logic.getType();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MbtiResultPage(data: {"type": type, "scores": logic.scores}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final currentQuestions = parts[currentPart];
    final question = currentQuestions[currentIndex];

    final totalQuestions = parts.fold(0, (sum, part) => sum + part.length);

    final currentGlobalIndex =
        parts.take(currentPart).fold(0, (sum, part) => sum + part.length) +
        currentIndex +
        1;

    return Scaffold(
      appBar: AppBar(
        title: Text("MBTI (Part ${currentPart + 1}/4)"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$currentGlobalIndex / $totalQuestions",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Text(
              t.tr(question.textKey),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            ...options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => answer(opt["value"] as int),
                    child: Text(t.tr(opt["key"] as String)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
