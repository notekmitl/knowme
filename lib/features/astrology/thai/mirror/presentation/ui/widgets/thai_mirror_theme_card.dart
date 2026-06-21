import 'package:flutter/material.dart';

import '../../models/thai_mirror_theme_card_state.dart';

/// Single top-theme card for Thai Mirror Result Page.
class ThaiMirrorThemeCard extends StatelessWidget {
  const ThaiMirrorThemeCard({
    super.key,
    required this.state,
  });

  final ThaiMirrorThemeCardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${state.rank}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: muted.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.themeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              _ConfidenceBadge(label: state.confidenceLabel),
            ],
          ),
          if (state.description != null && state.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              state.description!,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: muted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            state.evidenceCount > 0
                ? '${state.evidenceCount} แหล่งอ้างอิง'
                : 'ยังไม่มีแหล่งอ้างอิง',
            style: TextStyle(
              fontSize: 12.5,
              color: muted.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
