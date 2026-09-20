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
        'กรอบคำอ่านของรอบนี้เน้นการจัดลำดับเรื่องสำคัญและใช้ประสบการณ์ประกอบการตัดสินใจ';
    final relation = _relationReading(cycle.natalRelations);
    final parts = <String>[theme, if (relation.isNotEmpty) relation];
    if (!past) {
      parts.add(
        _cycleActions[cycle.stemTenGod] ??
            'ควรวางเป้าหมายระยะยาวให้ชัด แล้วแบ่งเป็นช่วงที่ตรวจผลได้',
      );
    }
    return parts.join(' ');
  }

  static String _annualReading(BaziAnnualInfluence annual) {
    final theme =
        _annualThemes[annual.stemTenGod] ??
        'เป็นปีที่ควรเลือกเป้าหมายหลักให้ชัดและเดินตามลำดับ';
    final relation = _relationReading(annual.natalRelations);
    final action =
        _annualActions[annual.stemTenGod] ??
        'แนวทางที่ควรพิจารณาคือตั้งผลลัพธ์ที่วัดได้และทบทวนแผนเป็นระยะ';
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
      return 'มีสัญญาณทั้งการเปลี่ยนและการประสาน จึงควรเปิดทางเลือกโดยตกลงบทบาทและขอบเขตให้ชัด';
    }
    if (clash) {
      return 'สัญญาณปะทะชี้ให้ทบทวนงาน บทบาท หรือตารางชีวิต และเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ';
    }
    if (friction) {
      return 'สัญญาณเสียดทานชี้ให้ตรวจข้อตกลง เวลา และภาระที่รับไว้ให้ละเอียดกว่าปกติ';
    }
    if (combine) {
      return 'สัญญาณผสานชี้ให้พิจารณาการรวมคน ความรู้ หรือทรัพยากรเพื่อพัฒนาสิ่งที่ทำอยู่';
    }
    return '';
  }

  static const _cycleThemes = <String, String>{
    '正印':
        'กรอบคำอ่านของรอบนี้เน้นการสร้างฐานความรู้ ความมั่นคง และระบบสนับสนุนระยะยาว',
    '偏印':
        'กรอบคำอ่านของรอบนี้เน้นการค้นคว้า เปลี่ยนมุมมอง และทดลองวิธีทำงานที่ต่างจากเดิม',
    '比肩':
        'กรอบคำอ่านของรอบนี้เน้นการยืนด้วยตัวเอง อำนาจตัดสินใจ และผลงานในชื่อของตน',
    '劫财': 'กรอบคำอ่านของรอบนี้เน้นทีม หุ้นส่วน การแข่งขัน และการแบ่งผลประโยชน์',
    '食神':
        'กรอบคำอ่านของรอบนี้เน้นการเปลี่ยนความรู้และประสบการณ์ให้เป็นผลงานที่ทำซ้ำได้',
    '伤官':
        'กรอบคำอ่านของรอบนี้เน้นการทบทวนวิธีเดิม สื่อสารให้ชัด และแก้ข้อจำกัดหลัก',
    '正财': 'กรอบคำอ่านของรอบนี้เน้นการจัดระบบรายได้ ทรัพย์สิน และความรับผิดชอบ',
    '偏财':
        'กรอบคำอ่านของรอบนี้เน้นการประเมินโอกาสจากตลาด เครือข่าย หรือทรัพยากรภายนอก',
    '正官':
        'กรอบคำอ่านของรอบนี้เน้นบทบาททางการ มาตรฐาน และความน่าเชื่อถือระยะยาว',
    '七杀': 'กรอบคำอ่านของรอบนี้เน้นโจทย์ยาก การแข่งขัน และภาระที่ต้องจัดลำดับ',
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
    '正印': 'สัญญาณรายปีเน้นการเรียนรู้ วางฐาน และขอแรงสนับสนุนให้ถูกจุด',
    '偏印': 'สัญญาณรายปีเน้นการทดลองแนวทางใหม่และทบทวนสิ่งที่เคยเชื่อ',
    '比肩': 'สัญญาณรายปีเน้นการตัดสินใจด้วยตัวเองและทำขอบเขตของงานให้ชัด',
    '劫财': 'สัญญาณรายปีเน้นทีม คู่แข่ง หุ้นส่วน และข้อตกลงผลประโยชน์',
    '食神': 'สัญญาณรายปีเน้นการสร้างผลงาน ถ่ายทอดความรู้ และทำสิ่งที่ต่อยอดได้',
    '伤官':
        'สัญญาณรายปีเน้นการเปลี่ยนระบบ สื่อสารให้ชัด และแก้สิ่งที่ไม่มีประสิทธิภาพ',
    '正财': 'สัญญาณรายปีเน้นกระแสเงินสด งานประจำ และผลลัพธ์ที่วัดได้',
    '偏财': 'สัญญาณรายปีเน้นการประเมินโอกาสทางธุรกิจ เครือข่าย และรายได้หลายทาง',
    '正官': 'สัญญาณรายปีเน้นมาตรฐาน ความน่าเชื่อถือ สัญญา และบทบาทที่เป็นทางการ',
    '七杀': 'สัญญาณรายปีเน้นแรงกดดัน เส้นตาย และงานสำคัญที่ต้องจัดลำดับ',
  };

  static const _annualActions = <String, String>{
    '正印': 'แนวทางที่ควรพิจารณาคือเพิ่มทักษะ วางระบบ และเตรียมทรัพยากรให้พร้อม',
    '偏印': 'แนวทางที่ควรพิจารณาคือทดลองทางเลือกใหม่ พร้อมกำหนดเกณฑ์หยุดให้ชัด',
    '比肩':
        'แนวทางที่ควรพิจารณาคือเลือกเรื่องที่เป็นเจ้าของเองและกำหนดผลลัพธ์ให้ชัด',
    '劫财': 'แนวทางที่ควรพิจารณาคือทบทวนคู่ค้า ทีม และข้อตกลงก่อนผูกภาระเพิ่ม',
    '食神':
        'แนวทางที่ควรพิจารณาคือทำผลงานให้เสร็จ ทดสอบการใช้ และค่อยวางแผนต่อยอด',
    '伤官':
        'แนวทางที่ควรพิจารณาคือแก้ระบบที่ติดขัด โดยใช้ข้อมูลแทนอารมณ์ในการเจรจา',
    '正财':
        'แนวทางที่ควรพิจารณาคือจัดงบ กระแสเงินสด และตัวชี้วัดของรายได้หลักให้ชัด',
    '偏财': 'หากเปิดตลาดหรือเครือข่ายใหม่ ควรกำหนดวงเงินและจุดหยุดไว้ล่วงหน้า',
    '正官': 'แนวทางที่ควรพิจารณาคือกำหนดบทบาท ข้อตกลง และมาตรฐานที่ตรวจสอบได้',
    '七杀':
        'แนวทางที่ควรพิจารณาคือเลือกงานสำคัญหนึ่งเรื่องและกันเวลาฟื้นตัวไว้ล่วงหน้า',
  };
}
