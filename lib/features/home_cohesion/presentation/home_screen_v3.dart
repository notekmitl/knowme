import 'package:flutter/material.dart';

import 'home_compact_profile_section.dart';
import 'home_hero_section.dart';
import 'home_knowme_insight_section.dart';
import 'home_knowme_signature_section.dart';
import 'home_narrative_preview_section.dart';
import 'home_profile_completion_bar.dart';
import 'home_recovery_banner.dart';
import 'home_screen_v3_models.dart';
import 'home_v3_more_section.dart';
import 'home_v3_psychology_tests_section.dart';
import 'home_v35_design.dart';

/// Emotional Home surface — UX Conversion Sprint V1 hierarchy.
class HomeScreenV3 extends StatelessWidget {
  const HomeScreenV3({
    super.key,
    required this.data,
    required this.callbacks,
  });

  final HomeScreenV3Data data;
  final HomeScreenV3Callbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeProfileCompletionBar(completion: data.completion),
        const SizedBox(height: HomeV35Design.cardGap),
        HomeHeroSection(
          data: data.hero,
          onViewFullResult: callbacks.onViewAstrologyResult,
          onUnlockDeepProfile: callbacks.onUnlockDeepProfile,
        ),
        if (data.showRecoveryBanner) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeRecoveryBanner(onStartTest: callbacks.onUnlockDeepProfile),
        ],
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeV3PsychologyTestsSection(
          data: data.psychologyTests,
          onTestAction: callbacks.onPsychologyTest,
        ),
        if (data.narrativePreview.isVisible) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeNarrativePreviewSection(
            data: data.narrativePreview,
            onContinue: callbacks.onContinueDiscovering,
          ),
        ],
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeKnowMeSignatureSection(data: data.signature),
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeKnowMeInsightSection(
          data: data.insight,
          onViewFullInsight: callbacks.onViewFullInsight,
        ),
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeCompactProfileSection(
          data: data.profile,
          onEditProfile: callbacks.onEditProfile,
        ),
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeV3MoreSection(
          data: data.more,
          onItemSelected: callbacks.onMoreItem,
        ),
      ],
    );
  }
}
