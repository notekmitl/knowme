import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_reflection_strip.dart';

/// V5 — Recurring life patterns (not traits).
class FusionLifePatternSection extends StatelessWidget {
  const FusionLifePatternSection({
    super.key,
    required this.data,
  });

  final FusionLifePatternViewModel data;

  @override
  Widget build(BuildContext context) {
    return FusionReflectionStrip(
      title: data.title,
      body: data.body,
    );
  }
}
