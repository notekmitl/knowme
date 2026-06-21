import '../contracts/astrology_fusion_contract.dart';
import '../entities/astrology_fusion_result.dart';
import '../entities/fusion_agreement.dart';
import '../entities/fusion_insight.dart';
import '../entities/fusion_signal.dart';
import '../entities/fusion_tension.dart';
import '../entities/future_tendency.dart';
import '../entities/growth_opportunity.dart';
import '../entities/reflection_result.dart';
import 'source_lens_versions.dart';

/// Persisted Astrology Fusion intelligence snapshot (AF-09).
class AstrologyFusionSnapshot {
  const AstrologyFusionSnapshot({
    required this.version,
    required this.generatedAt,
    required this.signals,
    required this.agreements,
    required this.tensions,
    required this.reflection,
    required this.fusionInsight,
    required this.growthOpportunities,
    required this.futureTendencies,
    required this.sourceLensVersions,
  });

  final String version;
  final DateTime generatedAt;
  final List<FusionSignal> signals;
  final List<FusionAgreement> agreements;
  final List<FusionTension> tensions;
  final ReflectionResult reflection;
  final FusionInsightResult fusionInsight;
  final List<GrowthOpportunity> growthOpportunities;
  final List<FutureTendency> futureTendencies;
  final SourceLensVersions sourceLensVersions;

  AstrologyFusionResult toResult() {
    return AstrologyFusionResult(
      version: version,
      generatedAt: generatedAt,
      topThemes: const [],
      signals: signals,
      tensions: tensions,
      reflection: reflection,
      futureTendencies: futureTendencies,
      fusionInsight: fusionInsight,
      lensOrigins: const [],
      growthOpportunities: growthOpportunities,
    );
  }

  factory AstrologyFusionSnapshot.fromPipeline({
    required DateTime generatedAt,
    required List<FusionSignal> signals,
    required List<FusionAgreement> agreements,
    required List<FusionTension> tensions,
    required ReflectionResult reflection,
    required FusionInsightResult fusionInsight,
    required List<GrowthOpportunity> growthOpportunities,
    required List<FutureTendency> futureTendencies,
    required SourceLensVersions sourceLensVersions,
    String version = AstrologyFusionContract.version,
  }) {
    return AstrologyFusionSnapshot(
      version: version,
      generatedAt: generatedAt,
      signals: signals,
      agreements: agreements,
      tensions: tensions,
      reflection: reflection,
      fusionInsight: fusionInsight,
      growthOpportunities: growthOpportunities,
      futureTendencies: futureTendencies,
      sourceLensVersions: sourceLensVersions,
    );
  }
}
