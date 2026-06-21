import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v2_copy.dart';

class HomeAstrologySummarySection extends StatelessWidget {
  const HomeAstrologySummarySection({
    super.key,
    required this.data,
    required this.onViewFullResult,
  });

  final HomeAstrologySummarySectionData data;
  final void Function() onViewFullResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: const Color(0xFF2A1F3D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              HomeV2Copy.astrologyTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.72),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            if (!data.isAvailable) ...[
              Text(
                data.emptyHint,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ] else ...[
              Text(
                data.identity,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.summary,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              if (data.reflectionSummary.trim().isNotEmpty &&
                  data.reflectionSummary != data.summary) ...[
                const SizedBox(height: 14),
                Text(
                  data.reflectionSummary,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ],
            if (data.canOpenFullResult) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onViewFullResult,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Text(HomeV2Copy.viewAstrologyResult),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
