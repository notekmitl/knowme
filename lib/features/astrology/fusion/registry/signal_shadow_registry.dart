import '../domain/entities/fusion_signal.dart';
import '../domain/entities/signal_shadow_pattern.dart';

/// Per-signal shadow depth templates (deterministic — no AI).
abstract final class SignalShadowRegistry {
  static const Map<FusionSignalType, SignalShadowPattern> patterns = {
    FusionSignalType.autonomy: SignalShadowPattern(
      blindSpot: 'อาจมองข้ามมุมมองที่ต้องการความร่วมมือ',
      overusePattern: 'ทำทุกอย่างคนเดียวมากเกินไป',
    ),
    FusionSignalType.structure: SignalShadowPattern(
      blindSpot: 'อาจมองไม่เห็นโอกาสที่ต้องยืดหยุ่น',
      overusePattern: 'ยึดติดกับรูปแบบเดิมมากเกินไป',
    ),
    FusionSignalType.growth: SignalShadowPattern(
      blindSpot: 'อาจรีบเปลี่ยนก่อนสิ่งใหม่พร้อม',
      overusePattern: 'ไล่ตามการเติบโตจนลืมพักหรือทบทวน',
    ),
    FusionSignalType.connection: SignalShadowPattern(
      blindSpot: 'อาจมองข้ามความต้องการส่วนตัวของตัวเอง',
      overusePattern: 'ดูแลผู้อื่นจนลืมขอบเขตของตัวเอง',
    ),
    FusionSignalType.adaptation: SignalShadowPattern(
      blindSpot: 'อาจปรับตัวจนไม่รู้ว่าต้องการอะไรจริง ๆ',
      overusePattern: 'เปลี่ยนตามสถานการณ์บ่อยเกินจนไม่มั่นคง',
    ),
    FusionSignalType.leadership: SignalShadowPattern(
      blindSpot: 'อาจมองข้ามความต้องการของทีมที่ไม่ได้พูดออกมา',
      overusePattern: 'รับบทบาทผู้นำทุกเรื่องจนเหนื่อยล้า',
    ),
    FusionSignalType.creativity: SignalShadowPattern(
      blindSpot: 'อาจมองข้ามขั้นตอนที่ทำให้ไอเดียสำเร็จได้จริง',
      overusePattern: 'ไล่ตามความใหม่จนงานค้างคา',
    ),
    FusionSignalType.expression: SignalShadowPattern(
      blindSpot: 'อาจแสดงออกโดยไม่รู้ว่าผู้อื่นรับได้แค่ไหน',
      overusePattern: 'พูดหรือแสดงออกมากเกินจนความหมายจางลง',
    ),
    FusionSignalType.reflection: SignalShadowPattern(
      blindSpot: 'อาจคิดมากจนพลาดโอกาสลงมือทำ',
      overusePattern: 'ทบทวนซ้ำจนไม่กล้าตัดสินใจ',
    ),
    FusionSignalType.transformation: SignalShadowPattern(
      blindSpot: 'อาจสับสนระหว่างการเปลี่ยนแปลงกับการไม่มั่นคง',
      overusePattern: 'เปลี่ยนมุมมองบ่อยจนไม่มีแก่นแท้',
    ),
  };

  static SignalShadowPattern? forSignal(FusionSignalType type) {
    return patterns[type];
  }
}
