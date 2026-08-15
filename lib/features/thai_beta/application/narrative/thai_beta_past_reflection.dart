/// Developmentally appropriate, evidence-bounded reflection copy for past
/// life periods. The resolver depends only on the age range, never on an
/// acceptance fixture identifier.
library;

enum ThaiBetaPastAgeBand { childhood, adolescence, emergingAdult, adult }

class ThaiBetaPastReflection {
  const ThaiBetaPastReflection({
    required this.ageBand,
    required this.theme,
    required this.question,
  });

  final ThaiBetaPastAgeBand ageBand;
  final String theme;
  final String question;
}

abstract final class ThaiBetaPastReflectionComposer {
  static ThaiBetaPastAgeBand resolveAgeBand({
    required int startAge,
    required int endAge,
  }) {
    final start = startAge < 1 ? 1 : startAge;
    final end = endAge < start ? start : endAge;
    const bands = <(ThaiBetaPastAgeBand, int, int)>[
      (ThaiBetaPastAgeBand.childhood, 1, 10),
      (ThaiBetaPastAgeBand.adolescence, 11, 17),
      (ThaiBetaPastAgeBand.emergingAdult, 18, 29),
      (ThaiBetaPastAgeBand.adult, 30, 200),
    ];
    var selected = ThaiBetaPastAgeBand.adult;
    var largestOverlap = -1;
    for (final band in bands) {
      final overlapStart = start > band.$2 ? start : band.$2;
      final overlapEnd = end < band.$3 ? end : band.$3;
      final overlap = overlapEnd >= overlapStart
          ? overlapEnd - overlapStart + 1
          : 0;
      if (overlap > largestOverlap) {
        selected = band.$1;
        largestOverlap = overlap;
      }
    }
    return selected;
  }

  static ThaiBetaPastReflection compose({
    required int startAge,
    required int endAge,
    required String ageLabel,
    required String phaseName,
    required String keyword,
    String decisionLens = '',
    String reportStrength = '',
  }) {
    final band = resolveAgeBand(startAge: startAge, endAge: endAge);
    final theme = keyword.trim().isEmpty
        ? 'สิ่งที่เปลี่ยนไปตามช่วงวัย'
        : keyword.trim();
    final phase = phaseName.trim().isEmpty ? 'ช่วงชีวิตนี้' : phaseName.trim();
    final lens = decisionLens.trim().isEmpty
        ? 'การตัดสินใจวันนี้'
        : 'โจทย์${decisionLens.trim()}วันนี้';
    final strength = reportStrength.trim().isEmpty
        ? 'สิ่งที่คุณทำได้ดี'
        : reportStrength.trim();
    return switch (band) {
      ThaiBetaPastAgeBand.childhood => ThaiBetaPastReflection(
        ageBand: band,
        theme:
            'ธีมสำหรับทบทวน: $themeใน$phaseอาจเทียบได้กับความทรงจำเรื่องบ้าน '
            'ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการได้รับการยอมรับ โดยให้$strengthช่วยมองว่าฐานใดติดตัวมา',
        question:
            'คำถามสะท้อน: เมื่อนึกถึงวัย $ageLabel คุณจำได้ไหมว่าที่ใดหรือใคร'
            'ทำให้กล้าลอง เล่น หรือเรียนรู้ และความทรงจำนั้นบอกอะไรเกี่ยวกับฐานที่คุณใช้ตัดสินใจวันนี้',
      ),
      ThaiBetaPastAgeBand.adolescence => ThaiBetaPastReflection(
        ageBand: band,
        theme:
            'ธีมสำหรับทบทวน: ใน$phase $strengthชวนให้มอง$themeผ่านการเรียน เพื่อน กฎ '
            'ความคาดหวัง และการเริ่มเลือกด้วยเสียงของตัวเอง',
        question:
            'คำถามสะท้อน: หากย้อนถึงวัย $ageLabel ความทรงจำใดบอกว่าคุณเริ่ม'
            'แยกสิ่งที่ตัวเองต้องการออกจากสิ่งที่คนรอบข้างคาด และตัวเลือกครั้งนั้นหล่อวิธีรับมือ$lensอย่างไร',
      ),
      ThaiBetaPastAgeBand.emergingAdult => ThaiBetaPastReflection(
        ageBand: band,
        theme:
            'ธีมสำหรับทบทวน: $themeของ$phaseซึ่งอ่านผ่าน$strengthอยู่ในบริบทของการเป็นอิสระ '
            'การศึกษา การเริ่มงาน ความสัมพันธ์ และทรัพยากรที่ต้องจัดการเองมากขึ้น โดย$strengthช่วยแยกสิ่งที่เลือกเองจากสิ่งที่รับตามแรงรอบตัว',
        question:
            'คำถามสะท้อน: เมื่อคิดถึงวัย $ageLabel คุณจำจุดใดได้ชัดที่สุด'
            'ระหว่างการออกไปยืนด้วยตัวเอง การเริ่มเส้นทางใหม่ หรือการตั้งขอบเขตกับคนใกล้ตัว แล้วบทเรียนนั้นช่วยคัด$lensแบบไหน',
      ),
      ThaiBetaPastAgeBand.adult => ThaiBetaPastReflection(
        ageBand: band,
        theme:
            'ธีมสำหรับทบทวน: ลองวาง$themeของ$phaseไว้ข้างงาน เงิน ความสัมพันธ์ '
            'ความรับผิดชอบ และบทบาทที่อาจต้องจัดใหม่ แล้วใช้$strengthดูว่าเกณฑ์เดิมส่วนใดยังควรรักษา',
        question:
            'คำถามสะท้อน: เมื่อมองกลับไปที่วัย $ageLabel มีความทรงจำช่วงใด'
            'ที่คุณต้องชั่งระหว่างสิ่งที่รับผิดชอบอยู่กับบทบาทที่อยากเปลี่ยน และเกณฑ์ครั้งนั้นยังเหมาะกับ$lensหรือไม่',
      ),
    };
  }
}
