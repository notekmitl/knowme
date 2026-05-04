import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/domain/models/personality_core_result.dart';
import 'package:knowme/data/personality_questions.dart';
import 'package:knowme/services/personality_scoring_service.dart';

class PersonalityProvider extends ChangeNotifier {
  final Map<String, int> _answers = {};

  PersonalityCoreResult? _result;

  PersonalityCoreResult? get result => _result;

  void submitAnswer(String questionId, int value) {
    _answers[questionId] = value;
  }

  void calculateResult() {
    _result = PersonalityScoringService.calculate(
      questions: personalityQuestions,
      answers: _answers,
    );

    notifyListeners();
  }

  Future<void> saveToFirestore() async {
    if (_result == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('psychology')
        .doc('personality_core')
        .set(_result!.toMap());
  }

  Future<void> loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('psychology')
        .doc('personality_core')
        .get();

    if (doc.exists) {
      _result = PersonalityCoreResult.fromMap(doc.data()!);
      notifyListeners();
    }
  }

  void clear() {
    _answers.clear();
    _result = null;
  }
}
