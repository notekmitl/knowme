/// Product-facing astrology readiness states.
enum AstrologyFlowState {
  computing,
  firstGeneration,
  incompleteProfile,
  ready,
}

abstract final class AstrologyFlowCopy {
  static const computingTitle = 'กำลังคำนวณ';
  static const computingBody = 'กำลังเตรียมผลวิเคราะห์...';
  static const firstGenTitle = 'สร้างดวงครั้งแรก';
  static const firstGenBody =
      'ข้อมูลเกิดพร้อมแล้ว — แตะเพื่อสร้างผลโหราศาสตร์ของคุณ';
  static const incompleteProfileTitle = 'ข้อมูลเกิดไม่ครบ';
  static const incompleteProfileBody =
      'กรอกวันเกิด เวลาเกิด และสถานที่เกิดเพื่อเริ่มสร้างดวง';
  static const completeProfileCta = 'กรอกข้อมูลเกิด';
  static const generateCta = 'สร้างดวง';
  static const retryCta = 'ลองอีกครั้ง';

  static String generationTitle(String systemName) => 'กำลังสร้าง$systemName';
  static String generationBody(String systemName) =>
      'ใช้เวลาประมาณ 5–10 วินาที';
}
