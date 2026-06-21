import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';

/// Most distinctive cross-lens insight — V4.
class FusionSurprisingInsight {
  const FusionSurprisingInsight({
    required this.headline,
    required this.body,
    required this.reflection,
  });

  final String headline;
  final String body;
  final String reflection;

  String get formattedBody => '$headline\n\n$body\n\n$reflection';
}

abstract final class FusionSurprisingInsightBuilder {
  static FusionSurprisingInsight? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty && result.topThemes.isEmpty) {
      return null;
    }

    final scored = <_Candidate>[];

    if (_hasAutonomyPattern(result)) {
      scored.add(
        const _Candidate(
          priority: 100,
          insight: FusionSurprisingInsight(
            headline: 'คุณอาจไม่ได้เหนื่อยเพราะชีวิตยากเกินไป',
            body:
                'แต่เหนื่อย\n'
                'เพราะพยายามเป็นคนที่ไม่ใช่ตัวเอง',
            reflection:
                'หลายศาสตร์ไม่ได้สะท้อนว่าคุณอ่อนแอ\n\n'
                'แต่สะท้อนว่า\n\n'
                'คุณมักมีพลังมากที่สุด\n'
                'เมื่อเลิกเปรียบเทียบตัวเองกับความคาดหวังของคนอื่น',
          ),
        ),
      );
    }

    if (result.tensions.isNotEmpty) {
      scored.add(
        const _Candidate(
          priority: 90,
          insight: FusionSurprisingInsight(
            headline: 'ความขัดแย้งภายในอาจไม่ใช่จุดอ่อน',
            body:
                'แต่อาจเป็นสัญญาณว่า\n'
                'คุณมีหลายมิติที่สามารถเลือกใช้ได้',
            reflection:
                'หลายศาสตร์เห็นว่าคุณเติบโตได้ดี\n'
                'เมื่อรู้ว่ากำลังถ่วงน้ำหนักอะไรอยู่',
          ),
        ),
      );
    }

    if (_hasExpressionPattern(result)) {
      scored.add(
        const _Candidate(
          priority: 85,
          insight: FusionSurprisingInsight(
            headline: 'คุณอาจไม่ได้ต้องการความสนใจมากกว่าที่มีอยู่',
            body:
                'แต่ต้องการความเข้าใจ\n'
                'ในสิ่งที่คุณพูดอย่างตรงไปตรงมา',
            reflection:
                'หลายศาสตร์สะท้อนว่า\n'
                'พลังของคุณมักเกิดขึ้นเมื่อไม่ต้องซ่อนสิ่งที่คิดและรู้สึก',
          ),
        ),
      );
    }

    if (_hasReflectionPattern(result)) {
      scored.add(
        const _Candidate(
          priority: 75,
          insight: FusionSurprisingInsight(
            headline: 'การหยุดมองย้อนกลับอาจไม่ได้ทำให้คุณช้าลง',
            body:
                'แต่อาจเป็นวิธีที่คุณใช้\n'
                'เพื่อตัดสินใจอย่างมีน้ำหนัก',
            reflection:
                'หลายศาสตร์สะท้อนว่า\n'
                'ความชัดเจนของคุณมักมาหลังการทบทวน ไม่ใช่การรีบลงมือ',
          ),
        ),
      );
    }

    if (scored.isEmpty) {
      return const FusionSurprisingInsight(
        headline: 'หลายศาสตร์อาจกำลังสะท้อนสิ่งที่คุณมองข้าม',
        body:
            'จุดที่คุณให้ความสำคัญมากที่สุด\n'
            'อาจเป็นจุดที่คุณมีพลังมากที่สุดเช่นกัน',
        reflection:
            'การเห็นภาพนี้ชัดขึ้น\n'
            'อาจช่วยให้คุณเข้าใจตัวเองลึกขึ้นโดยไม่ต้องเปลี่ยนตัวเองทั้งหมด',
      );
    }

    scored.sort((a, b) => b.priority.compareTo(a.priority));
    return scored.first.insight;
  }

  static bool _hasAutonomyPattern(AstrologyFusionResult result) {
    if (result.topThemes.any((t) => t == 'independent' || t == 'driven')) {
      return true;
    }
    return _visibleSignals(result).any((s) => s.type == FusionSignalType.autonomy);
  }

  static bool _hasExpressionPattern(AstrologyFusionResult result) {
    if (result.topThemes.any((t) => t == 'expressive' || t == 'openness')) {
      return true;
    }
    return _visibleSignals(result).any((s) => s.type == FusionSignalType.expression);
  }

  static bool _hasReflectionPattern(AstrologyFusionResult result) {
    if (result.topThemes.any((t) => t == 'analytical' || t == 'intuitive')) {
      return true;
    }
    return _visibleSignals(result).any((s) => s.type == FusionSignalType.reflection);
  }

  static List<FusionSignal> _visibleSignals(AstrologyFusionResult result) {
    return result.signals
        .where(
          (s) =>
              s.supportLevel != FusionSupportLevel.low &&
              s.type != FusionSignalType.transformation,
        )
        .toList();
  }
}

class _Candidate {
  const _Candidate({required this.priority, required this.insight});

  final int priority;
  final FusionSurprisingInsight insight;
}
