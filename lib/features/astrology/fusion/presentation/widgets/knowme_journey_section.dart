import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:knowme/core/i18n/app_text.dart';

import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart';

import 'package:knowme/features/tests/big_five/big_five_routes.dart';
import 'package:knowme/features/tests/eq/eq_routes.dart';

import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

import 'package:knowme/features/tests/fusion/fusion_routes.dart';

import 'package:knowme/features/tests/mbti/mbti_routes.dart';

import 'package:knowme/features/tests/mbti_cognitive/mbti_cognitive_routes.dart';

import 'package:knowme/features/tests/mbti_summary/application/mbti_summary_loader.dart';

import 'package:knowme/features/tests/mbti_summary/mbti_summary_routes.dart';

import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/personality_mirror/personality_mirror_routes.dart';
import 'package:knowme/features/tests/mbti_summary/presentation/mbti_summary_gate_page.dart';

import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';

import 'package:knowme/presentation/pages/bazi/bazi_result_page.dart';



import '../../analytics/fusion_analytics.dart';

import '../../application/astrology_fusion_entry_service.dart';

import '../../domain/entities/astrology_fusion_entry_status.dart';

import '../astrology_fusion_routes.dart';



/// Home discovery hub — grouped lenses for self-understanding (composition only).

class HomeDiscoveryHub extends StatelessWidget {

  const HomeDiscoveryHub({

    super.key,

    required this.entryState,

    required this.globalFusionEntry,

    required this.personalityMirrorEntry,

  });



  final AstrologyFusionEntryState entryState;

  final FusionEntryState globalFusionEntry;

  final PersonalityMirrorEntryState personalityMirrorEntry;



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        _DiscoverySection(

          title: AppText.t('fusion_v11_lens_astrology'),

          description: AppText.t('home_discovery_astrology_section_desc'),

          children: [

            _DiscoveryTile(

              title: 'Western',

              subtitle: _lensSubtitle('western_natal'),

              onTap: () => Navigator.push(

                context,

                MaterialPageRoute(builder: (_) => const AstrologyResultPage()),

              ),

            ),

            _DiscoveryTile(

              title: 'BaZi',

              subtitle: _lensSubtitle('chinese_bazi'),

              onTap: () => Navigator.push(

                context,

                MaterialPageRoute(builder: (_) => const BaziResultPage()),

              ),

            ),

            _DiscoveryTile(

              title: 'Thai',

              subtitle: _lensSubtitle('thai_astrology'),

              onTap: _canOpenThai()

                  ? () => ThaiMirrorRoutes.openResult(context)

                  : null,

            ),

            _DiscoveryTile(

              title: 'Astrology Fusion',

              subtitle: _astrologyFusionSubtitle(),

              onTap: entryState.canOpen

                  ? () {

                      FusionAnalytics.tracker.trackJourneyStepOpened(

                        stepId: 'astrology_fusion',

                        status: entryState.readiness.status.name,

                        lensCount: entryState.readiness.completedLensCount,

                      );

                      AstrologyFusionRoutes.openResult(context);

                    }

                  : null,

              emphasized: true,

            ),

          ],

        ),

        const SizedBox(height: 24),

        _DiscoverySection(

          title: AppText.t('home_discovery_tests_title'),

          description: AppText.t('home_discovery_tests_section_desc'),

          children: [

            _DiscoveryTile(

              title: AppText.t('fusion_v11_lens_mbti'),

              subtitle: AppText.t('home_journey_mbti_body'),

              onTap: () => Navigator.push(context, MbtiRoutes.miniTestRoute()),

            ),

            _DiscoveryTile(

              title: AppText.t('fusion_v11_lens_cognitive'),

              subtitle: AppText.t('home_journey_cognitive_body'),

              onTap: () =>

                  Navigator.push(context, MbtiCognitiveRoutes.testRoute()),

            ),

            _DiscoveryTile(

              title: AppText.t('big_five_test_title'),

              subtitle: AppText.t('home_big_five_discovery_body'),

              onTap: () => BigFiveRoutes.openTest(context),

            ),

            _DiscoveryTile(

              title: AppText.t('fusion_v11_lens_eq'),

              subtitle: AppText.t('home_journey_eq_body'),

              onTap: () => Navigator.push(context, EqRoutes.home()),

            ),

            _DiscoveryTile(

              title: AppText.t('home_discovery_mbti_summary_title'),

              subtitle: AppText.t('home_journey_summary_body'),

              onTap: () => _openMbtiSummary(context),

            ),

            _DiscoveryTile(

              title: AppText.t('personality_mirror_home_title'),

              subtitle: _personalityMirrorSubtitle(),

              onTap: () => PersonalityMirrorRoutes.open(context),

              emphasized: true,

            ),

          ],

        ),

        const SizedBox(height: 24),

        _DiscoverySection(

          title: AppText.t('home_discovery_overview_title'),

          children: [

            _DiscoveryTile(

              title: AppText.t('fusion_v11_title'),

              subtitle: _globalFusionSubtitle(),

              onTap: globalFusionEntry.canOpen

                  ? () => FusionRoutes.openResult(context)

                  : null,

            ),

          ],

        ),

      ],

    );

  }



  bool _canOpenThai() {

    return entryState.readiness.completedLensIds.contains('thai_astrology');

  }



  String _lensSubtitle(String lensId) {

    final completed = entryState.readiness.completedLensIds.contains(lensId);

    return completed ? 'พร้อมแล้ว' : 'ยังไม่พร้อม';

  }



  String _globalFusionSubtitle() {

    if (!globalFusionEntry.canOpen) {

      return 'ยังไม่พร้อม';

    }

    return AppText.t('home_journey_fusion_body');

  }



  String _personalityMirrorSubtitle() {
    return switch (personalityMirrorEntry.tileStatus) {
      PersonalityMirrorTileStatus.locked =>
        AppText.t('personality_mirror_home_subtitle_locked'),
      PersonalityMirrorTileStatus.partial =>
        AppText.t('personality_mirror_home_subtitle_partial'),
      PersonalityMirrorTileStatus.ready =>
        AppText.t('personality_mirror_home_subtitle_ready'),
    };
  }

  String _astrologyFusionSubtitle() {

    return switch (entryState.readiness.status) {

      AstrologyFusionEntryStatus.unavailable =>

        'เริ่มต้นด้วยการทำดวงอย่างน้อย 1 ระบบ',

      AstrologyFusionEntryStatus.partiallyAvailable =>

        'Fusion เริ่มทำงานได้แล้ว — เพิ่มศาสตร์อื่นเพื่อมุมมองที่หลากหลายขึ้น',

      AstrologyFusionEntryStatus.available => 'Fusion พร้อมแล้ว',

    };

  }



  Future<void> _openMbtiSummary(BuildContext context) async {

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {

      await Navigator.push(context, MbtiSummaryRoutes.gateRoute());

      return;

    }



    final loader = MbtiSummaryLoader();

    final availability = await loader.loadAvailability(uid);

    if (!context.mounted) return;



    if (availability.canOpenFusion) {

      await Navigator.push(context, MbtiSummaryRoutes.fusionRoute());

    } else {

      await Navigator.push(

        context,

        MbtiSummaryRoutes.gateRoute(

          args: MbtiSummaryGateArgs(availability: availability),

        ),

      );

    }

  }

}



class _DiscoverySection extends StatelessWidget {

  const _DiscoverySection({

    required this.title,

    required this.children,

    this.description,

  });



  final String title;

  final String? description;

  final List<Widget> children;



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        Text(

          title,

          style: const TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w700,

          ),

        ),

        if (description != null) ...[

          const SizedBox(height: 6),

          Text(

            description!,

            style: TextStyle(

              fontSize: 13,

              height: 1.45,

              color: Colors.grey.shade700,

            ),

          ),

        ],

        const SizedBox(height: 12),

        ...children,

      ],

    );

  }

}



class _DiscoveryTile extends StatelessWidget {

  const _DiscoveryTile({

    required this.title,

    required this.subtitle,

    required this.onTap,

    this.emphasized = false,

  });



  final String title;

  final String subtitle;

  final VoidCallback? onTap;

  final bool emphasized;



  @override

  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;



    return Card(

      margin: const EdgeInsets.only(bottom: 10),

      color: emphasized ? scheme.primaryContainer.withValues(alpha: 0.35) : null,

      child: ListTile(

        title: Text(

          title,

          style: TextStyle(

            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,

          ),

        ),

        subtitle: Text(subtitle),

        trailing: onTap == null

            ? Icon(Icons.lock_outline, color: scheme.outline)

            : const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,

      ),

    );

  }

}


