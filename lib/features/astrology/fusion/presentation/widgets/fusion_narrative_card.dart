import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_v21_copy.dart';
import '../fusion_result_v22_copy.dart';
import 'fusion_interactive_card.dart';
import 'fusion_premium_artwork.dart';

/// Personal narrative growth card — V2.2 / Global Fusion ready.
class FusionNarrativeCard extends StatelessWidget {
  const FusionNarrativeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.visualStyle,
  });

  final String title;
  final String description;
  final IconData icon;
  final FusionGrowthVisualStyle visualStyle;

  String get displayTitle => FusionResultV22Copy.narrativeTitle(title);

  String get narrativeBody => FusionResultV22Copy.personalGrowthNarrative(
        title: title,
        description: description,
      );

  @override
  Widget build(BuildContext context) {
    return FusionInteractiveCard(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
        border: Border.all(color: FusionResultDesign.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FusionGrowthArtwork(style: visualStyle),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.28),
                        border: Border.all(
                          color: FusionResultDesign.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(icon, color: FusionResultDesign.gold, size: 22),
                    ),
                    const Spacer(),
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: FusionResultDesign.gold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          narrativeBody,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.65,
                            color: FusionResultDesign.textSecondary.withValues(alpha: 0.98),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
