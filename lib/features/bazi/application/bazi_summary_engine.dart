import 'package:knowme/data/models/bazi_chart_model.dart';

import '../domain/bazi_summary.dart';

/// Deterministic meaning-layer summary (no AI, no network).
abstract final class BaziSummaryEngine {
  static const _elementOrder = ['wood', 'fire', 'earth', 'metal', 'water'];

  static BaziSummary build(BaziChartModel chart, String lang) {
    final counts = _balanceMap(chart.elementBalance);
    final missing = counts.entries.any((e) => e.value == 0);
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final minCount = counts.values.fold<int>(
      counts.values.first,
      (a, b) => a < b ? a : b,
    );
    final spread = maxCount - minCount;
    final top = _topElements(counts, maxCount);
    final balanced = spread == 0;

    return BaziSummary(
      paragraph1: balanced
          ? _balancedParagraph1(chart.dayMaster, lang)
          : _visibleEnergiesParagraph1(top, chart.dayMaster, lang),
      paragraph2: balanced
          ? _balancedParagraph2(lang)
          : _combinationParagraph2(top, lang),
      paragraph3: _balanceContextParagraph3(
        spread: spread,
        topCount: top.length,
        missing: missing,
        balanced: balanced,
        lang: lang,
      ),
    );
  }

  static List<String> _topElements(Map<String, int> counts, int maxCount) {
    if (maxCount <= 0) return const [];
    return _elementOrder
        .where((element) => counts[element] == maxCount)
        .toList();
  }

  static String _balancedParagraph1(BaziDayMaster dayMaster, String lang) {
    final anchor = _dayMasterAnchor(dayMaster, lang);
    if (lang == 'th') {
      return '$anchor '
          'ดวงนี้มีองค์ประกอบของธาตุทั้งห้าปรากฏกระจายตัวใกล้เคียงกัน '
          'ซึ่งในศาสตร์จีนมักถูกมองว่าเป็นโครงสร้างที่ไม่เน้นพลังใดทางหนึ่งเป็นพิเศษ';
    }
    return '$anchor '
        'this chart shows all five components in similar amounts, '
        'which in Chinese tradition is often read as a structure '
        'that does not lean heavily on one energy alone.';
  }

  static String _visibleEnergiesParagraph1(
    List<String> top,
    BaziDayMaster dayMaster,
    String lang,
  ) {
    final anchor = _dayMasterAnchor(dayMaster, lang);
    if (lang == 'th') {
      final labels = _joinThaiElementLabels(top);
      final meanings = _joinThaiInline(
        top.map((e) => _traditionMeaning(e, lang)).toList(),
      );
      return '$anchor '
          'ดวงนี้มีองค์ประกอบของ$labelsปรากฏค่อนข้างเด่น '
          'ซึ่งในศาสตร์จีนมักถูกเชื่อมโยงกับ$meanings';
    }

    final labels = _joinEnglishElementLabels(top);
    final meanings = _joinEnglishInline(
      top.map((e) => _traditionMeaning(e, lang)).toList(),
    );
    if (top.length == 1) {
      return '$anchor '
          'this chart shows a fairly prominent $labels component, '
          'which in Chinese tradition is often linked to $meanings.';
    }
    return '$anchor '
        'this chart shows fairly prominent $labels components, '
        'which in Chinese tradition are often linked to $meanings.';
  }

  static String _dayMasterAnchor(BaziDayMaster dayMaster, String lang) {
    final label = _dayMasterShortLabel(dayMaster, lang);
    if (lang == 'th') {
      return 'เมื่อมองร่วมกับธาตุประจำตัวอย่าง$label';
    }
    return 'Seen alongside a Day Master such as $label';
  }

  static String _dayMasterShortLabel(BaziDayMaster dayMaster, String lang) {
    if (lang == 'th') {
      return '${_elementLabel(dayMaster.element, lang)}'
          '${_polarityLabel(dayMaster.polarity, lang)}';
    }
    return '${_polarityLabel(dayMaster.polarity, lang)} '
        '${_elementLabel(dayMaster.element, lang)}';
  }

  static String _combinationParagraph2(List<String> top, String lang) {
    if (lang == 'th') {
      final traits = _joinThaiInline(
        top.map((e) => _portraitTrait(e, lang)).toList(),
      );
      if (top.length == 1) {
        return 'เมื่อองค์ประกอบนี้ปรากฏเด่น '
            'ดวงลักษณะนี้มักให้ภาพของคนที่$traits';
      }
      return 'เมื่อองค์ประกอบเหล่านี้ปรากฏร่วมกัน '
          'ดวงลักษณะนี้มักให้ภาพของคนที่$traits';
    }

    final traits = _joinEnglishInline(
      top.map((e) => _portraitTrait(e, lang)).toList(),
    );
    if (top.length == 1) {
      return 'When this component appears prominently, '
          'this chart pattern often suggests someone who $traits.';
    }
    return 'When these components appear together, '
        'this chart pattern often suggests someone who $traits.';
  }

  static String _balancedParagraph2(String lang) {
    if (lang == 'th') {
      return 'ดวงลักษณะนี้มักให้ภาพของคนที่สามารถดึงจุดแข็งของแต่ละองค์ประกอบเข้ามาใช้ร่วมกัน '
          'โดยไม่ยึดติดกับพลังใดทางหนึ่งมากเกินไป';
    }
    return 'This chart pattern often suggests someone who can draw on '
        'the strengths of each component together '
        'without leaning too heavily on one energy alone.';
  }

  static String? _balanceContextParagraph3({
    required int spread,
    required int topCount,
    required bool missing,
    required bool balanced,
    required String lang,
  }) {
    if (missing || spread > 1 || topCount < 2) {
      return null;
    }
    if (balanced) {
      if (lang == 'th') {
        return 'ภาพรวมมีความสมดุลค่อนข้างมาก '
            'โดยองค์ประกอบต่างๆ มีบทบาทใกล้เคียงกัน';
      }
      return 'The overall spread looks fairly balanced, '
          'with each component playing a similar role.';
    }
    if (lang == 'th') {
      return 'ภาพรวมยังถือว่าค่อนข้างสมดุล '
          'โดยไม่มีธาตุใดโดดเด่นจนกลบองค์ประกอบอื่นอย่างชัดเจน';
    }
    return 'The overall spread still looks fairly balanced, '
        'without any one element clearly overshadowing the rest.';
  }

  static String _traditionMeaning(String element, String lang) {
    if (lang == 'th') {
      return switch (element) {
        'wood' => 'การเติบโตและการพัฒนา',
        'fire' => 'การแสดงออก',
        'earth' => 'ความมั่นคงและการรองรับ',
        'metal' => 'ความชัดเจนในการตัดสินใจ',
        'water' => 'ความสามารถในการปรับตัวต่อสถานการณ์',
        _ => element,
      };
    }
    return switch (element) {
      'wood' => 'growth and development',
      'fire' => 'outward expression',
      'earth' => 'steadiness and support',
      'metal' => 'clarity in decision-making',
      'water' => 'adaptability to changing situations',
      _ => element,
    };
  }

  static String _portraitTrait(String element, String lang) {
    if (lang == 'th') {
      return switch (element) {
        'wood' => 'เปิดพื้นที่ให้สิ่งใหม่ค่อยๆ เติบโต',
        'fire' => 'กล้าแสดงออกในสิ่งที่คิด',
        'earth' => 'สร้างความมั่นคงให้สิ่งที่กำลังดำเนินอยู่',
        'metal' => 'พยายามมองสถานการณ์ให้ชัดก่อนตัดสินใจ',
        'water' => 'สามารถตอบสนองต่อการเปลี่ยนแปลงรอบตัวได้ค่อนข้างดี',
        _ => element,
      };
    }
    return switch (element) {
      'wood' => 'can make room for new growth to unfold gradually',
      'fire' => 'can express what is on the mind with some courage',
      'earth' => 'can build steadiness into what is already underway',
      'metal' => 'can try to see a situation clearly before deciding',
      'water' => 'can respond to changes around them fairly well',
      _ => element,
    };
  }

  static String _joinThaiElementLabels(List<String> elements) {
    final labels = elements.map((e) => _elementLabel(e, 'th')).toList();
    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]} และ${labels[1]}';
    final head = labels.sublist(0, labels.length - 1);
    return '${head.join(' ')} และ${labels.last}';
  }

  static String _joinEnglishElementLabels(List<String> elements) {
    final labels = elements.map((e) => _elementLabel(e, 'en')).toList();
    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]} and ${labels[1]}';
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  static String _joinThaiInline(List<String> items) {
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items[0]} และ${items[1]}';
    final head = items.sublist(0, items.length - 1);
    return '${head.join(' ')} และ${items.last}';
  }

  static String _joinEnglishInline(List<String> items) {
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items[0]} and ${items[1]}';
    return '${items.sublist(0, items.length - 1).join(', ')}, and ${items.last}';
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

  static String _polarityLabel(String polarity, String lang) {
    if (lang == 'th') {
      return polarity == 'yang' ? 'หยาง' : 'หยิน';
    }
    return polarity == 'yang' ? 'Yang' : 'Yin';
  }
}
