import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

class ThaiMirrorConsumerHeroSection extends StatelessWidget {
  const ThaiMirrorConsumerHeroSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorConsumerHeroState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.secondaryContainer.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.headline,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.28,
              letterSpacing: -0.4,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            state.summary,
            style: TextStyle(
              fontSize: 16,
              height: 1.65,
              color: scheme.onSurface,
            ),
          ),
          if (state.tags.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
