import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';
import '../widgets/thai_mirror_advice_section.dart';
import '../widgets/thai_mirror_birth_data_confidence_banner.dart';
import '../widgets/thai_mirror_closing_message_section.dart';
import '../widgets/thai_mirror_consumer_hero_section.dart';
import '../widgets/thai_mirror_future_prediction_section.dart';
import '../widgets/thai_mirror_insight_cards_section.dart';
import '../widgets/thai_mirror_life_dashboard_section.dart';
import '../widgets/thai_mirror_life_timeline_section.dart';
import '../widgets/thai_mirror_narrative_report_section.dart';
import '../widgets/thai_mirror_reflection_summary_section.dart';
import '../widgets/thai_mirror_signature_insight_section.dart';
import '../widgets/thai_mirror_source_transparency_section.dart';

/// Thai Mirror Result Page — consumer-facing personality insight experience.
///
/// V4: reads like a long-form article. Sections flow with generous vertical
/// rhythm, a single tasteful mount animation, a centred readable column on
/// desktop and a quiet background wash.
class ThaiMirrorResultPage extends StatefulWidget {
  const ThaiMirrorResultPage({
    super.key,
    required this.consumerState,
    this.embeddedInParentScroll = false,
    this.disableAnimations = false,
    this.personalCoreFirst = false,
    this.relevantLifeTimeline = false,
    this.lifeMapMode = true,
    this.collapseSecondarySections = false,
  });

  final ThaiMirrorConsumerViewState consumerState;

  /// When true, omits [Scaffold] and inner [SingleChildScrollView] so a parent
  /// (e.g. [ThaiBetaReportPage]) owns the single page scroll for full capture.
  final bool embeddedInParentScroll;

  /// Skips mount fade/slide animations (screenshot / capture mode).
  final bool disableAnimations;

  /// V1.2 Thai Beta: place Personal Core (signature insight) immediately after
  /// birth-confidence so the overview leads before dashboard/timeline detail.
  final bool personalCoreFirst;

  /// V1.2.1 Thai Beta: show only previous/current/next life periods and
  /// collapse secondary period detail by default (presentation-only).
  final bool relevantLifeTimeline;

  /// V1.2.3 — full eight-period Life Map (overrides relevant-only when true).
  final bool lifeMapMode;

  /// V1.2.3 — secondary report sections start collapsed to shorten the page.
  final bool collapseSecondarySections;

  @override
  State<ThaiMirrorResultPage> createState() => _ThaiMirrorResultPageState();
}

class _ThaiMirrorResultPageState extends State<ThaiMirrorResultPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fade;
  Animation<Offset>? _slide;

  @override
  void initState() {
    super.initState();
    if (!widget.disableAnimations) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      )..forward();
      _fade = CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic);
      _slide = Tween<Offset>(
        begin: const Offset(0, 0.025),
        end: Offset.zero,
      ).animate(_fade!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final consumerState = widget.consumerState;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 768;
    final horizontalPadding = isWide ? 32.0 : 18.0;
    final maxContentWidth = isWide ? 780.0 : double.infinity;
    final topPadding = widget.embeddedInParentScroll
        ? (isWide ? 16.0 : 12.0)
        : (isWide ? 28.0 : 20.0);

    // Major-section rhythm — generous breathing room between blocks.
    const gap = 36.0;

    final articleBody = RepaintBoundary(
      key: const Key('thai_consumer_full_page'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _articleSections(
          context,
          consumerState: consumerState,
          scheme: scheme,
          gap: gap,
        ),
      ),
    );

    final animatedArticle = widget.disableAnimations
        ? articleBody
        : FadeTransition(
            opacity: _fade!,
            child: SlideTransition(position: _slide!, child: articleBody),
          );

    final article = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: animatedArticle,
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.18),
            scheme.surface,
            scheme.surface,
          ],
          stops: const [0.0, 0.32, 1.0],
        ),
      ),
      child: widget.embeddedInParentScroll
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                48,
              ),
              child: article,
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  48,
                ),
                child: article,
              ),
            ),
    );

    if (widget.embeddedInParentScroll) {
      return decorated;
    }

    return Scaffold(body: decorated);
  }

  List<Widget> _articleSections(
    BuildContext context, {
    required ThaiMirrorConsumerViewState consumerState,
    required ColorScheme scheme,
    required double gap,
  }) {
    return [
      RepaintBoundary(
        key: const Key('thai_consumer_hero'),
        child: ThaiMirrorConsumerHeroSection(state: consumerState.hero),
      ),
      const SizedBox(height: 18),
      RepaintBoundary(
        child: ThaiMirrorBirthDataConfidenceBanner(
          state: consumerState.birthDataConfidence,
        ),
      ),
      if (widget.personalCoreFirst &&
          !consumerState.signatureInsight.isEmpty) ...[
        SizedBox(height: gap),
        RepaintBoundary(
          key: const Key('thai_consumer_signature_insight'),
          child: ThaiMirrorSignatureInsightSection(
            state: consumerState.signatureInsight,
          ),
        ),
      ],
      if (consumerState.lifeTimeline != null &&
          !consumerState.lifeTimeline!.isEmpty) ...[
        SizedBox(height: gap),
        RepaintBoundary(
          key: const Key('thai_consumer_life_timeline'),
          child: ThaiMirrorLifeTimelineSection(
            state: consumerState.lifeTimeline!,
            relevantPeriodsOnly:
                widget.relevantLifeTimeline && !widget.lifeMapMode,
            lifeMapMode: widget.lifeMapMode,
          ),
        ),
      ],
      if (consumerState.futurePrediction != null &&
          !consumerState.futurePrediction!.isEmpty) ...[
        SizedBox(height: gap),
        RepaintBoundary(
          key: const Key('thai_consumer_future_prediction'),
          child: _MaybeCollapsedSection(
            collapse: widget.collapseSecondarySections,
            title: consumerState.futurePrediction!.sectionTitle,
            child: ThaiMirrorFuturePredictionSection(
              state: consumerState.futurePrediction!,
            ),
          ),
        ),
      ],
      if (!widget.personalCoreFirst &&
          !consumerState.signatureInsight.isEmpty) ...[
        SizedBox(height: gap),
        RepaintBoundary(
          key: const Key('thai_consumer_signature_insight'),
          child: ThaiMirrorSignatureInsightSection(
            state: consumerState.signatureInsight,
          ),
        ),
      ],
      SizedBox(height: gap),
      RepaintBoundary(
        key: const Key('thai_consumer_life_dashboard'),
        child: _MaybeCollapsedSection(
          collapse: widget.collapseSecondarySections,
          title: 'ภาพรวมชีวิต',
          child: ThaiMirrorLifeDashboardSection(
            items: consumerState.lifeDashboard,
            secretTip: consumerState.secretTip,
          ),
        ),
      ),
      SizedBox(height: gap),
      RepaintBoundary(
        key: const Key('thai_consumer_strengths'),
        child: _MaybeCollapsedSection(
          collapse: widget.collapseSecondarySections,
          title: consumerState.strengths.title,
          child: ThaiMirrorInsightCardsSection(state: consumerState.strengths),
        ),
      ),
      SizedBox(height: gap),
      RepaintBoundary(
        key: const Key('thai_consumer_cautions'),
        child: _MaybeCollapsedSection(
          collapse: widget.collapseSecondarySections,
          title: consumerState.cautions.title,
          child: ThaiMirrorInsightCardsSection(state: consumerState.cautions),
        ),
      ),
      SizedBox(height: gap),
      RepaintBoundary(
        key: const Key('thai_consumer_advice'),
        child: _MaybeCollapsedSection(
          collapse: widget.collapseSecondarySections,
          title: consumerState.advice.title,
          child: ThaiMirrorAdviceSection(state: consumerState.advice),
        ),
      ),
      if (consumerState.narrativeSections.isNotEmpty) ...[
        SizedBox(height: gap + 8),
        RepaintBoundary(
          key: const Key('thai_consumer_narrative'),
          child: _MaybeCollapsedSection(
            collapse: widget.collapseSecondarySections,
            title: 'บทอ่านเพิ่มเติม',
            child: ThaiMirrorNarrativeReportSection(
              sections: consumerState.narrativeSections,
            ),
          ),
        ),
      ],
      if (consumerState.reflectionSummary.points.isNotEmpty) ...[
        SizedBox(height: gap + 8),
        RepaintBoundary(
          key: const Key('thai_consumer_reflection_summary'),
          child: ThaiMirrorReflectionSummarySection(
            state: consumerState.reflectionSummary,
          ),
        ),
      ],
      if (!consumerState.closingMessage.isEmpty) ...[
        SizedBox(height: gap),
        RepaintBoundary(
          key: const Key('thai_consumer_closing'),
          child: ThaiMirrorClosingMessageSection(
            state: consumerState.closingMessage,
          ),
        ),
      ],
      SizedBox(height: gap),
      RepaintBoundary(
        key: const Key('thai_consumer_source'),
        child: ThaiMirrorSourceTransparencySection(
          state: consumerState.sourceTransparency,
        ),
      ),
      if (consumerState.disclaimers.isNotEmpty) ...[
        const SizedBox(height: 24),
        RepaintBoundary(
          key: const Key('thai_consumer_footer'),
          child: Column(
            children: consumerState.disclaimers
                .map(
                  (disclaimer) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      disclaimer,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ];
  }
}

/// Presentation-only collapsible wrapper for secondary report blocks (V1.2.3).
class _MaybeCollapsedSection extends StatelessWidget {
  const _MaybeCollapsedSection({
    required this.collapse,
    required this.title,
    required this.child,
  });

  final bool collapse;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!collapse) return child;
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        children: [child],
      ),
    );
  }
}
