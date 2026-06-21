import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V5 — Symbolic life lesson band.
class FusionLifeLessonSection extends StatelessWidget {
  const FusionLifeLessonSection({
    super.key,
    required this.data,
  });

  final FusionLifeLessonViewModel data;

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
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: FusionResultDesign.purple.withValues(alpha: 0.15),
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
