import 'package:flutter/material.dart';

import '../mirror_view_models.dart';
import 'mirror_cards_common.dart';
import 'mirror_theme.dart';

/// P3 — the gentle decision card. It never commands; it leans.
class MirrorDecisionCard extends StatelessWidget {
  const MirrorDecisionCard({super.key, required this.decision});

  final MirrorDecision decision;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = _leanColor(decision.lean);
    return MirrorCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(_leanIcon(decision.lean), color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    decision.headline,
                    style: text.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(decision.body, style: text.bodyLarge),
          const SizedBox(height: 16),
          MirrorAreasWrap(areas: [decision.focus]),
          const SizedBox(height: 14),
          MirrorClarityPill(label: decision.clarity.label),
          MirrorWhyTile(
            areas: [decision.focus],
            clarity: decision.clarity,
            cardId: 'decision',
          ),
        ],
      ),
    );
  }

  Color _leanColor(MirrorLean lean) {
    switch (lean) {
      case MirrorLean.goFor:
        return MirrorTheme.strong;
      case MirrorLean.prepare:
        return MirrorTheme.steady;
      case MirrorLean.wait:
        return MirrorTheme.tender;
    }
  }

  IconData _leanIcon(MirrorLean lean) {
    switch (lean) {
      case MirrorLean.goFor:
        return Icons.bolt_rounded;
      case MirrorLean.prepare:
        return Icons.construction_rounded;
      case MirrorLean.wait:
        return Icons.hourglass_bottom_rounded;
    }
  }
}
