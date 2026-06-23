import 'package:flutter/material.dart';

import 'home_astrology_hub_section.dart';
import 'home_compact_profile_section.dart';
import 'home_hero_section.dart';
import 'home_knowme_insight_section.dart';
import 'home_knowme_signature_section.dart';
import 'home_narrative_preview_section.dart';
import 'home_profile_completion_bar.dart';
import 'home_recovery_banner.dart';
import 'home_screen_v3_models.dart';
import 'home_v3_more_section.dart';
import 'home_v35_design.dart';

/// Emotional Home surface — astrology-first hierarchy.
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
        const SizedBox(height: HomeV35Design.sectionGap),
        HomeAstrologyHubSection(
          hub: data.astrologyHub,
          psychologyTests: data.psychologyTests,
          onOpenSystem: callbacks.onOpenAstrologySystem,
          onOpenFusion: callbacks.onOpenCrossSystemFusion,
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
        if (data.signature.isVisible || data.insight.cards.isNotEmpty) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeKnowMeSignatureSection(data: data.signature),
        ],
        if (data.insight.cards.isNotEmpty ||
            data.insight.emptyHint.isNotEmpty) ...[
          const SizedBox(height: HomeV35Design.sectionGap),
          HomeKnowMeInsightSection(
            data: data.insight,
            onViewFullInsight: callbacks.onViewFullInsight,
          ),
        ],
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
