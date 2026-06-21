import 'package:flutter/material.dart';

import '../../domain/entities/growth_opportunity.dart';

class GrowthOpportunitiesSection extends StatelessWidget {
  const GrowthOpportunitiesSection({
    super.key,
    required this.opportunities,
  });

  final List<GrowthOpportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'โอกาสในการเติบโต',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Growth Opportunities',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final opportunity in opportunities) ...[
          Card(
            elevation: 0,
            color: scheme.tertiaryContainer.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opportunity.description,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
