import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../domain/entities/future_tendency.dart';
import '../domain/entities/theme_family.dart';
import '../registry/family_registry.dart';
import '../registry/signal_combination_registry_v2.dart';
import '../registry/signal_opportunity_registry.dart';

/// Pattern-based tendencies V3 — combination + opportunity depth.
abstract final class FutureTendenciesBuilder {
  static List<FutureTendency> build(List<FusionSignal> signals) {
    if (signals.isEmpty) return const [];

    final ranked = List<FusionSignal>.from(signals)
      ..sort((a, b) {
        final supportCompare =
            b.supportLevel.rank.compareTo(a.supportLevel.rank);
        if (supportCompare != 0) return supportCompare;
        return b.supportingLenses.length.compareTo(a.supportingLenses.length);
      });

    final types = ranked.map((signal) => signal.type).toSet();
    final tendencies = <FutureTendency>[];
    final seenTitles = <String>{};

    void addTendency(FutureTendency tendency) {
      if (seenTitles.add(tendency.title)) {
        tendencies.add(tendency);
      }
    }

    final combination = SignalCombinationRegistryV2.tendencyForTypes(types);
    if (combination != null) {
      addTendency(_enrichWithOpportunity(combination, ranked));
    }

    if (_hasGrowthAndAdaptation(signals)) {
      final growthAdaptation =
          SignalCombinationRegistryV2.combinations['growth|adaptation'];
      if (growthAdaptation != null) {
        addTendency(_enrichWithOpportunity(growthAdaptation, ranked));
      }
    }

    for (final signal in ranked.take(2)) {
      if (signal.type == FusionSignalType.transformation) continue;
      final opportunity = SignalOpportunityRegistry.forSignal(signal.type);
      if (opportunity == null) continue;

      final label = _tendencyTitleFor(signal.type);
      if (!seenTitles.contains(label)) {
        addTendency(
          FutureTendency(
            title: label,
            description: opportunity.opportunityPattern,
          ),
        );
      }
      if (tendencies.length >= 3) break;
    }

    return tendencies.take(3).toList();
  }

  static FutureTendency _enrichWithOpportunity(
    FutureTendency base,
    List<FusionSignal> ranked,
  ) {
    final lead = ranked.firstWhere(
      (signal) => signal.type != FusionSignalType.transformation,
      orElse: () => ranked.first,
    );
    final opportunity = SignalOpportunityRegistry.forSignal(lead.type);
    if (opportunity == null) return base;

    return FutureTendency(
      title: base.title,
      description: '${base.description}\n${opportunity.opportunityPattern}',
    );
  }

  static String _tendencyTitleFor(FusionSignalType type) {
    return switch (type) {
      FusionSignalType.autonomy => 'โอกาสจากการตัดสินใจเอง',
      FusionSignalType.structure => 'โอกาสจากความน่าเชื่อถือ',
      FusionSignalType.growth => 'โอกาสจากการเรียนรู้',
      FusionSignalType.connection => 'โอกาสจากความสัมพันธ์',
      FusionSignalType.adaptation => 'โอกาสจากการปรับตัว',
      FusionSignalType.leadership => 'โอกาสจากภาวะผู้นำ',
      FusionSignalType.creativity => 'โอกาสจากความคิดใหม่',
      FusionSignalType.expression => 'โอกาสจากการสื่อสาร',
      FusionSignalType.reflection => 'โอกาสจากการทบทวน',
      FusionSignalType.transformation => 'โอกาสจากการเปลี่ยนแปลง',
    };
  }

  static bool _hasGrowthAndAdaptation(List<FusionSignal> signals) {
    final hasGrowth =
        signals.any((signal) => signal.type == FusionSignalType.growth);
    if (!hasGrowth) return false;

    final hasAdaptationSignal =
        signals.any((signal) => signal.type == FusionSignalType.adaptation);

    final hasAdaptationTheme = signals.any(
      (signal) => signal.sourceThemes.any(
        (themeId) =>
            FusionFamilyRegistry.familyForThemeId(themeId) ==
            ThemeFamily.adaptation,
      ),
    );

    return hasAdaptationSignal || hasAdaptationTheme;
  }
}
