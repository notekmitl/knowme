import 'package:flutter/material.dart';

import 'home_astrology_summary_card.dart';
import 'home_compact_profile_section.dart';
import 'home_hero_section.dart';
import 'home_narrative_preview_section.dart';
import 'home_profile_completion_bar.dart';
import 'home_psychology_enhancement_section.dart';
import 'home_recovery_banner.dart';
import 'home_screen_v3_models.dart';
import 'home_v35_design.dart';

/// Emotional Home surface — simplified astrology-first hierarchy.
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
          onViewFullResult: callbacks.onOpenAstrologyCenter,
          onUnlockDeepProfile: callbacks.onUnlockDeepProfile,
        ),
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeAstrologySummaryCard(
          data: data.astrologySummary,
          onOpenAstrologyCenter: callbacks.onOpenAstrologyCenter,
        ),
        const SizedBox(height: HomeV35Design.sectionGap),
        HomePsychologyEnhancementSection(
          data: data.psychologyTests,
          onPsychologyTest: callbacks.onPsychologyTest,
        ),
        if (data.showRecoveryBanner) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeRecoveryBanner(onStartTest: callbacks.onUnlockDeepProfile),
        ],
        if (callbacks.narrativeLoading) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: HomeV35Design.purpleSoft,
            color: HomeV35Design.purpleAccent,
          ),
        ],
        if (data.narrativePreview.isVisible) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeNarrativePreviewSection(
            data: data.narrativePreview,
            onContinue: callbacks.onContinueDiscovering,
          ),
        ],
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeCompactProfileSection(
          data: data.profile,
          onEditProfile: callbacks.onEditProfile,
        ),
      ],
    );
  }
}
