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
      pastCycles: _cycleEntries(recentPast, past: true),
      futureYears: _annualEntries(annual.take(5)),
      futureCycles: _cycleEntries(laterCycles, past: false),
    );
  }

  static List<BaziTimelineEntry> _cycleEntries(
    Iterable<BaziLuckCycle> cycles, {
    required bool past,
  }) {
    final seenRelations = <String>{};
    final seenThemes = <String>{};
    return [
      for (final cycle in cycles)
        BaziTimelineEntry(
          label: _cycleLabel(cycle),
          reading: _cycleReading(
            cycle,
            past: past,
            includeRelation: _includeRelationOnce(
              seenRelations,
              cycle.natalRelations,
            ),
            repeatedTheme: !seenThemes.add(cycle.stemTenGod),
          ),
        ),
    ];
  }

  static List<BaziTimelineEntry> _annualEntries(
    Iterable<BaziAnnualInfluence> annual,
  ) {
    final seenRelations = <String>{};
    final seenThemes = <String>{};
    return [
      for (final year in annual)
        BaziTimelineEntry(
          label: 'ปี ${year.year + 543} · ${year.pillarLabel}',
          reading: _annualReading(
            year,
            includeRelation: _includeRelationOnce(
              seenRelations,
              year.natalRelations,
            ),
            repeatedTheme: !seenThemes.add(year.stemTenGod),
          ),
        ),
    ];
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

  static String _cycleReading(
    BaziLuckCycle cycle, {
    required bool past,
    required bool includeRelation,
    required bool repeatedTheme,
  }) {
    final rawTheme = repeatedTheme
        ? _repeatedTheme(cycle.stemTenGod, past: past)
        : _cycleThemes[cycle.stemTenGod] ??
              'ช่วงนี้คุณต้องจัดลำดับเรื่องสำคัญ และใช้ประสบการณ์ช่วยตัดสินใจ';
    final theme = repeatedTheme
        ? rawTheme
        : rawTheme.replaceFirst('ช่วงนี้', past ? 'ช่วงนั้น' : 'ช่วงต่อไปนี้');
    final relation = includeRelation
        ? _relationReading(
            cycle.natalRelations,
            context: past
                ? _RelationContext.pastCycle
                : _RelationContext.futureCycle,
          )
        : '';
    final parts = <String>[theme, if (relation.isNotEmpty) relation];
    if (!past && !repeatedTheme) {
      parts.add(
        _cycleActions[cycle.stemTenGod] ??
            'ควรวางเป้าหมายระยะยาวให้ชัด แล้วแบ่งเป็นช่วงที่ตรวจผลได้',
      );
    }
    return parts.join(' ');
  }

  static String _annualReading(
    BaziAnnualInfluence annual, {
    required bool includeRelation,
    required bool repeatedTheme,
  }) {
    final theme = repeatedTheme
        ? _repeatedAnnualTheme(annual.stemTenGod)
        : _annualThemes[annual.stemTenGod] ??
              'ปีนี้ควรเลือกเป้าหมายหลักให้ชัดและเดินตามลำดับ';
    final relation = includeRelation
        ? _relationReading(
            annual.natalRelations,
            context: _RelationContext.annual,
          )
        : '';
    final action = repeatedTheme
        ? ''
        : _annualActions[annual.stemTenGod] ??
              'ควรตั้งเป้าหมายที่วัดผลได้และทบทวนแผนเป็นระยะ';
    return '$theme${relation.isEmpty ? '' : ' $relation'}'
        '${action.isEmpty ? '' : ' $action'}';
  }

  static bool _includeRelationOnce(
    Set<String> seen,
    List<BaziRelation> relations,
  ) {
    final key = _relationKey(relations);
    return key.isEmpty || seen.add(key);
  }

  static String _relationKey(List<BaziRelation> relations) {
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
    if (clash && combine) return 'clash-combine';
    if (clash) return 'clash';
    if (friction) return 'friction';
    if (combine) return 'combine';
    return '';
  }

  static String _relationReading(
    List<BaziRelation> relations, {
    required _RelationContext context,
  }) {
    final key = _relationKey(relations);
    return switch ((key, context)) {
      ('clash-combine', _RelationContext.pastCycle) =>
        'มีทั้งเรื่องที่ต้องเปลี่ยนและเรื่องที่ต้องร่วมมือ การตกลงบทบาทและขอบเขตให้ชัดช่วยลดความสับสนได้',
      ('clash-combine', _RelationContext.annual) =>
        'มีทั้งเรื่องที่ต้องเปลี่ยนและเรื่องที่ต้องร่วมมือ ควรเปิดทางเลือกไว้ พร้อมตกลงบทบาทและขอบเขตให้ชัด',
      ('clash-combine', _RelationContext.futureCycle) =>
        'ในช่วงยาวนี้มีทั้งเรื่องที่ต้องเปลี่ยนและเรื่องที่ต้องร่วมมือ ควรเปิดทางเลือกไว้ พร้อมตกลงบทบาทและขอบเขตให้ชัด',
      ('clash', _RelationContext.pastCycle) =>
        'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต การเว้นจังหวะก่อนตัดสินใจช่วยให้เห็นทางเลือกชัดขึ้น',
      ('clash', _RelationContext.annual) =>
        'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต ควรเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
      ('clash', _RelationContext.futureCycle) =>
        'ในช่วงยาวนี้แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต ควรเผื่อทางเลือกก่อนตัดสินใจเรื่องสำคัญ',
      ('friction', _RelationContext.pastCycle) =>
        'เรื่องเวลา หน้าที่ และข้อตกลงต้องชัด เพราะความเข้าใจไม่ตรงกันอาจกลายเป็นภาระตามมา',
      ('friction', _RelationContext.annual) =>
        'ต้องคุยเรื่องเวลา หน้าที่ และข้อตกลงให้ชัด เพราะความเข้าใจไม่ตรงกันอาจกลายเป็นภาระตามมา',
      ('friction', _RelationContext.futureCycle) =>
        'ในช่วงยาวนี้ต้องคุยเรื่องเวลา หน้าที่ และข้อตกลงให้ชัด เพื่อไม่ให้ความเข้าใจต่างกันกลายเป็นภาระ',
      ('combine', _RelationContext.pastCycle) =>
        'การรวมคน ความรู้ หรือทรัพยากรช่วยให้สิ่งที่ทำอยู่เดินต่อได้ดีขึ้น',
      ('combine', _RelationContext.annual) =>
        'เหมาะกับการรวมคน ความรู้ หรือทรัพยากร เพื่อพัฒนาสิ่งที่ทำอยู่ให้เดินต่อได้ดีขึ้น',
      ('combine', _RelationContext.futureCycle) =>
        'ในช่วงยาวนี้เหมาะกับการรวมคน ความรู้ หรือทรัพยากร เพื่อพัฒนาสิ่งที่ทำอยู่ให้มั่นคงขึ้น',
      _ => '',
    };
  }

  static String _repeatedTheme(String tenGod, {required bool past}) {
    final topic = _tenGodTopics[tenGod] ?? 'การจัดลำดับเรื่องสำคัญ';
    return past
        ? 'ช่วงนั้นเรื่อง$topicกลับมาเด่นอีกครั้ง ลองดูว่าคุณรับมือได้ต่างจากรอบก่อนอย่างไร'
        : 'ช่วงนี้เรื่อง$topicกลับมาเด่นอีกครั้ง ควรทบทวนเป้าหมายก่อนใช้วิธีเดิม';
  }

  static String _repeatedAnnualTheme(String tenGod) {
    final topic = _tenGodTopics[tenGod] ?? 'การจัดลำดับเรื่องสำคัญ';
    return 'ปีนี้เรื่อง$topicกลับมาเด่นอีกครั้ง ควรนำบทเรียนจากรอบก่อนมาปรับใช้กับสถานการณ์ปัจจุบัน';
  }

  static const _tenGodTopics = <String, String>{
    '正印': 'การเรียนรู้และวางรากฐาน',
    '偏印': 'การลองวิธีใหม่และเปลี่ยนมุมมอง',
    '比肩': 'การตัดสินใจด้วยตัวเอง',
    '劫财': 'ทีม หุ้นส่วน และการแข่งขัน',
    '食神': 'การสร้างผลงานและถ่ายทอดความรู้',
    '伤官': 'การปรับวิธีเดิมและแก้จุดติดขัด',
    '正财': 'รายได้ ทรัพย์สิน และความรับผิดชอบ',
    '偏财': 'โอกาสจากตลาดและเครือข่าย',
    '正官': 'มาตรฐานและความน่าเชื่อถือ',
    '七杀': 'โจทย์ยาก แรงกดดัน และเส้นตาย',
  };

  static const _cycleThemes = <String, String>{
    '正印':
        'ช่วงนี้เหมาะกับการเรียนรู้และวางรากฐาน สิ่งที่เตรียมไว้ดีจะช่วยให้คุณเดินต่อได้มั่นคงขึ้น',
    '偏印':
        'ช่วงนี้คุณมีโอกาสได้ลองวิธีใหม่ ๆ และมองเรื่องเดิมต่างออกไป สิ่งที่ได้เรียนรู้ในช่วงนี้จะช่วยให้ตัดสินใจได้รอบคอบขึ้น',
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
    '正印':
        'ปีนี้เด่นเรื่องการเรียนรู้และวางรากฐาน การขอความช่วยเหลือให้ถูกจุดจะช่วยให้เดินต่อได้คล่องขึ้น',
    '偏印': 'ปีนี้เหมาะกับการลองทางใหม่และทบทวนสิ่งที่เคยเชื่อ',
    '比肩': 'ปีนี้คุณต้องตัดสินใจด้วยตัวเองมากขึ้น และทำขอบเขตของงานให้ชัด',
    '劫财': 'ปีนี้เรื่องทีม คู่แข่ง หุ้นส่วน และข้อตกลงผลประโยชน์เด่นขึ้น',
    '食神': 'ปีนี้เหมาะกับการสร้างผลงาน ถ่ายทอดความรู้ และทำสิ่งที่ต่อยอดได้',
    '伤官':
        'ปีนี้คุณเห็นสิ่งที่ควรเปลี่ยนชัดขึ้น ควรสื่อสารเหตุผลและแก้จุดที่ทำให้งานติดขัด',
    '正财': 'ปีนี้เรื่องกระแสเงินสด งานประจำ และผลลัพธ์ที่วัดได้สำคัญขึ้น',
    '偏财':
        'ปีนี้มีโอกาสจากธุรกิจ เครือข่าย หรือรายได้หลายทาง แต่ต้องคัดให้รอบคอบ',
    '正官': 'ปีนี้เรื่องมาตรฐาน ความน่าเชื่อถือ สัญญา และบทบาททางการเด่นขึ้น',
    '七杀': 'ปีนี้มีแรงกดดันและเส้นตายมากขึ้น คุณต้องจัดลำดับงานสำคัญก่อน',
  };

  static const _annualActions = <String, String>{
    '正印': 'ควรเพิ่มทักษะ วางระบบ และเตรียมทรัพยากรให้พร้อม',
    '偏印': 'ควรลองทางเลือกใหม่ในขอบเขตเล็ก ๆ และกำหนดจุดหยุดไว้ก่อน',
    '比肩': 'ควรเลือกเรื่องที่คุณเป็นเจ้าของเอง และกำหนดผลลัพธ์ให้ชัด',
    '劫财': 'ควรทบทวนคู่ค้า ทีม และข้อตกลงก่อนรับภาระเพิ่ม',
    '食神': 'ควรทำผลงานให้เสร็จ ทดลองใช้ แล้วค่อยวางแผนต่อยอด',
    '伤官': 'ควรแก้ระบบที่ติดขัด และใช้ข้อมูลแทนอารมณ์เวลาเจรจา',
    '正财': 'ควรจัดงบ กระแสเงินสด และเป้าหมายของรายได้หลักให้ชัด',
    '偏财': 'หากเปิดตลาดหรือเครือข่ายใหม่ ควรกำหนดวงเงินและจุดหยุดไว้ล่วงหน้า',
    '正官': 'ควรกำหนดบทบาท ข้อตกลง และมาตรฐานที่ตรวจสอบได้',
    '七杀': 'ควรเลือกงานสำคัญหนึ่งเรื่อง และกันเวลาพักไว้ล่วงหน้า',
  };
}

enum _RelationContext { pastCycle, annual, futureCycle }
