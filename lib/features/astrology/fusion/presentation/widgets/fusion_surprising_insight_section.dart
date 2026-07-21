import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V4 — Most surprising cross-lens insight.
class FusionSurprisingInsightSection extends StatelessWidget {
  const FusionSurprisingInsightSection({
    super.key,
    required this.data,
  });

  final FusionSurprisingInsightViewModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FusionResultDesign.purple.withValues(alpha: 0.08),
            FusionResultDesign.gold.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: FusionResultDesign.purple.withValues(alpha: 0.2),
        ),
      ),
      child: FusionReflectionStrip(
        title: data.title,
        body: data.formattedBody,
        centered: true,
      ),
    );
  }
}
