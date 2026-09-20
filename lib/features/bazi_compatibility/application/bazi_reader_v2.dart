import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';

class BaziReaderV2Reading {
  const BaziReaderV2Reading({
    required this.overview,
    required this.identity,
    required this.work,
    required this.money,
    required this.relationships,
    required this.balance,
    required this.currentCycleTitle,
    required this.currentCycle,
    required this.annualTitle,
    required this.annual,
  });

  final String overview;
  final String identity;
  final String work;
  final String money;
  final String relationships;
  final String balance;
  final String currentCycleTitle;
  final String currentCycle;
  final String annualTitle;
  final String annual;
}

/// Turns Reader V2 calculation facts into direct, conversational Thai.
///
/// Every branch is deterministic and facts come from [BaziChartModel]. The
/// prose explains tendencies and practical trade-offs; it never guarantees an
/// event, diagnosis, investment result, or relationship outcome.
abstract final class BaziReaderV2 {
  static const interpretationContractId = 'knowme_bazi_reader_th_v2';

  static BaziReaderV2Reading build(BaziChartModel chart, {DateTime? asOf}) {
    final date = asOf ?? DateTime.now();
    final profile = BaziSymbolicReadingEngine.profileFor(chart.dayMaster.stem);
    final topFamilies = chart.tenGodBalance.topFamilies;
    final topNames = topFamilies
        .map((family) => _familyName[family] ?? family)
        .toList(growable: false);
    final support = chart.dayMasterSupport;
    final supportCopy =
        _supportCopy[support.band] ??
        'มีแรงหนุนหลายด้านปะปนกัน จึงต้องอ่านจากบริบทของแต่ละช่วงชีวิต';
    final relationCopy = _natalRelationCopy(chart.natalRelations);
    final completeness = chart.timeKnown
        ? ''
        : 'คำอ่านนี้ไม่มีเสาชั่วโมง จึงไม่เติมเรื่องที่ขึ้นกับเวลาเกิด';

    final overview =
        'แกนดวงของคุณคือ ${profile.name} เปรียบเหมือน “${profile.symbol}” '
        '$supportCopy ในโครงสร้างดวง${_topFamilySummary(topNames)} '
        '${_overviewAction(topFamilies)}'
        '${relationCopy.isEmpty ? '' : ' $relationCopy'}'
        '${completeness.isEmpty ? '' : ' $completeness'}';

    final identity =
        '${profile.overview} จุดแข็งที่กรอบนี้ชวนให้ลองใช้คือ ${profile.strengths.first} '
        'เมื่อต้องตัดสินใจ ควรกำหนดเป้าหมายและขอบเขตให้ชัด ถ้าต้องรับหลายเรื่องพร้อมกัน '
        'ให้ระวังการใช้มาตรฐานกับตัวเองและคนรอบข้างมากเกินจำเป็น '
        'วิธีใช้พลังนี้ให้คุ้มคือ ${profile.practices.first}';

    final work = _workReading(chart, topFamilies);
    final money = _moneyReading(chart);
    final relationships = _relationshipReading(chart);
    final balance = _balanceReading(chart, profile.cautions.first);

    final cycle = _currentCycle(chart, date.year);
    final currentCycleTitle = cycle == null
        ? 'จังหวะชีวิตปัจจุบัน'
        : 'จังหวะชีวิตปัจจุบัน · ${cycle.pillarLabel} (${cycle.startYear + 543}–${cycle.endYear + 543})';
    final currentCycle = cycle == null
        ? 'ยังไม่แสดงดวงจรสิบปี เพราะข้อมูลเพศหรือเวลาเกิดไม่ครบ ระบบจึงไม่กำหนดทิศทางเดินดวงแทนผู้ใช้'
        : _cycleReading(cycle);

    final annual = cycle == null ? null : _annual(cycle, date.year);
    final annualTitle = annual == null
        ? 'จังหวะรายปี'
        : 'ปี ${annual.year + 543} · ${annual.pillarLabel}';
    final annualCopy = annual == null
        ? 'ยังไม่มีข้อมูลรายปีที่ยืนยันได้สำหรับช่วงนี้ จึงไม่เติมเหตุการณ์จากการคาดเดา'
        : _annualReading(annual, cycle!);

    return BaziReaderV2Reading(
      overview: overview,
      identity: identity,
      work: work,
      money: money,
      relationships: relationships,
      balance: balance,
      currentCycleTitle: currentCycleTitle,
      currentCycle: currentCycle,
      annualTitle: annualTitle,
      annual: annualCopy,
    );
  }

  static String _workReading(BaziChartModel chart, List<String> topFamilies) {
    final parts = <String>[];
    for (final family in topFamilies) {
      final copy = _workFamilyCopy[family];
      if (copy != null) parts.add(copy);
    }
    final body = parts.isEmpty
        ? 'แนวโน้มของดวงสนับสนุนงานที่กำหนดผลลัพธ์และขอบเขตความรับผิดชอบได้ชัด'
        : _workSummary(parts);
    final supportWarning = chart.dayMasterSupport.band == 'lean'
        ? ' จุดสำคัญคืออย่ารับแรงกดดันทุกเรื่องไว้คนเดียว ควรมีข้อมูล ระบบ และผู้ช่วยที่ไว้ใจได้ก่อนขยายงาน'
        : ' เมื่อมีเป้าหมายชัด ควรกำหนดขอบเขต ผู้รับผิดชอบ และจุดตรวจผลก่อนรับงานเพิ่ม';
    return '$body$supportWarning';
  }

  static String _moneyReading(BaziChartModel chart) {
    final weights = chart.tenGodBalance.familyWeight;
    final wealth = weights['wealth'] ?? 0;
    final output = weights['output'] ?? 0;
    final peer = weights['peer'] ?? 0;
    final opening = wealth >= 4
        ? 'ในแบบจำลองนี้ หมวดการจัดการทรัพย์มีน้ำหนักเด่น หัวข้อการเงินที่ควรทบทวนคือการทำให้ภาระและทรัพยากรเกิดผลต่อเนื่อง'
        : 'ในแบบจำลองนี้ เรื่องเงินเชื่อมกับการเปลี่ยนความคิดและความรับผิดชอบให้เป็นผลลัพธ์ มากกว่าการพึ่งโชคเพียงอย่างเดียว';
    final earning = output >= wealth
        ? ' แนวทางที่สอดคล้องกับข้อมูลคือใช้ความคิด การสื่อสาร ผลิตภัณฑ์ หรือผลงานที่คนอื่นนำไปใช้ได้'
        : ' แนวทางที่สอดคล้องกับข้อมูลคือจัดสรรเวลา งบ และทรัพยากรให้เกิดผลที่ตรวจสอบได้';
    final caution = peer >= wealth
        ? ' ต้องแยกเงินส่วนตัว เงินร่วม และอำนาจตัดสินใจให้ชัด เพราะค่าใช้จ่ายจากทีม หุ้นส่วน หรือการขยายงานอาจโตเร็วกว่าที่เห็น'
        : ' ควรกำหนดเพดานลงทุนและจุดหยุดไว้ล่วงหน้า เพื่อไม่ให้โอกาสใหม่ดึงเงินออกจากงานหลัก';
    return '$opening$earning$caution';
  }

  static String _relationshipReading(BaziChartModel chart) {
    final gender = chart.luck.gender;
    final spouseFamily = gender == 'male'
        ? 'wealth'
        : gender == 'female'
        ? 'authority'
        : null;
    final weight = spouseFamily == null
        ? 0
        : chart.tenGodBalance.familyWeight[spouseFamily] ?? 0;
    final dayGod = chart.pillars.day.hiddenTenGods.isEmpty
        ? ''
        : chart.pillars.day.hiddenTenGods.first;
    final opening = spouseFamily == null
        ? 'หัวข้อที่ควรทบทวนในความสัมพันธ์คือเวลา บทบาท และความคาดหวังที่ตกลงร่วมกัน'
        : weight >= 4
        ? 'ในแบบจำลองนี้ หมวดคู่ครองมีน้ำหนักเด่น'
        : 'ในแบบจำลองนี้ หมวดคู่ครองไม่ได้อยู่ในกลุ่มที่มีน้ำหนักเด่น';
    final palace =
        _relationshipPalaceCopy[dayGod] ??
        'หัวข้อที่ควรทบทวนคือความชัดเจนและพื้นที่ให้แต่ละคนตัดสินใจได้';
    final dayRelations = chart.natalRelations
        .where((relation) => relation.roles.contains('day'))
        .toList(growable: false);
    final relation = _relationshipRelationCopy(dayRelations);
    return '$opening $palace${relation.isEmpty ? '' : ' $relation'}';
  }

  static String _balanceReading(BaziChartModel chart, String profileCaution) {
    final support = chart.dayMasterSupport;
    final action = switch (support.band) {
      'lean' =>
        'ควรลดจำนวนเรื่องที่ต้องตัดสินใจพร้อมกัน เติมเวลาพัก ข้อมูล และคนช่วยก่อนรับภาระใหม่',
      'supported' =>
        'ควรระวังความมั่นใจหรือความเคยชินกลายเป็นความดื้อ เปิดพื้นที่ให้ข้อมูลที่ขัดกับความคิดเดิม',
      _ =>
        'ควรรักษาจังหวะระหว่างการลงมือ การทบทวน และการขอความเห็นจากคนที่กล้าทักท้วง',
    };
    return '$profileCaution $action การอ่านธาตุส่วนนี้เป็นภาษาเชิงสมดุล ไม่ใช่การวินิจฉัยสุขภาพ';
  }

  static String _cycleReading(BaziLuckCycle cycle) {
    final theme =
        _tenGodCycleCopy[cycle.stemTenGod] ??
        'ช่วงปัจจุบันเน้นการจัดลำดับความสำคัญและใช้ประสบการณ์ประกอบการตัดสินใจ';
    final relation = _transitRelationCopy(
      cycle.natalRelations,
      context: _TransitContext.currentCycle,
    );
    return '$theme ช่วงนี้ครอบคลุมอายุจีน ${cycle.startAge}–${cycle.endAge} ปี'
        '${relation.isEmpty ? '' : ' $relation'}';
  }

  static String _annualReading(
    BaziAnnualInfluence annual,
    BaziLuckCycle cycle,
  ) {
    final theme =
        _tenGodAnnualCopy[annual.stemTenGod] ??
        'ปีนี้ควรเลือกเป้าหมายที่วัดผลได้และเดินตามลำดับ';
    final annualSignal = _transitSignal(annual.natalRelations);
    final cycleSignal = _transitSignal(cycle.natalRelations);
    final relation = annualSignal.isNotEmpty && annualSignal == cycleSignal
        ? _annualEchoCopy(annualSignal)
        : _transitRelationCopy(
            annual.natalRelations,
            context: _TransitContext.annual,
          );
    final action =
        _tenGodAnnualAction[annual.stemTenGod] ??
        'จึงควรเลือกเป้าหมายที่วัดผลได้และทบทวนแผนเป็นระยะ';
    return '$theme${relation.isEmpty ? '' : ' $relation'} $action';
  }

  static BaziLuckCycle? _currentCycle(BaziChartModel chart, int year) {
    for (final cycle in chart.luck.cycles) {
      if (year >= cycle.startYear && year <= cycle.endYear) return cycle;
    }
    return null;
  }

  static BaziAnnualInfluence? _annual(BaziLuckCycle cycle, int year) {
    for (final annual in cycle.annual) {
      if (annual.year == year) return annual;
    }
    return null;
  }

  static String _natalRelationCopy(List<BaziRelation> relations) {
    final combine = relations.where((item) => item.kind.contains('combine'));
    final tension = relations.where(
      (item) => item.kind.contains('clash') || item.kind.contains('punishment'),
    );
    if (combine.isNotEmpty && tension.isNotEmpty) {
      return 'ในแบบจำลองพบทั้งแรงผสานและแรงปะทะ จึงควรรวมมุมมองที่ต่างกันโดยไม่เร่งข้อสรุปจนข้ามผลกระทบ';
    }
    if (combine.isNotEmpty) {
      return 'ในแบบจำลองพบแรงผสานเด่น จึงควรใช้การเชื่อมคน ความคิด หรือทรัพยากรที่ดูแยกจากกัน';
    }
    if (tension.isNotEmpty) {
      return 'ในแบบจำลองพบแรงปะทะภายใน จึงควรเว้นจังหวะก่อนตัดสินใจและเผื่อเวลาตรวจผลกระทบ';
    }
    return '';
  }

  static String _relationshipRelationCopy(List<BaziRelation> relations) {
    if (relations.any((item) => item.kind.contains('clash'))) {
      return 'หากเกิดความเห็นต่าง ควรพูดเรื่องจังหวะ วิธีตัดสินใจ และเงื่อนไขที่ต้องการให้ตรงก่อนลงมือ';
    }
    if (relations.any((item) => item.kind.contains('combine'))) {
      return 'ควรแยกให้ชัดว่าเรื่องใดคือความรัก และเรื่องใดคือภาระหรือแผนที่รับร่วมกัน';
    }
    return '';
  }

  static String _transitRelationCopy(
    List<BaziRelation> relations, {
    required _TransitContext context,
  }) {
    final signal = _transitSignal(relations);
    if (context == _TransitContext.currentCycle) {
      return switch (signal) {
        'clash' =>
          'ช่วงปัจจุบันมีสัญญาณปะทะกับพื้นดวง จึงควรวางแผนปรับระบบ ตาราง หรือบทบาท และเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
        'friction' =>
          'ช่วงปัจจุบันมีแรงเสียดทานแฝง จึงควรยืนยันข้อตกลง เวลา และผู้รับผิดชอบให้ชัด',
        'combine' =>
          'ช่วงปัจจุบันมีแรงผสานกับพื้นดวง จึงควรพิจารณาว่าจะรวมทรัพยากร ความร่วมมือ หรือปรับของเดิมให้เกิดผลในรูปแบบใหม่อย่างไร',
        _ => '',
      };
    }
    return switch (signal) {
      'clash' =>
        'สัญญาณรายปีปะทะกับพื้นดวง จึงควรวางแผนปรับระบบ ตาราง หรือบทบาท และเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
      'friction' =>
        'สัญญาณรายปีมีแรงเสียดทานแฝง จึงควรยืนยันข้อตกลง เวลา และผู้รับผิดชอบให้ชัด',
      'combine' =>
        'สัญญาณรายปีมีแรงผสานกับพื้นดวง จึงควรพิจารณาว่าจะรวมทรัพยากร ความร่วมมือ หรือปรับของเดิมให้เกิดผลในรูปแบบใหม่อย่างไร',
      _ => '',
    };
  }

  static String _transitSignal(List<BaziRelation> relations) {
    if (relations.any((item) => item.kind.contains('clash'))) return 'clash';
    if (relations.any(
      (item) =>
          item.kind.contains('harm') ||
          item.kind.contains('break') ||
          item.kind.contains('punishment'),
    )) {
      return 'friction';
    }
    if (relations.any(
      (item) => item.kind.contains('combine') || item.kind.contains('harmony'),
    )) {
      return 'combine';
    }
    return '';
  }

  static String _annualEchoCopy(String signal) {
    return switch (signal) {
      'clash' => 'สัญญาณรายปีย้ำธีมการปรับระบบของช่วงปัจจุบัน',
      'friction' => 'สัญญาณรายปีย้ำธีมการตรวจข้อตกลงและภาระของช่วงปัจจุบัน',
      'combine' => 'สัญญาณรายปีย้ำธีมการประสานทรัพยากรของช่วงปัจจุบัน',
      _ => '',
    };
  }

  static String _topFamilySummary(List<String> names) {
    if (names.isEmpty) return 'ยังไม่มีกลุ่มพลังเด่นที่แยกได้ชัด';
    if (names.length == 1) return 'มีพลังเด่นคือ ${names.first}';
    if (names.length == 2) {
      return 'มีพลังเด่น 2 กลุ่ม: ${names.first}; กับ${names.last}';
    }
    return 'มีพลังเด่น ${names.length} กลุ่ม: '
        '${names.sublist(0, names.length - 1).join('; ')}; และ${names.last}';
  }

  static String _overviewAction(List<String> families) {
    if (families.contains('authority') && families.contains('output')) {
      return 'จึงควรใช้ข้อมูลและระบบช่วยเปลี่ยนแรงกดดันให้เป็นผลงานที่ตรวจสอบได้';
    }
    return 'จึงควรเลือกใช้พลังเด่นเหล่านี้ภายใต้เป้าหมายและขอบเขตที่ตรวจสอบได้';
  }

  static String _workSummary(List<String> parts) {
    if (parts.length == 1) return 'แนวโน้มของดวงสนับสนุน${parts.first}';
    return 'แนวโน้มของดวงสนับสนุน${parts.first} '
        '${parts.skip(1).map((part) => 'รวมถึง$part').join(' ')}';
  }

  static const _familyName = <String, String>{
    'resource': 'การเรียนรู้และแรงสนับสนุน',
    'peer': 'ความเป็นตัวเองและผู้ร่วมทาง',
    'output': 'ความคิด การสื่อสาร และผลงาน',
    'wealth': 'การจัดการเงินและทรัพยากร',
    'authority': 'มาตรฐาน ความรับผิดชอบ และแรงกดดัน',
  };

  static const _supportCopy = <String, String>{
    'lean':
        'แบบจำลองประเมินแรงหนุนของธาตุประจำตัวว่าค่อนข้างบาง จึงควรใช้ข้อมูล ระบบ และทรัพยากรช่วยรองรับการตัดสินใจ',
    'balanced':
        'แบบจำลองประเมินแรงหนุนของธาตุประจำตัวไว้ระดับกลาง จึงควรจัดลำดับพลังตามบริบทของแต่ละช่วง',
    'supported':
        'แบบจำลองประเมินแรงหนุนของธาตุประจำตัวไว้สูง จึงควรใช้แรงที่มีโดยไม่ยึดวิธีของตัวเองมากเกินไป',
  };

  static const _workFamilyCopy = <String, String>{
    'resource':
        'งานที่ต้องศึกษาลึก วางระบบความรู้ หรือเป็นที่พึ่งด้านข้อมูลให้ผู้อื่น',
    'peer': 'บทบาทที่มีอิสระในการตัดสินใจ ทำงานกับคนเก่ง และแบ่งอำนาจกันชัด',
    'output':
        'งานที่ต้องคิด อธิบาย ออกแบบ หรือแก้ปัญหาให้เกิดผลงานที่นำไปใช้ได้',
    'wealth':
        'งานที่เชื่อมงบ เวลา ลูกค้า และทรัพยากรให้เกิดผลทางธุรกิจที่ตรวจสอบได้',
    'authority':
        'งานที่ต้องตัดสินใจภายใต้ข้อจำกัด ตั้งมาตรฐาน และรับผิดชอบผลลัพธ์',
  };

  static const _relationshipPalaceCopy = <String, String>{
    '正印':
        'หัวข้อที่ควรทบทวนคือความมั่นคง ความเข้าใจ และพื้นที่พักใจของทั้งสองฝ่าย',
    '偏印':
        'หัวข้อที่ควรทบทวนคือการเข้าใจวิธีคิดที่ต่างกันโดยไม่บังคับให้อีกฝ่ายตอบสนองเหมือนตน',
    '比肩':
        'หัวข้อที่ควรทบทวนคือความเท่าเทียม พื้นที่ส่วนตัว และการไม่ให้ฝ่ายหนึ่งควบคุมทั้งหมด',
    '劫财':
        'หัวข้อที่ควรทบทวนคือจุดยืน เรื่องเงิน เวลา และอำนาจตัดสินใจที่ตกลงร่วมกัน',
    '食神': 'หัวข้อที่ควรทบทวนคือความสบายใจ การดูแลกัน และการพูดคุยที่ไม่กดดัน',
    '伤官':
        'หัวข้อที่ควรทบทวนคือการสื่อสารอย่างตรงไปตรงมา พร้อมระวังคำพูดเร็วหรือแรงเกินเจตนา',
    '正财': 'หัวข้อที่ควรทบทวนคือความสม่ำเสมอและการรับผิดชอบในชีวิตประจำวัน',
    '偏财':
        'หัวข้อที่ควรทบทวนคือความยืดหยุ่น ประสบการณ์ร่วม และการเปิดโอกาสให้กัน',
    '正官':
        'หัวข้อที่ควรทบทวนคือความชัดเจน ความซื่อสัตย์ และข้อตกลงที่ทั้งสองฝ่ายรักษาได้',
    '七杀':
        'หัวข้อที่ควรทบทวนคือจังหวะตัดสินใจ แรงกดดัน และการไม่ควบคุมกันมากเกินไป',
  };

  static const _tenGodCycleCopy = <String, String>{
    '正印':
        'ช่วงปัจจุบันเน้นการสร้างฐานความรู้ ความมั่นคง และระบบสนับสนุนระยะยาว',
    '偏印':
        'ช่วงปัจจุบันเน้นการค้นคว้า เปลี่ยนมุมมอง และสร้างวิธีทำงานที่ต่างจากเดิม',
    '比肩':
        'ช่วงปัจจุบันเน้นการยืนด้วยตัวเอง สร้างอำนาจตัดสินใจ และทำให้ผลงานของตนชัดขึ้น',
    '劫财': 'ช่วงปัจจุบันเน้นทีม หุ้นส่วน การแข่งขัน และการแบ่งผลประโยชน์',
    '食神':
        'ช่วงปัจจุบันเน้นการเปลี่ยนความรู้และประสบการณ์ให้เป็นผลงานที่ทำซ้ำได้',
    '伤官': 'ช่วงปัจจุบันเน้นการทบทวนวิธีเดิม สื่อสารให้ชัด และแก้ข้อจำกัดหลัก',
    '正财': 'ช่วงปัจจุบันเน้นการจัดระบบรายได้ ทรัพย์สิน และความรับผิดชอบ',
    '偏财': 'ช่วงปัจจุบันเน้นการประเมินโอกาสจากตลาด เครือข่าย หรือทรัพยากรภายนอก',
    '正官': 'ช่วงปัจจุบันเน้นบทบาททางการ มาตรฐาน และความน่าเชื่อถือระยะยาว',
    '七杀': 'ช่วงปัจจุบันเน้นการรับมือโจทย์ยาก การแข่งขัน และภาระที่ต้องจัดลำดับ',
  };

  static const _tenGodAnnualCopy = <String, String>{
    '正印': 'ปีนี้เด่นเรื่องการเรียนรู้ วางฐาน และขอแรงสนับสนุนให้ถูกจุด',
    '偏印': 'ปีนี้เด่นเรื่องการทดลองแนวทางใหม่และทบทวนสิ่งที่เคยเชื่อ',
    '比肩': 'ปีนี้เด่นเรื่องการตัดสินใจด้วยตัวเองและทำตัวตนของงานให้ชัด',
    '劫财': 'ปีนี้เด่นเรื่องทีม คู่แข่ง หุ้นส่วน และข้อตกลงผลประโยชน์',
    '食神': 'ปีนี้เด่นเรื่องการสร้างผลงาน ถ่ายทอดความรู้ และทำสิ่งที่ต่อยอดได้',
    '伤官':
        'ปีนี้เด่นเรื่องการเปลี่ยนระบบ พูดความจริง และแก้สิ่งที่ไม่มีประสิทธิภาพ',
    '正财': 'ปีนี้เด่นเรื่องกระแสเงินสด งานประจำ และผลลัพธ์ที่วัดได้',
    '偏财': 'ปีนี้เด่นเรื่องโอกาสทางธุรกิจ เครือข่าย และรายได้จากหลายทาง',
    '正官': 'ปีนี้เด่นเรื่องมาตรฐาน ความน่าเชื่อถือ สัญญา และบทบาทที่เป็นทางการ',
    '七杀': 'ปีนี้แรงกดดันและเส้นตายเด่น',
  };

  static const _tenGodAnnualAction = <String, String>{
    '正印': 'จึงควรเพิ่มทักษะ วางระบบ และเตรียมทรัพยากรให้พร้อม',
    '偏印': 'จึงควรทดลองทางเลือกแบบจำกัดขอบเขตและกำหนดเกณฑ์หยุดให้ชัด',
    '比肩': 'จึงควรเลือกเรื่องที่เป็นเจ้าของเองและกำหนดผลลัพธ์ที่ตรวจสอบได้',
    '劫财': 'จึงควรทบทวนทีม คู่ค้า และข้อตกลงก่อนผูกภาระเพิ่ม',
    '食神': 'จึงควรทำผลงานให้เสร็จ ทดสอบการนำไปใช้ และค่อยวางแผนต่อยอด',
    '伤官': 'จึงควรแก้ระบบที่ติดขัดโดยใช้ข้อมูลแทนอารมณ์ในการเจรจา',
    '正财': 'จึงควรจัดงบ กระแสเงินสด และตัวชี้วัดของรายได้หลักให้ชัด',
    '偏财': 'จึงควรประเมินตลาดหรือเครือข่ายใหม่ภายใต้วงเงินที่กำหนดไว้',
    '正官': 'จึงควรกำหนดบทบาท ข้อตกลง และมาตรฐานที่ตรวจสอบได้',
    '七杀': 'จึงควรเลือกงานสำคัญหนึ่งเรื่องและกำหนดแผนดำเนินงานให้ชัด',
  };
}

enum _TransitContext { currentCycle, annual }
