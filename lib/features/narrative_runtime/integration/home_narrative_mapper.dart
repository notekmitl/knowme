import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v38_identity_copy.dart';

import '../domain/narrative_mode.dart';
import '../domain/narrative_result.dart';

/// Maps [NarrativeResult] into Home V3.8 surface data.
abstract final class HomeNarrativeMapper {
  static HomeNarrativeOverlay? overlay(NarrativeResult? narrative) {
    if (narrative == null || narrative.paragraphCount == 0) return null;

    final identity = narrative.sectionFor(NarrativeMode.identity);
    final relationship = narrative.sectionFor(NarrativeMode.relationship);
    final decision = narrative.sectionFor(NarrativeMode.decision);
    final growth = narrative.sectionFor(NarrativeMode.growth);

    final identityParagraphs = identity?.paragraphs ?? const [];
    final headlineRaw = identityParagraphs.isNotEmpty
        ? identityParagraphs.first.text
        : '';
    final supportingRaw = identityParagraphs.length > 1
        ? identityParagraphs[1].text
        : (growth?.paragraphs.isNotEmpty == true
            ? growth!.paragraphs.first.text
            : '');

    final signatureLabels = [
      ...?identity?.paragraphs.map((p) => p.patternLabel),
      ...?relationship?.paragraphs.map((p) => p.patternLabel),
    ].take(3).toList(growable: false);

    final insightCards = <HomeInsightCardData>[
      ...?relationship?.paragraphs.take(1).map(
            (p) => HomeInsightCardData(
              humanMeaning: p.text,
              supportingExplanation: p.patternLabel,
              visualKind: HomeThemeVisualKind.relationships,
            ),
          ),
      ...?decision?.paragraphs.take(1).map(
            (p) => HomeInsightCardData(
              humanMeaning: p.text,
              supportingExplanation: p.patternLabel,
              visualKind: HomeThemeVisualKind.structure,
            ),
          ),
      ...?growth?.paragraphs.take(1).map(
            (p) => HomeInsightCardData(
              humanMeaning: p.text,
              supportingExplanation: p.patternLabel,
              visualKind: HomeThemeVisualKind.growth,
            ),
          ),
    ].take(3).toList(growable: false);

    return HomeNarrativeOverlay(
      heroIdentity: HomeV38IdentityCopy.headline(headlineRaw),
      heroSupporting: HomeV38IdentityCopy.supporting(supportingRaw),
      signatureLabels: signatureLabels,
      insightCards: insightCards,
      confidenceBand: narrative.confidence.band,
    );
  }
}

class HomeNarrativeOverlay {
  const HomeNarrativeOverlay({
    required this.heroIdentity,
    required this.heroSupporting,
    required this.signatureLabels,
    required this.insightCards,
    required this.confidenceBand,
  });

  final String heroIdentity;
  final String heroSupporting;
  final List<String> signatureLabels;
  final List<HomeInsightCardData> insightCards;
  final String confidenceBand;
}
