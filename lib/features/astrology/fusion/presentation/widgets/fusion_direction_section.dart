import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V6 — Future direction paths (not fortune-telling).
class FusionDirectionSection extends StatelessWidget {
  const FusionDirectionSection({
    super.key,
    required this.data,
  });

  final FusionDirectionViewModel data;

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
                  title: data.directionALabel,
                  body: data.directionA,
                ),
                Divider(
                  height: 1,
                  color: FusionResultDesign.purple.withValues(alpha: 0.15),
                ),
                FusionStoryBlock(
                  title: data.directionBLabel,
                  body: data.directionB,
                ),
                Divider(
                  height: 1,
                  color: FusionResultDesign.purple.withValues(alpha: 0.15),
                ),
                FusionStoryBlock(
                  title: data.reflectionQuestionLabel,
                  body: data.reflectionQuestion,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
