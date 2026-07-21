import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V6 — Life chapter band after hero.
class FusionLifeChapterSection extends StatelessWidget {
  const FusionLifeChapterSection({
    super.key,
    required this.data,
  });

  final FusionLifeChapterViewModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FusionResultDesign.gold.withValues(alpha: 0.1),
            FusionResultDesign.purple.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: FusionResultDesign.gold.withValues(alpha: 0.22),
        ),
      ),
      child: FusionReflectionStrip(
        title: data.title,
        body: '${data.chapterTitle}\n\n${data.body}',
        centered: true,
      ),
    );
  }
}
