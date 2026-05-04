import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/domain/models/test_module.dart';
import '../../domain/models/test_question.dart';
import 'package:knowme/services//question_service.dart';
import 'package:knowme/services//scoring_router.dart';

class UniversalTestPage extends StatefulWidget {
  final TestModule module;

  const UniversalTestPage({super.key, required this.module});

  @override
  State<UniversalTestPage> createState() => _UniversalTestPageState();
}

class _UniversalTestPageState extends State<UniversalTestPage> {
  int index = 0;

  Map<String, int> answers = {};

  String language = "th";

  List<TestQuestion> questions = [];

  late DocumentReference testRef;

  late DocumentReference resultRef;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initTest();
  }

  Future<void> initTest() async {
    questions = QuestionService.getQuestions(widget.module);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    testRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tests")
        .doc(widget.module.id);

    resultRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("results")
        .doc(widget.module.id);

    await checkExistingProgress();

    loading = false;

    if (mounted) setState(() {});
  }

  Future<void> checkExistingProgress() async {
    final doc = await testRef.get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;

    if (data["answers"] != null) {
      answers = Map<String, int>.from(data["answers"]);
    }

    if (data["answered"] != null) {
      index = data["answered"];
    }

    if (index >= questions.length) {
      index = questions.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("ยังไม่มีคำถามในแบบทดสอบนี้")),
      );
    }

    final question = questions[index];

    /// default options (สำหรับ BigFive)
    final defaultOptions = [
      {
        "score": 1,
        "text": {"th": "ไม่เห็นด้วยอย่างยิ่ง", "en": "Strongly disagree"},
      },
      {
        "score": 2,
        "text": {"th": "ไม่เห็นด้วย", "en": "Disagree"},
      },
      {
        "score": 3,
        "text": {"th": "ปานกลาง", "en": "Neutral"},
      },
      {
        "score": 4,
        "text": {"th": "เห็นด้วย", "en": "Agree"},
      },
      {
        "score": 5,
        "text": {"th": "เห็นด้วยอย่างยิ่ง", "en": "Strongly agree"},
      },
    ];

    final options = question.options.isEmpty
        ? defaultOptions
        : question.options;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.module.title[language] ?? widget.module.title["en"]!,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// progress
              Text(
                "คำถาม ${index + 1} / ${questions.length}",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: (index + 1) / questions.length),

              const SizedBox(height: 40),

              /// question
              Text(
                question.text[language] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              /// options
              ...options.map((option) {
                final text = option["text"][language] ?? "";

                final score = option["score"];

                return answerButton(question, text, score);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget answerButton(TestQuestion question, String text, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () async {
          answers[question.id] = score;

          await testRef.set({
            "module": widget.module.id,
            "answered": answers.length,
            "total": questions.length,
            "answers": answers,
            "updatedAt": FieldValue.serverTimestamp(),
          });

          if (index < questions.length - 1) {
            setState(() {
              index++;
            });
          } else {
            final result = ScoringRouter.calculate(
              widget.module,
              answers,
              questions,
            );

            await resultRef.set({
              ...result,
              "createdAt": FieldValue.serverTimestamp(),
            });

            await testRef.set({
              "completed": true,
              "completedAt": FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
