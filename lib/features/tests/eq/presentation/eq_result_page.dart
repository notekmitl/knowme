import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/eq_test_session_state.dart';
import '../data/eq_firestore_repository.dart';
import '../domain/eq_models.dart';
import '../domain/eq_test_type.dart';
import 'eq_result_content.dart';
import 'eq_test_page.dart';

class EqResultPage extends StatelessWidget {
  const EqResultPage({
    super.key,
    required this.summary,
    this.session,
    this.testType = EqTestType.awareness,
  });

  final EqResultSummary summary;
  final EqTestSessionState? session;
  final EqTestType testType;

  Future<void> _retake(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppText.t('eq_retake_dialog_title')),
          content: Text(AppText.t('eq_retake_dialog_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppText.t('eq_retake_cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppText.t('eq_retake_confirm')),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    if (session != null) {
      await session!.restart();
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await EqFirestoreRepositoryImpl().clearSession(uid, testType.testId);
      }
    }

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EqTestPage(
          testType: testType,
          startFreshAfterRetake: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final hero = EqResultContent.heroForLevel(testType, summary.level);
    final tendency =
        EqResultContent.tendencyForLevel(testType, summary.level);
    final guidance =
        EqResultContent.guidanceForLevel(testType, summary.level);
    final disclosure = EqResultContent.disclosureForLevel(
      testType,
      summary.level,
      summary.scoredQuestionCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(EqResultContent.resultTitle(testType)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EqResultContent.levelLabel(testType, summary.level),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hero,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.55,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.t('eq_result_tendency_heading'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tendency,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.t('eq_result_guidance_heading'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < guidance.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Text(
              guidance[i],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            AppText.t('eq_result_disclosure_heading'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            disclosure,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: muted,
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => _retake(context),
            child: Text(AppText.t('eq_retake_button')),
          ),
        ],
      ),
    );
  }
}
