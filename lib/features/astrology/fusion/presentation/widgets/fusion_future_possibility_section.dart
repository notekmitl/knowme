import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V4 — Future possibility layer (reflection only, no fortune-telling).
class FusionFuturePossibilitySection extends StatelessWidget {
  const FusionFuturePossibilitySection({
    super.key,
    required this.data,
  });

  final FusionFuturePossibilityViewModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          data.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FusionResultDesign.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: FusionResultDesign.purple.withValues(alpha: 0.12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                FusionStoryBlock(
                  title: data.opportunityLabel,
                  body: data.opportunity,
                ),
                Divider(
                  height: 1,
                  color: FusionResultDesign.purple.withValues(alpha: 0.15),
                ),
                FusionStoryBlock(
                  title: data.challengeLabel,
                  body: data.challenge,
                ),
                Divider(
                  height: 1,
                  color: FusionResultDesign.purple.withValues(alpha: 0.15),
                ),
                FusionStoryBlock(
                  title: data.futureQuestionLabel,
                  body: data.futureReflection,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
