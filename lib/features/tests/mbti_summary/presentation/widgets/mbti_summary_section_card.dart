import 'package:flutter/material.dart';

import 'mbti_summary_layout.dart';

class MbtiSummarySectionCard extends StatelessWidget {
  const MbtiSummarySectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accentColor,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MbtiSummaryLayout.cardPaddingH,
          MbtiSummaryLayout.cardPaddingV,
          MbtiSummaryLayout.cardPaddingH,
          MbtiSummaryLayout.cardPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: accent),
                  const SizedBox(width: MbtiSummaryLayout.spaceXs),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MbtiSummaryLayout.cardTitleGap),
            child,
          ],
        ),
      ),
    );
  }
}
