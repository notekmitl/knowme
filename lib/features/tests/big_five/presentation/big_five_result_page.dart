import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/big_five_result_content.dart';
import '../big_five_routes.dart';
import '../domain/big_five_models.dart';
import 'widgets/big_five_cross_trait_pattern.dart';
import 'widgets/big_five_depth_timeline.dart';
import 'widgets/big_five_result_hero.dart';
import 'widgets/big_five_trait_card.dart';

/// Big Five Result V1 — behavioral mirror (no scores, no diagnosis).
class BigFiveResultPage extends StatelessWidget {
  const BigFiveResultPage({
    super.key,
    required this.summary,
    this.canContinueToStandard = false,
    this.canContinueToDeep = false,
    this.pendingAnswersForContinue,
    this.onContinueToStandard,
    this.onContinueToDeep,
  });

  final BigFiveResultSummary summary;
  final bool canContinueToStandard;
  final bool canContinueToDeep;
  final Map<String, int>? pendingAnswersForContinue;
  final VoidCallback? onContinueToStandard;
  final VoidCallback? onContinueToDeep;

  void _continueToStandard(BuildContext context) {
    if (onContinueToStandard != null) {
      onContinueToStandard!();
      return;
    }
    Navigator.pushReplacement(
      context,
      BigFiveRoutes.testRoute(
        continueToStandardCheckpoint: true,
        restoredAnswers: pendingAnswersForContinue,
      ),
    );
  }

  void _continueToDeep(BuildContext context) {
    if (onContinueToDeep != null) {
      onContinueToDeep!();
      return;
    }
    Navigator.pushReplacement(
      context,
      BigFiveRoutes.testRoute(
        continueToDeepCheckpoint: true,
        restoredAnswers: pendingAnswersForContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BigFiveResultContent.build(summary);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('big_five_result_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BigFiveResultHero(paragraphs: content.heroParagraphs),
            const SizedBox(height: 16),
            Text(
              AppText.t('big_five_result_traits_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final trait in content.traitCards)
              BigFiveTraitCard(content: trait),
            if (content.patternText != null) ...[
              const SizedBox(height: 4),
              BigFiveCrossTraitPattern(
                depthTier: summary.depthTier,
                patternText: content.patternText!,
              ),
            ],
            const SizedBox(height: 16),
            BigFiveDepthTimeline(
              scoredQuestionCount: summary.scoredQuestionCount,
            ),
            const SizedBox(height: 12),
            Text(
              content.depthHint,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: muted,
              ),
            ),
            if (canContinueToStandard) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToStandard(context),
                  child: Text(AppText.t('big_five_continue_standard')),
                ),
              ),
            ],
            if (canContinueToDeep) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueToDeep(context),
                  child: Text(AppText.t('big_five_continue_deep')),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              content.disclosure,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: muted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
