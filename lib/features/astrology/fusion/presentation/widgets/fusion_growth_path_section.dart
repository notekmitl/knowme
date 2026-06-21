import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_narrative_card.dart';

/// Section 5 — Personal narrative growth path — V2.2.
class FusionGrowthPathSection extends StatelessWidget {
  const FusionGrowthPathSection({
    super.key,
    required this.paths,
  });

  final List<FusionGrowthPathViewModel> paths;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Text('🌱', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'เส้นทางเติบโต',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FusionResultDesign.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: FusionResultDesign.purple.withValues(alpha: 0.45),
                width: 3,
              ),
            ),
            gradient: LinearGradient(
              colors: [
                FusionResultDesign.purple.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: const Text(
            'เมื่อคุณพร้อมลงมือทำจริง\n'
            'เส้นทางเหล่านี้มักช่วยให้คุณเติบโตอย่างมีความหมาย',
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: FusionResultDesign.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cardWidth = isWide
                ? (constraints.maxWidth - FusionResultDesign.cardGap * 2) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: FusionResultDesign.cardGap,
              runSpacing: FusionResultDesign.cardGap,
              children: [
                for (final path in paths)
                  SizedBox(
                    width: cardWidth,
                    child: FusionNarrativeCard(
                      title: path.title,
                      description: path.description,
                      icon: path.icon,
                      visualStyle: path.visualStyle,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
