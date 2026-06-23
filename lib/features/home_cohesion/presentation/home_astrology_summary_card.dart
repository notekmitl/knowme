import 'package:flutter/material.dart';

import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';

/// Compact Home entry to astrology — status summary + single CTA.
class HomeAstrologySummaryCard extends StatelessWidget {
  const HomeAstrologySummaryCard({
    super.key,
    required this.data,
    required this.onOpenAstrologyCenter,
  });

  final HomeAstrologySummaryCardData data;
  final VoidCallback onOpenAstrologyCenter;

  @override
  Widget build(BuildContext context) {
    if (data.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeV3Copy.astrologyHubTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: HomeV35Design.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AstrologyFlowCopy.computingBody,
            style: const TextStyle(
              fontSize: 13,
              color: HomeV35Design.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const AstrologySummaryShimmer(),
        ],
      );
    }

    return Material(
      color: HomeV35Design.surface,
      borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: data.canOpen ? onOpenAstrologyCenter : null,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            border: Border.all(color: const Color(0xFFE8E2F0)),
            boxShadow: [HomeV35Design.cardShadow],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: HomeV35Design.purpleSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: HomeV35Design.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HomeV3Copy.astrologyHubTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: HomeV35Design.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.statusLine,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: HomeV35Design.textSecondary,
                          ),
                        ),
                        if (data.progressLine.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            data.progressLine,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: HomeV35Design.purpleAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onOpenAstrologyCenter,
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeV35Design.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    data.ctaLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
