import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V2.3 — Emotional close before footer (KnowMe Moment).
class FusionKnowMeMomentSection extends StatelessWidget {
  const FusionKnowMeMomentSection({
    super.key,
    required this.data,
  });

  final FusionKnowMeMomentViewModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FusionResultDesign.gold.withValues(alpha: 0.08),
            FusionResultDesign.purple.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: FusionResultDesign.gold.withValues(alpha: 0.2),
        ),
      ),
      child: FusionReflectionStrip(
        title: data.title,
        body: data.body,
        centered: true,
      ),
    );
  }
}
