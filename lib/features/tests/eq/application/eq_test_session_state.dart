import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../data/eq_firestore_repository.dart';
import '../domain/eq_models.dart';
import '../domain/eq_test_type.dart';
import 'eq_scorer.dart';

enum EqTestSessionStatus { loading, ready, empty, error }

/// Lean one-shot EQ session (no checkpoints).
class EqTestSessionState extends ChangeNotifier {
  EqTestSessionState({
    required this.testType,
    this.startFreshAfterRetake = false,
    EqFirestoreRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ?? EqFirestoreRepositoryImpl(),
        _auth = auth ?? FirebaseAuth.instance;

  /// When true, skip stored `results/*` so retake opens the test (not old snapshot).
  final bool startFreshAfterRetake;

  final EqTestType testType;
  final EqFirestoreRepository _repository;
  final FirebaseAuth _auth;

  EqTestSessionStatus status = EqTestSessionStatus.loading;
  String? errorMessage;
  EqResultSummary? existingCompletedResult;

  late List<TestQuestion> questions;
  int index = 0;
  Map<String, int> answers = {};

  String get testId => testType.testId;

  bool get isLoading => status == EqTestSessionStatus.loading;
  int get total => questions.length;
  int get answeredCount => answers.length;

  double get progressValue => total == 0 ? 0 : (index + 1) / total;

  TestQuestion? get currentQuestion =>
      total > 0 && index >= 0 && index < total ? questions[index] : null;

  int? get selectedScoreForCurrent {
    final q = currentQuestion;
    if (q == null) return null;
    return answers[q.id];
  }

  bool get canGoBack => index > 0;
  bool get canGoNext => index < total - 1;
  bool get isLastQuestion => total > 0 && index == total - 1;

  bool get currentQuestionAnswered {
    final q = currentQuestion;
    return q != null && answers.containsKey(q.id);
  }

  bool get canFinishTest =>
      isLastQuestion && currentQuestionAnswered && answers.length == total;

  String? get _uid => _auth.currentUser?.uid;

  Future<void>? _persistTail;

  Future<void> _writeProgress() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _repository.saveProgress(
        uid: uid,
        testId: testId,
        answeredCount: answers.length,
        index: index,
        total: total,
        answers: answers,
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Serializes writes so out-of-order Firestore updates cannot regress progress.
  Future<void> saveProgress() {
    final previous = _persistTail ?? Future<void>.value();
    final next = previous.then((_) => _writeProgress());
    _persistTail = next;
    return next;
  }

  /// Await in-flight writes, then flush the latest in-memory snapshot once more.
  Future<void> persistBeforeLeave() async {
    await (_persistTail ?? Future<void>.value());
    await _writeProgress();
  }

  Future<void> initialize() async {
    status = EqTestSessionStatus.loading;
    errorMessage = null;
    existingCompletedResult = null;
    notifyListeners();

    questions = List.unmodifiable(eqQuestionsFor(testType));

    if (questions.isEmpty) {
      status = EqTestSessionStatus.empty;
      notifyListeners();
      return;
    }

    await restore();
  }

  Future<void> restore() async {
    final uid = _uid;
    if (uid == null) {
      status = EqTestSessionStatus.ready;
      notifyListeners();
      return;
    }

    try {
      final result = await _repository.loadLatestResult(uid, testId);
      if (result != null && !startFreshAfterRetake) {
        existingCompletedResult = result;
        status = EqTestSessionStatus.ready;
        notifyListeners();
        return;
      }

      final session = await _repository.loadSession(uid, testId);
      if (session != null && session.answers.isNotEmpty) {
        answers = Map<String, int>.from(session.answers);
        index = _clampIndex(session.index);
        if (index < _clampIndex(session.answered)) {
          index = _clampIndex(session.answered);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      status = EqTestSessionStatus.error;
      notifyListeners();
      return;
    }

    status = EqTestSessionStatus.ready;
    notifyListeners();
  }

  int _clampIndex(int value) {
    if (total == 0) return 0;
    if (value < 0) return 0;
    if (value >= total) return total - 1;
    return value;
  }

  Future<void> answer(int score) async {
    final q = currentQuestion;
    if (q == null) return;

    answers = {...answers, q.id: score};
    notifyListeners();
    await saveProgress();
  }

  Future<void> goBack() async {
    if (!canGoBack) return;
    index--;
    notifyListeners();
    await saveProgress();
  }

  Future<void> goNext() async {
    if (!canGoNext || !currentQuestionAnswered) return;
    index++;
    notifyListeners();
    await saveProgress();
  }

  Future<EqResultSummary?> finish() async {
    if (!canFinishTest) return null;

    final summary = EqScorer.score(
      testId: testId,
      questions: questions,
      answers: answers,
    );

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.saveResult(uid, summary);
        await _repository.markCompleted(uid, testId);
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return null;
      }
    }

    existingCompletedResult = summary;
    return summary;
  }

  Future<void> restart() async {
    existingCompletedResult = null;
    answers = {};
    index = 0;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.clearSession(uid, testId);
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return;
      }
    }

    status = EqTestSessionStatus.ready;
    notifyListeners();
    await saveProgress();
  }

}
