import 'package:knowme/data/models/bazi_chart_model.dart';

import '../domain/bazi_theme.dart';

/// Deterministic BaZi insight mapping (no AI, no network).
abstract final class BaziThemeEngine {
  static const int _minBullets = 3;
  static const int _maxBullets = 5;

  static BaziTheme build(BaziChartModel chart, String lang) {
    return BaziTheme(
      coreSelf: _coreSelf(chart.dayMaster, lang),
      strengths: _cap(_strengths(chart, lang), _maxBullets),
      growthAreas: _cap(_growthAreas(chart, lang), _maxBullets),
    );
  }

  static String heroHeadline(BaziDayMaster dm, String lang) {
    if (lang == 'th') {
      return '${_polarityLabel(dm.polarity, lang)}${_elementLabel(dm.element, lang)}';
    }
    return '${_polarityLabel(dm.polarity, lang)} ${_elementLabel(dm.element, lang)}';
  }

  static String heroContextLine(String lang) =>
      lang == 'th' ? 'ในมุมมองของดวงจีน' : 'Through the Chinese chart lens';

  static String heroOwnershipLine(BaziDayMaster dm, String lang) {
    if (lang == 'th') {
      return 'ธาตุประจำตัวของคุณคือ'
          '${_elementLabel(dm.element, lang)}${_polarityLabel(dm.polarity, lang)}';
    }
    return 'Your Day Master element is '
        '${_polarityLabel(dm.polarity, lang)} ${_elementLabel(dm.element, lang)}';
  }

  static String heroSymbolNarrative(BaziDayMaster dm, String lang) {
    final key = _dmKey(dm);
    return _heroSymbolCopy[lang]?[key] ?? _heroSymbolCopy['en']![key]!;
  }

  /// Backward-compatible single-line hero text (tests / legacy callers).
  static String heroIntro(BaziChartModel chart, String lang) {
    return heroSymbolNarrative(chart.dayMaster, lang);
  }

  static BaziDominantHighlight? dominantHighlight(
    BaziChartModel chart,
    String lang,
  ) {
    final element = chart.dominantElement ?? _dominantFromBalance(chart);
    if (element == null || element.isEmpty) return null;

    return BaziDominantHighlight(
      headline: _dominantHeadline(element, lang),
      intro: _dominantIntroCopy[lang]?[element] ?? _dominantIntroCopy['en']![element]!,
      associations: List<String>.from(
        _dominantAssociationsCopy[lang]?[element] ??
            _dominantAssociationsCopy['en']![element]!,
      ),
    );
  }

  static String? _dominantFromBalance(BaziChartModel chart) {
    final sorted = _sortedBalance(chart.elementBalance);
    if (sorted.isEmpty || sorted.first.count == 0) return null;
    return sorted.first.element;
  }

  static String _dominantHeadline(String element, String lang) {
    if (lang == 'th') {
      return 'ธาตุ${_elementLabel(element, lang)}เด่น';
    }
    return 'Prominent ${_elementLabel(element, lang)}';
  }

  // --- Core Self (Day Master) ---

  static String _coreSelf(BaziDayMaster dm, String lang) {
    final key = _dmKey(dm);
    return _coreSelfCopy[lang]?[key] ?? _coreSelfCopy['en']![key]!;
  }

  static String _dmKey(BaziDayMaster dm) => '${dm.polarity}_${dm.element}';

  // --- Strengths ---

  static List<String> _strengths(BaziChartModel chart, String lang) {
    final items = <String>[];
    final seen = <String>{};

    void add(String? value) {
      if (value == null || value.isEmpty || seen.contains(value)) return;
      seen.add(value);
      items.add(value);
    }

    add(_dmStrengthCopy[lang]?[_dmKey(chart.dayMaster)]);

    final dominant = chart.dominantElement;
    if (dominant != null && dominant != chart.dayMaster.element) {
      add(_dominantStrengthCopy[lang]?[dominant]);
    }

    for (final entry in _sortedBalance(chart.elementBalance)) {
      if (items.length >= _maxBullets) break;
      if (entry.count < 2) continue;
      add(_highBalanceStrengthCopy[lang]?[entry.element]);
    }

    add(_yearAnimalStrengthCopy[lang]?[chart.yearAnimal.en.toLowerCase()]);

    return _padToMin(items, _genericStrengths(lang), _minBullets);
  }

  // --- Growth Areas (Element Balance) ---

  static List<String> _growthAreas(BaziChartModel chart, String lang) {
    final balance = chart.elementBalance;
    final counts = _balanceMap(balance);
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final minCount = counts.values.fold<int>(counts.values.first, (a, b) => a < b ? a : b);
    final items = <String>[];
    final seen = <String>{};

    void add(String? value) {
      if (value == null || value.isEmpty || seen.contains(value)) return;
      seen.add(value);
      items.add(value);
    }

    for (final entry in counts.entries) {
      if (entry.value == maxCount && maxCount >= 3) {
        add(_overDominantGrowthCopy[lang]?[entry.key]);
      }
    }

    for (final entry in counts.entries) {
      if (entry.value == 0) {
        add(_missingElementGrowthCopy[lang]?[entry.key]);
      }
    }

    if (maxCount - minCount >= 3) {
      add(_imbalanceGrowthCopy[lang]);
    }

    if (maxCount >= 4) {
      add(_intensityGrowthCopy[lang]);
    }

    return _padToMin(items, _genericGrowthAreas(lang), _minBullets);
  }

  // --- Helpers ---

  static String _polarityLabel(String polarity, String lang) {
    if (lang == 'th') {
      return polarity == 'yang' ? 'หยาง' : 'หยิน';
    }
    return polarity == 'yang' ? 'Yang' : 'Yin';
  }

  static String _elementLabel(String element, String lang) {
    if (lang == 'th') {
      return switch (element) {
        'wood' => 'ไม้',
        'fire' => 'ไฟ',
        'earth' => 'ดิน',
        'metal' => 'ทอง',
        'water' => 'น้ำ',
        _ => element,
      };
    }
    return switch (element) {
      'wood' => 'Wood',
      'fire' => 'Fire',
      'earth' => 'Earth',
      'metal' => 'Metal',
      'water' => 'Water',
      _ => element,
    };
  }

  static Map<String, int> _balanceMap(BaziElementBalance balance) {
    return {
      'wood': balance.wood,
      'fire': balance.fire,
      'earth': balance.earth,
      'metal': balance.metal,
      'water': balance.water,
    };
  }

  static List<({String element, int count})> _sortedBalance(
    BaziElementBalance balance,
  ) {
    final entries = _balanceMap(balance).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries) (element: e.key, count: e.value),
    ];
  }

  static List<String> _cap(List<String> items, int max) {
    if (items.length <= max) return items;
    return items.sublist(0, max);
  }

  static List<String> _padToMin(
    List<String> items,
    List<String> fallback,
    int min,
  ) {
    final out = List<String>.from(items);
    for (final item in fallback) {
      if (out.length >= min) break;
      if (!out.contains(item)) out.add(item);
    }
    return out;
  }

  static List<String> _genericStrengths(String lang) {
    if (lang == 'th') {
      return [
        'มักปรับตัวกับสถานการณ์ได้เมื่อจำเป็น',
        'มีมุมมองของตัวเองที่ค่อยๆ ก่อตัวขึ้น',
      ];
    }
    return [
      'You can adapt when the situation calls for it',
      'Your perspective tends to form gradually over time',
    ];
  }

  static List<String> _genericGrowthAreas(String lang) {
    if (lang == 'th') {
      return [
        'อาจลืมถอยห่างเพื่อฟังจังหวะของตัวเองบ้าง',
        'บางช่วงอาจลงมือเร็วกว่าที่ร่างกายหรือใจพร้อม',
      ];
    }
    return [
      'You may forget to step back and listen to your own rhythm',
      'Sometimes you may move before your body or mind feels ready',
    ];
  }

  static const Map<String, Map<String, String>> _coreSelfCopy = {
    'th': {
      'yang_wood': 'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อได้เริ่มต้น พัฒนา '
          'หรือผลักดันบางสิ่งให้เติบโต — การขยับไปข้างหน้ามักให้ความหมายกับคุณมากกว่าการยืนอยู่กับที่',
      'yin_wood': 'คุณอาจมองการเติบโตเป็นกระบวนการที่ค่อยเป็นค่อยไป '
          'มากกว่าการก้าวกระโดด — บางครั้งการรอจังหวะที่เหมาะอาจรู้สึกเป็นทางที่ปลอดภัยกว่า',
      'yang_fire': 'พลังของคุณมักปรากฏเมื่อมีบางสิ่งที่จุดประกาย — '
          'คุณอาจรู้สึกมีชีวิตชีวาขึ้นเมื่อเห็นความคืบหน้าหรือได้ลงมือทำจริง',
      'yin_fire': 'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อได้ลงมือทำบางอย่างที่ยังเป็นแรงบันดาลใจ '
          '— แม้ภายนอกจะดูสงบ ภายในมักมีไฟเล็กๆ ที่ต้องการถูกจุด',
      'yang_earth': 'คุณอาจมุ่งหน้าไปกับสิ่งที่แน่นอนและมีโครงสร้าง — '
          'การวางรากฐานมักให้ความรู้สึกมั่นคงกว่าการเริ่มจากความว่าง',
      'yin_earth': 'ความมั่นคงอาจเป็นเสาหลักที่คุณพึ่งได้ — '
          'คุณอาจชอบสร้างพื้นที่ปลอดภัยก่อนที่จะขยายตัวออกไป',
      'yang_metal': 'ความชัดเจนอาจเป็นสิ่งที่คุณให้ความสำคัญ — '
          'บางครั้งการตัดสินใจอาจดูตรงไปตรงมากว่าที่คนอื่นเห็น',
      'yin_metal': 'บางครั้งคุณอาจแยกแยะรายละเอียดได้ชัดกว่าที่คนอื่นสังเกต — '
          'การจัดระเบียบหรือคัดกรองมักช่วยให้คุณรู้สึกพร้อมลงมือ',
      'yang_water': 'คุณอาจปรับตัวกับสถานการณ์ได้ไว — '
          'บางครั้งการไหลไปตามจังหวะอาจรู้สึกเป็นธรรมชาติกว่าการยึดตำแหน่งเดิม',
      'yin_water': 'คุณอาจรับรู้สิ่งรอบตัวลึกกว่าที่พูดออกมา — '
          'มักใช้เวลาประมวลผลก่อนแสดงออก แม้ภายนอกจะดูนิ่ง',
    },
    'en': {
      'yang_wood': 'You may feel most at ease when you can start, develop, '
          'or nudge something forward — movement often means more to you than standing still.',
      'yin_wood': 'Growth may feel like a gradual process rather than a leap — '
          'waiting for the right rhythm can feel safer than forcing pace.',
      'yang_fire': 'Your energy often shows when something sparks momentum — '
          'you may feel more alive when you see progress or take real action.',
      'yin_fire': 'You may feel comfortable acting on quiet inspiration — '
          'even when you look calm outside, a small inner flame often wants to be lit.',
      'yang_earth': 'You may lean toward what feels solid and structured — '
          'building a foundation can feel steadier than starting from empty ground.',
      'yin_earth': 'Stability may be a pillar you rely on — '
          'you might prefer to create a safe base before expanding outward.',
      'yang_metal': 'Clarity may matter deeply to you — '
          'your decisions can look more direct than others expect.',
      'yin_metal': 'You may notice details others overlook — '
          'sorting and refining can help you feel ready to act.',
      'yang_water': 'You may adapt quickly to changing conditions — '
          'flowing with the moment can feel more natural than holding one fixed stance.',
      'yin_water': 'You may sense more than you say aloud — '
          'processing inwardly can come before visible expression.',
    },
  };

  static const Map<String, Map<String, String>> _heroSymbolCopy = {
    'th': {
      'yang_wood': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของการเริ่มต้น การเติบโต '
          'และการผลักดันสิ่งใหม่ให้ขยับไปข้างหน้า',
      'yin_wood': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของการเติบโตอย่างค่อยเป็นค่อยไป '
          'และการรอจังหวะที่เหมาะก่อนขยายตัว',
      'yang_fire': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของพลัง ความกระตือรือร้น '
          'และการลงมือเมื่อเห็นทิศทาง',
      'yin_fire': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของแรงบันดาลใจภายใน '
          'และการรักษาความอ่อนโยนแม้มีพลังซ่อนอยู่',
      'yang_earth': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของความมั่นคง โครงสร้าง '
          'และการวางรากฐานก่อนก้าวต่อ',
      'yin_earth': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของการดูแล การอำนวยความสะดวก '
          'และการสร้างพื้นที่ที่ปลอดภัย',
      'yang_metal': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของความชัดเจน ความตรงไปตรงมา '
          'และการตัดสินใจเมื่อเห็นสิ่งที่ควรทำ',
      'yin_metal': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของการคัดเลือก การจัดระเบียบ '
          'และความละเอียดรอบคอบ',
      'yang_water': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของความยืดหยุ่น การไหล '
          'และการปรับจังหวะตามบริบท',
      'yin_water': 'ธาตุนี้มักถูกใช้เป็นสัญลักษณ์ของการรับรู้ลึก การไตร่ตรอง '
          'และการประมวลผลก่อนแสดงออก',
    },
    'en': {
      'yang_wood': 'This element is often read as a symbol of beginnings, growth, '
          'and pushing new momentum forward.',
      'yin_wood': 'This element is often read as a symbol of gradual growth '
          'and waiting for the right season to expand.',
      'yang_fire': 'This element is often read as a symbol of drive, spark, '
          'and action when direction appears.',
      'yin_fire': 'This element is often read as a symbol of inner inspiration '
          'and quiet warmth beneath the surface.',
      'yang_earth': 'This element is often read as a symbol of steadiness, structure, '
          'and building before moving on.',
      'yin_earth': 'This element is often read as a symbol of care, support, '
          'and creating a safe base.',
      'yang_metal': 'This element is often read as a symbol of clarity, directness, '
          'and decisive action when the path is visible.',
      'yin_metal': 'This element is often read as a symbol of refinement, sorting, '
          'and careful attention to detail.',
      'yang_water': 'This element is often read as a symbol of flexibility, flow, '
          'and timing with context.',
      'yin_water': 'This element is often read as a symbol of deep sensing, reflection, '
          'and inner processing before expression.',
    },
  };

  static const Map<String, Map<String, String>> _dominantIntroCopy = {
    'th': {
      'wood': 'ดวงนี้มีพลังของธาตุไม้ค่อนข้างชัด',
      'fire': 'ดวงนี้มีพลังของธาตุไฟค่อนข้างชัด',
      'earth': 'ดวงนี้มีพลังของธาตุดินค่อนข้างชัด',
      'metal': 'ดวงนี้มีพลังของธาตุทองค่อนข้างชัด',
      'water': 'ดวงนี้มีพลังของธาตุน้ำค่อนข้างชัด',
    },
    'en': {
      'wood': 'This chart shows a fairly clear Wood emphasis.',
      'fire': 'This chart shows a fairly clear Fire emphasis.',
      'earth': 'This chart shows a fairly clear Earth emphasis.',
      'metal': 'This chart shows a fairly clear Metal emphasis.',
      'water': 'This chart shows a fairly clear Water emphasis.',
    },
  };

  static const Map<String, Map<String, List<String>>> _dominantAssociationsCopy = {
    'th': {
      'wood': ['การเติบโต', 'การเริ่มต้น', 'การขยายตัว', 'ความยืดหยุ่นในการพัฒนา'],
      'fire': ['ความกระตือรือร้น', 'การลงมือ', 'พลังขับเคลื่อน', 'การมองเห็นทิศทาง'],
      'earth': ['ความมั่นคง', 'การดูแล', 'ความอดทน', 'การวางรากฐาน'],
      'metal': ['ความชัดเจน', 'มาตรฐาน', 'การตัดสินใจ', 'การจัดระเบียบ'],
      'water': ['การไตร่ตรอง', 'การปรับตัว', 'การรับรู้บริบท', 'ความลื่นไหล'],
    },
    'en': {
      'wood': ['Growth', 'Beginnings', 'Expansion', 'Developmental flexibility'],
      'fire': ['Drive', 'Action', 'Momentum', 'Direction-seeking'],
      'earth': ['Stability', 'Care', 'Endurance', 'Grounding'],
      'metal': ['Clarity', 'Standards', 'Decision-making', 'Order'],
      'water': ['Reflection', 'Adaptation', 'Context sensing', 'Flow'],
    },
  };

  static const Map<String, Map<String, String>> _dmStrengthCopy = {
    'th': {
      'yang_wood': 'มีแรงผลักดันในการเริ่มต้นและพัฒนาสิ่งใหม่',
      'yin_wood': 'อดทนกับกระบวนการที่ใช้เวลาและค่อยเป็นค่อยไป',
      'yang_fire': 'มีพลังเมื่อได้เห็นความคืบหน้าหรือลงมือทำจริง',
      'yin_fire': 'สามารถรักษาแรงบันดาลใจแม้ในช่วงที่ภายนดูสงบ',
      'yang_earth': 'มองเห็นโครงสร้างและรายละเอียดที่จำเป็นได้ชัด',
      'yin_earth': 'สร้างความมั่นคงให้ตัวเองและคนรอบข้างได้',
      'yang_metal': 'ตัดสินใจได้ตรงเมื่อข้อมูลชัดเจน',
      'yin_metal': 'แยกแยะรายละเอียดและจัดลำดับได้ดี',
      'yang_water': 'ปรับตัวกับสถานการณ์ที่เปลี่ยนได้ไว',
      'yin_water': 'รับรู้บรรยากาศและอารมณ์รอบตัวได้ลึก',
    },
    'en': {
      'yang_wood': 'You can push new beginnings and development forward',
      'yin_wood': 'You can stay patient with slow, gradual progress',
      'yang_fire': 'You gain momentum when you see real progress',
      'yin_fire': 'You can sustain inspiration even when you look calm outside',
      'yang_earth': 'You see structure and necessary detail clearly',
      'yin_earth': 'You can create steadiness for yourself and others',
      'yang_metal': 'You decide cleanly when information is clear',
      'yin_metal': 'You sort details and priorities well',
      'yang_water': 'You adapt quickly when conditions shift',
      'yin_water': 'You sense atmosphere and emotion deeply',
    },
  };

  static const Map<String, Map<String, String>> _dominantStrengthCopy = {
    'th': {
      'wood': 'มองเห็นโอกาสในการเติบโตและขยายตัว',
      'fire': 'ไม่ชอบหยุดนิ่งเป็นเวลานานเมื่อมีเป้าหมาย',
      'earth': 'ยึดพื้นที่ที่มั่นคงและทำต่อได้ยาว',
      'metal': 'คัดกรองสิ่งที่สำคัญออกจากสิ่งที่รบกวนได้',
      'water': 'ไหลไปกับบริบทได้โดยไม่ต้องยึดติดกับแผนเดิม',
    },
    'en': {
      'wood': 'You spot room to grow and expand',
      'fire': 'You rarely stay still for long when a goal is alive',
      'earth': 'You hold steady ground and keep going',
      'metal': 'You filter what matters from what distracts',
      'water': 'You move with context without clinging to one plan',
    },
  };

  static const Map<String, Map<String, String>> _highBalanceStrengthCopy = {
    'th': {
      'wood': 'มีพลังในการผลักดันการเติบโตเมื่อจังหวะพร้อม',
      'fire': 'มีแรงขับเคลื่อนเมื่อมีสิ่งที่จุดประกาย',
      'earth': 'ทนต่อแรงกดดันและรักษาระเบียบได้ดี',
      'metal': 'มองเห็นโครงสร้างและขอบเขตได้ชัดเจน',
      'water': 'ปรับตัวและเชื่อมโยงกับคนรอบข้างได้ดี',
    },
    'en': {
      'wood': 'You can push growth when the timing is right',
      'fire': 'You have drive when something lights a spark',
      'earth': 'You handle pressure and keep order well',
      'metal': 'You see structure and boundaries clearly',
      'water': 'You adapt and connect with people around you',
    },
  };

  static const Map<String, Map<String, String>> _yearAnimalStrengthCopy = {
    'th': {
      'horse': 'มักมีพลังเมื่อได้เคลื่อนไหวหรือเห็นทิศทางชัด',
      'rat': 'มักหาทางออกหรือโอกาสได้เร็วในสถานการณ์ใหม่',
      'ox': 'มักทนต่อความยากและทำต่อเนื่องได้ยาว',
      'tiger': 'มักกล้าลงมือเมื่อเห็นสิ่งที่สำคัญ',
      'rabbit': 'มักสังเกตบรรยากาศและความสัมพันธ์ได้ดี',
      'dragon': 'มักมีวิสัยทัศน์เมื่อได้ผลักดันสิ่งใหญ่',
      'snake': 'มักคิดลึกก่อนลงมือและเลือกจังหวะได้ดี',
      'goat': 'มักเอื้อเฟื้อและดูแลความสมดุลรอบตัว',
      'monkey': 'มักหาทางแก้ปัญหาได้คล่องตัว',
      'rooster': 'มักใส่ใจรายละเอียดและมาตรฐาน',
      'dog': 'มักซื่อสัตย์ต่อค่านิยมและคนสำคัญ',
      'pig': 'มักเปิดใจและสร้างความสบายใจให้คนรอบข้าง',
    },
    'en': {
      'horse': 'You often gain energy when you can move with clear direction',
      'rat': 'You often find openings quickly in new situations',
      'ox': 'You often endure difficulty and keep going',
      'tiger': 'You often act boldly when something matters',
      'rabbit': 'You often notice atmosphere and relationships',
      'dragon': 'You often see bigger vision when pushing forward',
      'snake': 'You often think deeply before choosing timing',
      'goat': 'You often nurture balance around you',
      'monkey': 'You often solve problems with agility',
      'rooster': 'You often care about detail and standards',
      'dog': 'You often stay loyal to values and people',
      'pig': 'You often create ease and openness for others',
    },
  };

  static const Map<String, Map<String, String>> _overDominantGrowthCopy = {
    'th': {
      'wood': 'อาจผลักดันการเติบโตเร็วกว่าจังหวะที่ตัวเองหรือคนรอบข้างพร้อม',
      'fire': 'อาจใช้พลังงานมากเกินไปในบางช่วง',
      'earth': 'อาจยึดติดกับความมั่นคงจนลืมปรับตัว',
      'metal': 'อาจเข้มงวดกับตัวเองหรือคนอื่นมากเกินไป',
      'water': 'อาจไหลตามสถานการณ์จนลืมยืนยันขอบเขตของตัวเอง',
    },
    'en': {
      'wood': 'You may push growth faster than you or others are ready for',
      'fire': 'You may spend more energy than needed in some stretches',
      'earth': 'You may cling to stability and forget to adapt',
      'metal': 'You may hold yourself or others to overly strict standards',
      'water': 'You may flow with situations and forget your own boundaries',
    },
  };

  static const Map<String, Map<String, String>> _missingElementGrowthCopy = {
    'th': {
      'wood': 'อาจลืมเว้นพื้นที่ให้การเติบโตใหม่หรือการเริ่มต้นเล็กๆ',
      'fire': 'อาจรอจังหวะนานเกินไปก่อนลงมือ',
      'earth': 'อาจละเลยรากฐานหรือการดูแลตัวเองในระยะยาว',
      'metal': 'อาจปล่อยผ่านรายละเอียดที่สำคัญในบางครั้ง',
      'water': 'อาจลืมฟังความรู้สึกหรือบรรยากาศรอบตัว',
    },
    'en': {
      'wood': 'You may forget to leave room for small new beginnings',
      'fire': 'You may wait too long before taking action',
      'earth': 'You may overlook long-term grounding and self-care',
      'metal': 'You may let important details slip sometimes',
      'water': 'You may forget to listen to feeling and atmosphere',
    },
  };

  static const Map<String, String> _imbalanceGrowthCopy = {
    'th': 'ธาตุในดวงอาจกระจุกหรือขาดไปบางด้าน — การสังเกตจังหวะของตัวเองอาจช่วยให้สมดุลขึ้น',
    'en': 'Your elements may cluster or leave gaps — noticing your own rhythm can help restore balance',
  };

  static const Map<String, String> _intensityGrowthCopy = {
    'th': 'เมื่อพลังงานทางใดทางหนึ่งสูงมาก อาจช่วยตัวเองด้วยการพักหรือถอยห่างสั้นๆ',
    'en': 'When one energy runs very high, a short pause or step back may help',
  };
}
