import 'package:flutter/material.dart';

import '../mirror_view_models.dart';
import 'mirror_cards_common.dart';
import 'mirror_theme.dart';

/// P3 — the opening "your current life" card. Emotion first, evidence behind a
/// tap. Speaks about life areas, never astrology.
class MirrorInsightCard extends StatelessWidget {
  const MirrorInsightCard({super.key, required this.insight});

  final MirrorInsight insight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MirrorCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.headline, style: text.titleLarge),
          const SizedBox(height: 12),
          Text(insight.body, style: text.bodyLarge),
          const SizedBox(height: 16),
          MirrorAreasWrap(areas: insight.areas),
          const SizedBox(height: 14),
          MirrorClarityPill(label: insight.clarity.label),
          MirrorWhyTile(
            areas: insight.areas,
            clarity: insight.clarity,
            cardId: 'currentLife',
          ),
        ],
      ),
    );
  }
}
