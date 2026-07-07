import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

import '../../application/thai_beta_analysis.dart';
import '../../application/thai_beta_evidence_badge_audience.dart';
import '../../application/thai_evidence_badge_feature_flag.dart';
import '../widgets/thai_beta_progress_bar.dart';
import 'thai_beta_feedback_page.dart';

/// Shows the **existing** Thai report for a beta analysis, with a CTA into the
/// feedback step. The report itself is not redesigned — it reuses
/// [ThaiMirrorResultPage] exactly as production does.
///
/// LEVEL 1 Canon evidence badges render here only when the controlled-beta
/// feature flag and audience gate allow it.
class ThaiBetaReportPage extends StatefulWidget {
  const ThaiBetaReportPage({
    super.key,
    required this.analysis,
    this.featureFlagOverride,
    this.audienceOverride,
    this.badgeViewModelsOverride,
    this.repository,
  });

  final ThaiBetaAnalysis analysis;

  /// Test injection for feature flag state.
  final ThaiEvidenceBadgeFeatureFlagState? featureFlagOverride;

  /// Test injection for audience gate.
  final ThaiBetaEvidenceBadgeAudience? audienceOverride;

  /// Test injection for precomputed safe badge view models.
  final List<ThaiPublicEvidenceBadgeBetaViewModel>? badgeViewModelsOverride;

  final ThaiCanonEvidenceRepository? repository;

  @override
  State<ThaiBetaReportPage> createState() => _ThaiBetaReportPageState();
}

class _ThaiBetaReportPageState extends State<ThaiBetaReportPage> {
  List<ThaiPublicEvidenceBadgeBetaViewModel> _badges = const [];
  bool _loadingBadges = false;

  @override
  void initState() {
    super.initState();
    _loadBadgesIfNeeded();
  }

  Future<void> _loadBadgesIfNeeded() async {
    if (widget.badgeViewModelsOverride != null) {
      setState(() => _badges = widget.badgeViewModelsOverride!);
      return;
    }

    final shouldRender = ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: widget.featureFlagOverride,
      audience: widget.audienceOverride,
    );
    if (!shouldRender) return;

    final pipeline = widget.analysis.pipelineResult;
    if (pipeline == null || !pipeline.isSuccess) return;

    setState(() => _loadingBadges = true);
    try {
      final repo =
          widget.repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repo,
      );
      if (!mounted) return;
      setState(() {
        _badges = ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle);
        _loadingBadges = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _badges = const [];
        _loadingBadges = false;
      });
    }
  }

  bool get _showBadgePanel {
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: widget.featureFlagOverride,
      audience: widget.audienceOverride,
    )) {
      return false;
    }
    if (!ThaiPublicEvidenceBadgeBetaGate.isBetaResearchResultSurface(
      onThaiBetaReportPage: true,
    )) {
      return false;
    }
    return _badges.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    if (!analysis.isSuccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('ผลวิเคราะห์')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              analysis.errorMessage ?? 'เกิดข้อผิดพลาดในการวิเคราะห์',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ThaiBetaProgressBar(current: ThaiBetaStep.read),
            if (_showBadgePanel)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  child: ThaiBetaEvidenceBadgePanel(badges: _badges),
                ),
              )
            else if (_loadingBadges)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ThaiMirrorResultPage(
                consumerState: analysis.consumerViewState!,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ThaiBetaFeedbackPage(analysis: analysis),
            ),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('ให้ความคิดเห็นต่อผลวิเคราะห์'),
        ),
      ),
    );
  }
}
