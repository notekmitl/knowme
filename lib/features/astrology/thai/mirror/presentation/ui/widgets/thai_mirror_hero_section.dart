import 'package:flutter/material.dart';

import '../../models/thai_mirror_hero_state.dart';

/// Hero block for Thai Mirror Result Page (P0).
class ThaiMirrorHeroSection extends StatelessWidget {
  const ThaiMirrorHeroSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorHeroState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.titleTh,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: -0.3,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          state.titleEn,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: muted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          state.reflectionSummary,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.62,
            color: scheme.onSurface,
          ),
        ),
        if (state.topThemeNames.isNotEmpty) ...[
          const SizedBox(height: 18),
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
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.55),
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
      ],
    );
  }
}
