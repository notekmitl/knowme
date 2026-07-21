import 'package:flutter/material.dart';

import '../../models/thai_mirror_hero_state.dart';

/// Insight-first summary block — 3–5 lines about the user.
class ThaiMirrorInsightSummarySection extends StatelessWidget {
  const ThaiMirrorInsightSummarySection({
    super.key,
    required this.state,
  });

  final ThaiMirrorHeroState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปคุณ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.reflectionSummary,
            style: TextStyle(
              fontSize: 16,
              height: 1.65,
              color: scheme.onSurface,
            ),
          ),
          if (state.topThemeNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.topThemeNames
                  .map(
                    (name) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            state.titleTh,
            style: TextStyle(
              fontSize: 12.5,
              color: muted.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
