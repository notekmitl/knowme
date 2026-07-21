import 'package:knowme/data/models/bazi_chart_model.dart';

/// Readable explanations for the in-depth evidence accordion (no backend/engine).
abstract final class BaziEvidenceLayer {
  // --- Chinese Big 3 ---

  static String bigThreeIntro(String lang) {
    if (lang == 'th') {
      return 'องค์ประกอบหลักที่มักใช้เป็นจุดเริ่มต้นในการอ่านดวงจีน';
    }
    return 'Core starting points in Chinese chart reading';
  }

  static String dayMasterEvidenceDescription(String lang) {
    if (lang == 'th') {
      return 'เป็นแกนหลักที่ใช้ในการอ่านดวงจีน';
    }
    return 'Main anchor in Chinese chart reading';
  }

  static String yearAnimalEvidenceDescription(String lang) {
    if (lang == 'th') {
      return 'ใช้เป็นสัญลักษณ์ประกอบการตีความ';
    }
    return 'Supporting symbol in interpretation';
  }

  static String dominantElementEvidenceDescription(String lang) {
    if (lang == 'th') {
      return 'ธาตุที่ปรากฏเด่นที่สุดในดวงนี้';
    }
    return 'Most prominent element in this chart';
  }

  static String dayMasterDisplayValue(BaziDayMaster dm, String lang) {
    if (lang == 'th') {
      return '${_polarityLabel(dm.polarity, lang)}${_elementLabel(dm.element, lang)}';
    }
    return '${_polarityLabel(dm.polarity, lang)} ${_elementLabel(dm.element, lang)}';
  }

  static String yearAnimalDisplayValue(BaziYearAnimal animal, String lang) {
    if (lang == 'th') {
      return _yearAnimalThai(animal.en) ?? animal.en;
    }
    return animal.en;
  }

  // --- Four Pillars ---

  static String fourPillarsIntro(String lang) {
    if (lang == 'th') {
      return 'ดวงจีนแบ่งข้อมูลออกเป็น\n'
          '• ปี\n'
          '• เดือน\n'
          '• วัน\n'
          '• เวลาเกิด\n\n'
          'เป็นโครงสร้างพื้นฐานที่ใช้ในการคำนวณดวงจีน';
    }
    return 'A Chinese chart divides birth data into\n'
        '• Year\n'
        '• Month\n'
        '• Day\n'
        '• Birth time\n\n'
        'This is the structural basis for BaZi calculation';
  }

  static String pillarRoleShort(String role, String lang) {
    if (lang == 'th') {
      return switch (role) {
        'year' => 'ปี',
        'month' => 'เดือน',
        'day' => 'วัน',
        'hour' => 'ชั่วโมง',
        _ => role,
      };
    }
    return switch (role) {
      'year' => 'Year',
      'month' => 'Month',
      'day' => 'Day',
      'hour' => 'Hour',
      _ => role,
    };
  }

  static String pillarRoleLabel(String role, String lang) {
    if (lang == 'th') {
      return switch (role) {
        'year' => 'ปี (รากฐานและสภาพแวดล้อม)',
        'month' => 'เดือน (บริบทฤดูกาล)',
        'day' => 'วัน (แก่นตัวตน)',
        'hour' => 'ชั่วโมง (เวลาเกิด)',
        _ => pillarRoleShort(role, lang),
      };
    }
    return switch (role) {
      'year' => 'Year (foundation and environment)',
      'month' => 'Month (seasonal context)',
      'day' => 'Day (core self)',
      'hour' => 'Hour (birth time)',
      _ => pillarRoleShort(role, lang),
    };
  }

  static String pillarCodeLabel(String lang) =>
      lang == 'th' ? 'รหัสเสา' : 'Pillar code';

  static String heavenlyStemLabel(String lang) =>
      lang == 'th' ? 'ลำต้นฟ้า' : 'Heavenly Stem';

  static String earthlyBranchLabel(String lang) =>
      lang == 'th' ? 'กิ่งดิน' : 'Earthly Branch';

  static String formatHeavenlyStem(BaziPillar pillar, String lang) {
    final meta = _stemMeta[pillar.stem];
    if (meta == null) {
      return pillar.stem;
    }
    final elementPolarity = _elementPolarityLabel(meta.$1, meta.$2, lang);
    return '${pillar.stem} ($elementPolarity)';
  }

  static String formatEarthlyBranch(BaziPillar pillar, String lang) {
    final animal = _branchAnimalLabel(pillar.branch, lang);
    if (animal == null) {
      return pillar.branch;
    }
    return '${pillar.branch} ($animal)';
  }

  static String formatPillarCode(BaziPillar pillar, String lang) =>
      '${pillarCodeLabel(lang)}: ${pillar.pillarLabel}';

  static String formatHeavenlyStemLine(BaziPillar pillar, String lang) =>
      '${heavenlyStemLabel(lang)}: ${formatHeavenlyStem(pillar, lang)}';

  static String formatEarthlyBranchLine(BaziPillar pillar, String lang) =>
      '${earthlyBranchLabel(lang)}: ${formatEarthlyBranch(pillar, lang)}';

  // --- Four Pillars element legend (display only) ---

  static const _elementOrder = ['wood', 'fire', 'earth', 'metal', 'water'];

  static String elementLegendTitle(String lang) =>
      lang == 'th' ? 'ความหมายของธาตุ' : 'What the elements mean';

  static List<String> elementLegendLines(String lang) => [
        for (final element in _elementOrder)
          '${elementIcon(element)} ${_elementLabel(element, lang)} — '
          '${_elementLegendMeaning(element, lang)}',
      ];

  static String elementIcon(String element) => switch (element) {
        'wood' => '🌱',
        'fire' => '🔥',
        'earth' => '🏔',
        'metal' => '⚔️',
        'water' => '🌊',
        _ => '',
      };

  static String elementWithIcon(String element, String lang) =>
      '${elementIcon(element)} ${_elementLabel(element, lang)}';

  static String formatPillarElements(
    String stemElement,
    String branchElement,
    String lang,
  ) =>
      '${elementWithIcon(stemElement, lang)} / '
      '${elementWithIcon(branchElement, lang)}';

  static String _elementLegendMeaning(String element, String lang) {
    if (lang == 'th') {
      return switch (element) {
        'wood' => 'การเติบโต การพัฒนา',
        'fire' => 'พลังงาน การแสดงออก',
        'earth' => 'ความมั่นคง การรองรับ',
        'metal' => 'ความชัดเจน ระเบียบ',
        'water' => 'ความยืดหยุ่น การปรับตัว',
        _ => element,
      };
    }
    return switch (element) {
      'wood' => 'growth, development',
      'fire' => 'energy, expression',
      'earth' => 'stability, support',
      'metal' => 'clarity, structure',
      'water' => 'flexibility, adaptation',
      _ => element,
    };
  }

  static String? elementBalanceSummaryNote(BaziChartModel chart, String lang) {
    final counts = _balanceMap(chart.elementBalance);
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final minCount = counts.values.fold<int>(
      counts.values.first,
      (a, b) => a < b ? a : b,
    );
    final missing = counts.entries.any((e) => e.value == 0);
    if (missing || maxCount == 0 || maxCount - minCount > 1) {
      return null;
    }
    if (lang == 'th') {
      return 'ค่าใกล้เคียงกันมักสะท้อนการกระจายตัวที่ค่อนข้างสมดุล';
    }
    return 'Similar counts often reflect a fairly even spread';
  }

  // --- Element Balance ---

  static String elementBalanceOverviewLabel(String lang) =>
      lang == 'th' ? 'ภาพรวมธาตุ' : 'Element overview';

  static String elementBalanceHowToRead(String lang) {
    if (lang == 'th') {
      return 'กราฟนี้แสดงการกระจายตัวของธาตุทั้ง 5 ภายในโครงสร้างดวงจีน\n\n'
          'ค่าที่สูงกว่าไม่ได้หมายถึงดีกว่า\n'
          'แต่สะท้อนว่าธาตุนั้นปรากฏในดวงบ่อยกว่า';
    }
    return 'This chart shows how all five elements are distributed '
        'across the BaZi structure.\n\n'
        'Higher values do not mean better.\n'
        'They reflect how often that element appears in the chart.';
  }

  static String elementBalanceObservationsTitle(String lang) =>
      lang == 'th' ? 'สิ่งที่สังเกตได้' : 'What stands out';

  static List<String> elementBalanceObservations(
    BaziChartModel chart,
    String lang,
  ) {
    final counts = _balanceMap(chart.elementBalance);
    final missing = counts.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList()
      ..sort();
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final minCount = counts.values.fold<int>(
      counts.values.first,
      (a, b) => a < b ? a : b,
    );
    final spread = maxCount - minCount;
    final top = counts.entries
        .where((e) => e.value == maxCount && maxCount > 0)
        .map((e) => e.key)
        .toList()
      ..sort();
    final bottom = counts.entries
        .where((e) => e.value == minCount && e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    if (missing.isNotEmpty) {
      return _observationsMissingCase(missing, top, lang);
    }
    if (spread == 0) {
      return _observationsBalancedCase(lang);
    }
    return _observationsDominantCase(top, bottom, spread, lang);
  }

  static List<String> _observationsMissingCase(
    List<String> missing,
    List<String> top,
    String lang,
  ) {
    return [
      _missingElementObservation(missing, lang),
      _prominentComparedObservation(top, lang),
      _noticeableDifferenceObservation(lang),
    ];
  }

  static List<String> _observationsBalancedCase(String lang) {
    if (lang == 'th') {
      return [
        'ธาตุทั้งห้ากระจายตัวใกล้เคียงกัน',
        'ยังไม่เห็นธาตุใดโดดเด่นเป็นพิเศษ',
        'ภาพรวมมีความสมดุลค่อนข้างมาก',
      ];
    }
    return [
      'All five elements appear in similar amounts',
      'No single element stands out in particular',
      'The overall spread looks fairly balanced',
    ];
  }

  static List<String> _observationsDominantCase(
    List<String> top,
    List<String> bottom,
    int spread,
    String lang,
  ) {
    final observations = <String>[
      _prominentObservation(top, lang),
    ];
    if (bottom.isNotEmpty && spread > 0) {
      observations.add(_lowerObservation(bottom, lang));
    }
    observations.add(
      spread <= 1
          ? _broadlyBalancedObservation(lang)
          : _noticeableDifferenceObservation(lang),
    );
    return observations;
  }

  static String _missingElementObservation(List<String> elements, String lang) {
    if (lang == 'th') {
      if (elements.length == 1) {
        return 'ไม่พบธาตุ${_elementLabel(elements.first, lang)}ในโครงสร้างหลัก';
      }
      final labels = elements.map((e) => _elementLabel(e, lang)).toList();
      return 'ไม่พบ${_joinThaiDominant(labels)}ในโครงสร้างหลัก';
    }
    if (elements.length == 1) {
      return 'No ${_elementLabel(elements.first, lang)} in the main structure';
    }
    final labels = elements.map((e) => _elementLabel(e, lang)).toList();
    return 'No ${labels.join(' or ')} in the main structure';
  }

  static String _prominentObservation(List<String> top, String lang) {
    final labels = top.map((e) => _elementLabel(e, lang)).toList();
    if (lang == 'th') {
      return '${_joinThaiElementNames(labels)} ปรากฏค่อนข้างเด่น';
    }
    if (labels.length == 1) {
      return '${labels.first} appears fairly prominent';
    }
    return '${_joinEnglishList(labels)} appear fairly prominent';
  }

  static String _prominentComparedObservation(List<String> top, String lang) {
    final labels = top.map((e) => _elementLabel(e, lang)).toList();
    if (lang == 'th') {
      if (labels.length == 1) {
        return '${labels.first}ปรากฏค่อนข้างเด่นเมื่อเทียบกับธาตุอื่น';
      }
      return '${_joinThaiElementNames(labels)}ปรากฏค่อนข้างเด่นเมื่อเทียบกับธาตุอื่น';
    }
    if (labels.length == 1) {
      return '${labels.first} appears fairly prominent compared with other elements';
    }
    return '${_joinEnglishList(labels)} appear fairly prominent compared with other elements';
  }

  static String _lowerObservation(List<String> bottom, String lang) {
    final labels = bottom.map((e) => _elementLabel(e, lang)).toList();
    if (lang == 'th') {
      return '${_joinThaiElementNames(labels)}ปรากฏน้อยกว่าองค์ประกอบอื่น';
    }
    if (labels.length == 1) {
      return '${labels.first} appears less often than other elements';
    }
    return '${_joinEnglishList(labels)} appear less often than other elements';
  }

  static String _broadlyBalancedObservation(String lang) {
    if (lang == 'th') {
      return 'ภาพรวมยังถือว่าค่อนข้างสมดุล';
    }
    return 'The overall spread still looks fairly balanced';
  }

  static String _noticeableDifferenceObservation(String lang) {
    if (lang == 'th') {
      return 'การกระจายตัวของธาตุยังมีความแตกต่างกันพอสมควร';
    }
    return 'Element distribution still shows noticeable differences';
  }

  static String _joinThaiElementNames(List<String> labels) {
    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]}และ${labels[1]}';
    final head = labels.sublist(0, labels.length - 1);
    return '${head.join(' ')} และ${labels.last}';
  }

  static String _joinEnglishList(List<String> labels) {
    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]} and ${labels[1]}';
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  static String elementBalanceSummary(BaziChartModel chart, String lang) {
    final counts = _balanceMap(chart.elementBalance);
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final minCount = counts.values.fold<int>(
      counts.values.first,
      (a, b) => a < b ? a : b,
    );
    final missing = counts.entries.where((e) => e.value == 0).toList();
    final top = counts.entries
        .where((e) => e.value == maxCount && maxCount > 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    if (missing.isNotEmpty) {
      return _missingElementSummary(missing.map((e) => e.key).toList(), lang);
    }

    if (maxCount > 0 && maxCount - minCount <= 1) {
      return _balancedSummary(lang);
    }

    return _dominantSummary(top, lang);
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

  static String _dominantSummary(List<String> elements, String lang) {
    final labels = elements.map((e) => _elementLabel(e, lang)).toList();

    if (lang == 'th') {
      if (labels.length == 1) {
        return 'ธาตุ${labels.first}ค่อนข้างเด่น';
      }
      return '${_joinThaiDominant(labels)}ค่อนข้างเด่น';
    }

    if (labels.length == 1) {
      return '${labels.first} is fairly prominent';
    }
    return '${labels.join(' and ')} are fairly prominent';
  }

  static String _missingElementSummary(List<String> elements, String lang) {
    if (lang == 'th') {
      if (elements.length == 1) {
        final label = _elementLabel(elements.first, lang);
        return 'ไม่พบธาตุ$labelในโครงสร้างหลัก';
      }
      final labels = elements.map((e) => _elementLabel(e, lang)).toList();
      return 'ไม่พบ${_joinThaiDominant(labels)}ในโครงสร้างหลัก';
    }

    if (elements.length == 1) {
      final label = _elementLabel(elements.first, lang);
      return 'No $label in the main structure';
    }
    final labels = elements.map((e) => _elementLabel(e, lang)).toList();
    return 'No ${labels.join(' or ')} in the main structure';
  }

  static String _balancedSummary(String lang) {
    if (lang == 'th') {
      return 'ธาตุทั้งห้ากระจายตัวค่อนข้างสมดุล';
    }
    return 'The five elements are fairly balanced';
  }

  static String _joinThaiDominant(List<String> labels) {
    if (labels.length == 1) return 'ธาตุ${labels.first}';
    if (labels.length == 2) {
      return 'ธาตุ${labels[0]}และ${labels[1]}';
    }
    final head = labels.sublist(0, labels.length - 1);
    return 'ธาตุ${head.join(' ')} และ${labels.last}';
  }

  static String? _yearAnimalThai(String en) {
    return switch (en.toLowerCase()) {
      'rat' => 'หนู',
      'ox' => 'วัว',
      'tiger' => 'เสือ',
      'rabbit' => 'กระต่าย',
      'dragon' => 'มังกร',
      'snake' => 'งู',
      'horse' => 'ม้า',
      'goat' => 'แพะ',
      'monkey' => 'ลิง',
      'rooster' => 'ไก่',
      'dog' => 'สุนัข',
      'pig' => 'หมู',
      _ => null,
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

  static String _elementPolarityLabel(
    String element,
    String polarity,
    String lang,
  ) {
    if (lang == 'th') {
      return '${_elementLabel(element, lang)}${_polarityLabel(polarity, lang)}';
    }
    return '${_polarityLabel(polarity, lang)} ${_elementLabel(element, lang)}';
  }

  static const _stemMeta = <String, (String element, String polarity)>{
    '甲': ('wood', 'yang'),
    '乙': ('wood', 'yin'),
    '丙': ('fire', 'yang'),
    '丁': ('fire', 'yin'),
    '戊': ('earth', 'yang'),
    '己': ('earth', 'yin'),
    '庚': ('metal', 'yang'),
    '辛': ('metal', 'yin'),
    '壬': ('water', 'yang'),
    '癸': ('water', 'yin'),
  };

  static const _branchAnimalEn = <String, String>{
    '子': 'Rat',
    '丑': 'Ox',
    '寅': 'Tiger',
    '卯': 'Rabbit',
    '辰': 'Dragon',
    '巳': 'Snake',
    '午': 'Horse',
    '未': 'Goat',
    '申': 'Monkey',
    '酉': 'Rooster',
    '戌': 'Dog',
    '亥': 'Pig',
  };

  static String? _branchAnimalLabel(String branch, String lang) {
    final en = _branchAnimalEn[branch];
    if (en == null) {
      return null;
    }
    if (lang == 'th') {
      return _yearAnimalThai(en) ?? en;
    }
    return en;
  }
}
