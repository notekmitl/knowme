import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../data/mbti_cognitive_firestore_repository.dart';
import '../domain/mbti_cognitive_models.dart';
import 'mbti_cognitive_result_content.dart';
import 'mbti_cognitive_test_page.dart';
import 'widgets/mbti_cognitive_function_bars.dart';
import 'widgets/mbti_cognitive_progress_timeline.dart';

class MbtiCognitiveResultPage extends StatelessWidget {
  const MbtiCognitiveResultPage({
    super.key,
    required this.summary,
    this.canContinueToStandard = false,
    this.canContinueToAccurate = false,
    this.pendingAnswersForContinue,
    this.onRestart,
  });

  final MbtiCognitiveResultSummary summary;
  final bool canContinueToStandard;
  final bool canContinueToAccurate;
  final Map<String, int>? pendingAnswersForContinue;
  final VoidCallback? onRestart;

  void _continueToStandard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MbtiCognitiveTestPage(
          continueToStandardCheckpoint: true,
          restoredAnswers: pendingAnswersForContinue,
        ),
      ),
    );
  }

  void _continueToAccurate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MbtiCognitiveTestPage(
          continueToAccurateCheckpoint: true,
          restoredAnswers: pendingAnswersForContinue,
        ),
      ),
    );
  }

  Future<void> _retake(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppText.t('mbti_cog_retake_dialog_title')),
          content: Text(AppText.t('mbti_cog_retake_dialog_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppText.t('mbti_cog_retake_cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppText.t('mbti_cog_retake_confirm')),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    if (onRestart != null) {
      onRestart!();
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await MbtiCognitiveFirestoreRepositoryImpl().clearSession(uid);
    }

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MbtiCognitiveTestPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thinkingSummary = MbtiCognitiveResultContent.thinkingStyleSummary(
      summary.topFour,
    );
    final stackHint =
        MbtiCognitiveResultContent.stackProfileSummary(summary.stackTypeHints);
    final confidenceLabel =
        MbtiCognitiveResultContent.confidenceTierLabel(summary.scoredQuestionCount);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('mbti_cog_result_title')),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _ProfileHero(
              thinkingSummary: thinkingSummary,
              stackHint: stackHint,
              confidenceLabel: confidenceLabel,
            ),
            const SizedBox(height: 14),
            Text(
              AppText.t('mbti_cog_disclaimer'),
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            MbtiCognitivePreferenceRanking(
              orderedFunctions: summary.topFunctions,
            ),
            const SizedBox(height: 14),
            MbtiCognitiveProgressTimeline(
              scoredQuestionCount: summary.scoredQuestionCount,
            ),
            const SizedBox(height: 20),
            if (canContinueToStandard) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToStandard(context),
                  child: Text(AppText.t('mbti_cog_continue_standard')),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (canContinueToAccurate) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToAccurate(context),
                  child: Text(AppText.t('mbti_cog_continue_accurate')),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _retake(context),
                child: Text(AppText.t('mbti_cog_restart')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.thinkingSummary,
    required this.stackHint,
    required this.confidenceLabel,
  });

  final String thinkingSummary;
  final String stackHint;
  final String confidenceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade800,
            Colors.indigo.shade600,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              confidenceLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppText.t('mbti_cog_think_heading'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            thinkingSummary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            stackHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
