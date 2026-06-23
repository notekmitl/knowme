import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_routes.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_loader.dart';
import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';
import 'package:knowme/features/home_cohesion/presentation/home_astrology_hub_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v35_design.dart';
import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';
import 'package:knowme/presentation/pages/bazi/bazi_result_page.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';

/// Full astrology destination — Thai, BaZi, Western, Fusion.
class AstrologyCenterPage extends StatefulWidget {
  const AstrologyCenterPage({super.key, required this.uid});

  final String uid;

  @override
  State<AstrologyCenterPage> createState() => _AstrologyCenterPageState();
}

class _AstrologyCenterPageState extends State<AstrologyCenterPage> {
  final _loader = HomeV2Loader();
  final _coordinator = AstrologyGenerationCoordinator();
  HomeAstrologyHubSectionData? _hub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? retrySystemId}) async {
    if (widget.uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = _hub == null);

    final bundle = await _loader.loadBundle(
      widget.uid,
      includeHeavyDerivations: false,
    );

    final snapshot = await _coordinator.ensureGenerated(
      widget.uid,
      retrySystemId: retrySystemId,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _hub = HomeV3Assembler.astrologyHubFrom(bundle, generation: progress);
          _loading = false;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _hub = HomeV3Assembler.astrologyHubFrom(bundle, generation: snapshot);
      _loading = false;
    });
  }

  void _openSystem(String systemId) {
    switch (systemId) {
      case 'thai':
        ThaiMirrorRoutes.openResult(context);
      case 'bazi':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BaziResultPage()),
        );
      case 'western':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AstrologyResultPage()),
        );
      default:
        break;
    }
  }

  void _openFusion() {
    AstrologyFusionRoutes.openResult(context);
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilePageV1()),
    ).then((_) => _load());
  }

  void _retrySystem(String systemId) {
    _load(retrySystemId: systemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeV35Design.background,
      appBar: AppBar(
        backgroundColor: HomeV35Design.background,
        elevation: 0,
        title: Text(HomeV3Copy.astrologyHubTitle),
      ),
      body: SafeArea(
        child: _loading && _hub == null
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: AstrologySummaryShimmer(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: HomeAstrologyHubSection(
                  hub: _hub ??
                      const HomeAstrologyHubSectionData(
                        systems: [],
                        fusionGenerationStatus:
                            AstrologyGenerationStatus.notReady,
                        fusionTitle: '',
                        fusionDescription: '',
                        fusionStatusMessage: '',
                        fusionActionLabel: '',
                      ),
                  onOpenSystem: _openSystem,
                  onOpenFusion: _openFusion,
                  onEditProfile: _openEditProfile,
                  onRetrySystem: _retrySystem,
                ),
              ),
      ),
    );
  }
}
