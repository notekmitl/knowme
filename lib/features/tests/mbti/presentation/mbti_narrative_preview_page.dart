import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:knowme/features/funnel_telemetry/funnel_telemetry.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v35_design.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_runtime_loader.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import 'mbti_result_page.dart';

/// Mini narrative preview shown immediately after MBTI completion.
class MbtiNarrativePreviewPage extends StatefulWidget {
  const MbtiNarrativePreviewPage({
    super.key,
    required this.summary,
    this.canContinueToStandard = false,
    this.canContinueToAccurate = false,
    this.pendingAnswersForContinue,
  });

  final MbtiResultSummary summary;
  final bool canContinueToStandard;
  final bool canContinueToAccurate;
  final Map<String, int>? pendingAnswersForContinue;

  @override
  State<MbtiNarrativePreviewPage> createState() =>
      _MbtiNarrativePreviewPageState();
}

class _MbtiNarrativePreviewPageState extends State<MbtiNarrativePreviewPage> {
  final _loader = NarrativeRuntimeLoader();
  String? _previewText;
  int _lockedSections = 3;
  String _title = '';
  String _rewardLine = '';
  bool _loading = true;
  bool _telemetrySent = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final narrative = await _loader.loadForUser(
      uid,
      generatedAt: DateTime.now().toUtc(),
    );

    if (!mounted) return;

    var preview = '';
    var locked = 3;
    var total = 4;
    var title = HomeV3Copy.narrativePreviewTitle(1, 4);
    var rewardLine = HomeV3Copy.narrativePreviewRewardLine(3);

    if (narrative != null && narrative.paragraphCount > 0) {
      final identity = narrative.sectionFor(NarrativeMode.identity);
      if (identity != null && identity.paragraphs.isNotEmpty) {
        preview = identity.paragraphs.first.text;
      } else {
        preview = narrative.sections.first.paragraphs.first.text;
      }
      locked = (narrative.sections.length - 1).clamp(1, 4);
      total = narrative.sections.length.clamp(1, 5);
      title = HomeV3Copy.narrativePreviewTitle(total - locked, total);
      rewardLine = HomeV3Copy.narrativePreviewRewardLine(locked);
    } else {
      preview = HomeV3Copy.narrativePreviewFallback;
    }

    setState(() {
      _previewText = preview;
      _lockedSections = locked;
      _title = title;
      _rewardLine = rewardLine;
      _loading = false;
    });

    if (!_telemetrySent) {
      _telemetrySent = true;
      await FunnelTelemetry.track(FunnelTelemetryEvent.narrativePreviewSeen);
    }
  }

  void _openMbtiResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MbtiResultPage(
          summary: widget.summary,
          canContinueToStandard: widget.canContinueToStandard,
          canContinueToAccurate: widget.canContinueToAccurate,
          pendingAnswersForContinue: widget.pendingAnswersForContinue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeV35Design.background,
      appBar: AppBar(
        backgroundColor: HomeV35Design.background,
        elevation: 0,
        title: Text('🎁 ${HomeV3Copy.narrativePreviewBadge}'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: HomeV35Design.surface,
                        borderRadius:
                            BorderRadius.circular(HomeV35Design.cardRadius),
                        boxShadow: [HomeV35Design.cardShadow],
                        border: Border.all(
                          color: HomeV35Design.goldCta.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: HomeV35Design.textPrimary,
                            ),
                          ),
                          if (_rewardLine.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _rewardLine,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: HomeV35Design.purpleAccent,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Text(
                            _previewText ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.55,
                              color: HomeV35Design.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (var i = 0; i < _lockedSections; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _BlurredSection(
                                label: HomeV3Copy.narrativeLockedSectionLabels[
                                    i.clamp(
                                      0,
                                      HomeV3Copy
                                              .narrativeLockedSectionLabels
                                              .length -
                                          1,
                                    )],
                                hint: HomeV3Copy.narrativePreviewLockedHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      HomeV3Copy.mbtiPreviewNextStep,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: HomeV35Design.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeV35Design.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(HomeV3Copy.mbtiPreviewBackHome),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _openMbtiResult,
                      child: Text(HomeV3Copy.mbtiPreviewViewResult),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BlurredSection extends StatelessWidget {
  const _BlurredSection({
    required this.label,
    required this.hint,
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 56,
            color: HomeV35Design.purpleSoft,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: HomeV35Design.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.white.withValues(alpha: 0.35),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: HomeV35Design.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomeV35Design.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
