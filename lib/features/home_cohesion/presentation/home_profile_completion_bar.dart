import 'package:flutter/material.dart';

import '../domain/home_profile_completion.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Profile completion funnel bar — UX Conversion Sprint V1.
class HomeProfileCompletionBar extends StatelessWidget {
  const HomeProfileCompletionBar({
    super.key,
    required this.completion,
  });

  final HomeProfileCompletion completion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: HomeV35Design.surface,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        boxShadow: [HomeV35Design.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  HomeV3Copy.profileCompletionTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomeV35Design.textPrimary,
                  ),
                ),
              ),
              Text(
                '${completion.progressPercent}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HomeV35Design.purpleAccent,
                ),
              ),
            ],
          ),
          if (completion.progressSubtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              completion.progressSubtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: HomeV35Design.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completion.progressPercent / 100,
              minHeight: 8,
              backgroundColor: HomeV35Design.purpleSoft,
              color: HomeV35Design.purpleAccent,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final step in completion.steps) _StepChip(step: step),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.step});

  final HomeCompletionStep step;

  @override
  Widget build(BuildContext context) {
    final icon = switch (step.status) {
      HomeCompletionStepStatus.complete => '✓',
      HomeCompletionStepStatus.pending => '○',
      HomeCompletionStepStatus.locked => '🔒',
    };

    final isCurrent = step.isCurrent && step.status != HomeCompletionStepStatus.complete;

    final color = switch (step.status) {
      HomeCompletionStepStatus.complete => HomeV35Design.purpleAccent,
      HomeCompletionStepStatus.pending =>
        isCurrent ? HomeV35Design.purpleAccent : HomeV35Design.textSecondary,
      HomeCompletionStepStatus.locked => HomeV35Design.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? HomeV35Design.purpleSoft
            : HomeV35Design.purpleSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: isCurrent
            ? Border.all(color: HomeV35Design.purpleAccent, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${step.stepNumber}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
