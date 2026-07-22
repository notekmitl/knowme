import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../application/narrative/thai_beta_narrative_composer.dart';
import '../../application/thai_beta_analysis.dart';
import '../../application/thai_beta_evidence_badge_audience.dart';
import '../../application/thai_beta_evidence_badge_audience_resolver.dart';
import '../../application/thai_evidence_badge_feature_flag.dart';
import '../thai_beta_screenshot_mode.dart';
import '../widgets/thai_beta_progress_bar.dart';
import '../widgets/thai_beta_report_export_button.dart';
import 'thai_beta_feedback_page.dart';

import 'package:knowme/core/web/screenshot_friendly_scroll.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

/// Shows the **existing** Thai report for a beta analysis, with a CTA into the
/// feedback step. The report itself is not redesigned — it reuses
/// [ThaiMirrorResultPage] exactly as production does.
///
/// LEVEL 1 Canon evidence badges render here only when the controlled-beta
/// feature flag and audience gate allow it.
///
/// Screenshot mode (`?screenshot=1`, `?capture=1`, `/beta/thai/capture`):
/// long-form reading layout with a single Flutter scroll owner (banner +
/// export chrome stay sticky above the scrollable report body).
class ThaiBetaReportPage extends StatelessWidget {
  const ThaiBetaReportPage({
    super.key,
    required this.analysis,
    this.featureFlagOverride,
    this.audienceOverride,
    this.badgeViewModelsOverride,
    this.repository,
    this.audienceAccess,
    this.screenshotModeOverride,
    this.showCaptureModeBanner = false,
    this.captureBannerMessage,
  });

  final ThaiBetaAnalysis analysis;

  /// Test injection for feature flag state.
  final ThaiEvidenceBadgeFeatureFlagState? featureFlagOverride;

  /// Test injection for audience gate.
  final ThaiBetaEvidenceBadgeAudience? audienceOverride;

  /// Test injection for precomputed safe badge view models.
  final List<ThaiPublicEvidenceBadgeBetaViewModel>? badgeViewModelsOverride;

  final ThaiCanonEvidenceRepository? repository;

  /// Injectable audience resolver (production uses Firebase auth + admin access).
  final ThaiBetaEvidenceBadgeAudienceAccess? audienceAccess;

  /// When set, overrides [ThaiBetaScreenshotScope] (tests / capture route).
  final bool? screenshotModeOverride;

  /// Shows the internal capture-route banner ( `/beta/thai/capture` only).
  final bool showCaptureModeBanner;

  /// Optional override for the capture banner (e.g. QA sample route label).
  final String? captureBannerMessage;

  @override
  Widget build(BuildContext context) {
    final screenshotMode =
        screenshotModeOverride ?? ThaiBetaScreenshotScope.of(context);

    if (audienceOverride != null) {
      return _ThaiBetaReportScaffold(
        analysis: analysis,
        audience: audienceOverride!,
        featureFlagOverride: featureFlagOverride,
        badgeViewModelsOverride: badgeViewModelsOverride,
        repository: repository,
        screenshotMode: screenshotMode,
        showCaptureModeBanner: showCaptureModeBanner,
        captureBannerMessage: captureBannerMessage,
      );
    }

    final access =
        audienceAccess ?? FirebaseThaiBetaEvidenceBadgeAudienceAccess();
    return StreamBuilder<ThaiBetaEvidenceBadgeAudienceSnapshot>(
      stream: access.watch(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final audience = data == null
            ? const ThaiBetaEvidenceBadgeAudience.anonymous()
            : ThaiBetaEvidenceBadgeAudienceResolver.resolve(
                researchAccess: data.researchAccess,
                userId: data.userId,
              );
        return _ThaiBetaReportScaffold(
          key: ValueKey(
            'beta-report-${audience.isInternalTester}-${audience.isInvitedBetaTester}-$screenshotMode',
          ),
          analysis: analysis,
          audience: audience,
          featureFlagOverride: featureFlagOverride,
          badgeViewModelsOverride: badgeViewModelsOverride,
          repository: repository,
          screenshotMode: screenshotMode,
          showCaptureModeBanner: showCaptureModeBanner,
          captureBannerMessage: captureBannerMessage,
        );
      },
    );
  }
}

class _ThaiBetaReportScaffold extends StatefulWidget {
  const _ThaiBetaReportScaffold({
    super.key,
    required this.analysis,
    required this.audience,
    required this.screenshotMode,
    this.showCaptureModeBanner = false,
    this.captureBannerMessage,
    this.featureFlagOverride,
    this.badgeViewModelsOverride,
    this.repository,
  });

  final ThaiBetaAnalysis analysis;
  final ThaiBetaEvidenceBadgeAudience audience;
  final bool screenshotMode;
  final bool showCaptureModeBanner;
  final String? captureBannerMessage;
  final ThaiEvidenceBadgeFeatureFlagState? featureFlagOverride;
  final List<ThaiPublicEvidenceBadgeBetaViewModel>? badgeViewModelsOverride;
  final ThaiCanonEvidenceRepository? repository;

  @override
  State<_ThaiBetaReportScaffold> createState() => _ThaiBetaReportScaffoldState();
}

class _ThaiBetaReportScaffoldState extends State<_ThaiBetaReportScaffold> {
  static const _captureContentKeyValue = Key('thaiBetaReportCaptureContentKey');

  final GlobalKey _captureContentMeasureKey = GlobalKey();

  List<ThaiPublicEvidenceBadgeBetaViewModel> _badges = const [];
  bool _loadingBadges = false;
  int _hostSyncGeneration = 0;
  double _lastMeasuredContentHeight = 0;

  @override
  void initState() {
    super.initState();
    // Capture/reading mode uses Flutter as the only scroll owner.
    // Do not expand document/html host height (that fought user scrolling).
    // Always clear any leftover screenshot host styles from a prior visit.
    if (kIsWeb) {
      disableScreenshotFriendlyScroll();
    }
    _loadBadgesIfNeeded();
    _scheduleDiagnosticsRefresh();
  }

  @override
  void dispose() {
    if (kIsWeb) {
      disableScreenshotFriendlyScroll();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ThaiBetaReportScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audience.isInternalTester != widget.audience.isInternalTester ||
        oldWidget.audience.isInvitedBetaTester !=
            widget.audience.isInvitedBetaTester) {
      _loadBadgesIfNeeded();
    }
    if (oldWidget.screenshotMode != widget.screenshotMode && kIsWeb) {
      // Leaving or entering capture: never leave document scroll styles locked.
      disableScreenshotFriendlyScroll();
    }
    _scheduleDiagnosticsRefresh();
  }

  /// Refresh measured-height diagnostics only — does not mutate body/html scroll.
  void _scheduleDiagnosticsRefresh() {
    if (!widget.screenshotMode) return;
    final generation = ++_hostSyncGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _hostSyncGeneration) return;
      final box = _captureContentMeasureKey.currentContext?.findRenderObject()
          as RenderBox?;
      if (box == null || !box.hasSize) return;
      final contentHeight = box.size.height;
      if ((contentHeight - _lastMeasuredContentHeight).abs() < 4) return;
      _lastMeasuredContentHeight = contentHeight;
      setState(() {});
    });
  }

  Future<void> _loadBadgesIfNeeded() async {
    if (widget.badgeViewModelsOverride != null) {
      setState(() => _badges = widget.badgeViewModelsOverride!);
      _scheduleDiagnosticsRefresh();
      return;
    }

    final shouldRender = ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: widget.featureFlagOverride,
      audience: widget.audience,
    );
    if (!shouldRender) {
      if (_badges.isNotEmpty || _loadingBadges) {
        setState(() {
          _badges = const [];
          _loadingBadges = false;
        });
        _scheduleDiagnosticsRefresh();
      }
      return;
    }

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
      _scheduleDiagnosticsRefresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _badges = const [];
        _loadingBadges = false;
      });
      _scheduleDiagnosticsRefresh();
    }
  }

  bool get _showBadgePanel {
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: widget.featureFlagOverride,
      audience: widget.audience,
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

  Widget _buildReportColumn(ThaiBetaAnalysis analysis) {
    final bottomInset = widget.screenshotMode
        ? 24.0
        : 88 + MediaQuery.paddingOf(context).bottom;

    final reportBody = <Widget>[
      if (_showBadgePanel)
        ThaiBetaEvidenceBadgePanel(badges: _badges)
      else if (_loadingBadges)
        const LinearProgressIndicator(minHeight: 2),
      ThaiMirrorResultPage(
        embeddedInParentScroll: true,
        disableAnimations: widget.screenshotMode,
        personalCoreFirst: true,
        consumerState: ThaiBetaNarrativeComposer.narrativeView(analysis),
      ),
      if (widget.screenshotMode)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'ให้ความคิดเห็นต่อผลวิเคราะห์ — ใช้หน้า /beta/thai ปกติเพื่อส่ง feedback',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      SizedBox(height: bottomInset),
    ];

    if (widget.screenshotMode) {
      // Banner + export chrome are pinned in Scaffold; this column is report body.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyedSubtree(
            key: _captureContentMeasureKey,
            child: Column(
              key: _captureContentKeyValue,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: reportBody,
            ),
          ),
          _buildScreenshotDiagnostics(analysis),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThaiBetaProgressBar(current: ThaiBetaStep.read),
        ...reportBody,
      ],
    );
  }

  Widget _buildCaptureModeBanner() {
    final message =
        widget.captureBannerMessage ?? 'Thai Beta Capture Mode Active';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotDiagnostics(ThaiBetaAnalysis analysis) {
    final box =
        _captureContentMeasureKey.currentContext?.findRenderObject() as RenderBox?;
    final contentHeight = box?.hasSize == true ? box!.size.height : 0.0;
    final diagnostics = readScreenshotHostDiagnostics(
      reportContentHeight: contentHeight,
    );
    final uri = ThaiBetaScreenshotMode.diagnosticUri;

    final lines = <String>[
      'screenshotMode: true',
      'route: ${uri.path}',
      'query: ${uri.hasQuery ? uri.query : '(none)'}',
      'contentMeasuredHeight: ${contentHeight.toStringAsFixed(0)}',
      // Host height is intentionally not applied during reading (Flutter scrolls).
      'appliedHostHeight: ${readAppliedHostHeightPx().toStringAsFixed(0)}',
    ];
    if (diagnostics != null) {
      lines.addAll([
        'window.innerHeight: ${diagnostics.windowInnerHeight.toStringAsFixed(0)}',
        'document.scrollHeight: ${diagnostics.documentScrollHeight.toStringAsFixed(0)}',
        'body.scrollHeight: ${diagnostics.bodyScrollHeight.toStringAsFixed(0)}',
      ]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        key: const Key('thai_beta_screenshot_diagnostics'),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            lines.join('\n'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.35,
                ),
          ),
        ),
      ),
    );
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

    final reportColumn = _buildReportColumn(analysis);

    if (widget.screenshotMode) {
      // Pin capture banner + export chrome in the first viewport.
      // Not gated by evidence badge / admin / invited-beta flags.
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.showCaptureModeBanner)
                        _buildCaptureModeBanner(),
                      ThaiBetaReportExportButton(
                        analysis: analysis,
                        badges: _showBadgePanel ? _badges : const [],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('thai_beta_report_screenshot_layout'),
                  // Flutter owns capture scrolling (wheel / touch / scrollbar /
                  // keyboard). NeverScrollable + document-host scroll left
                  // users unable to read the report on /beta/thai/capture.
                  primary: true,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: reportColumn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final body = SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const Key('thai_beta_report_page_scroll'),
        primary: true,
        child: reportColumn,
      ),
    );

    return Scaffold(
      body: body,
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
