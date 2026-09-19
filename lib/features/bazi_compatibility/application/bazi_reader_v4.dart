import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_reader_v2.dart';

class BaziTimelineEntry {
  const BaziTimelineEntry({required this.label, required this.reading});

  final String label;
  final String reading;
}

class BaziReaderV4Reading {
  const BaziReaderV4Reading({
    required this.natal,
    required this.pastCycles,
    required this.futureYears,
    required this.futureCycles,
  });

  final BaziReaderV2Reading natal;
  final List<BaziTimelineEntry> pastCycles;
  final List<BaziTimelineEntry> futureYears;
  final List<BaziTimelineEntry> futureCycles;
}

/// Extends the accepted Reader V3 natal copy into a readable life timeline.
///
/// Calculation facts remain owned by the Reader V3 chart contract. V4 only
/// selects already-calculated Da Yun and Liu Nian facts and translates them
/// into calibrated Thai: recent past, present, the next five years, and the
/// next two decade cycles. It never invents an event or fills missing timing.
abstract final class BaziReaderV4 {
  static const interpretationContractId = 'knowme_bazi_reader_th_v4';

  static BaziReaderV4Reading build(BaziChartModel chart, {DateTime? asOf}) {
    final date = asOf ?? DateTime.now();
    final natal = BaziReaderV2.build(chart, asOf: date);
    final cycles = [...chart.luck.cycles]
      ..sort((left, right) => left.startYear.compareTo(right.startYear));
    final current = _currentCycle(cycles, date.year);

    if (current == null) {
      return BaziReaderV4Reading(
        natal: natal,
        pastCycles: const [],
        futureYears: const [],
        futureCycles: const [],
      );
    }

    final completed = cycles
        .where((cycle) => cycle.endYear < date.year)
        .toList(growable: false);
    final recentPast = completed.length <= 3
        ? completed
        : completed.sublist(completed.length - 3);

    final annual =
        cycles
            .expand((cycle) => cycle.annual)
            .where((year) => year.year > date.year)
            .toList(growable: false)
          ..sort((left, right) => left.year.compareTo(right.year));

    final laterCycles = cycles
        .where((cycle) => cycle.startYear > current.endYear)
        .take(2)
        .toList(growable: false);

    return BaziReaderV4Reading(
      natal: natal,
      pastCycles: [
        for (final cycle in recentPast)
          BaziTimelineEntry(
            label: _cycleLabel(cycle),
            reading: _cycleReading(cycle, past: true),
          ),
      ],
      futureYears: [
        for (final year in annual.take(5))
          BaziTimelineEntry(
            label: 'ปี ${year.year + 543} · ${year.pillarLabel}',
            reading: _annualReading(year),
          ),
      ],
      futureCycles: [
        for (final cycle in laterCycles)
          BaziTimelineEntry(
            label: _cycleLabel(cycle),
            reading: _cycleReading(cycle, past: false),
          ),
      ],
    );
  }

  static BaziLuckCycle? _currentCycle(List<BaziLuckCycle> cycles, int year) {
    for (final cycle in cycles) {
      if (year >= cycle.startYear && year <= cycle.endYear) return cycle;
    }
    return null;
  }

  static String _cycleLabel(BaziLuckCycle cycle) =>
      '${cycle.pillarLabel} · ${cycle.startYear + 543}–${cycle.endYear + 543} '
      '(อายุจีน ${cycle.startAge}–${cycle.endAge})';

  static String _cycleReading(BaziLuckCycle cycle, {required bool past}) {
    final theme =
        _cycleThemes[cycle.stemTenGod] ??
        'เป็นรอบที่เน้นการจัดลำดับเรื่องสำคัญและนำประสบการณ์มาใช้ให้เกิดผล';
    final relation = _relationReading(cycle.natalRelations);
    final close = past
        ? 'จุดสำคัญของรอบนี้คือสิ่งที่ได้เรียนรู้และวิธีรับมือที่ยังนำมาใช้ได้ในปัจจุบัน'
        : _cycleActions[cycle.stemTenGod] ??
              'ควรวางเป้าหมายระยะยาวให้ชัด แล้วแบ่งเป็นช่วงที่ตรวจผลได้';
    return '$theme${relation.isEmpty ? '' : ' $relation'} $close';
  }

  static String _annualReading(BaziAnnualInfluence annual) {
    final theme =
        _annualThemes[annual.stemTenGod] ??
        'เป็นปีที่ควรเลือกเป้าหมายหลักให้ชัดและเดินตามลำดับ';
    final relation = _relationReading(annual.natalRelations);
    final action =
        _annualActions[annual.stemTenGod] ??
        'เหมาะกับการตั้งผลลัพธ์ที่วัดได้และทบทวนแผนเป็นระยะ';
    return '$theme${relation.isEmpty ? '' : ' $relation'} $action';
  }

  static String _relationReading(List<BaziRelation> relations) {
    final clash = relations.any((item) => item.kind.contains('clash'));
    final friction = relations.any(
      (item) =>
          item.kind.contains('harm') ||
          item.kind.contains('break') ||
          item.kind.contains('punishment'),
    );
    final combine = relations.any(
      (item) => item.kind.contains('combine') || item.kind.contains('harmony'),
    );
    if (clash && combine) {
      return 'มีทั้งแรงเปลี่ยนและแรงร่วมมือ จึงควรเปิดทางเลือกใหม่โดยตกลงบทบาทและขอบเขตให้ชัด';
    }
    if (clash) {
      return 'มีแรงเปลี่ยนเด่น เรื่องงาน บทบาท หรือตารางชีวิตอาจต้องจัดใหม่ จึงไม่ควรตัดสินใจเพราะแรงกดดันชั่วคราว';
    }
    if (friction) {
      return 'มีแรงเสียดทานแฝง ควรตรวจข้อตกลง เวลา และภาระที่รับไว้ให้ละเอียดกว่าปกติ';
    }
    if (combine) {
      return 'มีแรงผสานเด่น เหมาะกับการรวมคน ความรู้ หรือทรัพยากรเพื่อทำเรื่องเดิมให้เกิดผลมากขึ้น';
    }
    return '';
  }

  static const _cycleThemes = <String, String>{
    '正印': 'เป็นรอบสร้างฐานความรู้ ความมั่นคง และระบบสนับสนุนระยะยาว',
    '偏印': 'เป็นรอบค้นคว้า เปลี่ยนมุมมอง และสร้างวิธีทำงานที่ต่างจากเดิม',
    '比肩': 'เป็นรอบยืนด้วยตัวเอง สร้างอำนาจตัดสินใจ และทำให้ตัวตนชัดขึ้น',
    '劫财': 'เป็นรอบที่ทีม หุ้นส่วน การแข่งขัน และการแบ่งผลประโยชน์มีบทบาทมาก',
    '食神': 'เป็นรอบเปลี่ยนความรู้และประสบการณ์ให้เป็นผลงานหรือรายได้ที่ทำซ้ำได้',
    '伤官': 'เป็นรอบรื้อวิธีเดิม พูดชัดขึ้น และสร้างสิ่งใหม่จากข้อจำกัด',
    '正财': 'เป็นรอบจัดระบบรายได้ ทรัพย์สิน และความรับผิดชอบให้มั่นคง',
    '偏财': 'เป็นรอบมองหาโอกาสใหม่จากตลาด เครือข่าย หรือทรัพยากรภายนอก',
    '正官': 'เป็นรอบรับบทบาททางการ วางมาตรฐาน และสร้างความน่าเชื่อถือระยะยาว',
    '七杀': 'เป็นรอบที่โจทย์ยากและการแข่งขันผลักให้เติบโตผ่านภาระจริง',
  };

  static const _cycleActions = <String, String>{
    '正印': 'ควรลงทุนกับความรู้ ระบบ และคนที่ช่วยให้ฐานแข็งแรงก่อนขยายงาน',
    '偏印': 'ควรทดลองแบบเล็กก่อน แล้วเก็บเฉพาะวิธีที่พิสูจน์ผลได้',
    '比肩': 'ควรสร้างผลงานในชื่อของตน พร้อมแบ่งขอบเขตกับผู้ร่วมงานให้ชัด',
    '劫财': 'ควรเขียนข้อตกลงเรื่องเงิน บทบาท และผลประโยชน์ก่อนเริ่มร่วมมือ',
    '食神': 'ควรทำความรู้หรือผลงานให้เป็นระบบที่ส่งต่อและสร้างผลซ้ำได้',
    '伤官': 'ควรใช้การเปลี่ยนแปลงแก้คอขวดหลัก โดยไม่เปิดหลายแนวรบพร้อมกัน',
    '正财': 'ควรวางกระแสเงินสดและทรัพย์สินให้มั่นคงก่อนรับภาระระยะยาวเพิ่ม',
    '偏财': 'ควรคัดโอกาสจากผลตอบแทนและภาระดูแลจริง ไม่ตัดสินจากความตื่นเต้น',
    '正官': 'ควรสร้างมาตรฐาน เอกสาร และความน่าเชื่อถือที่ใช้ต่อรองได้ในระยะยาว',
    '七杀': 'ควรเลือกโจทย์ยากที่คุ้มกับพลัง และกำหนดเส้นแบ่งไม่ให้ภาระล้นชีวิต',
  };

  static const _annualThemes = <String, String>{
    '正印': 'เด่นเรื่องการเรียนรู้ วางฐาน และขอแรงสนับสนุนให้ถูกจุด',
    '偏印': 'เด่นเรื่องการทดลองแนวทางใหม่และทบทวนสิ่งที่เคยเชื่อ',
    '比肩': 'เด่นเรื่องการตัดสินใจด้วยตัวเองและทำตัวตนของงานให้ชัด',
    '劫财': 'เด่นเรื่องทีม คู่แข่ง หุ้นส่วน และข้อตกลงผลประโยชน์',
    '食神': 'เด่นเรื่องการสร้างผลงาน ถ่ายทอดความรู้ และทำสิ่งที่ต่อยอดได้',
    '伤官': 'เด่นเรื่องการเปลี่ยนระบบ พูดความจริง และแก้สิ่งที่ไม่มีประสิทธิภาพ',
    '正财': 'เด่นเรื่องกระแสเงินสด งานประจำ และผลลัพธ์ที่วัดได้',
    '偏财': 'เด่นเรื่องโอกาสทางธุรกิจ เครือข่าย และรายได้จากหลายทาง',
    '正官': 'เด่นเรื่องมาตรฐาน ความน่าเชื่อถือ สัญญา และบทบาทที่เป็นทางการ',
    '七杀': 'เด่นเรื่องแรงกดดัน เส้นตาย และการผลักงานสำคัญให้จบ',
  };

  static const _annualActions = <String, String>{
    '正印': 'เหมาะกับการเพิ่มทักษะ วางระบบ และเตรียมทรัพยากรให้พร้อม',
    '偏印': 'เหมาะกับการทดลองทางเลือกใหม่ แต่ควรกำหนดเกณฑ์หยุดให้ชัด',
    '比肩': 'เหมาะกับการตัดสินใจเรื่องที่เป็นเจ้าของเองและสร้างผลงานในชื่อของตน',
    '劫财': 'เหมาะกับการทบทวนคู่ค้า ทีม และข้อตกลงก่อนผูกภาระเพิ่ม',
    '食神': 'เหมาะกับการทำผลงานให้เสร็จ เผยแพร่ และต่อยอดเป็นรายได้',
    '伤官': 'เหมาะกับการแก้ระบบที่ติดขัด โดยใช้ข้อมูลแทนอารมณ์ในการเจรจา',
    '正财': 'เหมาะกับการเก็บกำไร จัดงบ และทำรายได้หลักให้สม่ำเสมอ',
    '偏财': 'เหมาะกับการเปิดตลาดหรือเครือข่ายใหม่ภายใต้วงเงินที่กำหนดไว้',
    '正官': 'เหมาะกับการรับบทบาทที่ชัด ทำสัญญา และสร้างมาตรฐานที่คนเชื่อถือ',
    '七杀': 'เหมาะกับการเลือกงานใหญ่หนึ่งเรื่องและกันเวลาฟื้นตัวไว้ล่วงหน้า',
  };
}
