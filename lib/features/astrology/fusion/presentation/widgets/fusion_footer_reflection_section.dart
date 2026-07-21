import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_interactive_card.dart';

/// Section 7 — Premium KnowMe closing reflection — V2.1.
class FusionFooterReflectionSection extends StatelessWidget {
  const FusionFooterReflectionSection({
    super.key,
    required this.data,
  });

  final FusionFooterReflectionViewModel data;

  @override
  Widget build(BuildContext context) {
    return FusionInteractiveCard(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: FusionResultDesign.cosmicCard(
        fill: const Color(0xFF16102C),
      ),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FusionResultDesign.gold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.75,
              color: FusionResultDesign.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
