import 'package:flutter/material.dart';

import '../mirror_view_models.dart';
import 'mirror_cards_common.dart';
import 'mirror_theme.dart';

/// P3 — the forward-looking "season ahead" card.
class MirrorPredictionCard extends StatelessWidget {
  const MirrorPredictionCard({super.key, required this.prediction});

  final MirrorPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MirrorCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(prediction.headline, style: text.titleLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(prediction.body, style: text.bodyLarge),
          const SizedBox(height: 16),
          MirrorAreasWrap(areas: prediction.areas),
          const SizedBox(height: 14),
          MirrorClarityPill(label: prediction.clarity.label),
          MirrorWhyTile(
            areas: prediction.areas,
            clarity: prediction.clarity,
            cardId: 'prediction',
          ),
        ],
      ),
    );
  }
}
