import '../domain/entities/fusion_insight.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../domain/entities/fusion_tension.dart';
import '../domain/entities/future_tendency.dart';
import '../domain/entities/reflection_result.dart';
import '../registry/fusion_insight_registry.dart';
import '../registry/signal_registry.dart';

/// Fusion Insight Engine V2 — synthesizes cross-lens meaning (not reflection echo).
abstract final class FusionInsightEngine {
  static FusionInsightResult build({
    required List<FusionSignal> signals,
    required List<FusionTension> tensions,
    required ReflectionResult reflection,
    required List<FutureTendency> futureTendencies,
  }) {
    final supportedTypes = _supportedSignalTypes(signals);
    final primary = _buildPrimary(
      supportedTypes: supportedTypes,
      futureTendencies: futureTendencies,
    );
    final secondary = _buildSecondary(
      tensions: tensions,
      supportedTypes: supportedTypes,
      primary: primary,
    );

    if (primary == null && secondary == null) {
      return FusionInsightResult(
        primary: FusionInsight(
          title: 'ภาพที่ยังกำลังเกิดขึ้น',
          description:
              'เมื่อมีข้อมูลจากหลายศาสตร์มากขึ้น '
              'ความหมายที่เกิดจากการรวมกันจะชัดขึ้นเรื่อย ๆ '
              'โดยไม่จำเป็นต้องตัดสินว่ามุมใดถูกกว่า',
        ),
      );
    }

    return FusionInsightResult(
      primary: primary,
      secondary: secondary,
    );
  }

  static Set<FusionSignalType> _supportedSignalTypes(List<FusionSignal> signals) {
    return signals
        .where(
          (signal) =>
              signal.supportLevel != FusionSupportLevel.low &&
              signal.type != FusionSignalType.transformation,
        )
        .map((signal) => signal.type)
        .toSet();
  }

  static FusionInsight? _buildPrimary({
    required Set<FusionSignalType> supportedTypes,
    required List<FutureTendency> futureTendencies,
  }) {
    if (supportedTypes.isEmpty) return null;

    final combination = FusionInsightRegistry.insightForCombination(supportedTypes);
    if (combination != null) return combination;

    final ranked = supportedTypes.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final type in ranked) {
      final single = FusionInsightRegistry.insightForSingle(type);
      if (single != null) return single;
    }

    if (futureTendencies.isNotEmpty) {
      final tendency = futureTendencies.first;
      return FusionInsight(
        title: tendency.title,
        description: tendency.description,
      );
    }

    return null;
  }

  static FusionInsight? _buildSecondary({
    required List<FusionTension> tensions,
    required Set<FusionSignalType> supportedTypes,
    required FusionInsight? primary,
  }) {
    for (final tension in tensions) {
      final types = tension.perspectives
          .map((perspective) => FusionSignalRegistry.signalForTheme(perspective.themeId))
          .whereType<FusionSignalType>()
          .toSet();

      if (types.length < 2) continue;

      final insight = FusionInsightRegistry.insightForTensionPair(types);
      if (insight == null) continue;
      if (_isDuplicateInsight(primary, insight)) continue;
      return insight;
    }

    if (supportedTypes.contains(FusionSignalType.autonomy) &&
        supportedTypes.contains(FusionSignalType.connection)) {
      final insight =
          FusionInsightRegistry.insightForTensionPair({
        FusionSignalType.autonomy,
        FusionSignalType.connection,
      });
      if (insight != null && !_isDuplicateInsight(primary, insight)) {
        return insight;
      }
    }

    return null;
  }

  static bool _isDuplicateInsight(FusionInsight? primary, FusionInsight candidate) {
    if (primary == null) return false;
    return primary.title == candidate.title ||
        primary.description.trim() == candidate.description.trim();
  }
}
