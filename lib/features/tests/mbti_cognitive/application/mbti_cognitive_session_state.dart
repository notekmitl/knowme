import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/mbti_cognitive_firestore_repository.dart';
import '../data/mbti_cognitive_questions.dart';
import '../domain/mbti_cognitive_models.dart';
import 'mbti_cognitive_scorer.dart';

enum MbtiCognitiveSessionStatus { loading, ready, empty, error }

/// Progressive cognitive session (16 → 40 → 80), aligned with MBTI progressive flow.
class MbtiCognitiveSessionState extends ChangeNotifier {
  MbtiCognitiveSessionState({
    MbtiCognitiveFirestoreRepository? repository,
    MbtiCognitiveScorer? scorer,
    FirebaseAuth? auth,
  })  : _repository = repository ?? MbtiCognitiveFirestoreRepositoryImpl(),
        _scorer = scorer ?? const MbtiCognitiveScorer(),
        _auth = auth ?? FirebaseAuth.instance;

  final MbtiCognitiveFirestoreRepository _repository;
  final MbtiCognitiveScorer _scorer;
  final FirebaseAuth _auth;

  MbtiCognitiveSessionStatus status = MbtiCognitiveSessionStatus.loading;
  String? errorMessage;
  MbtiCognitiveResultSummary? existingCompletedResult;

  List<MbtiCognitiveQuestion> questions =
      List.unmodifiable(mbtiCognitiveMiniActiveQuestions);
  int index = 0;
  Map<String, int> answers = {};

  bool get isLoading => status == MbtiCognitiveSessionStatus.loading;
  bool get hasQuestions => questions.isNotEmpty;
  int get totalQuestions => mbtiCognitiveAccurateCheckpoint;
  int get total => questions.length;
  int get answeredCount => answers.length;

  MbtiCognitiveCheckpoint get currentCheckpoint {
    if (answeredCount >= mbtiCognitiveAccurateCheckpoint) {
      return MbtiCognitiveCheckpoint.accurate;
    }
    if (answeredCount >= mbtiCognitiveStandardCheckpoint) {
      return MbtiCognitiveCheckpoint.standard;
    }
    return MbtiCognitiveCheckpoint.mini;
  }

  bool get isMiniCheckpointReached =>
      answeredCount >= mbtiCognitiveMiniCheckpoint;

  bool get isStandardCheckpointReached =>
      answeredCount >= mbtiCognitiveStandardCheckpoint;

  bool get isAccurateCheckpointReached =>
      answeredCount >= mbtiCognitiveAccurateCheckpoint;

  double get progressValue => total == 0 ? 0 : (index + 1) / total;

  MbtiCognitiveQuestion? get currentQuestion =>
      hasQuestions && index >= 0 && index < total ? questions[index] : null;

  int? get selectedScoreForCurrent {
    final q = currentQuestion;
    if (q == null) return null;
    return answers[q.id];
  }

  bool get canGoBack => index > 0;
  bool get canGoNext => index < total - 1;
  bool get isLastQuestion => hasQuestions && index == total - 1;
  bool get currentQuestionAnswered {
    final q = currentQuestion;
    return q != null && answers.containsKey(q.id);
  }

  bool get canFinishTest =>
      isLastQuestion && currentQuestionAnswered && answers.length == total;

  bool get canOfferStandardContinue =>
      isMiniCheckpointReached && !isStandardCheckpointReached;

  bool get canOfferAccurateContinue =>
      isStandardCheckpointReached && !isAccurateCheckpointReached;

  bool get canOfferAnyContinue =>
      canOfferStandardContinue || canOfferAccurateContinue;

  String? get _uid => _auth.currentUser?.uid;

  bool _usesAccurateQuestionSet(int answered, int sessionTotal) {
    return sessionTotal >= mbtiCognitiveAccurateCheckpoint ||
        answered >= mbtiCognitiveStandardCheckpoint;
  }

  bool _usesStandardQuestionSet(int answered, int sessionTotal) {
    return sessionTotal >= mbtiCognitiveStandardCheckpoint ||
        answered >= mbtiCognitiveMiniCheckpoint;
  }

  void _applyQuestionSetForProgress({required int answered, int? sessionTotal}) {
    final sessionT = sessionTotal ?? answered;
    if (_usesAccurateQuestionSet(answered, sessionT)) {
      questions = List.unmodifiable(mbtiCognitiveAccurateActiveQuestions);
    } else if (_usesStandardQuestionSet(answered, sessionT)) {
      questions = List.unmodifiable(mbtiCognitiveStandardActiveQuestions);
    } else {
      questions = List.unmodifiable(mbtiCognitiveMiniActiveQuestions);
    }
  }

  MbtiCognitiveResultSummary resultForDisplay(MbtiCognitiveResultSummary stored) {
    final fromAnswers = answers.length;
    if (fromAnswers <= stored.scoredQuestionCount) return stored;
    return MbtiCognitiveResultSummary(
      testId: stored.testId,
      scores: stored.scores,
      topFunctions: stored.topFunctions,
      scoredAt: stored.scoredAt,
      scoringVersion: stored.scoringVersion,
      stackTypeHints: stored.stackTypeHints,
      scoredQuestionCount: fromAnswers,
    );
  }

  Future<void> initialize() async {
    status = MbtiCognitiveSessionStatus.loading;
    errorMessage = null;
    existingCompletedResult = null;
    notifyListeners();

    _applyQuestionSetForProgress(
      answered: 0,
      sessionTotal: mbtiCognitiveMiniCheckpoint,
    );

    if (questions.isEmpty) {
      status = MbtiCognitiveSessionStatus.empty;
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
            status = MbtiCognitiveSessionStatus.ready;
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
          index = _clampIndex(_indexFromAnsweredCount(session.answered));
        }
      } catch (e) {
        errorMessage = e.toString();
        status = MbtiCognitiveSessionStatus.error;
        notifyListeners();
        return;
      }
    }

    status = MbtiCognitiveSessionStatus.ready;
    notifyListeners();
  }

  int _clampIndex(int value) {
    if (total == 0) return 0;
    if (value < 0) return 0;
    if (value >= total) return total - 1;
    return value;
  }

  int _indexFromAnsweredCount(int answered) {
    if (answered <= 0) return 0;
    return _clampIndex(answered);
  }

  void selectAnswer(int score) {
    final q = currentQuestion;
    if (q == null) return;

    answers = {...answers, q.id: score};
    notifyListeners();
    _persistProgress();
  }

  void goBack() {
    if (!canGoBack) return;
    index--;
    notifyListeners();
  }

  void goNext() {
    if (!canGoNext || !currentQuestionAnswered) return;
    index++;
    notifyListeners();
  }

  Future<void> resumeToStandardCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferStandardContinue) return;

    questions = List.unmodifiable(mbtiCognitiveStandardActiveQuestions);
    index = mbtiCognitiveMiniCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          total: mbtiCognitiveStandardCheckpoint,
          answers: answers,
        );
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return;
      }
    }

    status = MbtiCognitiveSessionStatus.ready;
    notifyListeners();
  }

  Future<void> resumeToAccurateCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferAccurateContinue) return;

    questions = List.unmodifiable(mbtiCognitiveAccurateActiveQuestions);
    index = mbtiCognitiveStandardCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          total: mbtiCognitiveAccurateCheckpoint,
          answers: answers,
        );
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return;
      }
    }

    status = MbtiCognitiveSessionStatus.ready;
    notifyListeners();
  }

  Future<MbtiCognitiveResultSummary?> finish() async {
    if (!canFinishTest) return null;

    final summary = _scorer.score(
      questions: questions,
      answers: answers,
      scoredQuestionCount: questions.length,
    );

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.saveResult(uid, summary);
        await _repository.markCompleted(uid);
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return null;
      }
    }

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
    questions = List.unmodifiable(mbtiCognitiveMiniActiveQuestions);
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

  Future<void> _persistProgress() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _repository.saveProgress(
        uid: uid,
        answeredCount: answers.length,
        total: total,
        answers: answers,
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
