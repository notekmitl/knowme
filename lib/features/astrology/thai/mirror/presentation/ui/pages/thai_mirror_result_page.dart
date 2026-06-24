import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';
import '../widgets/thai_mirror_advice_section.dart';
import '../widgets/thai_mirror_birth_data_confidence_banner.dart';
import '../widgets/thai_mirror_consumer_hero_section.dart';
import '../widgets/thai_mirror_insight_cards_section.dart';
import '../widgets/thai_mirror_life_dashboard_section.dart';
import '../widgets/thai_mirror_source_transparency_section.dart';

/// Thai Mirror Result Page — consumer-facing personality insight experience.
class ThaiMirrorResultPage extends StatelessWidget {
  const ThaiMirrorResultPage({
    super.key,
    required this.consumerState,
  });

  final ThaiMirrorConsumerViewState consumerState;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: RepaintBoundary(
            key: const Key('thai_consumer_full_page'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              RepaintBoundary(
                key: const Key('thai_consumer_hero'),
                child: ThaiMirrorConsumerHeroSection(state: consumerState.hero),
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                child: ThaiMirrorBirthDataConfidenceBanner(
                  state: consumerState.birthDataConfidence,
                ),
              ),
              const SizedBox(height: 28),
              RepaintBoundary(
                key: const Key('thai_consumer_strengths'),
                child: ThaiMirrorInsightCardsSection(state: consumerState.strengths),
              ),
              const SizedBox(height: 28),
              RepaintBoundary(
                key: const Key('thai_consumer_cautions'),
                child: ThaiMirrorInsightCardsSection(state: consumerState.cautions),
              ),
              const SizedBox(height: 28),
              RepaintBoundary(
                key: const Key('thai_consumer_advice'),
                child: ThaiMirrorAdviceSection(state: consumerState.advice),
              ),
              const SizedBox(height: 28),
              RepaintBoundary(
                key: const Key('thai_consumer_life_dashboard'),
                child: ThaiMirrorLifeDashboardSection(
                  items: consumerState.lifeDashboard,
                  secretTip: consumerState.secretTip,
                ),
              ),
              const SizedBox(height: 28),
              RepaintBoundary(
                key: const Key('thai_consumer_source'),
                child: ThaiMirrorSourceTransparencySection(
                  state: consumerState.sourceTransparency,
                ),
              ),
              if (consumerState.disclaimers.isNotEmpty) ...[
                const SizedBox(height: 20),
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
    );
  }
}
