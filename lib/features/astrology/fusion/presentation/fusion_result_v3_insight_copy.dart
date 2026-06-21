/// V3 insight copy — human meaning text only (no UI).
abstract final class FusionResultV3InsightCopy {
  static const warningSectionLabel = 'จุดที่ควรระวัง';

  static const knowMeMomentTitle = '✦ สิ่งที่น่าสนใจที่สุดจากหลายศาสตร์';

  static const peakPotentialItems = [
    FusionPeakPotentialItem(
      title: 'เมื่อคุณเป็นเจ้าของการตัดสินใจ',
      body:
          'คุณมักทำได้ดีที่สุด\n'
          'เมื่อรู้สึกว่าชีวิตกำลังเดินไปในทิศทางที่คุณเลือกเอง\n\n'
          'ต่อให้เส้นทางนั้นยากขึ้น\n'
          'คุณกลับมีพลังมากกว่าการเดินตามสิ่งที่คนอื่นคาดหวัง',
    ),
    FusionPeakPotentialItem(
      title: 'เมื่อคุณไม่ต้องซ่อนสิ่งที่คิด',
      body:
          'คุณมีแนวโน้มสร้างความเข้าใจและความร่วมมือได้ดี\n\n'
          'เมื่อสามารถพูดสิ่งที่คิด\n'
          'โดยไม่ต้องคอยปรับตัวจนหายไปจากตัวตนเดิม',
    ),
    FusionPeakPotentialItem(
      title: 'เมื่อคุณหยุดก่อนตัดสินใจเรื่องสำคัญ',
      body:
          'คุณมักเห็นทางเลือกที่ลึกกว่าเดิม\n\n'
          'หลายครั้งความชัดเจนของคุณ\n'
          'เกิดขึ้นหลังการทบทวน\n'
          'ไม่ใช่จากการรีบตัดสินใจ',
    ),
  ];

  static ({String title, String description}) strengthForSignalKey(String key) {
    if (key.contains('อิสระ') || key.contains('พึ่งพาตัวเอง')) {
      return (
        title: 'การรับผิดชอบต่อทางเลือก',
        description:
            'คุณไม่กลัวการรับผิดชอบต่อทางเลือกของตัวเอง\n\n'
            'แม้ไม่รู้ผลลัพธ์ทั้งหมด\n'
            'คุณมักพร้อมเดินหน้ามากกว่ารอความมั่นใจสมบูรณ์แบบ',
      );
    }
    if (key.contains('แสดงออก')) {
      return (
        title: 'พลังจากความจริงใจ',
        description:
            'คุณมีพลังเมื่อได้สื่อสารสิ่งที่เชื่อ\n\n'
            'ความคิดของคุณมักมีผลต่อคนรอบตัว\n'
            'เมื่อคุณพูดด้วยความจริงใจ',
      );
    }
    if (key.contains('ทบทวน')) {
      return (
        title: 'ความชัดเจนหลังการทบทวน',
        description:
            'คุณเรียนรู้จากประสบการณ์ได้ดี\n\n'
            'สิ่งที่เกิดขึ้นในอดีต\n'
            'มักกลายเป็นข้อมูลสำคัญ\n'
            'สำหรับการตัดสินใจครั้งต่อไป',
      );
    }
    if (key.contains('โครงสร้าง') || key.contains('รับผิดชอบ')) {
      return (
        title: 'ความมั่นคงในการลงมือทำ',
        description:
            'หลายศาสตร์เห็นรูปแบบเดียวกันว่า\n'
            'คุณมีพลังเมื่อมีโครงสร้างที่ชัด\n'
            'และรู้ว่ากำลังรับผิดชอบอะไรอยู่',
      );
    }
    if (key.contains('เติบโต') || key.contains('เรียนรู้')) {
      return (
        title: 'การเรียนรู้จากประสบการณ์',
        description:
            'คุณเรียนรู้จากประสบการณ์ได้ดี\n\n'
            'สิ่งที่เกิดขึ้นในอดีต\n'
            'มักกลายเป็นข้อมูลสำคัญ\n'
            'สำหรับการตัดสินใจครั้งต่อไป',
      );
    }
    return (
      title: key.split('และ').first.trim(),
      description:
          'หลายศาสตร์เห็นรูปแบบชีวิตแบบเดียวกันในด้านนี้\n'
          'และมักสะท้อนว่าคุณมีพลังเมื่อได้ใช้จุดแข็งนี้อย่างต่อเนื่อง',
    );
  }
}

/// Peak potential item — shared with V2.3 section.
class FusionPeakPotentialItem {
  const FusionPeakPotentialItem({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
