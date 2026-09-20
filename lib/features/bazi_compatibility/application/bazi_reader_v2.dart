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
        'ดวงนี้มีแรงหนุนหลายด้าน คุณจึงควรดูสถานการณ์จริงก่อนตัดสินใจ';
    final relationCopy = _natalRelationCopy(chart.natalRelations);
    final completeness = chart.timeKnown
        ? ''
        : 'คำอ่านนี้ไม่มีเสาชั่วโมง จึงไม่เติมเรื่องที่ขึ้นกับเวลาเกิด';

    final overview =
        'แกนดวงของคุณคือ ${profile.name} เปรียบเหมือน “${profile.symbol}” '
        '$supportCopy ${_topFamilySummary(topNames)} '
        '${_overviewAction(topFamilies)}'
        '${relationCopy.isEmpty ? '' : ' $relationCopy'}'
        '${completeness.isEmpty ? '' : ' $completeness'}';

    final identity =
        'ดวงนี้มีจุดเด่นคือ${profile.strengths.first} '
        'คุณใช้จุดเด่นนี้ได้ดีเมื่อ${profile.practices.first} '
        'เมื่อต้องรับหลายเรื่องพร้อมกัน ให้เลือกเรื่องสำคัญก่อนและกำหนดขอบเขตให้ชัด';

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
        ? 'เรื่องงาน ดวงนี้หนุนงานที่กำหนดผลลัพธ์และขอบเขตความรับผิดชอบได้ชัด'
        : _workSummary(parts);
    final supportWarning = chart.dayMasterSupport.band == 'lean'
        ? ' อย่ารับแรงกดดันทุกเรื่องไว้คนเดียว ควรเตรียมข้อมูล ระบบ และคนช่วยที่ไว้ใจก่อนขยายงาน'
        : ' ก่อนรับงานเพิ่ม ควรกำหนดขอบเขต ผู้รับผิดชอบ และจุดตรวจผลให้ชัด';
    return '$body$supportWarning';
  }

  static String _moneyReading(BaziChartModel chart) {
    final weights = chart.tenGodBalance.familyWeight;
    final wealth = weights['wealth'] ?? 0;
    final output = weights['output'] ?? 0;
    final peer = weights['peer'] ?? 0;
    final opening = wealth >= 4
        ? 'เรื่องเงินเด่นที่การจัดเวลา งบ และทรัพยากรให้เกิดผลต่อเนื่อง'
        : 'เรื่องเงินควรพึ่งผลงานและความรับผิดชอบที่จับต้องได้ มากกว่ารอโชคเพียงอย่างเดียว';
    final earning = output >= wealth
        ? ' คุณควรต่อยอดความคิด การสื่อสาร หรือผลงานที่คนอื่นนำไปใช้ได้'
        : ' คุณควรจัดสรรเวลา งบ และทรัพยากรให้เห็นผลชัด';
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
        ? 'เรื่องความสัมพันธ์ต้องคุยเวลา บทบาท และความคาดหวังให้ตรงกัน'
        : weight >= 4
        ? 'ความสัมพันธ์เป็นเรื่องเด่นในดวงนี้'
        : 'เรื่องความสัมพันธ์ควรค่อย ๆ สร้างจากความชัดเจนและความสม่ำเสมอ';
    final palace =
        _relationshipPalaceCopy[dayGod] ??
        'ควรให้ความชัดเจนและพื้นที่ตัดสินใจกับกันและกัน';
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
        'ช่วงนี้คุณควรจัดลำดับเรื่องสำคัญ และใช้ประสบการณ์ช่วยตัดสินใจ';
    final relation = _transitRelationCopy(
      cycle.natalRelations,
      context: _TransitContext.currentCycle,
    );
    return '$theme จังหวะนี้อยู่ในช่วงอายุจีน ${cycle.startAge}–${cycle.endAge} ปี'
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
      return 'ดวงนี้มีทั้งจังหวะที่เรื่องต่าง ๆ ไปด้วยกันได้ และจังหวะที่ขัดกัน คุณจึงควรฟังมุมมองที่ต่างก่อนรีบสรุป';
    }
    if (combine.isNotEmpty) {
      return 'ดวงนี้เด่นเรื่องการเชื่อมคน ความคิด หรือทรัพยากรที่ดูแยกจากกัน';
    }
    if (tension.isNotEmpty) {
      return 'ดวงนี้มีจังหวะที่ความต้องการขัดกันได้ คุณจึงควรเว้นระยะก่อนตัดสินใจและเผื่อเวลาตรวจผลกระทบ';
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
          'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต ควรเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
        'friction' =>
          'ต้องคุยเรื่องเวลา หน้าที่ และข้อตกลงให้ชัด เพราะความเข้าใจไม่ตรงกันอาจกลายเป็นภาระตามมา',
        'combine' =>
          'เหมาะกับการรวมคน ความรู้ หรือทรัพยากร เพื่อพัฒนาสิ่งที่ทำอยู่ให้เดินต่อได้ดีขึ้น',
        _ => '',
      };
    }
    return switch (signal) {
      'clash' =>
        'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต ควรเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
      'friction' =>
        'ต้องคุยเรื่องเวลา หน้าที่ และข้อตกลงให้ชัด เพราะความเข้าใจไม่ตรงกันอาจกลายเป็นภาระตามมา',
      'combine' =>
        'เหมาะกับการรวมคน ความรู้ หรือทรัพยากร เพื่อพัฒนาสิ่งที่ทำอยู่ให้เดินต่อได้ดีขึ้น',
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
      'clash' => 'ปีนี้ย้ำว่าควรปรับระบบและเผื่อแผนสำรองจากช่วงปัจจุบัน',
      'friction' => 'ปีนี้ย้ำว่าควรตรวจข้อตกลงและภาระจากช่วงปัจจุบันให้ชัด',
      'combine' => 'ปีนี้ย้ำว่าควรต่อยอดความร่วมมือจากช่วงปัจจุบัน',
      _ => '',
    };
  }

  static String _topFamilySummary(List<String> names) {
    if (names.isEmpty) return 'เรื่องเด่นในดวงนี้ต้องดูตามแต่ละช่วงชีวิต';
    if (names.length == 1) return 'เรื่องที่เด่นในดวงนี้คือ ${names.first}';
    if (names.length == 2) {
      return 'เรื่องที่เด่นในดวงนี้มี 2 ด้าน คือ ${names.first} กับ${names.last}';
    }
    return 'เรื่องที่เด่นในดวงนี้คือ '
        '${names.sublist(0, names.length - 1).join(', ')} และ${names.last}';
  }

  static String _overviewAction(List<String> families) {
    if (families.contains('authority') && families.contains('output')) {
      return 'คุณใช้จุดเด่นนี้ได้ดีเมื่อมีข้อมูลและระบบช่วยเปลี่ยนแรงกดดันให้เป็นผลงานที่ตรวจสอบได้';
    }
    return 'คุณใช้จุดเด่นเหล่านี้ได้ดีเมื่อมีเป้าหมายและขอบเขตที่ชัด';
  }

  static String _workSummary(List<String> parts) {
    if (parts.length == 1) return 'เรื่องงาน ดวงนี้หนุน${parts.first}';
    return 'เรื่องงาน ดวงนี้หนุน${parts.first} '
        '${parts.skip(1).map((part) => 'และ$part').join(' ')}';
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
        'ดวงนี้มีแรงหนุนค่อนข้างน้อย คุณจึงตัดสินใจได้รอบคอบขึ้นเมื่อมีข้อมูล ระบบ และคนที่ไว้ใจได้ช่วยรองรับ',
    'balanced':
        'ดวงนี้มีแรงหนุนพอดี คุณจึงปรับตัวได้ดีเมื่อรู้ว่าเรื่องไหนควรเดินหน้าและเรื่องไหนควรรอ',
    'supported':
        'ดวงนี้มีแรงหนุนมาก คุณเดินหน้าได้ดี แต่ควรฟังมุมมองอื่นก่อนยึดวิธีของตัวเอง',
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
    '正印': 'ควรสร้างความมั่นคง ความเข้าใจ และพื้นที่พักใจให้กัน',
    '偏印': 'ควรเข้าใจวิธีคิดที่ต่างกัน โดยไม่คาดหวังให้อีกฝ่ายตอบสนองเหมือนคุณ',
    '比肩':
        'ควรรักษาความเท่าเทียม พื้นที่ส่วนตัว และไม่ให้ฝ่ายหนึ่งควบคุมทุกเรื่อง',
    '劫财': 'ควรตกลงเรื่องเงิน เวลา และอำนาจตัดสินใจร่วมกันให้ชัด',
    '食神': 'ควรดูแลความสบายใจและพูดคุยกันโดยไม่กดดัน',
    '伤官': 'ควรพูดกันตรง ๆ พร้อมระวังคำพูดที่เร็วหรือแรงเกินเจตนา',
    '正财': 'ควรแสดงความสม่ำเสมอและแบ่งความรับผิดชอบในชีวิตประจำวัน',
    '偏财': 'ควรยืดหยุ่น เปิดโอกาสให้กัน และหาเวลาสร้างประสบการณ์ร่วม',
    '正官': 'ควรซื่อสัตย์ต่อกันและใช้ข้อตกลงที่ทั้งสองฝ่ายรักษาได้จริง',
    '七杀': 'ควรระวังแรงกดดันในเวลาตัดสินใจ และไม่ควบคุมกันมากเกินไป',
  };

  static const _tenGodCycleCopy = <String, String>{
    '正印':
        'ช่วงนี้เหมาะกับการเรียนรู้และวางรากฐาน สิ่งที่เตรียมไว้ดีจะช่วยให้คุณเดินต่อได้มั่นคงขึ้น',
    '偏印':
        'ช่วงนี้คุณมีโอกาสได้ลองวิธีใหม่ ๆ และมองเรื่องเดิมต่างออกไป สิ่งที่ได้เรียนรู้จะช่วยให้ตัดสินใจได้รอบคอบขึ้น',
    '比肩':
        'ช่วงนี้คุณอยากตัดสินใจด้วยตัวเองมากขึ้น เหมาะกับการสร้างผลงานที่บอกได้ชัดว่าคุณรับผิดชอบอะไร',
    '劫财':
        'ช่วงนี้เรื่องทีม หุ้นส่วน และการแข่งขันเด่นขึ้น ควรแบ่งบทบาทและผลประโยชน์ให้ชัด',
    '食神':
        'ช่วงนี้เหมาะกับการเปลี่ยนความรู้และประสบการณ์ให้เป็นผลงานที่นำไปใช้ต่อได้',
    '伤官':
        'ช่วงนี้คุณมองเห็นจุดติดขัดได้ชัดขึ้น ควรปรับวิธีเดิมและสื่อสารเหตุผลให้คนที่เกี่ยวข้องเข้าใจ',
    '正财':
        'ช่วงนี้เรื่องรายได้ ทรัพย์สิน และความรับผิดชอบเด่นขึ้น ควรจัดให้เป็นระบบ',
    '偏财':
        'ช่วงนี้มีโอกาสจากตลาด เครือข่าย หรือทรัพยากรภายนอก ควรดูทั้งผลตอบแทนและภาระที่ตามมา',
    '正官':
        'ช่วงนี้บทบาทและความรับผิดชอบชัดขึ้น เหมาะกับการสร้างมาตรฐานและความน่าเชื่อถือระยะยาว',
    '七杀': 'ช่วงนี้มีโจทย์ยากและแรงกดดันมากขึ้น คุณควรเลือกภาระที่สำคัญก่อน',
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
