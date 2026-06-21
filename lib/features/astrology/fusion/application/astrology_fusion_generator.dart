import '../adapters/bazi_real_adapter.dart';
import '../adapters/lens_theme_output.dart';
import '../adapters/thai_real_adapter.dart';
import '../adapters/western_real_adapter.dart';
import '../domain/contracts/astrology_fusion_contract.dart';
import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_agreement.dart';
import '../domain/entities/fusion_insight.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_tension.dart';
import '../domain/entities/future_tendency.dart';
import '../domain/entities/growth_opportunity.dart';
import '../domain/entities/reflection_result.dart';
import '../domain/models/astrology_fusion_real_input.dart';
import '../domain/models/astrology_fusion_snapshot.dart';
import '../domain/models/source_lens_versions.dart';
import '../engines/agreement_engine.dart';
import '../engines/fusion_insight_engine.dart';
import '../engines/future_tendencies_builder.dart';
import '../engines/growth_opportunities_builder.dart';
import '../engines/reflection_builder.dart';
import '../engines/signal_engine.dart';
import '../engines/tension_engine.dart';
import '../engines/why_this_appears_builder.dart';
import '../registry/theme_registry.dart';

/// Astrology Fusion orchestrator — real lens adapters + intelligence pipeline.
abstract final class AstrologyFusionGenerator {
  static const int defaultTopThemeLimit = 5;

  static AstrologyFusionResult generateFromRealData(
    AstrologyFusionRealInput input, {
    int topThemeLimit = defaultTopThemeLimit,
    DateTime? generatedAt,
  }) {
    final outputs = <LensThemeOutput>[
      if (input.western != null) ...WesternRealAdapter.adapt(input.western!),
      if (input.bazi != null) ...BaziRealAdapter.adapt(input.bazi!),
      if (input.thai != null) ...ThaiRealAdapter.adapt(input.thai!),
    ];

    return generate(
      outputs,
      topThemeLimit: topThemeLimit,
      generatedAt: generatedAt,
    );
  }

  static AstrologyFusionSnapshot generateSnapshot(
    AstrologyFusionRealInput input, {
    required SourceLensVersions sourceLensVersions,
    int topThemeLimit = defaultTopThemeLimit,
    DateTime? generatedAt,
  }) {
    final outputs = <LensThemeOutput>[
      if (input.western != null) ...WesternRealAdapter.adapt(input.western!),
      if (input.bazi != null) ...BaziRealAdapter.adapt(input.bazi!),
      if (input.thai != null) ...ThaiRealAdapter.adapt(input.thai!),
    ];

    final pipeline = _runPipeline(
      outputs,
      generatedAt: generatedAt,
    );

    return AstrologyFusionSnapshot.fromPipeline(
      generatedAt: pipeline.generatedAt,
      signals: pipeline.signals,
      agreements: pipeline.agreements,
      tensions: pipeline.tensions,
      reflection: pipeline.reflection,
      fusionInsight: pipeline.fusionInsight,
      growthOpportunities: pipeline.growthOpportunities,
      futureTendencies: pipeline.futureTendencies,
      sourceLensVersions: sourceLensVersions,
    );
  }

  static AstrologyFusionResult generate(
    List<LensThemeOutput> outputs, {
    int topThemeLimit = defaultTopThemeLimit,
    DateTime? generatedAt,
  }) {
    final pipeline = _runPipeline(
      outputs,
      generatedAt: generatedAt,
    );
    final knownOutputs = outputs
        .where((output) => FusionThemeRegistry.contains(output.themeId))
        .toList();
    final lensOrigins = WhyThisAppearsBuilder.build(knownOutputs);
    final topThemes = _rankTopThemes(knownOutputs, topThemeLimit);

    return AstrologyFusionResult(
      version: AstrologyFusionContract.version,
      generatedAt: pipeline.generatedAt,
      topThemes: topThemes,
      signals: pipeline.signals,
      tensions: pipeline.tensions,
      reflection: pipeline.reflection,
      futureTendencies: pipeline.futureTendencies,
      fusionInsight: pipeline.fusionInsight,
      lensOrigins: lensOrigins,
      growthOpportunities: pipeline.growthOpportunities,
    );
  }

  static _FusionPipelineResult _runPipeline(
    List<LensThemeOutput> outputs, {
    DateTime? generatedAt,
  }) {
    final knownOutputs = outputs
        .where((output) => FusionThemeRegistry.contains(output.themeId))
        .toList();

    final agreements = AgreementEngine.detect(knownOutputs);
    final tensions = TensionEngine.detect(knownOutputs);
    final signals = SignalEngine.build(
      agreements: agreements,
      tensions: tensions,
    );
    final reflection = ReflectionBuilder.build(signals);
    final futureTendencies = FutureTendenciesBuilder.build(signals);
    final growthOpportunities = GrowthOpportunitiesBuilder.build(signals);
    final fusionInsight = FusionInsightEngine.build(
      signals: signals,
      tensions: tensions,
      reflection: reflection,
      futureTendencies: futureTendencies,
    );

    return _FusionPipelineResult(
      generatedAt: generatedAt ?? DateTime.now(),
      agreements: agreements,
      signals: signals,
      tensions: tensions,
      reflection: reflection,
      futureTendencies: futureTendencies,
      growthOpportunities: growthOpportunities,
      fusionInsight: fusionInsight,
    );
  }

  static List<String> _rankTopThemes(
    List<LensThemeOutput> outputs,
    int topThemeLimit,
  ) {
    final counts = <String, int>{};
    final confidenceTotals = <String, double>{};

    for (final output in outputs) {
      final themeId = output.themeId.trim().toLowerCase();
      counts[themeId] = (counts[themeId] ?? 0) + 1;
      confidenceTotals[themeId] =
          (confidenceTotals[themeId] ?? 0) + output.confidence;
    }

    final ranked = counts.keys.toList()
      ..sort((a, b) {
        final countCompare = counts[b]!.compareTo(counts[a]!);
        if (countCompare != 0) return countCompare;
        return confidenceTotals[b]!.compareTo(confidenceTotals[a]!);
      });

    final limit = topThemeLimit < 1 ? 1 : topThemeLimit;
    return ranked.take(limit).toList();
  }
}

class _FusionPipelineResult {
  const _FusionPipelineResult({
    required this.generatedAt,
    required this.agreements,
    required this.signals,
    required this.tensions,
    required this.reflection,
    required this.futureTendencies,
    required this.growthOpportunities,
    required this.fusionInsight,
  });

  final DateTime generatedAt;
  final List<FusionAgreement> agreements;
  final List<FusionSignal> signals;
  final List<FusionTension> tensions;
  final ReflectionResult reflection;
  final List<FutureTendency> futureTendencies;
  final List<GrowthOpportunity> growthOpportunities;
  final FusionInsightResult fusionInsight;
}
