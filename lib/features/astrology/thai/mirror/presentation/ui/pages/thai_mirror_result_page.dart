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
  });

  final ThaiMirrorConsumerViewState consumerState;

  @override
  State<ThaiMirrorResultPage> createState() => _ThaiMirrorResultPageState();
}

class _ThaiMirrorResultPageState extends State<ThaiMirrorResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.025),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void dispose() {
    _controller.dispose();
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

    // Major-section rhythm — generous breathing room between blocks.
    const gap = 36.0;

    return Scaffold(
      body: DecoratedBox(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isWide ? 28 : 20,
              horizontalPadding,
              48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: RepaintBoundary(
                      key: const Key('thai_consumer_full_page'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RepaintBoundary(
                            key: const Key('thai_consumer_hero'),
                            child: ThaiMirrorConsumerHeroSection(
                              state: consumerState.hero,
                            ),
                          ),
                          const SizedBox(height: 18),
                          RepaintBoundary(
                            child: ThaiMirrorBirthDataConfidenceBanner(
                              state: consumerState.birthDataConfidence,
                            ),
                          ),
                          if (consumerState.lifeTimeline != null &&
                              !consumerState.lifeTimeline!.isEmpty) ...[
                            const SizedBox(height: gap),
                            RepaintBoundary(
                              key: const Key('thai_consumer_life_timeline'),
                              child: ThaiMirrorLifeTimelineSection(
                                state: consumerState.lifeTimeline!,
                              ),
                            ),
                          ],
                          if (consumerState.futurePrediction != null &&
                              !consumerState.futurePrediction!.isEmpty) ...[
                            const SizedBox(height: gap),
                            RepaintBoundary(
                              key: const Key('thai_consumer_future_prediction'),
                              child: ThaiMirrorFuturePredictionSection(
                                state: consumerState.futurePrediction!,
                              ),
                            ),
                          ],
                          if (!consumerState.signatureInsight.isEmpty) ...[
                            const SizedBox(height: gap),
                            RepaintBoundary(
                              key: const Key('thai_consumer_signature_insight'),
                              child: ThaiMirrorSignatureInsightSection(
                                state: consumerState.signatureInsight,
                              ),
                            ),
                          ],
                          const SizedBox(height: gap),
                          RepaintBoundary(
                            key: const Key('thai_consumer_life_dashboard'),
                            child: ThaiMirrorLifeDashboardSection(
                              items: consumerState.lifeDashboard,
                              secretTip: consumerState.secretTip,
                            ),
                          ),
                          const SizedBox(height: gap),
                          RepaintBoundary(
                            key: const Key('thai_consumer_strengths'),
                            child: ThaiMirrorInsightCardsSection(
                              state: consumerState.strengths,
                            ),
                          ),
                          const SizedBox(height: gap),
                          RepaintBoundary(
                            key: const Key('thai_consumer_cautions'),
                            child: ThaiMirrorInsightCardsSection(
                              state: consumerState.cautions,
                            ),
                          ),
                          const SizedBox(height: gap),
                          RepaintBoundary(
                            key: const Key('thai_consumer_advice'),
                            child: ThaiMirrorAdviceSection(
                              state: consumerState.advice,
                            ),
                          ),
                          if (consumerState.narrativeSections.isNotEmpty) ...[
                            const SizedBox(height: gap + 8),
                            RepaintBoundary(
                              key: const Key('thai_consumer_narrative'),
                              child: ThaiMirrorNarrativeReportSection(
                                sections: consumerState.narrativeSections,
                              ),
                            ),
                          ],
                          if (consumerState
                              .reflectionSummary.points.isNotEmpty) ...[
                            const SizedBox(height: gap + 8),
                            RepaintBoundary(
                              key: const Key('thai_consumer_reflection_summary'),
                              child: ThaiMirrorReflectionSummarySection(
                                state: consumerState.reflectionSummary,
                              ),
                            ),
                          ],
                          if (!consumerState.closingMessage.isEmpty) ...[
                            const SizedBox(height: gap),
                            RepaintBoundary(
                              key: const Key('thai_consumer_closing'),
                              child: ThaiMirrorClosingMessageSection(
                                state: consumerState.closingMessage,
                              ),
                            ),
                          ],
                          const SizedBox(height: gap),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          disclaimer,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.5,
                                            color: scheme.onSurfaceVariant
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
