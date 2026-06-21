import '../domain/entities/fusion_signal.dart';
import '../domain/entities/signal_opportunity_pattern.dart';

/// Per-signal opportunity pattern templates (deterministic — no AI).
abstract final class SignalOpportunityRegistry {
  static const Map<FusionSignalType, SignalOpportunityPattern> patterns = {
    FusionSignalType.autonomy: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อกล้าตัดสินใจและรับผิดชอบทิศทางของตัวเอง',
    ),
    FusionSignalType.structure: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อแสดงความน่าเชื่อถือและรักษาสิ่งที่เริ่มไว้จนสำเร็จ',
    ),
    FusionSignalType.growth: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสผ่านการเรียนรู้หรือการเปลี่ยนแปลง',
    ),
    FusionSignalType.connection: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสผ่านผู้คนและความร่วมมือ',
    ),
    FusionSignalType.adaptation: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อยอมรับการเปลี่ยนแปลงและปรับแนวทางได้ทัน',
    ),
    FusionSignalType.leadership: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อคนรอบข้างต้องการทิศทางหรือการประสานงาน',
    ),
    FusionSignalType.creativity: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อมีปัญหาที่ต้องการแนวคิดใหม่หรือวิธีที่แตกต่าง',
    ),
    FusionSignalType.expression: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อการสื่อสารหรือการแสดงออกสร้างความเข้าใจร่วม',
    ),
    FusionSignalType.reflection: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อหยุดทบทวนแล้วเห็นทางเลือกที่ชัดขึ้น',
    ),
    FusionSignalType.transformation: SignalOpportunityPattern(
      opportunityPattern:
          'มักได้รับโอกาสเมื่อยอมรับการเปลี่ยนแปลงของตัวเองและเปิดรับมุมใหม่',
    ),
  };

  static SignalOpportunityPattern? forSignal(FusionSignalType type) {
    return patterns[type];
  }
}
