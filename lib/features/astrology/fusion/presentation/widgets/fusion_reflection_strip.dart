import 'package:flutter/material.dart';

import '../fusion_result_design.dart';

/// Non-card reflection band — V2.3 / Global Fusion ready.
class FusionReflectionStrip extends StatelessWidget {
  const FusionReflectionStrip({
    super.key,
    required this.title,
    required this.body,
    this.accentIcon,
    this.centered = false,
    this.compact = false,
  });

  final String title;
  final String body;
  final IconData? accentIcon;
  final bool centered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 24,
        vertical: compact ? 20 : 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            FusionResultDesign.purple.withValues(alpha: 0.1),
            Colors.transparent,
            FusionResultDesign.gold.withValues(alpha: 0.06),
          ],
        ),
        border: Border(
          left: centered
              ? BorderSide.none
              : BorderSide(
                  color: FusionResultDesign.gold.withValues(alpha: 0.45),
                  width: 3,
                ),
        ),
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (accentIcon != null) ...[
            Icon(accentIcon, color: FusionResultDesign.gold, size: 22),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: FusionResultDesign.goldSoft,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: compact ? 14 : 15,
              height: 1.7,
              color: FusionResultDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Story block within a narrative band — not a card.
class FusionStoryBlock extends StatelessWidget {
  const FusionStoryBlock({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FusionReflectionStrip(
        title: title,
        body: body,
        compact: true,
      ),
    );
  }
}
