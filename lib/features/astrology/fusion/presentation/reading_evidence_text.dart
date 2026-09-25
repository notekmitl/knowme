import '../adapters/lens_theme_output.dart';

/// Thai display text derived only from an adapter's recorded engine facts.
abstract final class ReadingEvidenceText {
  static const themes = <String, String>{
    'independent': 'การตัดสินใจด้วยตนเอง',
    'adaptable': 'การปรับตัว',
    'grounded': 'การให้ความสำคัญกับความมั่นคง',
    'expressive': 'การแสดงออก',
    'reserved': 'การเปิดใจอย่างระมัดระวัง',
    'analytical': 'การคิดวิเคราะห์',
    'structured': 'การจัดระบบ',
    'intuitive': 'การใช้สัญชาตญาณ',
    'flexible': 'การปรับวิธีคิด',
    'responsive': 'ความไวต่อความรู้สึก',
    'calm': 'ความนิ่ง',
    'passionate': 'ความทุ่มเท',
    'supportive': 'การดูแลผู้อื่น',
    'diplomatic': 'การประนีประนอม',
    'loyal': 'ความจริงจังในความสัมพันธ์',
    'independent_connection': 'พื้นที่ส่วนตัวในความสัมพันธ์',
    'driven': 'การมุ่งสู่เป้าหมาย',
    'responsible': 'ความรับผิดชอบ',
    'leadership': 'การกำหนดทิศทาง',
    'growth_focused': 'การเรียนรู้และเติบโต',
    'reliable': 'ความสม่ำเสมอ',
    'persistent': 'ความอดทน',
    'creative': 'ความคิดสร้างสรรค์',
    'overthinking': 'แนวโน้มคิดวน',
    'rigidity': 'แนวโน้มยึดกับแผน',
    'impatience': 'แนวโน้มรีบตัดสินใจ',
    'balance': 'การมองหาสมดุล',
    'reflection': 'การทบทวน',
    'openness': 'การเปิดรับมุมมองใหม่',
  };

  static const _elements = <String, String>{
    'wood': 'ไม้',
    'fire': 'ไฟ',
    'earth': 'ดิน',
    'metal': 'ทอง',
    'water': 'น้ำ',
    'air': 'ลม',
  };
  static const _signs = <String, String>{
    'Aries': 'เมษ',
    'Taurus': 'พฤษภ',
    'Gemini': 'เมถุน',
    'Cancer': 'กรกฎ',
    'Leo': 'สิงห์',
    'Virgo': 'กันย์',
    'Libra': 'ตุล',
    'Scorpio': 'พิจิก',
    'Sagittarius': 'ธนู',
    'Capricorn': 'มังกร',
    'Aquarius': 'กุมภ์',
    'Pisces': 'มีน',
  };
  static const _animals = <String, String>{
    'Rat': 'ชวด',
    'Ox': 'ฉลู',
    'Tiger': 'ขาล',
    'Rabbit': 'เถาะ',
    'Dragon': 'มะโรง',
    'Snake': 'มะเส็ง',
    'Horse': 'มะเมีย',
    'Goat': 'มะแม',
    'Monkey': 'วอก',
    'Rooster': 'ระกา',
    'Dog': 'จอ',
    'Pig': 'กุน',
  };

  static String theme(String id) => themes[id] ?? id;

  /// A concrete reflection prompt, not an additional natal claim.
  static String meaning(String id) =>
      <String, String>{
        'independent':
            'เวลาเลือกทางสำคัญ ลองดูว่าการได้ตัดสินใจเองมีน้ำหนักเพียงใด',
        'leadership': 'ลองสังเกตว่าคุณมักกำหนดทิศทางเองในเรื่องใด',
        'grounded':
            'เวลาเลือกงานหรือแผนชีวิต ลองดูว่าความมั่นคงมีน้ำหนักเพียงใด',
        'reliable': 'ลองเทียบกับสิ่งที่คุณรับปากและทำต่อเนื่องในชีวิตจริง',
        'responsible': 'ลองดูว่าภาระที่คุณรับไว้มีผลต่อการตัดสินใจอย่างไร',
        'structured': 'ลองสังเกตว่าการมีขั้นตอนชัดช่วยให้ลงมือได้อย่างไร',
        'analytical': 'ลองดูว่าคุณใช้ข้อมูลอะไรประกอบการตัดสินใจ',
        'adaptable': 'เมื่อต้องเปลี่ยนแผน ลองดูว่าคุณปรับวิธีทำส่วนใดก่อน',
        'growth_focused': 'ลองสังเกตว่าเรื่องใหม่แบบใดทำให้คุณอยากเรียนรู้',
        'supportive':
            'ลองดูว่าการช่วยเหลือผู้อื่นปรากฏในความสัมพันธ์จริงอย่างไร',
        'diplomatic': 'เมื่อมีความเห็นต่าง ลองดูว่าคุณหาจุดตกลงกันอย่างไร',
        'loyal': 'ลองสังเกตว่าอะไรทำให้คุณรักษาความสัมพันธ์ไว้',
        'expressive':
            'ลองดูว่าคุณสื่อสารความคิดหรือความรู้สึกในเรื่องสำคัญอย่างไร',
        'responsive':
            'ลองสังเกตว่าความรู้สึกของคนรอบตัวมีผลต่อการตอบสนองอย่างไร',
        'driven': 'ลองดูว่าเป้าหมายแบบใดทำให้คุณเดินหน้าต่อ',
        'persistent': 'ลองสังเกตว่าคุณทำเรื่องใดต่อแม้ต้องใช้เวลา',
        'passionate': 'ลองดูว่าเรื่องใดได้รับพลังและความใส่ใจจากคุณมาก',
        'calm': 'เมื่อมีแรงกดดัน ลองสังเกตวิธีที่คุณรักษาจังหวะของตน',
        'intuitive': 'ลองแยกให้ออกว่าความรู้สึกแรกกับข้อมูลจริงช่วยกันอย่างไร',
        'reflection': 'ลองดูว่าการเว้นเวลาทบทวนช่วยเปลี่ยนการตัดสินใจหรือไม่',
        'flexible': 'ลองสังเกตว่าข้อมูลใหม่ทำให้คุณเปลี่ยนมุมมองอย่างไร',
        'balance': 'ลองดูว่าคุณให้น้ำหนักแก่ความต้องการแต่ละด้านอย่างไร',
      }[id] ??
      'ลองเทียบข้อสังเกตนี้กับประสบการณ์จริงของตน';

  static String observation(LensThemeOutput source) {
    return 'พบประเด็น${theme(source.themeId)}จาก ${evidencePhrase(source)}';
  }

  static String evidencePhrase(LensThemeOutput source, {bool prose = false}) {
    return source.evidence
        .map(fact)
        .where((item) => item.isNotEmpty)
        .map(
          (item) => prose && item.startsWith('ลัคนา: ')
              ? item.substring('ลัคนา: '.length)
              : item,
        )
        .take(2)
        .join(prose ? 'และ' : ' และ ');
  }

  static String fact(String raw) {
    final value = raw.trim();
    if (value.startsWith('Day Master: ')) {
      final parts = value.substring(12).split(' ');
      if (parts.length == 2 && _elements.containsKey(parts[1])) {
        final polarity = parts[0] == 'yin'
            ? 'หยิน'
            : parts[0] == 'yang'
            ? 'หยาง'
            : parts[0];
        return 'ธาตุประจำวัน${_elements[parts[1]]}$polarity';
      }
    }
    if (value.startsWith('Dominant Element: ')) {
      final element = value.substring(18);
      return 'ธาตุเด่นของดวงจีนเป็น${_elements[element] ?? element}';
    }
    if (value.startsWith('Element Balance: ')) {
      final parts = value.substring(17).split('=');
      if (parts.length == 2) {
        return 'ธาตุ${_elements[parts[0]] ?? parts[0]}ปรากฏ ${parts[1]} ส่วนในผังธาตุ';
      }
    }
    if (value.startsWith('Year Animal: ')) {
      final animal = value.substring(13).split(' · ').first;
      return 'ปีนักษัตร${_animals[animal] ?? animal} (หลักฐานรอง)';
    }
    for (final entry in <String, String>{
      'Sun Sign: ': 'อาทิตย์',
      'Moon Sign: ': 'จันทร์',
      'Rising Sign: ': 'ลัคนา',
    }.entries) {
      if (value.startsWith(entry.key)) {
        final sign = value.substring(entry.key.length);
        return '${entry.value}อยู่ราศี${_signs[sign] ?? sign}';
      }
    }
    if (value.startsWith('Element Summary: ')) {
      final element = value.substring(17);
      return 'ธาตุ${_elements[element] ?? element}เด่นในอาทิตย์ จันทร์ และลัคนา';
    }
    if (value.startsWith('Modality Summary: ')) {
      final modality = value.substring(18);
      final thai =
          {
            'cardinal': 'เริ่มต้น',
            'fixed': 'คงที่',
            'mutable': 'ปรับเปลี่ยน',
          }[modality] ??
          modality;
      return 'คุณภาพราศีแบบ$thaiเด่นในอาทิตย์ จันทร์ และลัคนา';
    }
    return value; // Thai Mirror already supplies a source and content title.
  }
}
