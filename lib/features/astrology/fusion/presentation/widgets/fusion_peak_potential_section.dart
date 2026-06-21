import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_v23_copy.dart';
import 'fusion_reflection_strip.dart';

/// V2.3 — When you are at your best (narrative band, not cards).
class FusionPeakPotentialSection extends StatelessWidget {
  const FusionPeakPotentialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FusionResultV23Copy.peakPotentialTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FusionResultDesign.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          FusionResultV23Copy.peakPotentialSubtitle,
          style: const TextStyle(
            fontSize: 15,
            height: 1.65,
            color: FusionResultDesign.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: FusionResultDesign.gold.withValues(alpha: 0.12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                for (var i = 0;
                    i < FusionResultV23Copy.peakPotentialItems.length;
                    i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: FusionResultDesign.purple.withValues(alpha: 0.15),
                    ),
                  FusionStoryBlock(
                    title: FusionResultV23Copy.peakPotentialItems[i].title,
                    body: FusionResultV23Copy.peakPotentialItems[i].body,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
