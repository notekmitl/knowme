import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../data/big_five_firestore_repository.dart';
import '../data/modules/big_five_progressive_questions.dart';
import '../domain/big_five_depth_tier.dart';
import '../domain/big_five_models.dart';
import 'big_five_scorer.dart';

/// In-memory progressive session for Big Five (10 → 44 → 80).
class BigFiveSessionState extends ChangeNotifier {
  BigFiveSessionState({
    BigFiveFirestoreRepository? repository,
    BigFiveScorer? scorer,
    FirebaseAuth? auth,
  })  : _repository = repository ?? BigFiveFirestoreRepositoryImpl(),
        _scorer = scorer ?? const BigFiveScorer(),
        _auth = auth ?? FirebaseAuth.instance;

  final BigFiveFirestoreRepository _repository;
  final BigFiveScorer _scorer;
  final FirebaseAuth _auth;

  BigFiveSessionStatus status = BigFiveSessionStatus.loading;
  String? errorMessage;
  BigFiveResultSummary? existingCompletedResult;

  List<TestQuestion> questions =
      List.unmodifiable(BigFiveProgressiveQuestions.quick);
  int index = 0;
  Map<String, int> answers = {};

  bool get isLoading => status == BigFiveSessionStatus.loading;
  bool get hasQuestions => questions.isNotEmpty;
  int get total => questions.length;
  int get answeredCount => answers.length;
  double get progressValue => total == 0 ? 0 : (index + 1) / total;

  TestQuestion? get currentQuestion =>
      hasQuestions && index >= 0 && index < total ? questions[index] : null;

  int? get selectedScoreForCurrent {
    final question = currentQuestion;
    if (question == null) return null;
    return answers[question.id];
  }

  bool get canGoBack => index > 0;
  bool get canGoNext => index < total - 1;
  bool get isLastQuestion => hasQuestions && index == total - 1;
  bool get currentQuestionAnswered {
    final question = currentQuestion;
    return question != null && answers.containsKey(question.id);
  }

  bool get canFinishTest =>
      isLastQuestion && currentQuestionAnswered && answers.length == total;

  int get totalQuestions => bigFiveDeepCheckpoint;

  BigFiveDepthTier get currentDepthTier {
    final count = answeredCount;
    if (count >= bigFiveDeepCheckpoint) return BigFiveDepthTier.deep;
    if (count >= bigFiveStandardCheckpoint) return BigFiveDepthTier.standard;
    return BigFiveDepthTier.quick;
  }

  bool get isQuickCheckpointReached => answeredCount >= bigFiveQuickCheckpoint;

  bool get isStandardCheckpointReached =>
      answeredCount >= bigFiveStandardCheckpoint;

  bool get isDeepCheckpointReached => answeredCount >= bigFiveDeepCheckpoint;

  bool get canOfferStandardContinue =>
      isQuickCheckpointReached && !isStandardCheckpointReached;

  bool get canOfferDeepContinue =>
      isStandardCheckpointReached && !isDeepCheckpointReached;

  bool get canOfferAnyContinue =>
      canOfferStandardContinue || canOfferDeepContinue;

  String? get _uid => _auth.currentUser?.uid;

  void _applyQuestionSetForProgress({required int answered, int? sessionTotal}) {
    final totalTarget = sessionTotal ?? answered;
    questions = List.unmodifiable(
      BigFiveProgressiveQuestions.forTargetTotal(totalTarget),
    );
  }

  Future<void> initialize() async {
    status = BigFiveSessionStatus.loading;
    errorMessage = null;
    existingCompletedResult = null;
    notifyListeners();

    _applyQuestionSetForProgress(
      answered: 0,
      sessionTotal: bigFiveQuickCheckpoint,
    );

    if (questions.isEmpty) {
      status = BigFiveSessionStatus.empty;
      notifyListeners();
      return;
    }

    final uid = _uid;
    if (uid != null) {
      try {
        final session = await _repository.loadSession(uid);
        if (session != null && session.completed) {
          if (session.answers.isNotEmpty) {
            answers = Map<String, int>.from(session.answers);
            _applyQuestionSetForProgress(
              answered: session.answered,
              sessionTotal: session.total,
            );
          }
          final result = await _repository.loadLatestResult(uid);
          if (result != null) {
            existingCompletedResult = result;
            status = BigFiveSessionStatus.ready;
            notifyListeners();
            return;
          }
        }
        if (session != null && session.answers.isNotEmpty) {
          answers = Map<String, int>.from(session.answers);
          _applyQuestionSetForProgress(
            answered: session.answered,
            sessionTotal: session.total,
          );
          index = _clampIndex(session.index);
        }
      } catch (error) {
        errorMessage = error.toString();
        status = BigFiveSessionStatus.error;
        notifyListeners();
        return;
      }
    }

    status = BigFiveSessionStatus.ready;
    notifyListeners();
  }

  int _clampIndex(int value) {
    if (total == 0) return 0;
    if (value < 0) return 0;
    if (value >= total) return total - 1;
    return value;
  }

  void selectAnswer(int score) {
    final question = currentQuestion;
    if (question == null) return;

    answers = {...answers, question.id: score};
    notifyListeners();
    _persistProgress();
  }

  void goBack() {
    if (!canGoBack) return;
    index--;
    notifyListeners();
    _persistProgress();
  }

  void goNext() {
    if (!canGoNext || !currentQuestionAnswered) return;
    index++;
    notifyListeners();
    _persistProgress();
  }

  /// Expands to 44 questions and resumes at Q11 (index 10).
  Future<void> resumeToStandardCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferStandardContinue) return;

    questions = List.unmodifiable(BigFiveProgressiveQuestions.standard);
    index = bigFiveQuickCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          index: index,
          total: bigFiveStandardCheckpoint,
          depthTier: BigFiveDepthTier.standard,
          answers: answers,
        );
      } catch (error) {
        errorMessage = error.toString();
        notifyListeners();
        return;
      }
    }

    status = BigFiveSessionStatus.ready;
    notifyListeners();
  }

  /// Expands to 80 questions and resumes at Q45 (index 44).
  Future<void> resumeToDeepCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferDeepContinue) return;

    questions = List.unmodifiable(BigFiveProgressiveQuestions.deep);
    index = bigFiveStandardCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          index: index,
          total: bigFiveDeepCheckpoint,
          depthTier: BigFiveDepthTier.deep,
          answers: answers,
        );
      } catch (error) {
        errorMessage = error.toString();
        notifyListeners();
        return;
      }
    }

    status = BigFiveSessionStatus.ready;
    notifyListeners();
  }

  Future<BigFiveResultSummary?> finish() async {
    if (!canFinishTest) return null;

    final summary = _scorer.score(
      questions: questions,
      answers: answers,
    );

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.saveResult(uid, summary);
        await _repository.markCompleted(uid);
      } catch (error) {
        errorMessage = error.toString();
        notifyListeners();
        return null;
      }
    }

    existingCompletedResult = summary;
    return summary;
  }

  Future<void> clearRemoteSession() async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.clearSession(uid);
  }

  void restartLocal() {
    answers = {};
    index = 0;
    questions = List.unmodifiable(BigFiveProgressiveQuestions.quick);
    existingCompletedResult = null;
    notifyListeners();
  }

  Future<void> restart({required bool clearRemote}) async {
    existingCompletedResult = null;
    if (clearRemote) {
      await clearRemoteSession();
    }
    restartLocal();
    await _persistProgress();
  }

  Future<void> persistBeforeLeave() async {
    if (status != BigFiveSessionStatus.ready) return;
    await _persistProgress();
  }

  Future<void> _persistProgress() async {
    final uid = _uid;
    if (uid == null) return;

    final depthTier = BigFiveDepthTier.forScoredQuestionCount(total);

    try {
      await _repository.saveProgress(
        uid: uid,
        answeredCount: answers.length,
        index: index,
        total: total,
        depthTier: depthTier,
        answers: answers,
      );
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }
}
