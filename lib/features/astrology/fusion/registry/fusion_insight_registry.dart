import '../domain/entities/fusion_insight.dart';
import '../domain/entities/fusion_signal.dart';

/// Template library for synthesized fusion insights (deterministic).
abstract final class FusionInsightRegistry {
  static const Map<FusionSignalType, FusionInsight> single = {
    FusionSignalType.autonomy: FusionInsight(
      title: 'เส้นทางที่สร้างด้วยตัวเอง',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจให้ความสำคัญกับการตัดสินใจและทิศทางของตัวเอง '
          'มากกว่าการถูกกำหนดจากภายนอก',
    ),
    FusionSignalType.structure: FusionInsight(
      title: 'โครงสร้างที่ทำให้มั่นใจ',
      description:
          'หลายศาสตร์สะท้อนว่าความรับผิดชอบและความสม่ำเสมอ '
          'อาจเป็นพื้นฐานที่ช่วยให้คุณรู้สึกมั่นคงเมื่อต้องเลือกทางเดิน',
    ),
    FusionSignalType.growth: FusionInsight(
      title: 'การเติบโตผ่านประสบการณ์',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจเติบโตได้ดีเมื่อได้ลองเรียนรู้ '
          'และขยายมุมมองจากสิ่งที่เกิดขึ้นจริง',
    ),
    FusionSignalType.connection: FusionInsight(
      title: 'พลังจากความสัมพันธ์',
      description:
          'หลายศาสตร์สะท้อนว่าการเชื่อมโยงและการดูแลผู้อื่น '
          'อาจมีบทบาทสำคัญต่อภาพรวมของตัวตนคุณ',
    ),
    FusionSignalType.adaptation: FusionInsight(
      title: 'การปรับตัวเมื่อโลกเปลี่ยน',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจมีความยืดหยุ่นในการปรับแนวทาง '
          'เมื่อสถานการณ์หรือบทบาทเปลี่ยนไป',
    ),
    FusionSignalType.leadership: FusionInsight(
      title: 'บทบาทผู้นำที่ค่อย ๆ ชัดขึ้น',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจถูกเรียกให้กำหนดทิศทาง '
          'หรือประสานงานเมื่อสิ่งรอบตัวต้องการความชัดเจน',
    ),
    FusionSignalType.creativity: FusionInsight(
      title: 'พลังสร้างสรรค์ที่แตกต่าง',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจมองเห็นทางใหม่ '
          'หรือสร้างแนวทางที่ไม่ซ้ำใครเมื่อเผชิญกับความท้าทาย',
    ),
    FusionSignalType.transformation: FusionInsight(
      title: 'มุมมองที่กำลังเปลี่ยนรูป',
      description:
          'หลายศาสตร์สะท้อนว่าภาพของตัวตนคุณอาจไม่ได้อยู่กับที่ '
          'แต่กำลังถูกปรับผ่านหลายแง่มุมที่ต่างกัน',
    ),
    FusionSignalType.expression: FusionInsight(
      title: 'การแสดงออกที่สะท้อนตัวตน',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจแสดงความรู้สึกและความคิดออกมา '
          'เมื่อรู้สึกปลอดภัยและเป็นตัวเอง',
    ),
    FusionSignalType.reflection: FusionInsight(
      title: 'การทบทวนก่อนก้าวต่อ',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจให้เวลากับการคิดทบทวน '
          'ก่อนตัดสินใจครั้งสำคัญ',
    ),
  };

  static const Map<String, FusionInsight> combinations = {
    'autonomy|structure': FusionInsight(
      title: 'อิสระที่ต้องมีโครงสร้างรองรับ',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจต้องการทั้งอิสระในการเลือกทาง '
          'และความรับผิดชอบที่ทำให้ทางนั้นดำเนินต่อได้จริง '
          'ความหมายที่เกิดขึ้นคือเส้นทางของคุณอาจไม่ใช่การหนีจากข้อผูกมัด '
          'แต่คือการเลือกว่าจะรับผิดชอบอะไรอย่างตั้งใจ',
    ),
    'autonomy|growth': FusionInsight(
      title: 'การเติบโตที่เริ่มจากตัวเอง',
      description:
          'หลายศาสตร์สะท้อนว่าการเติบโตของคุณอาจไม่ได้มาจากการทำตามคนอื่น '
          'แต่มาจากการตัดสินใจและประสบการณ์ที่คุณเลือกเอาเข้ามาเอง '
          'นี่คือภาพของคนที่ค่อย ๆ สร้างตัวเองผ่านทางเลือกของตัวเอง',
    ),
    'autonomy|structure|growth': FusionInsight(
      title: 'เส้นทางชีวิตที่สร้างด้วยตัวเอง',
      description:
          'หลายศาสตร์สะท้อนแนวโน้มของการสร้างเส้นทางชีวิตด้วยตัวเอง\n\n'
          'แต่การเติบโตไม่ได้มาจากความเป็นอิสระเพียงอย่างเดียว\n'
          'หลายครั้งโอกาสสำคัญอาจเกิดขึ้นเมื่อความรับผิดชอบและประสบการณ์เริ่มทำงานร่วมกัน',
    ),
    'growth|adaptation': FusionInsight(
      title: 'เติบโตผ่านการปรับตัว',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจเติบโตได้ดีที่สุดเมื่อยอมรับการเปลี่ยนแปลง '
          'และเรียนรู้จากสิ่งใหม่ ๆ ที่เข้ามา '
          'ไม่ใช่แค่ยืนหยัดในที่เดิม แต่คือขยับไปพร้อมกับประสบการณ์',
    ),
    'connection|leadership': FusionInsight(
      title: 'ผู้นำที่เชื่อมคนเข้าด้วยกัน',
      description:
          'หลายศาสตร์สะท้อนว่าบทบาทของคุณอาจไม่ใช่แค่การนำคนไปข้างหน้า '
          'แต่คือการสร้างความไว้ใจและพื้นที่ให้ผู้อื่นร่วมทาง '
          'ภาพรวมนี้เกิดจากการรวมทั้งความสัมพันธ์และทิศทาง',
    ),
    'creativity|structure': FusionInsight(
      title: 'สร้างสรรค์ภายในกรอบที่ชัด',
      description:
          'หลายศาสตร์สะท้อนว่าคุณอาจทำงานได้ดีเมื่อมีโครงสร้างรองรับ '
          'แต่ยังมีพื้นที่ให้ความคิดใหม่เกิดขึ้น '
          'ความหมายที่เกิดคือการสร้างสิ่งใหม่โดยไม่สูญเสียความมั่นคง',
    ),
  };

  static const Map<String, FusionInsight> tensionPairs = {
    'autonomy|connection': FusionInsight(
      title: 'อิสระและความสัมพันธ์',
      description:
          'หลายศาสตร์กำลังสะท้อนทั้งความต้องการอิสระ\n'
          'และความสำคัญของความสัมพันธ์\n\n'
          'ความท้าทายอาจไม่ใช่การเลือกด้านใดด้านหนึ่ง\n'
          'แต่คือการหาสมดุลระหว่างทั้งสองด้าน',
    ),
    'autonomy|structure': FusionInsight(
      title: 'อิสระและความรับผิดชอบ',
      description:
          'หลายศาสตร์สะท้อนทั้งความต้องการเดินด้วยตัวเอง '
          'และความจำเป็นในการรักษาโครงสร้าง '
          'ความหมายที่เกิดคือการเรียนรู้ว่าอิสระแท้จริงอาจมาพร้อมกับขอบเขตที่เลือกเอง',
    ),
    'growth|structure': FusionInsight(
      title: 'การเติบโตและความมั่นคง',
      description:
          'หลายศาสตร์สะท้อนทั้งแนวโน้มการเปลี่ยนแปลง '
          'และความต้องการมีรากฐานที่มั่นคง '
          'การรวมกันนี้ชี้ว่าคุณอาจเติบโตได้ดีเมื่อมีทั้งทิศทางและพื้นที่ปลอดภัย',
    ),
    'connection|expression': FusionInsight(
      title: 'ความสัมพันธ์และการแสดงออก',
      description:
          'หลายศาสตร์สะท้อนทั้งการเชื่อมโยงกับผู้อื่น '
          'และวิธีที่คุณแสดงความรู้สึกออกมา '
          'ภาพรวมนี้ชี้ว่าคุณอาจเข้าใจตัวเองผ่านปฏิสัมพันธ์กับคนรอบข้าง',
    ),
  };

  static String combinationKey(Iterable<FusionSignalType> types) {
    final names = types.map((type) => type.name).toList()..sort();
    return names.join('|');
  }

  static FusionInsight? insightForCombination(Set<FusionSignalType> types) {
    if (types.isEmpty) return null;

    final sortedKeys = combinations.keys.toList()
      ..sort((a, b) => b.split('|').length.compareTo(a.split('|').length));

    for (final key in sortedKeys) {
      final required = key.split('|').map(FusionSignalType.values.byName).toSet();
      if (types.containsAll(required)) {
        return combinations[key];
      }
    }

    return null;
  }

  static FusionInsight? insightForSingle(FusionSignalType type) {
    return single[type];
  }

  static FusionInsight? insightForTensionPair(Set<FusionSignalType> types) {
    if (types.length < 2) return null;

    final sortedKeys = tensionPairs.keys.toList()
      ..sort((a, b) => b.split('|').length.compareTo(a.split('|').length));

    for (final key in sortedKeys) {
      final pair = key.split('|').map(FusionSignalType.values.byName).toSet();
      if (types.containsAll(pair)) return tensionPairs[key];
    }

    return null;
  }
}
