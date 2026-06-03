import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:knowme/data/questions/mbti/mbti_progressive_questions.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../data/mbti_firestore_repository.dart';
import '../domain/mbti_models.dart';
import 'mbti_scorer.dart';

enum MbtiMiniSessionStatus { loading, ready, empty, error }

// TODO(progressive): checkpoint flow 16 → 40 → 80 on one session; use
// mbtiStandardQuestions / mbtiAccurateQuestions — not wired in this step.

/// In-memory session for MBTI mini — optional Firestore sync when user is signed in.
class MbtiMiniSessionState extends ChangeNotifier {
  MbtiMiniSessionState({
    MbtiFirestoreRepository? repository,
    MbtiScorer? scorer,
    FirebaseAuth? auth,
  }) : _repository = repository ?? MbtiFirestoreRepositoryImpl(),
       _scorer = scorer ?? const MbtiScorer(),
       _auth = auth ?? FirebaseAuth.instance;

  final MbtiFirestoreRepository _repository;
  final MbtiScorer _scorer;
  final FirebaseAuth _auth;

  MbtiMiniSessionStatus status = MbtiMiniSessionStatus.loading;
  String? errorMessage;

  /// Loaded when mini test session is completed — navigate to result, no dialog.
  MbtiResultSummary? existingCompletedResult;

  List<TestQuestion> questions = List.unmodifiable(mbtiMiniQuestions);
  int index = 0;
  Map<String, int> answers = {};

  bool get isLoading => status == MbtiMiniSessionStatus.loading;
  bool get hasQuestions => questions.isNotEmpty;
  int get total => questions.length;
  int get answeredCount => answers.length;
  double get progressValue =>
      total == 0 ? 0 : (index + 1) / total;

  TestQuestion? get currentQuestion =>
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

  int get currentQuestionIndex => index;

  int get totalQuestions => mbtiAccurateCheckpoint;

  MbtiCheckpoint get currentCheckpoint {
    final count = answeredCount;
    if (count >= mbtiAccurateCheckpoint) return MbtiCheckpoint.accurate;
    if (count >= mbtiStandardCheckpoint) return MbtiCheckpoint.standard;
    return MbtiCheckpoint.mini;
  }

  bool get isMiniCheckpointReached => answeredCount >= mbtiMiniCheckpoint;

  bool get isStandardCheckpointReached => answeredCount >= mbtiStandardCheckpoint;

  bool get isAccurateCheckpointReached => answeredCount >= mbtiAccurateCheckpoint;

  /// Mini (16) done, standard (40) not — eligible for result-page continue CTA.
  bool get canOfferStandardContinue =>
      isMiniCheckpointReached && !isStandardCheckpointReached;

  /// Standard (40) done, accurate (80) not — eligible for result-page continue CTA.
  bool get canOfferAccurateContinue =>
      isStandardCheckpointReached && !isAccurateCheckpointReached;

  bool get canOfferAnyContinue =>
      canOfferStandardContinue || canOfferAccurateContinue;

  String? get _uid => _auth.currentUser?.uid;

  bool _usesAccurateQuestionSet(int answered, int sessionTotal) {
    return sessionTotal >= mbtiAccurateCheckpoint ||
        answered >= mbtiStandardCheckpoint;
  }

  bool _usesStandardQuestionSet(int answered, int sessionTotal) {
    return sessionTotal >= mbtiStandardCheckpoint ||
        answered >= mbtiMiniCheckpoint;
  }

  void _applyQuestionSetForProgress({required int answered, int? sessionTotal}) {
    final total = sessionTotal ?? answered;
    if (_usesAccurateQuestionSet(answered, total)) {
      questions = List.unmodifiable(mbtiAccurateQuestions);
    } else if (_usesStandardQuestionSet(answered, total)) {
      questions = List.unmodifiable(mbtiStandardQuestions);
    } else {
      questions = List.unmodifiable(mbtiMiniQuestions);
    }
  }

  /// Aligns result UI when Firestore result lacks [scoredQuestionCount].
  MbtiResultSummary resultForDisplay(MbtiResultSummary stored) {
    final fromAnswers = answers.length;
    if (fromAnswers <= stored.scoredQuestionCount) return stored;
    return MbtiResultSummary(
      testId: stored.testId,
      type: stored.type,
      dimensions: stored.dimensions,
      scoredAt: stored.scoredAt,
      scoringVersion: stored.scoringVersion,
      scoredQuestionCount: fromAnswers,
    );
  }

  Future<void> initialize() async {
    status = MbtiMiniSessionStatus.loading;
    errorMessage = null;
    existingCompletedResult = null;
    notifyListeners();

    _applyQuestionSetForProgress(answered: 0, sessionTotal: mbtiMiniCheckpoint);

    if (questions.isEmpty) {
      status = MbtiMiniSessionStatus.empty;
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
            status = MbtiMiniSessionStatus.ready;
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
        status = MbtiMiniSessionStatus.error;
        notifyListeners();
        return;
      }
    }

    status = MbtiMiniSessionStatus.ready;
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

  /// Expands to 40 progressive questions and resumes at Q17 (index 16).
  ///
  /// [restoredAnswers] supports continue when progress was not persisted (guest).
  Future<void> resumeToStandardCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferStandardContinue) return;

    questions = List.unmodifiable(mbtiStandardQuestions);
    index = mbtiMiniCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          total: mbtiStandardCheckpoint,
          answers: answers,
        );
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return;
      }
    }

    status = MbtiMiniSessionStatus.ready;
    notifyListeners();
  }

  /// Expands to 80 progressive questions and resumes at Q41 (index 40).
  Future<void> resumeToAccurateCheckpoint({
    Map<String, int>? restoredAnswers,
  }) async {
    if (restoredAnswers != null && restoredAnswers.isNotEmpty) {
      answers = Map<String, int>.from(restoredAnswers);
    }
    if (!canOfferAccurateContinue) return;

    questions = List.unmodifiable(mbtiAccurateQuestions);
    index = mbtiStandardCheckpoint;
    existingCompletedResult = null;

    final uid = _uid;
    if (uid != null) {
      try {
        await _repository.unmarkCompleted(uid);
        await _repository.saveProgress(
          uid: uid,
          answeredCount: answers.length,
          total: mbtiAccurateCheckpoint,
          answers: answers,
        );
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return;
      }
    }

    status = MbtiMiniSessionStatus.ready;
    notifyListeners();
  }

  Future<MbtiResultSummary?> finish() async {
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
    questions = List.unmodifiable(mbtiMiniQuestions);
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
