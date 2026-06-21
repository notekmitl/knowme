import 'package:flutter/material.dart';

import '../domain/home_profile_completion.dart';
import 'home_v35_design.dart';

/// Profile completion funnel bar — Production Funnel Recovery V2.
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
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HomeV35Design.textPrimary,
                ),
              ),
              const Spacer(),
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
            spacing: 10,
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

    final color = switch (step.status) {
      HomeCompletionStepStatus.complete => HomeV35Design.purpleAccent,
      HomeCompletionStepStatus.pending => HomeV35Design.textSecondary,
      HomeCompletionStepStatus.locked => HomeV35Design.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HomeV35Design.purpleSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
