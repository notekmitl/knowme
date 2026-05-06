import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/i18n/app_text.dart';

import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

import 'package:knowme/services/question_service.dart';
import 'package:knowme/services/scoring_router.dart';
import 'package:knowme/services/personality_profile_service.dart';

import '../result/personality_result_page.dart';
import '../result/mbti_result_page.dart';
import '../result/eq_result_page.dart';

class UniversalTestPage extends StatefulWidget {
  final TestModule module;

  const UniversalTestPage({super.key, required this.module});

  @override
  State<UniversalTestPage> createState() => _UniversalTestPageState();
}

class _UniversalTestPageState extends State<UniversalTestPage> {
  int index = 0;

  Map<String, int> answers = {};

  String language = AppText.lang;

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
    final allQuestions = QuestionService.getQuestions(widget.module);

    questions = allQuestions.where((q) => !answers.containsKey(q.id)).toList();

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

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> checkExistingProgress() async {
    final doc = await testRef.get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;

    /// completed
    if (data["completed"] == true) {
      final restart = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              language == "th" ? "ทำแบบทดสอบอีกครั้ง?" : "Restart Test?",
            ),

            content: Text(
              language == "th"
                  ? "คุณทำแบบทดสอบนี้เสร็จแล้ว ต้องการทำใหม่หรือไม่"
                  : "You already completed this test. Restart?",
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),

                child: Text(language == "th" ? "ไม่" : "No"),
              ),

              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),

                child: Text(language == "th" ? "ทำใหม่" : "Restart"),
              ),
            ],
          );
        },
      );

      if (restart == true) {
        await testRef.delete();

        answers = {};
        index = 0;
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }

      return;
    }

    /// resume answers

    if (data["answers"] != null) {
      final raw = Map<String, dynamic>.from(data["answers"]);

      answers = {};

      raw.forEach((key, value) {
        if (value != null) {
          answers[key] = value;
        }
      });
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
      return Scaffold(
        body: Center(
          child: Text(
            language == "th"
                ? "ยังไม่มีคำถามในแบบทดสอบนี้"
                : "No questions available",
          ),
        ),
      );
    }

    final question = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t(widget.module.titleKey)),

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
                language == "th"
                    ? "คำถาม ${index + 1} / ${questions.length}"
                    : "Question ${index + 1} / ${questions.length}",

                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: (index + 1) / questions.length),

              const SizedBox(height: 40),

              /// question
              Text(
                question.text[language] ?? question.text["en"] ?? "",

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              /// options
              ...question.options.map((option) {
                final textMap = Map<String, dynamic>.from(option["text"] ?? {});

                final score = option["score"] ?? 0;

                return answerButton(
                  question,
                  textMap[language] ?? textMap["en"] ?? "",
                  score,
                );
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
            await finishTest();
          }
        },

        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> finishTest() async {
    /// calculate score

    final result = ScoringRouter.calculate(widget.module, answers, questions);

    /// save result

    await resultRef.set({...result, "createdAt": FieldValue.serverTimestamp()});

    /// mark completed

    await testRef.set({
      "completed": true,
      "completedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// rebuild personality profile

    final profileService = PersonalityProfileService();

    await profileService.buildProfile();

    if (!mounted) return;

    if (widget.module.id.startsWith("mbti")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MbtiResultPage(traits: result)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalityResultPage()),
      );
    }
  }
}
