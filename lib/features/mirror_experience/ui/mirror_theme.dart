import 'package:flutter/material.dart';

import '../mirror_view_models.dart';

/// P3 — the shared visual language of the Mirror Experience.
///
/// Warm, calm, emotion-first. Tone colours are gentle, never alarming — even a
/// "tender" area reads as care, not danger.
abstract final class MirrorTheme {
  static const Color seed = Color(0xFF7E57C2);

  static const Color strong = Color(0xFF2E7D5B);
  static const Color steady = Color(0xFF5B6B7E);
  static const Color tender = Color(0xFFB5651D);

  static Color toneColor(MirrorTone tone) {
    switch (tone) {
      case MirrorTone.strong:
        return strong;
      case MirrorTone.steady:
        return steady;
      case MirrorTone.tender:
        return tender;
    }
  }

  static IconData toneIcon(MirrorTone tone) {
    switch (tone) {
      case MirrorTone.strong:
        return Icons.trending_up_rounded;
      case MirrorTone.steady:
        return Icons.horizontal_rule_rounded;
      case MirrorTone.tender:
        return Icons.spa_rounded;
    }
  }

  static ThemeData themeData() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      );
}

/// A small, reusable tone chip for a life area.
class MirrorAreaChip extends StatelessWidget {
  const MirrorAreaChip({super.key, required this.area});

  final MirrorLifeArea area;

  @override
  Widget build(BuildContext context) {
    final color = MirrorTheme.toneColor(area.tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MirrorTheme.toneIcon(area.tone), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            area.title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A subtle "clarity" pill (how clear the read is).
class MirrorClarityPill extends StatelessWidget {
  const MirrorClarityPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_rounded, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Read is $label',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
