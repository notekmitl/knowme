import '../domain/entities/fusion_signal.dart';

import '../domain/entities/fusion_support_level.dart';

import '../domain/entities/reflection_result.dart';

import '../registry/signal_growth_registry.dart';

import '../registry/signal_shadow_registry.dart';



/// Deterministic template-based reflection copy V3 (no AI).

abstract final class ReflectionBuilder {

  static const Map<FusionSignalType, String> _insightPhrases = {

    FusionSignalType.autonomy: 'แนวโน้มของการพึ่งพาตัวเอง',

    FusionSignalType.structure: 'ความรับผิดชอบต่อสิ่งที่ทำ',

    FusionSignalType.growth: 'การเติบโตผ่านประสบการณ์',

    FusionSignalType.connection: 'การเชื่อมโยงและดูแลผู้อื่น',

    FusionSignalType.adaptation: 'การปรับตัวเมื่อสถานการณ์เปลี่ยน',

    FusionSignalType.expression: 'การแสดงออกทางอารมณ์และความคิด',

    FusionSignalType.reflection: 'การทบทวนและคิดอย่างลึกซึ้ง',

    FusionSignalType.leadership: 'บทบาทผู้นำและการกำหนดทิศทาง',

    FusionSignalType.creativity: 'ความคิดสร้างสรรค์และแนวคิดใหม่',

    FusionSignalType.transformation: 'ความหลากหลายของมุมมองที่อาจเปลี่ยนแปลงได้',

  };



  static const Map<FusionSignalType, String> _signalLabels = {

    FusionSignalType.autonomy: 'อิสระและการพึ่งพาตัวเอง',

    FusionSignalType.structure: 'โครงสร้างและความรับผิดชอบ',

    FusionSignalType.growth: 'การเติบโต',

    FusionSignalType.connection: 'ความสัมพันธ์',

    FusionSignalType.adaptation: 'การปรับตัว',

    FusionSignalType.expression: 'การแสดงออก',

    FusionSignalType.reflection: 'การทบทวน',

    FusionSignalType.leadership: 'ภาวะผู้นำ',

    FusionSignalType.creativity: 'ความคิดสร้างสรรค์',

    FusionSignalType.transformation: 'การเปลี่ยนแปลงของมุมมอง',

  };



  static ReflectionResult build(List<FusionSignal> signals) {

    if (signals.isEmpty) {

      return const ReflectionResult(

        summary: 'ยังไม่มีสัญญาณที่ชัดพอจากหลายศาสตร์ — ลองสำรวจดวงแต่ละมุมเพิ่มเติม',

        keyInsights: [],

      );

    }



    final ranked = _rankSignals(signals);

    final primary = ranked

        .where((signal) => signal.type != FusionSignalType.transformation)

        .take(2)

        .toList();



    final summary = _buildSummary(primary);

    final keyInsights = _buildKeyInsights(ranked);



    return ReflectionResult(

      summary: summary,

      keyInsights: keyInsights,

    );

  }



  static List<FusionSignal> _rankSignals(List<FusionSignal> signals) {

    return List<FusionSignal>.from(signals)

      ..sort((a, b) {

        final supportCompare =

            b.supportLevel.rank.compareTo(a.supportLevel.rank);

        if (supportCompare != 0) return supportCompare;

        return b.supportingLenses.length.compareTo(a.supportingLenses.length);

      });

  }



  static String _buildSummary(List<FusionSignal> primary) {

    if (primary.isEmpty) {

      return 'หลายศาสตร์สะท้อนภาพที่หลากหลาย — แต่ละมุมให้ความเข้าใจคนละแง่';

    }



    final narrative = primary

        .map((signal) => _insightPhrases[signal.type])

        .whereType<String>()

        .join(' และ ');



    final lead = primary.first;

    final growth = SignalGrowthRegistry.forSignal(lead.type);

    final shadow = SignalShadowRegistry.forSignal(lead.type);



    final buffer = StringBuffer('หลายศาสตร์สะท้อน$narrative');



    if (growth != null) {

      buffer.write(

        ' — ${growth.growthPotential} ${growth.developmentDirection}',

      );

    }



    if (shadow != null) {

      buffer.write(' แต่ควรระวัง${shadow.overusePattern}');

    }



    if (primary.length > 1) {

      final secondaryShadow =

          SignalShadowRegistry.forSignal(primary[1].type)?.blindSpot;

      if (secondaryShadow != null) {

        buffer.write(' และ$secondaryShadow');

      }

    }



    return buffer.toString();

  }



  static List<String> _buildKeyInsights(List<FusionSignal> ranked) {

    return ranked

        .where((signal) => signal.supportLevel != FusionSupportLevel.low)

        .map((signal) {

          final label = _signalLabels[signal.type] ?? signal.type.name;

          final growth = SignalGrowthRegistry.forSignal(signal.type);

          final maturity = growth?.maturityPath;

          if (maturity != null && maturity.isNotEmpty) {

            return '$label — $maturity';

          }

          final lensCount = signal.supportingLenses.length;

          return '$label — สนับสนุนจาก $lensCount มุม';

        })

        .take(5)

        .toList();

  }

}

