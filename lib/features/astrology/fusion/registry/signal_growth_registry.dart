import '../domain/entities/fusion_signal.dart';
import '../domain/entities/signal_growth_pattern.dart';

/// Per-signal growth depth templates (deterministic — no AI).
abstract final class SignalGrowthRegistry {
  static const Map<FusionSignalType, SignalGrowthPattern> patterns = {
    FusionSignalType.autonomy: SignalGrowthPattern(
      growthPotential: 'เรียนรู้การตัดสินใจอย่างมั่นใจ',
      maturityPath: 'ค่อย ๆ แยกแยะว่าอะไรควรทำเอง และอะไรควรขอมุมมองเพิ่ม',
      developmentDirection:
          'โดยไม่ปิดกั้นมุมมองจากผู้อื่น',
    ),
    FusionSignalType.structure: SignalGrowthPattern(
      growthPotential: 'เปลี่ยนความรับผิดชอบให้กลายเป็นความมั่นคงระยะยาว',
      maturityPath: 'เลือกโครงสร้างที่รองรับชีวิตจริง ไม่ใช่แค่ความสมบูรณ์แบบ',
      developmentDirection: 'ให้ความสม่ำเสมอกลายเป็นพลัง ไม่ใช่ภาระที่แข็งเกินไป',
    ),
    FusionSignalType.growth: SignalGrowthPattern(
      growthPotential: 'ขยายขอบเขตผ่านประสบการณ์ที่ท้าทายอย่างพอดี',
      maturityPath: 'แปลงสิ่งที่เรียนรู้ให้เป็นทิศทางที่ชัดขึ้น',
      developmentDirection: 'โดยไม่ต้องเปลี่ยนทุกอย่างพร้อมกัน',
    ),
    FusionSignalType.connection: SignalGrowthPattern(
      growthPotential: 'สร้างความสัมพันธ์ที่ให้พลังทั้งสองฝ่าย',
      maturityPath: 'เรียนรู้การดูแลผู้อื่นโดยไม่สูญเสียตัวเอง',
      developmentDirection: 'ให้ความใกล้ชิดกลายเป็นความมั่นคง ไม่ใช่การพึ่งพาอย่างเดียว',
    ),
    FusionSignalType.adaptation: SignalGrowthPattern(
      growthPotential: 'ใช้ความยืดหยุ่นเป็นทักษะ ไม่ใช่แค่การหลบเลี่ยง',
      maturityPath: 'รู้จักปรับตัวโดยยังรักษาแก่นแท้ของตัวเอง',
      developmentDirection: 'ให้การเปลี่ยนแปลงเป็นโอกาส ไม่ใช่ความไม่มั่นคง',
    ),
    FusionSignalType.leadership: SignalGrowthPattern(
      growthPotential: 'พัฒนาภาวะผู้นำที่ฟังและชี้ทางได้พร้อมกัน',
      maturityPath: 'แยกบทบาทผู้นำออกจากการควบคุมทุกอย่าง',
      developmentDirection: 'ให้ทิศทางชัดขึ้นโดยไม่ต้องแบกทุกคนไว้คนเดียว',
    ),
    FusionSignalType.creativity: SignalGrowthPattern(
      growthPotential: 'เปลี่ยนความคิดใหม่ให้กลายเป็นสิ่งที่ทำได้จริง',
      maturityPath: 'คัดเลือกไอเดียที่สอดคล้องกับชีวิตปัจจุบัน',
      developmentDirection: 'ให้ความคิดสร้างสรรค์มีรากฐาน ไม่ใช่แค่จินตนาการลอย ๆ',
    ),
    FusionSignalType.expression: SignalGrowthPattern(
      growthPotential: 'แสดงออกอย่างตรงไปตรงมาโดยยังคงความอ่อนไหว',
      maturityPath: 'รู้จักเวลาที่ควรพูด และเวลาที่ควรฟัง',
      developmentDirection: 'ให้การแสดงออกเชื่อมกับความเข้าใจตัวเองมากขึ้น',
    ),
    FusionSignalType.reflection: SignalGrowthPattern(
      growthPotential: 'ใช้การทบทวนเป็นเครื่องมือ ไม่ใช่การวนกลับไปมา',
      maturityPath: 'แปลงข้อสังเกตให้เป็นการตัดสินใจที่ชัดขึ้น',
      developmentDirection: 'ให้การคิดลึกนำไปสู่การก้าวต่อ ไม่ใช่การหยุดนิ่ง',
    ),
    FusionSignalType.transformation: SignalGrowthPattern(
      growthPotential: 'ยอมรับว่าตัวตนกำลังเปลี่ยนโดยไม่ต้องรีบนิยามตัวเอง',
      maturityPath: 'ให้เวลากับการปรับมุมมองทีละน้อย',
      developmentDirection: 'ให้ความเปลี่ยนแปลงมีความหมาย ไม่ใช่แค่ความไม่แน่นอน',
    ),
  };

  static SignalGrowthPattern? forSignal(FusionSignalType type) {
    return patterns[type];
  }
}
