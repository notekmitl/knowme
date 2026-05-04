import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:knowme/data/personality_questions.dart';
import '../../providers/personality_provider.dart';
import 'personality_result_page.dart';

class PersonalityTestPage extends StatefulWidget {
  const PersonalityTestPage({super.key});

  @override
  State<PersonalityTestPage> createState() => _PersonalityTestPageState();
}

class _PersonalityTestPageState extends State<PersonalityTestPage> {
  int currentQuestionIndex = 0;

  void answer(int score) {
    final provider = context.read<PersonalityProvider>();

    final question = personalityQuestions[currentQuestionIndex];

    provider.submitAnswer(question.id, score);

    if (currentQuestionIndex < personalityQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      provider.calculateResult();
      provider.saveToFirestore();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalityResultPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = personalityQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personality Test"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  "คำถาม ${currentQuestionIndex + 1} / ${personalityQuestions.length}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value:
                      (currentQuestionIndex + 1) / personalityQuestions.length,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.deepPurple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                question.text,
                key: ValueKey(question.id),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
              ),
            ),

            const SizedBox(height: 40),

            Column(
              children: [
                _answerCard("ไม่เห็นด้วยอย่างยิ่ง", 1),
                _answerCard("ไม่เห็นด้วย", 2),
                _answerCard("ปานกลาง", 3),
                _answerCard("เห็นด้วย", 4),
                _answerCard("เห็นด้วยอย่างยิ่ง", 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ⭐ ต้องอยู่ใน class นี้
  Widget _answerCard(String text, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => answer(score),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
