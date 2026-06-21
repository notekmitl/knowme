import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../domain/entities/growth_opportunity.dart';
import '../presentation/fusion_presentation_copy.dart';
import '../registry/signal_opportunity_registry.dart';

/// Builds 1–3 growth opportunity cards from strongest signals.
abstract final class GrowthOpportunitiesBuilder {
  static List<GrowthOpportunity> build(List<FusionSignal> signals) {
    if (signals.isEmpty) return const [];

    final ranked = List<FusionSignal>.from(signals)
      ..sort((a, b) {
        final supportCompare =
            b.supportLevel.rank.compareTo(a.supportLevel.rank);
        if (supportCompare != 0) return supportCompare;
        return b.supportingLenses.length.compareTo(a.supportingLenses.length);
      });

    final opportunities = <GrowthOpportunity>[];
    final seenTypes = <FusionSignalType>{};

    for (final signal in ranked) {
      if (signal.supportLevel == FusionSupportLevel.low) continue;
      if (signal.type == FusionSignalType.transformation) continue;
      if (!seenTypes.add(signal.type)) continue;

      final pattern = SignalOpportunityRegistry.forSignal(signal.type);
      if (pattern == null) continue;

      opportunities.add(
        GrowthOpportunity(
          title: FusionPresentationCopy.signalTitle(signal.type),
          description: pattern.opportunityPattern,
        ),
      );

      if (opportunities.length >= 3) break;
    }

    return opportunities;
  }
}
