import 'package:flutter/material.dart';

import '../../domain/entities/fusion_insight.dart';

class FusionInsightSection extends StatelessWidget {
  const FusionInsightSection({
    super.key,
    required this.insight,
  });

  final FusionInsightResult insight;

  @override
  Widget build(BuildContext context) {
    if (!insight.hasAny) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ความหมายจากการรวมหลายศาสตร์',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (insight.primary != null)
          _InsightCard(
            label: 'Primary Insight',
            insight: insight.primary!,
            scheme: scheme,
            emphasized: true,
          ),
        if (insight.primary != null && insight.secondary != null)
          const SizedBox(height: 12),
        if (insight.secondary != null)
          _InsightCard(
            label: 'Secondary Insight',
            insight: insight.secondary!,
            scheme: scheme,
            emphasized: false,
          ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.insight,
    required this.scheme,
    required this.emphasized,
  });

  final String label;
  final FusionInsight insight;
  final ColorScheme scheme;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emphasized
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
        color: emphasized
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            insight.description,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ],
      ),
    );
  }
}
