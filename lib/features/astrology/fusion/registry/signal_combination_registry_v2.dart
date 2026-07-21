import '../domain/entities/fusion_signal.dart';
import '../domain/entities/future_tendency.dart';

/// Combination-specific tendency templates for Future Tendencies V3.
abstract final class SignalCombinationRegistryV2 {
  static const Map<String, FutureTendency> combinations = {
    'autonomy|structure': FutureTendency(
      title: 'บทบาทที่เลือกรับเอง',
      description:
          'แนวโน้มของการได้รับบทบาทที่ต้องรับผิดชอบมากขึ้น '
          'โดยเฉพาะเมื่อคุณเลือกสิ่งที่ควรแบกรับอย่างตั้งใจ '
          'ไม่ใช่การแบกรับทุกอย่างที่เข้ามา',
    ),
    'growth|adaptation': FutureTendency(
      title: 'โอกาสผ่านการเปลี่ยนแปลง',
      description:
          'แนวโน้มของโอกาสที่เกิดจากการเรียนรู้สิ่งใหม่ '
          'หรือการปรับตัวเมื่อสถานการณ์เปลี่ยน '
          'การเติบโตมักมาพร้อมความยืดหยุ่น',
    ),
    'connection|structure': FutureTendency(
      title: 'ความสัมพันธ์ที่มั่นคง',
      description:
          'แนวโน้มของการสร้างความสัมพันธ์ที่เชื่อถือได้ '
          'ผ่านความสม่ำเสมอและการดูแลซึ่งกันและกัน '
          'ความมั่นคงมักมาจากการรักษาสัญญาเล็ก ๆ อย่างต่อเนื่อง',
    ),
    'growth|reflection': FutureTendency(
      title: 'การเติบโตจากการทบทวน',
      description:
          'แนวโน้มของการเรียนรู้จากประสบการณ์ '
          'ผ่านการหยุดทบทวนก่อนตัดสินใจครั้งถัดไป '
          'สิ่งที่คิดทบทวนอาจกลายเป็นทิศทางใหม่',
    ),
    'autonomy|growth': FutureTendency(
      title: 'เส้นทางที่ขยายจากตัวเอง',
      description:
          'แนวโน้มของการเติบโตผ่านทางเลือกที่คุณกำหนดเอง '
          'โอกาสมักมาเมื่อคุณกล้าลองสิ่งใหม่โดยไม่รอให้ใครมากำหนด',
    ),
    'connection|leadership': FutureTendency(
      title: 'โอกาสผ่านการเชื่อมคน',
      description:
          'แนวโน้มของโอกาสที่เกิดจากความสัมพันธ์และบทบาทผู้นำ '
          'การสร้างความไว้วางใจอาจเปิดประตูที่คาดไม่ถึง',
    ),
    'creativity|structure': FutureTendency(
      title: 'สร้างสรรค์ภายในกรอบที่ชัด',
      description:
          'แนวโน้มของการสร้างสิ่งใหม่โดยมีโครงสร้างรองรับ '
          'ความคิดสร้างสรรค์มักสำเร็จได้ดีเมื่อมีขอบเขตที่ชัดเจน',
    ),
    'autonomy|connection': FutureTendency(
      title: 'อิสระที่ยังเชื่อมกับคน',
      description:
          'แนวโน้มของโอกาสที่ต้องหาสมดุลระหว่างการตัดสินใจเอง '
          'กับการรักษาความสัมพันธ์ที่สำคัญ '
          'ทั้งสองด้านอาจเสริมกันเมื่อเลือกอย่างตั้งใจ',
    ),
  };

  static String combinationKey(Iterable<FusionSignalType> types) {
    final names = types.map((type) => type.name).toList()..sort();
    return names.join('|');
  }

  static FutureTendency? tendencyForTypes(Set<FusionSignalType> types) {
    if (types.length < 2) return null;

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
}
