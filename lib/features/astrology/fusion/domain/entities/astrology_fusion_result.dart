import 'fusion_insight.dart';
import 'fusion_signal.dart';
import 'fusion_tension.dart';
import 'future_tendency.dart';
import 'growth_opportunity.dart';
import 'lens_origin_insight.dart';
import 'reflection_result.dart';

/// Astrology Fusion output contract (AF-01 + AF-03 + AF-05 + AF-07 + AF-08).
class AstrologyFusionResult {
  const AstrologyFusionResult({
    required this.version,
    required this.generatedAt,
    required this.topThemes,
    required this.signals,
    required this.tensions,
    required this.reflection,
    required this.futureTendencies,
    required this.fusionInsight,
    required this.lensOrigins,
    required this.growthOpportunities,
  });

  final String version;
  final DateTime generatedAt;

  /// Canonical theme ids ranked by cross-lens support.
  final List<String> topThemes;

  final List<FusionSignal> signals;
  final List<FusionTension> tensions;
  final ReflectionResult reflection;
  final List<FutureTendency> futureTendencies;
  final FusionInsightResult fusionInsight;
  final List<LensOriginInsight> lensOrigins;
  final List<GrowthOpportunity> growthOpportunities;
}
