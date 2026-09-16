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

  static BaziReaderV2Reading build(
    BaziChartModel chart, {
    DateTime? asOf,
  }) {
    final date = asOf ?? DateTime.now();
    final profile = BaziSymbolicReadingEngine.profileFor(
      chart.dayMaster.stem,
    );
    final topFamilies = chart.tenGodBalance.topFamilies;
    final topNames = _joinThai(
      topFamilies.map((family) => _familyName[family] ?? family).toList(),
    );
    final support = chart.dayMasterSupport;
    final supportCopy = _supportCopy[support.band] ??
        'มีแรงหนุนหลายด้านปะปนกัน จึงต้องอ่านจากบริบทของแต่ละช่วงชีวิต';
    final relationCopy = _natalRelationCopy(chart.natalRelations);
    final completeness = chart.timeKnown
        ? 'คำอ่านนี้ใช้สี่เสาครบ รวมเสาชั่วโมง'
        : 'คำอ่านนี้ไม่มีเสาชั่วโมง จึงไม่เติมเรื่องที่ขึ้นกับเวลาเกิด';

    final overview =
        'แกนดวงของคุณคือ ${profile.name} เปรียบเหมือน “${profile.symbol}” '
        '$supportCopy ในโครงสร้างดวง พลังที่เด่นร่วมกันคือ $topNames '
        'จึงเป็นดวงที่เติบโตได้ดีเมื่อเปลี่ยนแรงกดดันและความคิดให้กลายเป็นผลงานที่จับต้องได้'
        '${relationCopy.isEmpty ? '' : ' $relationCopy'} — $completeness';

    final identity =
        '${profile.overview} จุดแข็งคือ ${profile.strengths.first} '
        'คุณมักตัดสินใจได้ดีเมื่อเป้าหมายและขอบเขตชัด แต่ถ้าต้องรับหลายเรื่องพร้อมกัน '
        'อาจใช้มาตรฐานกับตัวเองและคนรอบข้างมากเกินจำเป็น '
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

  static String _workReading(
    BaziChartModel chart,
    List<String> topFamilies,
  ) {
    final parts = <String>[];
    for (final family in topFamilies) {
      final copy = _workFamilyCopy[family];
      if (copy != null) parts.add(copy);
    }
    final body = parts.isEmpty
        ? 'เหมาะกับงานที่กำหนดผลลัพธ์และขอบเขตความรับผิดชอบได้ชัด'
        : _joinThai(parts);
    final supportWarning = chart.dayMasterSupport.band == 'lean'
        ? ' จุดสำคัญคืออย่ารับแรงกดดันทุกเรื่องไว้คนเดียว ควรมีข้อมูล ระบบ และผู้ช่วยที่ไว้ใจได้ก่อนขยายงาน'
        : ' เมื่อมีเป้าหมายชัด คุณสามารถรับผิดชอบงานใหญ่และประคองทีมให้เดินไปในทิศทางเดียวกันได้';
    return '$body$supportWarning';
  }

  static String _moneyReading(BaziChartModel chart) {
    final weights = chart.tenGodBalance.familyWeight;
    final wealth = weights['wealth'] ?? 0;
    final output = weights['output'] ?? 0;
    final peer = weights['peer'] ?? 0;
    final opening = wealth >= 4
        ? 'ดาวการจัดการทรัพย์มีน้ำหนักชัด คุณมักมองเรื่องเงินผ่านสิ่งที่ต้องทำให้เกิดผลและดูแลต่อเนื่อง'
        : 'เรื่องเงินไม่ได้เดินจากโชคอย่างเดียว แต่ขึ้นกับการเปลี่ยนความคิดและความรับผิดชอบให้เป็นผลลัพธ์';
    final earning = output >= wealth
        ? ' จุดทำเงินเด่นมาจากความคิด การสื่อสาร ผลิตภัณฑ์ หรือผลงานที่คนอื่นนำไปใช้ได้'
        : ' จุดทำเงินเด่นมาจากการจัดสรรเวลา งบ และทรัพยากรให้เกิดผลที่ตรวจสอบได้';
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
        ? 'ความสัมพันธ์ต้องอาศัยการตกลงเรื่องเวลา บทบาท และความคาดหวังให้ชัด'
        : weight >= 4
        ? 'พลังคู่ครองปรากฏชัดในดวง ความสัมพันธ์จึงมีผลต่อการตัดสินใจและทิศทางชีวิตมากกว่าที่แสดงออกภายนอก'
        : 'ความสัมพันธ์ไม่ได้ขับเคลื่อนด้วยความรู้สึกเพียงอย่างเดียว คุณต้องเห็นความรับผิดชอบและความไว้ใจที่พิสูจน์ได้';
    final palace = _relationshipPalaceCopy[dayGod] ??
        'เมื่ออยู่ใกล้กันจริง คุณต้องการทั้งความชัดเจนและพื้นที่ให้แต่ละคนตัดสินใจได้';
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
    final theme = _tenGodCycleCopy[cycle.stemTenGod] ??
        'เป็นช่วงที่ต้องจัดลำดับความสำคัญและใช้ประสบการณ์ให้เกิดผลชัดเจน';
    final relation = _transitRelationCopy(cycle.natalRelations);
    return '$theme ช่วงนี้ครอบคลุมอายุจีน ${cycle.startAge}–${cycle.endAge} ปี'
        '${relation.isEmpty ? '' : ' $relation'}';
  }

  static String _annualReading(
    BaziAnnualInfluence annual,
    BaziLuckCycle cycle,
  ) {
    final theme = _tenGodAnnualCopy[annual.stemTenGod] ??
        'ปีนี้ควรเลือกเป้าหมายที่วัดผลได้และเดินตามลำดับ';
    final relation = _transitRelationCopy(annual.natalRelations);
    final cycleBridge = annual.stem == cycle.stem
        ? 'พลังปีเดินในทิศเดียวกับดวงจรสิบปี จึงทำให้เรื่องเดิมชัดและเร็วขึ้น'
        : 'ควรใช้เป้าหมายของปีนี้เป็นงานย่อยภายใต้ทิศทางของดวงจรสิบปี ไม่เปิดหลายเรื่องพร้อมกัน';
    return '$theme $cycleBridge${relation.isEmpty ? '' : ' $relation'}';
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
      return 'ดวงมีทั้งแรงผสานและแรงปะทะ จึงมีความสามารถรวมสิ่งต่างกันให้เกิดผลงาน แต่ต้องไม่เร่งข้อสรุปจนข้ามความเห็นที่ไม่ตรงกัน';
    }
    if (combine.isNotEmpty) {
      return 'ดวงมีแรงผสานเด่น คุณจึงมักเห็นทางเชื่อมระหว่างคน ความคิด หรือทรัพยากรที่ดูแยกจากกัน';
    }
    if (tension.isNotEmpty) {
      return 'ดวงมีแรงปะทะภายในพอสมควร ข้อดีคือผลักให้ตัดสินใจและแก้ปัญหาเร็ว แต่ต้องเผื่อเวลาตรวจผลกระทบ';
    }
    return '';
  }

  static String _relationshipRelationCopy(List<BaziRelation> relations) {
    if (relations.any((item) => item.kind.contains('clash'))) {
      return 'เมื่อเกิดความเห็นต่าง ประเด็นมักอยู่ที่จังหวะหรือวิธีตัดสินใจ จึงควรพูดเงื่อนไขที่ต้องการให้ตรงก่อนลงมือ';
    }
    if (relations.any((item) => item.kind.contains('combine'))) {
      return 'คุณผูกความสัมพันธ์เข้ากับหน้าที่และแผนชีวิตได้ง่าย จึงต้องแยกให้ชัดว่าเรื่องใดคือความรักและเรื่องใดคือภาระ';
    }
    return '';
  }

  static String _transitRelationCopy(List<BaziRelation> relations) {
    final clash = relations.where((item) => item.kind.contains('clash')).length;
    final combine = relations
        .where(
          (item) =>
              item.kind.contains('combine') || item.kind.contains('harmony'),
        )
        .length;
    final friction = relations.where(
      (item) =>
          item.kind.contains('harm') ||
          item.kind.contains('break') ||
          item.kind.contains('punishment'),
    );
    if (clash > 0) {
      return 'มีสัญญาณปะทะกับพื้นดวง จึงเหมาะกับการปรับระบบ ตาราง หรือบทบาทอย่างมีแผน ไม่ควรตัดสินใจเพราะความกดดันชั่วคราว';
    }
    if (friction.isNotEmpty) {
      return 'มีแรงเสียดทานที่ไม่แสดงออกตรง ๆ ควรยืนยันข้อตกลง เวลา และผู้รับผิดชอบให้ชัด';
    }
    if (combine > 0) {
      return 'มีแรงผสานกับพื้นดวง เหมาะกับการรวมทรัพยากร ความร่วมมือ หรือทำของเดิมให้เกิดผลในรูปแบบใหม่';
    }
    return '';
  }

  static String _joinThai(List<String> values) {
    if (values.isEmpty) return 'หลายด้าน';
    if (values.length == 1) return values.first;
    if (values.length == 2) return '${values.first}และ${values.last}';
    return '${values.sublist(0, values.length - 1).join(' ')} และ${values.last}';
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
        'ธาตุประจำตัวมีแรงหนุนค่อนข้างบาง จึงทำงานได้ดีที่สุดเมื่อมีข้อมูล ระบบ และทรัพยากรคอยรองรับ',
    'balanced':
        'ธาตุประจำตัวมีแรงหนุนระดับกลาง จึงปรับตัวได้ดี แต่ผลลัพธ์ขึ้นกับการจัดลำดับพลังในแต่ละช่วง',
    'supported':
        'ธาตุประจำตัวมีแรงหนุนสูง จึงยืนระยะและรับผิดชอบเรื่องใหญ่ได้ แต่ต้องระวังยึดวิธีของตัวเองมากเกินไป',
  };

  static const _workFamilyCopy = <String, String>{
    'resource':
        'เหมาะกับงานที่ต้องศึกษาลึก วางระบบความรู้ หรือเป็นที่พึ่งด้านข้อมูลให้ผู้อื่น',
    'peer':
        'เหมาะกับบทบาทที่มีอิสระในการตัดสินใจ ทำงานกับคนเก่ง และแบ่งอำนาจกันชัด',
    'output':
        'เหมาะกับงานที่ต้องคิด อธิบาย ออกแบบ แก้ปัญหา หรือสร้างผลงานให้คนอื่นเห็นและนำไปใช้',
    'wealth':
        'เหมาะกับงานที่เชื่อมงบ เวลา ลูกค้า และทรัพยากรให้เกิดผลทางธุรกิจจริง',
    'authority':
        'เหมาะกับงานที่ต้องตัดสินใจภายใต้ข้อจำกัด ตั้งมาตรฐาน และรับผิดชอบผลลัพธ์ที่ชัดเจน',
  };

  static const _relationshipPalaceCopy = <String, String>{
    '正印': 'เมื่อคบจริง คุณต้องการความมั่นคง ความเข้าใจ และพื้นที่พักใจจากอีกฝ่าย',
    '偏印': 'เมื่อคบจริง คุณต้องการคนที่เข้าใจวิธีคิดเฉพาะตัวและไม่บังคับให้ตอบสนองเหมือนคนทั่วไป',
    '比肩': 'เมื่อคบจริง คุณต้องการความเท่าเทียมและพื้นที่ส่วนตัว ไม่ชอบให้ฝ่ายหนึ่งควบคุมทั้งหมด',
    '劫财': 'เมื่อคบจริง ทั้งสองฝ่ายอาจเป็นคนมีจุดยืน จึงต้องตกลงเรื่องเงิน เวลา และอำนาจตัดสินใจ',
    '食神': 'เมื่อคบจริง คุณให้ความสำคัญกับความสบายใจ การดูแลกัน และการพูดคุยที่ไม่กดดัน',
    '伤官': 'เมื่อคบจริง คุณต้องการการสื่อสารตรงและอิสระ แต่ควรระวังคำพูดเร็วหรือแรงเกินเจตนา',
    '正财': 'เมื่อคบจริง คุณมองความสม่ำเสมอและการรับผิดชอบในชีวิตประจำวันเป็นหลักฐานของความรัก',
    '偏财': 'เมื่อคบจริง คุณให้ความสำคัญกับความยืดหยุ่น ประสบการณ์ร่วม และการเปิดโอกาสให้กัน',
    '正官': 'เมื่อคบจริง คุณต้องการความชัดเจน ซื่อสัตย์ และข้อตกลงที่ทั้งสองฝ่ายรักษาได้',
    '七杀': 'เมื่อคบจริง ความสัมพันธ์มักผลักให้เติบโตและตัดสินใจเร็ว จึงต้องระวังแรงกดดันหรือการคุมกันมากเกินไป',
  };

  static const _tenGodCycleCopy = <String, String>{
    '正印': 'เป็นช่วงสร้างฐานความรู้ ความมั่นคง และระบบสนับสนุนระยะยาว',
    '偏印': 'เป็นช่วงค้นคว้า เปลี่ยนมุมมอง และสร้างวิธีทำงานที่ต่างจากเดิม',
    '比肩': 'เป็นช่วงยืนด้วยตัวเอง สร้างอำนาจตัดสินใจ และทำให้ชื่อของตนชัดขึ้น',
    '劫财': 'เป็นช่วงที่ทีม หุ้นส่วน การแข่งขัน และการแบ่งผลประโยชน์มีบทบาทมาก',
    '食神': 'เป็นช่วงเปลี่ยนความรู้และประสบการณ์ให้กลายเป็นผลงานหรือรายได้ที่ทำซ้ำได้',
    '伤官': 'เป็นช่วงรื้อวิธีเดิม พูดชัดขึ้น และสร้างสิ่งใหม่จากข้อจำกัดที่เคยรับไว้',
    '正财': 'เป็นช่วงจัดระบบรายได้ ทรัพย์สิน และความรับผิดชอบให้มั่นคง',
    '偏财': 'เป็นช่วงเห็นโอกาสใหม่จากตลาด เครือข่าย หรือทรัพยากรภายนอก',
    '正官': 'เป็นช่วงรับบทบาททางการ วางมาตรฐาน และสร้างความน่าเชื่อถือระยะยาว',
    '七杀': 'เป็นช่วงที่โจทย์ยากและการแข่งขันผลักให้ตัดสินใจเร็วและเติบโตผ่านภาระจริง',
  };

  static const _tenGodAnnualCopy = <String, String>{
    '正印': 'ปีนี้เด่นเรื่องการเรียนรู้ วางฐาน และขอแรงสนับสนุนให้ถูกจุด',
    '偏印': 'ปีนี้เด่นเรื่องการทดลองแนวทางใหม่และทบทวนสิ่งที่เคยเชื่อ',
    '比肩': 'ปีนี้เด่นเรื่องการตัดสินใจด้วยตัวเองและทำตัวตนของงานให้ชัด',
    '劫财': 'ปีนี้เด่นเรื่องทีม คู่แข่ง หุ้นส่วน และข้อตกลงผลประโยชน์',
    '食神': 'ปีนี้เด่นเรื่องการสร้างผลงาน ถ่ายทอดความรู้ และทำสิ่งที่ต่อยอดได้',
    '伤官': 'ปีนี้เด่นเรื่องการเปลี่ยนระบบ พูดความจริง และแก้สิ่งที่ไม่มีประสิทธิภาพ',
    '正财': 'ปีนี้เด่นเรื่องกระแสเงินสด งานประจำ และผลลัพธ์ที่วัดได้',
    '偏财': 'ปีนี้เด่นเรื่องโอกาสทางธุรกิจ เครือข่าย และรายได้จากหลายทาง',
    '正官': 'ปีนี้เด่นเรื่องมาตรฐาน ความน่าเชื่อถือ สัญญา และบทบาทที่เป็นทางการ',
    '七杀': 'ปีนี้แรงกดดันและเส้นตายเด่น เหมาะกับการผลักงานสำคัญให้จบ แต่ไม่ควรเปิดหลายแนวรบ',
  };
}
