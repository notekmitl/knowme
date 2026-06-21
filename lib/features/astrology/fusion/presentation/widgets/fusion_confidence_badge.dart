import 'package:flutter/material.dart';

import '../fusion_result_design.dart';

/// Reusable consensus confidence indicator — V2.2 / Global Fusion ready.
enum FusionConsensusLevel { high, medium, low }

class FusionConfidenceBadge extends StatelessWidget {
  const FusionConfidenceBadge({
    super.key,
    required this.alignedCount,
    required this.totalCount,
    this.compact = false,
    this.showStars = true,
    this.showRatio = true,
    this.showLevelLabel = true,
  });

  final int alignedCount;
  final int totalCount;
  final bool compact;
  final bool showStars;
  final bool showRatio;
  final bool showLevelLabel;

  FusionConsensusLevel get level {
    if (totalCount <= 0) return FusionConsensusLevel.low;
    final ratio = alignedCount / totalCount;
    if (ratio >= 0.85) return FusionConsensusLevel.high;
    if (ratio >= 0.55) return FusionConsensusLevel.medium;
    return FusionConsensusLevel.low;
  }

  String get levelLabel => switch (level) {
        FusionConsensusLevel.high => 'High',
        FusionConsensusLevel.medium => 'Medium',
        FusionConsensusLevel.low => 'Emerging',
      };

  int get starCount => switch (level) {
        FusionConsensusLevel.high => 5,
        FusionConsensusLevel.medium => 3,
        FusionConsensusLevel.low => 2,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: FusionResultDesign.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: FusionResultDesign.gold.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: FusionResultDesign.gold.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStars) ...[
            Text(
              '★' * starCount + '☆' * (5 - starCount),
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: FusionResultDesign.gold,
                letterSpacing: 1,
                height: 1,
              ),
            ),
            if (showRatio || showLevelLabel) const SizedBox(width: 10),
          ],
          if (showRatio)
            Text(
              '$alignedCount/$totalCount',
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: FusionResultDesign.goldSoft,
              ),
            ),
          if (showRatio && showLevelLabel) const SizedBox(width: 8),
          if (showLevelLabel)
            Text(
              'Consensus $levelLabel',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: FusionResultDesign.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
        ],
      ),
    );
  }
}
