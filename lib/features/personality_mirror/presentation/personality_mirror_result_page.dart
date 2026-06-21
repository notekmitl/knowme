import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/presentation/widgets/cross_mirror_discovery_bridge.dart';

import '../domain/personality_mirror_narrative_view.dart';

/// Personality Mirror Result V1 — renders [PersonalityMirrorNarrativeView] only.
class PersonalityMirrorResultPage extends StatelessWidget {
  const PersonalityMirrorResultPage({
    super.key,
    required this.narrative,
    this.showFullExperience = true,
  });

  final PersonalityMirrorNarrativeView narrative;
  final bool showFullExperience;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('personality_mirror_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(paragraphs: narrative.heroParagraphs),
            if (!showFullExperience) ...[
              const SizedBox(height: 12),
              _PartialExperienceBanner(),
            ],
            if (narrative.lensContributionLines.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(
                titleKey: 'personality_mirror_result_contributions_title',
              ),
              const SizedBox(height: 8),
              for (final line in narrative.lensContributionLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: muted,
                    ),
                  ),
                ),
            ],
            if (narrative.patternCards.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(
                titleKey: 'personality_mirror_result_patterns_title',
              ),
              const SizedBox(height: 10),
              for (final card in narrative.patternCards)
                _PatternCard(card: card),
            ],
            if (narrative.perspectiveCards.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(
                titleKey: 'personality_mirror_result_perspectives_title',
              ),
              const SizedBox(height: 10),
              for (final card in narrative.perspectiveCards)
                _PerspectiveCard(card: card),
            ],
            const SizedBox(height: 20),
            Text(
              narrative.depthHint,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: muted,
              ),
            ),
            const SizedBox(height: 16),
            const CrossMirrorDiscoveryBridge(
              target: CrossMirrorBridgeTarget.astrologyFusion,
            ),
            const SizedBox(height: 16),
            Text(
              narrative.disclosure,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: muted.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.t('personality_mirror_result_hero_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < paragraphs.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Text(
                paragraphs[i],
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppText.t(titleKey),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.card});

  final PersonalityMirrorPatternCard card;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              card.body,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.supportingLensesLabel,
              style: TextStyle(
                fontSize: 12,
                color: muted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerspectiveCard extends StatelessWidget {
  const _PerspectiveCard({required this.card});

  final PersonalityMirrorPerspectiveCard card;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              card.body,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartialExperienceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Text(
        AppText.t('personality_mirror_result_partial_hint'),
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: Colors.amber.shade900,
        ),
      ),
    );
  }
}
