import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_tension.dart';
import '../domain/entities/future_tendency.dart';
import '../domain/entities/reflection_result.dart';
import 'fusion_insight_engine.dart';

/// Legacy string builder — delegates to [FusionInsightEngine] V2.
abstract final class FusionInsightBuilder {
  static String build({
    required List<FusionSignal> signals,
    required ReflectionResult reflection,
    required List<FutureTendency> futureTendencies,
    List<FusionTension> tensions = const [],
  }) {
    final result = FusionInsightEngine.build(
      signals: signals,
      tensions: tensions,
      reflection: reflection,
      futureTendencies: futureTendencies,
    );

    final parts = <String>[];
    if (result.primary != null) {
      parts.add('${result.primary!.title}\n\n${result.primary!.description}');
    }
    if (result.secondary != null) {
      parts.add(
        '${result.secondary!.title}\n\n${result.secondary!.description}',
      );
    }

    if (parts.isEmpty) {
      return 'เมื่อมีข้อมูลจากหลายศาสตร์มากขึ้น '
          'ภาพสะท้อนตัวตนจากดวงจะชัดเจนขึ้นเรื่อย ๆ '
          'โดยไม่จำเป็นต้องตัดสินว่ามุมใดถูกกว่า';
    }

    return parts.join('\n\n');
  }
}
