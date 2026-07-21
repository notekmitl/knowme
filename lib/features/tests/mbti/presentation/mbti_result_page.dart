import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/mbti/mbti_types.dart';

import '../data/mbti_firestore_repository.dart';
import '../domain/mbti_models.dart';
import 'mbti_mini_test_page.dart';
import 'mbti_result_localized_content.dart';
import 'widgets/mbti_result_dimension_bars.dart';
import 'widgets/mbti_result_hero.dart';
import 'widgets/mbti_result_insight_card.dart';
import 'widgets/mbti_result_progress_timeline.dart';

/// Unified MBTI result — progressive flow lands here after finish.
class MbtiResultPage extends StatelessWidget {
  final MbtiResultSummary summary;
  final bool canContinueToStandard;
  final bool canContinueToAccurate;
  final Map<String, int>? pendingAnswersForContinue;

  const MbtiResultPage({
    super.key,
    required this.summary,
    this.canContinueToStandard = false,
    this.canContinueToAccurate = false,
    this.pendingAnswersForContinue,
  });

  void _continueToStandard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MbtiMiniTestPage(
          continueToStandardCheckpoint: true,
          restoredAnswers: pendingAnswersForContinue,
        ),
      ),
    );
  }

  void _continueToAccurate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MbtiMiniTestPage(
          continueToAccurateCheckpoint: true,
          restoredAnswers: pendingAnswersForContinue,
        ),
      ),
    );
  }

  Future<void> _retakeMini(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppText.t('mbti_result_retake_dialog_title')),
          content: Text(AppText.t('mbti_result_retake_dialog_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppText.t('mbti_result_common_cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppText.t('mbti_result_retake_dialog_confirm')),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await MbtiFirestoreRepositoryImpl().clearSession(uid);
    }

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MbtiMiniTestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;
    final type = summary.type;
    final mbti = mbtiTypes[type];
    final content = MbtiResultLocalizedContent(typeCode: type, lang: lang);
    final roleTitle = mbti?.title[lang] ?? mbti?.title['en'] ?? '';
    final summaryText =
        content.summary(AppText.t('mbti_result_unknown_type_body'));
    final dimensionPairs = dimensionPairsFromSummary(summary);

    return Scaffold(
      appBar: AppBar(title: Text(AppText.t('your_type'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MbtiResultHero(
              typeCode: type,
              roleTitle: roleTitle,
              summaryText: summaryText,
              keywordChips: content.strengths,
            ),
            const SizedBox(height: 14),
            MbtiResultDimensionBars(pairs: dimensionPairs),
            if (content.strengths.isNotEmpty) ...[
              const SizedBox(height: 16),
              MbtiResultInsightCard(
                titleKey: 'mbti_result_section_strengths',
                icon: Icons.auto_awesome_rounded,
                accentColor: Colors.green.shade600,
                children: content.strengths
                    .map((s) => MbtiResultInsightCheckItem(text: s))
                    .toList(),
              ),
            ],
            if (content.cautions.isNotEmpty) ...[
              const SizedBox(height: 16),
              MbtiResultInsightCard(
                titleKey: 'mbti_result_section_cautions',
                icon: Icons.tips_and_updates_outlined,
                accentColor: Colors.amber.shade800,
                children: content.cautions
                    .map(
                      (c) => MbtiResultInsightBulletItem(
                        text: c,
                        bulletColor: Colors.amber.shade700,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (content.careers.isNotEmpty) ...[
              const SizedBox(height: 16),
              MbtiResultInsightCard(
                titleKey: 'mbti_result_section_careers',
                icon: Icons.work_outline_rounded,
                accentColor: Theme.of(context).colorScheme.primary,
                children: content.careers
                    .map((c) => MbtiResultInsightBulletItem(text: c))
                    .toList(),
              ),
            ],
            if (content.relationshipsParagraph().isNotEmpty) ...[
              const SizedBox(height: 16),
              MbtiResultInsightCard(
                titleKey: 'mbti_result_section_relationships',
                icon: Icons.favorite_border_rounded,
                accentColor: Colors.pink.shade400,
                children: [
                  Text(
                    content.relationshipsParagraph(),
                    style: const TextStyle(fontSize: 15, height: 1.45),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            MbtiResultProgressTimeline(
              scoredQuestionCount: summary.scoredQuestionCount,
            ),
            const SizedBox(height: 28),
            if (canContinueToStandard) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToStandard(context),
                  child: Text(AppText.t('mbti_result_continue_standard')),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (canContinueToAccurate) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToAccurate(context),
                  child: Text(AppText.t('mbti_result_continue_accurate')),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _retakeMini(context),
                child: Text(AppText.t('mbti_result_retake_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
