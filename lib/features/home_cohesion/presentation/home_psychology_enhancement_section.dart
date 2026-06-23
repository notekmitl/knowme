import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v3_copy.dart';
import 'home_v3_psychology_tests_section.dart';
import 'home_v35_design.dart';

/// Secondary psychology layer — clearly separated from astrology.
class HomePsychologyEnhancementSection extends StatelessWidget {
  const HomePsychologyEnhancementSection({
    super.key,
    required this.data,
    required this.onPsychologyTest,
  });

  final HomePsychologyTestsSectionData data;
  final void Function(HomePsychologyTestItemData test) onPsychologyTest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeV35Design.surface,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        border: Border.all(color: const Color(0xFFE8E2F0)),
        boxShadow: [HomeV35Design.cardShadow],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  color: HomeV35Design.purpleAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeV3Copy.psychologyExpansionTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HomeV35Design.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HomeV3Copy.psychologyExpansionSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: HomeV35Design.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeV3PsychologyTestsSection(
            data: data,
            onTestAction: onPsychologyTest,
            showSectionHeader: false,
          ),
        ],
      ),
    );
  }
}
