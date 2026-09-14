import 'package:knowme/data/models/bazi_chart_model.dart';

class BaziDayMasterReading {
  const BaziDayMasterReading({
    required this.stem,
    required this.name,
    required this.symbol,
    required this.overview,
    required this.strengths,
    required this.cautions,
    required this.practices,
  });

  final String stem;
  final String name;
  final String symbol;
  final String overview;
  final List<String> strengths;
  final List<String> cautions;
  final List<String> practices;
}

class BaziRelationshipFamilyReading {
  const BaziRelationshipFamilyReading({
    required this.id,
    required this.label,
    required this.traditionalLabel,
    required this.element,
    required this.count,
    required this.meaning,
  });

  final String id;
  final String label;
  final String traditionalLabel;
  final String element;
  final int count;
  final String meaning;
}

class BaziNatalAreaReading {
  const BaziNatalAreaReading({
    required this.id,
    required this.title,
    required this.reading,
    required this.evidence,
  });

  final String id;
  final String title;
  final String reading;
  final String evidence;
}

class BaziSymbolicReading {
  const BaziSymbolicReading({
    required this.dayMaster,
    required this.relationships,
    required this.natalAreas,
    required this.overview,
    required this.coverageNote,
    required this.hasChartEmphasis,
  });

  final BaziDayMasterReading dayMaster;
  final List<BaziRelationshipFamilyReading> relationships;
  final List<BaziNatalAreaReading> natalAreas;
  final String overview;
  final String coverageNote;
  final bool hasChartEmphasis;
}

/// Conservative, deterministic interpretation over the governed V1 facts.
///
/// This layer deliberately does not infer Day Master strength, Useful God,
/// luck cycles, events, health, wealth outcomes, or relationship outcomes.
abstract final class BaziSymbolicReadingEngine {
  static const interpretationContractId = 'knowme_bazi_symbolic_reading_v1';

  static const supportedStems = <String>{
    '甲',
    '乙',
    '丙',
    '丁',
    '戊',
    '己',
    '庚',
    '辛',
    '壬',
    '癸',
  };

  static BaziSymbolicReading build(
    BaziChartModel chart, {
    String languageCode = 'th',
  }) {
    final th = languageCode != 'en';
    final profile = profileFor(
      chart.dayMaster.stem,
      languageCode: languageCode,
    );
    final hasCompleteNatalContext =
        chart.completeness == 'four_pillars' ||
        chart.completeness == 'three_pillars';
    final relationships = hasCompleteNatalContext
        ? _relationships(chart, th)
        : const <BaziRelationshipFamilyReading>[];

    return BaziSymbolicReading(
      dayMaster: profile,
      relationships: relationships,
      natalAreas: hasCompleteNatalContext
          ? _natalAreas(profile, relationships, th)
          : const <BaziNatalAreaReading>[],
      overview: _overview(
        chart,
        profile,
        relationships,
        hasCompleteNatalContext,
        th,
      ),
      coverageNote: _coverageNote(chart, th),
      hasChartEmphasis: hasCompleteNatalContext,
    );
  }

  static BaziDayMasterReading profileFor(
    String stem, {
    String languageCode = 'th',
  }) {
    final source = _profiles[stem];
    if (source == null) {
      throw ArgumentError.value(stem, 'stem', 'Unsupported Day Master stem');
    }
    return source.resolve(languageCode != 'en');
  }

  static List<BaziRelationshipFamilyReading> _relationships(
    BaziChartModel chart,
    bool th,
  ) {
    final dayElement = chart.dayMaster.element;
    final counts = <String, int>{
      'wood': chart.elementBalance.wood,
      'fire': chart.elementBalance.fire,
      'earth': chart.elementBalance.earth,
      'metal': chart.elementBalance.metal,
      'water': chart.elementBalance.water,
    };
    final resource = _resourceElement[dayElement] ?? '';
    final output = _outputElement[dayElement] ?? '';
    final wealth = _wealthElement[dayElement] ?? '';
    final authority = _authorityElement[dayElement] ?? '';

    BaziRelationshipFamilyReading item({
      required String id,
      required String labelTh,
      required String labelEn,
      required String traditional,
      required String element,
      required String meaningTh,
      required String meaningEn,
    }) {
      return BaziRelationshipFamilyReading(
        id: id,
        label: th ? labelTh : labelEn,
        traditionalLabel: traditional,
        element: element,
        count: counts[element] ?? 0,
        meaning: th ? meaningTh : meaningEn,
      );
    }

    return [
      item(
        id: 'resource',
        labelTh: 'พลังสนับสนุน',
        labelEn: 'Support and learning',
        traditional: '印 · Resource',
        element: resource,
        meaningTh: 'กรอบของการเรียนรู้ ข้อมูล การเติมพลัง และการรับแรงหนุน',
        meaningEn:
            'Learning, information, replenishment, and receiving support',
      ),
      item(
        id: 'peer',
        labelTh: 'พลังร่วมธาตุ',
        labelEn: 'Peers and agency',
        traditional: '比劫 · Companion',
        element: dayElement,
        meaningTh:
            'กรอบของตัวตน แรงขับของตัวเอง เพื่อนร่วมทาง และการแบ่งพื้นที่กับผู้อื่น',
        meaningEn: 'Self-direction, personal drive, peers, and shared space',
      ),
      item(
        id: 'output',
        labelTh: 'พลังการแสดงออก',
        labelEn: 'Expression and output',
        traditional: '食傷 · Output',
        element: output,
        meaningTh:
            'กรอบของความคิด การสื่อสาร การสร้างผลงาน และสิ่งที่ส่งออกไปสู่โลกภายนอก',
        meaningEn:
            'Ideas, communication, making, and what is expressed outwardly',
      ),
      item(
        id: 'wealth',
        labelTh: 'พลังการจัดการทรัพยากร',
        labelEn: 'Resources and execution',
        traditional: '財 · Wealth',
        element: wealth,
        meaningTh:
            'กรอบของการจัดการทรัพยากร งานที่ต้องทำให้เกิดผล และสิ่งที่ต้องรับผิดชอบดูแล',
        meaningEn: 'Managing resources, execution, and what must be maintained',
      ),
      item(
        id: 'authority',
        labelTh: 'พลังกรอบและความรับผิดชอบ',
        labelEn: 'Structure and responsibility',
        traditional: '官殺 · Authority',
        element: authority,
        meaningTh: 'กรอบของกฎ ขอบเขต แรงกดดัน มาตรฐาน และความรับผิดชอบ',
        meaningEn: 'Rules, boundaries, pressure, standards, and responsibility',
      ),
    ];
  }

  static String _overview(
    BaziChartModel chart,
    BaziDayMasterReading profile,
    List<BaziRelationshipFamilyReading> relationships,
    bool enoughContext,
    bool th,
  ) {
    if (!enoughContext) {
      return th
          ? 'แกนวันเกิดของดวงนี้คือ ${profile.name} ซึ่งใช้ภาพเปรียบเทียบว่า “${profile.symbol}” '
                'วันนี้มีเสาที่ยืนยันได้ไม่พอสำหรับสรุปภาพรวมของดวง ระบบจึงแสดงเฉพาะคำอ่านแกนตัวตนและไม่เติมผลที่กำกวม'
          : 'The Day Master is ${profile.name}, symbolised as "${profile.symbol}". '
                'Too few pillars are confirmed to summarise the whole chart, so only the Day Master reading is shown without filling the gaps.';
    }

    final maxCount = relationships
        .map((item) => item.count)
        .fold<int>(0, (left, right) => left > right ? left : right);
    final top = relationships.where((item) => item.count == maxCount).toList();
    final names = th
        ? _joinThai(top.map((item) => item.label).toList())
        : _joinEnglish(top.map((item) => item.label).toList());
    final total = chart.elementBalance.totalSlots;

    return th
        ? 'แกนวันเกิดของดวงนี้คือ ${profile.name} ใช้ภาพเปรียบเทียบว่า “${profile.symbol}” '
              'ในตำแหน่งธาตุที่มองเห็น $total ช่อง กลุ่ม $names ปรากฏมากที่สุด ($maxCount ช่อง) '
              'นี่คือจุดสังเกตเชิงโครงสร้าง ไม่ใช่คะแนนดีร้ายหรือคำรับรองว่าเหตุการณ์จะเกิดขึ้น'
        : 'The Day Master is ${profile.name}, symbolised as "${profile.symbol}". '
              'Across $total visible element slots, $names appears most often ($maxCount slots). '
              'This is a structural observation, not a score or a guarantee of events.';
  }

  static String _coverageNote(BaziChartModel chart, bool th) {
    if (chart.timeKnown) {
      return th
          ? 'คำอ่านนี้ใช้สี่เสาครบ รวมเสาชั่วโมงจากเวลาเกิดที่ระบุ'
          : 'This reading uses all four pillars, including the Hour pillar from the supplied birth time.';
    }
    if (chart.completeness == 'three_pillars') {
      return th
          ? 'คำอ่านนี้ใช้เฉพาะเสาปี เดือน และวัน จึงไม่รวมบทบาทจากเสาชั่วโมง'
          : 'This reading uses only the Year, Month, and Day pillars; Hour-pillar roles are excluded.';
    }
    return th
        ? 'เสาบางส่วนกำกวมเพราะไม่ทราบเวลาเกิด ระบบจึงไม่สรุปธาตุเด่นหรือภาพรวมจากข้อมูลที่ไม่ครบ'
        : 'Some pillars are ambiguous without a birth time, so no chart-wide emphasis is inferred from incomplete data.';
  }

  static List<BaziNatalAreaReading> _natalAreas(
    BaziDayMasterReading profile,
    List<BaziRelationshipFamilyReading> relationships,
    bool th,
  ) {
    final maxCount = relationships
        .map((item) => item.count)
        .fold<int>(0, (left, right) => left > right ? left : right);
    final top = relationships
        .where((item) => item.count == maxCount)
        .toList(growable: false);
    final wealth = relationships.firstWhere((item) => item.id == 'wealth');
    final familyNames = th
        ? _joinThai(top.map((item) => item.label).toList())
        : _joinEnglish(top.map((item) => item.label).toList());
    final basis = th
        ? 'หลักที่ใช้: Day Master ${profile.name}; $familyNames '
              '$maxCount ช่อง (มากที่สุดร่วมในชั้นธาตุที่มองเห็น)'
        : 'Basis: Day Master ${profile.name}; $familyNames at $maxCount visible slots (joint-highest where tied)';

    String topCopy(Map<String, String> catalog) {
      final parts = [for (final family in top) catalog[family.id]!];
      return th ? _joinThai(parts) : _joinEnglish(parts);
    }

    final strength = th
        ? '${profile.strengths.first} เมื่อเชื่อมกับโครงสร้างดวงที่มองเห็น '
              'พลังที่หยิบใช้ได้มากคือ ${topCopy(_strengthCopyTh)}'
        : '${profile.strengths.first}. In the visible chart structure, the most available working modes are ${topCopy(_strengthCopyEn)}.';
    final work = th
        ? 'รูปแบบงานที่สอดคล้องกับกลุ่มที่เห็นมากคือ ${topCopy(_workCopyTh)} '
              'ใช้เป็นคำถามเลือกบทบาทและสภาพแวดล้อมการทำงาน ไม่ใช่คำสั่งว่าอาชีพใดถูกกำหนดไว้แล้ว'
        : 'Work patterns aligned with the most visible families are ${topCopy(_workCopyEn)}. Use this to evaluate roles and work environments, not as a fixed career assignment.';
    final finance = _financeReading(wealth: wealth, top: top, th: th);
    final relationshipsReading = th
        ? 'เวลาอยู่กับคนอื่น ประเด็นที่ควรสังเกตเป็นพิเศษคือ ${topCopy(_relationshipCopyTh)} '
              'นี่อธิบายรูปแบบปฏิสัมพันธ์ที่ใช้ทบทวนตนเอง ไม่ได้ทำนายคู่ครองหรือผลของความสัมพันธ์'
        : 'With other people, the main themes to observe are ${topCopy(_relationshipCopyEn)}. This is a reflection on interaction style, not a prediction of partners or relationship outcomes.';
    final caution = th
        ? '${profile.cautions.first} และเมื่อใช้กลุ่มที่เห็นมากเกินสมดุล '
              'ควรเฝ้าดู ${topCopy(_cautionCopyTh)} แนวทางทดลองคือ ${profile.practices.first}'
        : '${profile.cautions.first}. When the most visible modes are overused, watch for ${topCopy(_cautionCopyEn)}. A practical experiment is: ${profile.practices.first}.';

    return [
      BaziNatalAreaReading(
        id: 'strengths',
        title: th ? 'จุดแข็งที่หยิบใช้ได้' : 'Usable strengths',
        reading: strength,
        evidence: basis,
      ),
      BaziNatalAreaReading(
        id: 'work',
        title: th ? 'การงานและบทบาท' : 'Work and roles',
        reading: work,
        evidence: basis,
      ),
      BaziNatalAreaReading(
        id: 'finance',
        title: th ? 'การเงินและทรัพยากร' : 'Money and resources',
        reading: finance,
        evidence: th
            ? '$basis; พลังการจัดการทรัพยากร ${wealth.count} ช่อง'
            : '$basis; Resources and execution ${wealth.count} visible slots',
      ),
      BaziNatalAreaReading(
        id: 'relationships',
        title: th
            ? 'ความสัมพันธ์และการอยู่ร่วมกัน'
            : 'Relationships and shared space',
        reading: relationshipsReading,
        evidence: basis,
      ),
      BaziNatalAreaReading(
        id: 'cautions',
        title: th
            ? 'สิ่งที่ควรระวังและแนวทางพัฒนา'
            : 'Watch-outs and development',
        reading: caution,
        evidence: basis,
      ),
    ];
  }

  static String _financeReading({
    required BaziRelationshipFamilyReading wealth,
    required List<BaziRelationshipFamilyReading> top,
    required bool th,
  }) {
    final wealthIsTop = top.any((item) => item.id == 'wealth');
    final practices = top
        .map((item) => (th ? _financePracticeTh : _financePracticeEn)[item.id]!)
        .toList();
    final practice = th ? _joinThai(practices) : _joinEnglish(practices);

    if (wealth.count == 0) {
      return th
          ? 'ชั้นธาตุที่ V1 มองเห็นยังไม่พบพลังการจัดการทรัพยากร จึงไม่สรุปว่าเรื่องเงินดีหรือร้าย '
                'วิธีใช้กลุ่มที่เห็นมากมาช่วยวางระบบคือ $practice'
          : 'The V1 surface layer shows no Resources-and-execution slots, so it does not label money as good or bad. Use the most visible modes to build a system by $practice.';
    }
    if (wealthIsTop) {
      return th
          ? 'พลังการจัดการทรัพยากรอยู่ในกลุ่มที่มองเห็นมากที่สุด จึงชวนอ่านเรื่องเงินผ่านการจัดสรรเวลา งบ และภาระให้เกิดผลที่ตรวจได้ '
                'วิธีใช้เชิงสร้างสรรค์คือ $practice'
          : 'Resources and execution is among the most visible families. Read money through how time, budget, and obligations are turned into trackable results. A constructive practice is $practice.';
    }
    return th
        ? 'พลังการจัดการทรัพยากรปรากฏ ${wealth.count} ช่อง แต่ไม่ใช่กลุ่มที่เห็นมากที่สุด '
              'จึงควรใช้เป็นจุดตรวจเรื่องงบและภาระควบคู่กับวิธีหลักของคุณคือ $practice'
        : 'Resources and execution appears in ${wealth.count} visible slots but is not the most visible family. Treat budget and obligations as a checkpoint alongside your primary mode: $practice.';
  }

  static String _joinThai(List<String> values) {
    if (values.length == 1) return values.first;
    if (values.length == 2) return '${values.first}และ${values.last}';
    return '${values.sublist(0, values.length - 1).join(' ')} และ${values.last}';
  }

  static String _joinEnglish(List<String> values) {
    if (values.length == 1) return values.first;
    if (values.length == 2) return '${values.first} and ${values.last}';
    return '${values.sublist(0, values.length - 1).join(', ')}, and ${values.last}';
  }

  static const _resourceElement = <String, String>{
    'wood': 'water',
    'fire': 'wood',
    'earth': 'fire',
    'metal': 'earth',
    'water': 'metal',
  };
  static const _outputElement = <String, String>{
    'wood': 'fire',
    'fire': 'earth',
    'earth': 'metal',
    'metal': 'water',
    'water': 'wood',
  };
  static const _wealthElement = <String, String>{
    'wood': 'earth',
    'fire': 'metal',
    'earth': 'water',
    'metal': 'wood',
    'water': 'fire',
  };
  static const _authorityElement = <String, String>{
    'wood': 'metal',
    'fire': 'water',
    'earth': 'wood',
    'metal': 'fire',
    'water': 'earth',
  };

  static const _strengthCopyTh = <String, String>{
    'resource': 'เรียนรู้ จัดข้อมูล และรับแรงสนับสนุน',
    'peer': 'ริเริ่ม ยืนจุดยืน และร่วมมือแบบมีพื้นที่ของตนเอง',
    'output': 'สื่อสารความคิดและสร้างผลงานให้คนอื่นเห็น',
    'wealth': 'จัดสรรทรัพยากรและทำงานให้เกิดผลเป็นรูปธรรม',
    'authority': 'วางมาตรฐาน ขอบเขต และรับผิดชอบสิ่งที่ชัดเจน',
  };
  static const _strengthCopyEn = <String, String>{
    'resource': 'learning, organising information, and receiving support',
    'peer': 'initiating, holding a position, and collaborating with autonomy',
    'output': 'communicating ideas and making visible work',
    'wealth': 'allocating resources and turning work into concrete results',
    'authority': 'setting standards, boundaries, and clear responsibility',
  };
  static const _workCopyTh = <String, String>{
    'resource':
        'งานที่ให้เวลาเรียนรู้ เตรียมข้อมูล หรือสนับสนุนให้คนและระบบพร้อม',
    'peer': 'งานที่ได้ตัดสินใจเอง เจรจาพื้นที่ และทำกับเพื่อนร่วมวิชาชีพ',
    'output': 'งานที่ต้องคิด สื่อสาร ออกแบบ หรือส่งผลงานออกสู่คนอื่น',
    'wealth': 'งานที่ต้องบริหารเวลา งบ ของที่มี และทำสิ่งที่รับผิดชอบให้เสร็จ',
    'authority': 'งานที่มีกรอบ มาตรฐาน ขอบเขต และความรับผิดชอบที่ชัด',
  };
  static const _workCopyEn = <String, String>{
    'resource':
        'work with room to learn, prepare information, or support readiness',
    'peer': 'work with autonomy, negotiated space, and professional peers',
    'output':
        'work that develops, communicates, designs, or publishes an output',
    'wealth': 'work that manages time, budget, assets, and completion',
    'authority':
        'work with clear rules, standards, boundaries, and accountability',
  };
  static const _financePracticeTh = <String, String>{
    'resource': 'รวบรวมข้อมูลก่อนตัดสินใจและกันงบสำหรับการเติมความพร้อม',
    'peer': 'แยกเงินส่วนตัว เงินร่วม และอำนาจตัดสินใจให้ชัด',
    'output': 'ผูกไอเดียหรือผลงานกับงบ เวลา และผลลัพธ์ที่วัดได้',
    'wealth': 'ทำงบ แบ่งภาระ และติดตามสิ่งที่ต้องดูแลเป็นรอบ',
    'authority': 'ตั้งเพดาน กติกา และจุดตรวจความเสี่ยงล่วงหน้า',
  };
  static const _financePracticeEn = <String, String>{
    'resource':
        'gathering information before decisions and budgeting for readiness',
    'peer': 'separating personal money, shared money, and decision rights',
    'output':
        'linking ideas and output to budget, time, and measurable results',
    'wealth':
        'budgeting, assigning obligations, and reviewing what must be maintained',
    'authority': 'setting limits, rules, and risk checkpoints in advance',
  };
  static const _relationshipCopyTh = <String, String>{
    'resource': 'การรับฟัง การให้แรงสนับสนุน และการมีพื้นที่เติมพลัง',
    'peer': 'ความเท่าเทียม พื้นที่ส่วนตัว และการแบ่งบทบาทกับอีกฝ่าย',
    'output': 'การพูดสิ่งที่คิดให้ชัดพร้อมเปิดพื้นที่ฟังการตอบกลับ',
    'wealth': 'ความสม่ำเสมอ การลงมือดูแล และการแบ่งภาระที่จับต้องได้',
    'authority': 'ขอบเขต ความคาดหวัง และความรับผิดชอบที่ตกลงร่วมกัน',
  };
  static const _relationshipCopyEn = <String, String>{
    'resource': 'listening, mutual support, and room to replenish',
    'peer': 'equality, personal space, and negotiated roles',
    'output': 'clear expression with room to hear the response',
    'wealth': 'consistency, practical care, and tangible shared obligations',
    'authority': 'boundaries, expectations, and mutually agreed responsibility',
  };
  static const _cautionCopyTh = <String, String>{
    'resource': 'การเก็บข้อมูลหรือรอความพร้อมนานจนยังไม่เริ่ม',
    'peer': 'การยืนพื้นที่ของตนจนกลายเป็นแข่งขันหรือแบ่งบทบาทไม่ลงตัว',
    'output': 'การพูดหรือสร้างต่อเนื่องจนเวลาฟังและเวลาพักหายไป',
    'wealth': 'การรับภาระจัดการมากเกินไปหรือผูกคุณค่าตนกับผลลัพธ์',
    'authority': 'การใช้มาตรฐานเข้มจนกลายเป็นแรงกดดันต่อตนเองและผู้อื่น',
  };
  static const _cautionCopyEn = <String, String>{
    'resource':
        'collecting information or waiting for readiness until action stalls',
    'peer':
        'protecting autonomy until collaboration turns competitive or unclear',
    'output': 'expressing and producing until listening and recovery disappear',
    'wealth': 'carrying too much management or tying self-worth to results',
    'authority': 'turning standards into pressure on yourself or other people',
  };

  static const _profiles = <String, _LocalizedDayMasterProfile>{
    '甲': _LocalizedDayMasterProfile(
      nameTh: '甲 Jia · ไม้หยาง',
      nameEn: '甲 Jia · Yang Wood',
      symbolTh: 'ต้นไม้ใหญ่ที่เติบโตขึ้นเป็นแนวตรง',
      symbolEn: 'a tall tree growing upward',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นการเติบโตระยะยาว การมีทิศทาง และการยืนหยัดต่อเนื่อง',
      overviewEn:
          'The symbolic reading emphasises long-term growth, direction, and sustained resolve.',
      strengthsTh: 'มองเป้าหมายระยะยาวและรักษาทิศทางได้ดี',
      strengthsEn:
          'Holding a long-term direction and building toward it steadily',
      cautionsTh: 'อาจยึดแนวทางเดิมนานเกินไปเมื่อสถานการณ์เปลี่ยน',
      cautionsEn:
          'Staying with the original direction too long after conditions change',
      practicesTh: 'ตั้งหมุดทบทวนระหว่างทาง เพื่อแยกความมุ่งมั่นออกจากความดื้อ',
      practicesEn:
          'Use review checkpoints to separate persistence from rigidity',
    ),
    '乙': _LocalizedDayMasterProfile(
      nameTh: '乙 Yi · ไม้หยิน',
      nameEn: '乙 Yi · Yin Wood',
      symbolTh: 'เถาวัลย์หรือไม้ดอกที่ปรับทิศตามสิ่งรอบตัว',
      symbolEn: 'a vine or flowering plant adapting to its support',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นความยืดหยุ่น การมองเห็นความเชื่อมโยง และการค่อย ๆ พัฒนา',
      overviewEn:
          'The symbolic reading emphasises flexibility, connection, and gradual development.',
      strengthsTh: 'ปรับวิธีโดยยังรักษาเป้าหมายและความสัมพันธ์',
      strengthsEn:
          'Adapting the route while preserving purpose and relationships',
      cautionsTh: 'อาจปรับตัวตามคนอื่นจนความต้องการของตัวเองไม่ชัด',
      cautionsEn: 'Adapting so much that personal needs become unclear',
      practicesTh: 'ระบุขอบเขตและก้าวถัดไปของตัวเองให้ชัดก่อนตอบรับคนอื่น',
      practicesEn:
          'Name your own boundary and next step before accommodating others',
    ),
    '丙': _LocalizedDayMasterProfile(
      nameTh: '丙 Bing · ไฟหยาง',
      nameEn: '丙 Bing · Yang Fire',
      symbolTh: 'ดวงอาทิตย์ที่ส่องออกไปเป็นวงกว้าง',
      symbolEn: 'the sun radiating across a wide field',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นความเปิดเผย พลังในการขับเคลื่อน และการทำให้ภาพใหญ่ชัด',
      overviewEn:
          'The symbolic reading emphasises openness, activation, and making the larger picture visible.',
      strengthsTh: 'สร้างแรงขับและสื่อสารภาพใหญ่ให้คนอื่นเห็น',
      strengthsEn: 'Creating momentum and communicating the larger picture',
      cautionsTh: 'อาจเร่งพลังมากเกินไปหรือพูดมากกว่าการฟัง',
      cautionsEn: 'Driving intensity too high or speaking more than listening',
      practicesTh: 'สลับช่วงขับเคลื่อนกับช่วงฟังและพักให้ชัด',
      practicesEn:
          'Alternate visible leadership with deliberate listening and recovery',
    ),
    '丁': _LocalizedDayMasterProfile(
      nameTh: '丁 Ding · ไฟหยิน',
      nameEn: '丁 Ding · Yin Fire',
      symbolTh: 'แสงเทียนหรือโคมไฟที่ส่องเฉพาะจุด',
      symbolEn: 'a candle or lamp giving focused light',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นการมองรายละเอียด การสื่อสารอย่างมีจุดหมาย และการรักษาความอบอุ่น',
      overviewEn:
          'The symbolic reading emphasises detail, purposeful communication, and sustained warmth.',
      strengthsTh:
          'ช่วยทำเรื่องที่คลุมเครือให้ชัดและใส่ใจความรู้สึกของคนรอบข้าง',
      strengthsEn:
          'Clarifying subtle issues while noticing the emotional temperature around them',
      cautionsTh: 'อาจใช้พลังกับรายละเอียดหรือความกังวลจนล้า',
      cautionsEn:
          'Spending too much energy on detail or worry until focus burns down',
      practicesTh: 'กำหนดสิ่งสำคัญที่จะส่องให้ชัด และกันเวลาพักจากเรื่องย่อย',
      practicesEn:
          'Choose what deserves focused light and protect recovery from minor demands',
    ),
    '戊': _LocalizedDayMasterProfile(
      nameTh: '戊 Wu · ดินหยาง',
      nameEn: '戊 Wu · Yang Earth',
      symbolTh: 'ภูเขาหรือผืนดินใหญ่ที่มั่นคง',
      symbolEn: 'a mountain or broad mass of stable earth',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นความมั่นคง ขอบเขต และการเป็นฐานให้สิ่งอื่น',
      overviewEn:
          'The symbolic reading emphasises stability, boundaries, and providing a dependable base.',
      strengthsTh: 'รักษาความต่อเนื่องและรับภาระระยะยาวได้',
      strengthsEn:
          'Maintaining continuity and carrying long-term responsibility',
      cautionsTh: 'อาจต้านการเปลี่ยนแปลงเพราะกังวลว่าฐานเดิมจะสั่นคลอน',
      cautionsEn:
          'Resisting necessary change in order to protect the existing base',
      practicesTh:
          'ทบทวนว่าสิ่งใดควรคงไว้ และสิ่งใดเปลี่ยนได้โดยฐานหลักยังอยู่',
      practicesEn:
          'Separate the foundation that must stay from the method that can change',
    ),
    '己': _LocalizedDayMasterProfile(
      nameTh: '己 Ji · ดินหยิน',
      nameEn: '己 Ji · Yin Earth',
      symbolTh: 'ดินเพาะปลูกที่ค่อย ๆ หล่อเลี้ยงให้เกิดผล',
      symbolEn: 'cultivated soil that steadily supports growth',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นการดูแลระบบ การจัดสรร และการทำให้สิ่งเล็ก ๆ เติบโตได้',
      overviewEn:
          'The symbolic reading emphasises cultivation, organisation, and helping small things develop.',
      strengthsTh: 'จัดระบบรายละเอียดและสร้างสภาพแวดล้อมที่เอื้อให้เกิดผล',
      strengthsEn:
          'Organising detail and creating conditions where work can grow',
      cautionsTh: 'อาจรับภาระดูแลมากจนขอบเขตของตัวเองหายไป',
      cautionsEn:
          'Taking on so much support work that personal boundaries disappear',
      practicesTh:
          'กำหนดว่างานใดคือการช่วย และงานใดควรส่งคืนให้เจ้าของรับผิดชอบ',
      practicesEn:
          'Define what support is yours to provide and what belongs to its owner',
    ),
    '庚': _LocalizedDayMasterProfile(
      nameTh: '庚 Geng · ทองหยาง',
      nameEn: '庚 Geng · Yang Metal',
      symbolTh: 'โลหะดิบหรือคมดาบที่ใช้ตัดสินใจ',
      symbolEn: 'raw metal or a blade used for decisive cutting',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นความชัดเจน การตัดสินใจ และการตัดสิ่งที่ไม่จำเป็นออก',
      overviewEn:
          'The symbolic reading emphasises clarity, decision, and removing what is no longer needed.',
      strengthsTh: 'ตัดสินใจในโจทย์ยากและยกสิ่งจำเป็นออกจากสิ่งรบกวน',
      strengthsEn: 'Making hard decisions and separating essentials from noise',
      cautionsTh: 'อาจตรงหรือเร็วเกินไปจนคนอื่นไม่ทันเห็นเจตนา',
      cautionsEn: 'Moving so directly that others miss the constructive intent',
      practicesTh: 'บอกเจตนาและผลกระทบที่ต้องการ ก่อนตัดหรือเปลี่ยนสิ่งใด',
      practicesEn: 'State the intent and desired outcome before making the cut',
    ),
    '辛': _LocalizedDayMasterProfile(
      nameTh: '辛 Xin · ทองหยิน',
      nameEn: '辛 Xin · Yin Metal',
      symbolTh: 'อัญมณีหรือโลหะที่ผ่านการขัดเกลา',
      symbolEn: 'a jewel or metal refined through careful polishing',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นความละเอียด มาตรฐาน และการปรับสิ่งที่มีอยู่ให้คมชัดขึ้น',
      overviewEn:
          'The symbolic reading emphasises precision, standards, and refining what already exists.',
      strengthsTh: 'มองเห็นรายละเอียดและยกระดับคุณภาพจากของที่มีอยู่',
      strengthsEn:
          'Seeing fine detail and raising the quality of existing work',
      cautionsTh: 'อาจใช้มาตรฐานสูงกับตัวเองจนความคืบหน้าช้า',
      cautionsEn:
          'Applying such high standards that progress slows or self-worth gets involved',
      practicesTh: 'กำหนดเกณฑ์ “ดีพอสำหรับรอบนี้” ให้ชัดก่อนเริ่มขัดเกลา',
      practicesEn:
          'Define what is good enough for this iteration before refining',
    ),
    '壬': _LocalizedDayMasterProfile(
      nameTh: '壬 Ren · น้ำหยาง',
      nameEn: '壬 Ren · Yang Water',
      symbolTh: 'แม่น้ำใหญ่หรือมหาสมุทรที่เคลื่อนไหวต่อเนื่อง',
      symbolEn: 'a great river or ocean in continuous motion',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นการมองภาพกว้าง การเคลื่อนที่ และการหาเส้นทางไปรอบอุปสรรค',
      overviewEn:
          'The symbolic reading emphasises breadth, movement, and finding a route around obstacles.',
      strengthsTh: 'เชื่อมโยงข้อมูลหลายด้านและปรับเส้นทางเมื่อพบอุปสรรค',
      strengthsEn:
          'Connecting broad information and changing course around obstacles',
      cautionsTh: 'อาจกระจายพลังไปหลายทิศจนไม่มีเส้นใดไปถึงผลลัพธ์',
      cautionsEn:
          'Spreading energy across too many channels for any one to reach a result',
      practicesTh: 'เลือกช่องทางหลักที่จะพาไปถึงหมุดถัดไป แล้วค่อยเปิดทางสำรอง',
      practicesEn:
          'Choose one main channel to the next checkpoint before opening alternatives',
    ),
    '癸': _LocalizedDayMasterProfile(
      nameTh: '癸 Gui · น้ำหยิน',
      nameEn: '癸 Gui · Yin Water',
      symbolTh: 'ฝน หมอก หรือหยาดน้ำค้างที่ซึมเข้าไปอย่างละเอียด',
      symbolEn: 'rain, mist, or dew arriving in fine detail',
      overviewTh:
          'คำอ่านเชิงสัญลักษณ์เน้นการสังเกตสิ่งละเอียด การรับรู้บรรยากาศ และอิทธิพลที่ค่อย ๆ สะสม',
      overviewEn:
          'The symbolic reading emphasises subtle observation, atmosphere, and effects that accumulate gradually.',
      strengthsTh: 'มองเห็นสัญญาณละเอียดและเลือกจังหวะโดยไม่ต้องใช้แรงปะทะ',
      strengthsEn:
          'Noticing subtle signals and choosing timing without forcing the situation',
      cautionsTh: 'อาจเก็บความคิดไว้ภายในนานจนการตัดสินใจช้า',
      cautionsEn: 'Keeping observations internal so long that decisions stall',
      practicesTh:
          'เขียนสิ่งที่สังเกตได้ออกมา และกำหนดเวลาว่าข้อมูลเท่าใดถือว่าพอสำหรับก้าวถัดไป',
      practicesEn:
          'Write observations down and set a point when the evidence is enough for the next step',
    ),
  };
}

class _LocalizedDayMasterProfile {
  const _LocalizedDayMasterProfile({
    required this.nameTh,
    required this.nameEn,
    required this.symbolTh,
    required this.symbolEn,
    required this.overviewTh,
    required this.overviewEn,
    required this.strengthsTh,
    required this.strengthsEn,
    required this.cautionsTh,
    required this.cautionsEn,
    required this.practicesTh,
    required this.practicesEn,
  });

  final String nameTh;
  final String nameEn;
  final String symbolTh;
  final String symbolEn;
  final String overviewTh;
  final String overviewEn;
  final String strengthsTh;
  final String strengthsEn;
  final String cautionsTh;
  final String cautionsEn;
  final String practicesTh;
  final String practicesEn;

  BaziDayMasterReading resolve(bool th) {
    return BaziDayMasterReading(
      stem: nameTh.substring(0, 1),
      name: th ? nameTh : nameEn,
      symbol: th ? symbolTh : symbolEn,
      overview: th ? overviewTh : overviewEn,
      strengths: [th ? strengthsTh : strengthsEn],
      cautions: [th ? cautionsTh : cautionsEn],
      practices: [th ? practicesTh : practicesEn],
    );
  }
}
