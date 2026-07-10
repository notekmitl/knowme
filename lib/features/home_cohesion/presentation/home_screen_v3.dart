import 'package:flutter/material.dart';

import 'package:knowme/features/mirror_experience/mirror_experience_input.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_runtime.dart';
import 'package:knowme/features/mirror_experience/ui/daily_mirror_section.dart';

import 'home_astrology_summary_card.dart';
import 'home_compact_profile_section.dart';
import 'home_hero_section.dart';
import 'home_narrative_preview_section.dart';
import 'home_profile_completion_bar.dart';
import 'home_psychology_enhancement_section.dart';
import 'home_recovery_banner.dart';
import 'home_screen_v3_models.dart';
import 'home_v35_design.dart';

/// Emotional Home surface (Home V4 → Daily Mirror, Phase C) — the Mirror
/// Experience is the emotional entry. When a birth date is available the top of
/// Home is the Daily Mirror (today's read: opportunity / caution / focus, one
/// suggested step, one conversation entry; the full guided journey is
/// secondary); otherwise the legacy hero remains so profile completion / unlock
/// onboarding is preserved. Everything below the entry (astrology summary,
/// psychology, profile) is unchanged.
class HomeScreenV3 extends StatelessWidget {
  const HomeScreenV3({
    super.key,
    required this.data,
    required this.callbacks,
    this.mirrorBirthDate,
  });

  final HomeScreenV3Data data;
  final HomeScreenV3Callbacks callbacks;

  /// When non-null, the Daily Mirror replaces the legacy hero as the emotional
  /// entry of Home (Phase B — Home V4 · Phase C — Daily Mirror).
  final DateTime? mirrorBirthDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeProfileCompletionBar(completion: data.completion),
        const SizedBox(height: HomeV35Design.cardGap),
        if (mirrorBirthDate != null)
          DailyMirrorSection(
            input: MirrorExperienceInput(birthDate: mirrorBirthDate!),
            runtime: MirrorExperienceRuntime.fusion,
          )
        else
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
