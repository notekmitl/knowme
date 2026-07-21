import 'package:flutter/material.dart';

import 'home_astrology_summary_section.dart';
import 'home_combined_reflection_section.dart';
import 'home_more_section.dart';
import 'home_profile_section.dart';
import 'home_psychology_tests_section.dart';
import 'home_screen_v2_models.dart';

/// User-centric Home surface (Home V2 — Section 43.2).
class HomeScreenV2 extends StatelessWidget {
  const HomeScreenV2({
    super.key,
    required this.data,
    required this.callbacks,
  });

  final HomeScreenV2Data data;
  final HomeScreenV2Callbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeProfileSection(
          data: data.profile,
          onEditProfile: callbacks.onEditProfile,
        ),
        const SizedBox(height: 20),
        HomeAstrologySummarySection(
          data: data.astrologySummary,
          onViewFullResult: callbacks.onViewAstrologyResult,
        ),
        const SizedBox(height: 24),
        HomeCombinedReflectionSection(
          data: data.combinedReflection,
          onViewFullResult: callbacks.onViewCombinedReflection,
        ),
        const SizedBox(height: 24),
        HomePsychologyTestsSection(
          data: data.psychologyTests,
          onTestAction: callbacks.onPsychologyTest,
        ),
        const SizedBox(height: 24),
        HomeMoreSection(
          data: data.more,
          onItemSelected: callbacks.onMoreItem,
        ),
      ],
    );
  }
}
