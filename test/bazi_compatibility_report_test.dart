import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_input_fingerprint.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_reader_v2.dart';

void main() {
  group('KnowMe BaZi Compatibility V1 report', () {
    test(
      'known-time report contains traceable facts and sourced symbolic reading',
      () {
        final report = BaziCompatibilityReportBuilder.build(
          BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
        );
        final text = report.plainText;

        expect(text, contains('คำทำนายพื้นดวงจีน · ปาจื้อ (BaZi)'));
        expect(text, contains('ภาพรวมคำอ่านพื้นดวง'));
        expect(text, contains('คำทำนายพื้นดวงแบบรายด้าน'));
        expect(text, contains('จุดแข็งที่หยิบใช้ได้'));
        expect(text, contains('การงานและบทบาท'));
        expect(text, contains('การเงินและทรัพยากร'));
        expect(text, contains('ความสัมพันธ์และการอยู่ร่วมกัน'));
        expect(text, contains('สิ่งที่ควรระวังและแนวทางพัฒนา'));
        expect(text, contains('หลักที่ใช้: Day Master'));
        expect(text, contains('丁 Ding · ไฟหยิน'));
        expect(text, contains('แสงเทียนหรือโคมไฟที่ส่องเฉพาะจุด'));
        expect(text, contains('พลังร่วมธาตุ · 比劫'));
        expect(text, contains('Companion · ไฟ 3 ช่อง'));
        expect(text, contains('พลังการจัดการทรัพยากร · 財'));
        expect(text, contains('Wealth · ทอง 3 ช่อง'));
        expect(text, contains('庚午 (geng/wu)'));
        expect(text, contains('ม้า (马 / Horse)'));
        expect(text, isNot(contains('กติกาความเข้ากันได้')));
        expect(text, contains('Li Chun (立春)'));
        expect(text, contains('Jie (節)'));
        expect(text, contains('00:00 ตามเวลาท้องถิ่น (sect=2)'));
        expect(text, isNot(contains('คุณจะ')));
        expect(text, contains('ISBN 9789675395321'));
        expect(text, contains('ISBN 9789675395918'));
        expect(text, contains('ไม่ใช้แหล่งเหล่านี้เป็นหลักฐานทางวิทยาศาสตร์'));
      },
    );

    test('Unknown time omits hour and transition-ambiguous values', () {
      final ordinary = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.unknown),
      ).plainText;
      final lichun = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.lichunUnknown),
      ).plainText;
      final jie = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.jieUnknown),
      ).plainText;

      expect(ordinary, contains('ไม่แสดงเสาชั่วโมง'));
      expect(ordinary, isNot(contains('戊申')));
      expect(lichun, isNot(contains('己巳')));
      expect(lichun, isNot(contains('庚午 (geng/wu)')));
      expect(lichun, isNot(contains('丁丑')));
      expect(lichun, isNot(contains('戊寅')));
      expect(lichun, contains('ไม่แสดงเสาปี'));
      expect(lichun, contains('ไม่แสดงเสาเดือน'));
      expect(jie, contains('ไม่แสดงเสาเดือน'));
      expect(jie, isNot(contains('戊寅')));
      expect(jie, isNot(contains('己卯')));
      expect(lichun, contains('ไม่สรุปธาตุเด่นหรือภาพรวม'));
      expect(jie, contains('ไม่สรุปธาตุเด่นหรือภาพรวม'));
      expect(lichun, isNot(contains('พลังสนับสนุน · 印')));
      expect(jie, isNot(contains('พลังสนับสนุน · 印')));
      expect(lichun, isNot(contains('คำทำนายพื้นดวงแบบรายด้าน')));
      expect(jie, isNot(contains('คำทำนายพื้นดวงแบบรายด้าน')));
    });

    test('health and finance caution is the final report content', () {
      final report = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
      );

      expect(report.sections.last.title, 'ข้อจำกัดและคำเตือน');
      expect(report.sections.last.notes.last, contains('สุขภาพ'));
      expect(report.sections.last.notes.last, contains('การเงิน'));
    });

    test('client input fingerprint matches backend canonical payload', () {
      const profile = ProfileModel(
        name: 'Test',
        gender: '',
        birthDate: '1990-05-12',
        birthTime: '15:30',
        birthPlace: '',
        latitude: 0,
        longitude: 0,
        timezone: 'Asia/Bangkok',
      );
      const unknown = ProfileModel(
        name: 'Test',
        gender: '',
        birthDate: '1990-05-12',
        birthTime: '',
        birthPlace: '',
        latitude: 0,
        longitude: 0,
        timezone: 'Asia/Bangkok',
      );

      expect(
        BaziInputFingerprint.forProfile(profile),
        '6a9fdd28dadb984f38f15ca566d5778b2e3b51b05568f798572a5813f73063c4',
      );
      expect(
        BaziInputFingerprint.forProfile(unknown),
        '96019a96d3bfb9fc7084bb6f53b8301c347f501ed2d7d977e524531ddaf28d58',
      );
    });
  });

  group('KnowMe BaZi Reader V4 interpretation', () {
    test('reads past, present, five future years, and long-term cycles', () {
      final report = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.readerV3Chart(),
        asOf: DateTime(2026, 9, 16),
      );
      final text = report.plainText;

      expect(report.title, 'คำทำนายดวงจีน · ปาจื้อ (BaZi)');
      expect(report.sections.first.title, 'ผังปาจื้อของคุณ');
      expect(text, contains('庚午 (geng/wu)'));
      expect(text, contains('辛巳 (xin/si)'));
      expect(text, contains('丁丑 (ding/chou)'));
      expect(text, contains('戊申 (wu/shen)'));
      expect(text, contains('แกนดวงของคุณคือ 丁 Ding · ไฟหยิน'));
      expect(text, isNot(contains('คำอ่านนี้ใช้สี่เสาครบ รวมเสาชั่วโมง')));
      expect(text, contains('การงาน'));
      expect(text, contains('การเงิน'));
      expect(text, contains('ความรักและความสัมพันธ์'));
      expect(text, contains('เส้นทางที่ผ่านมา · ดวงจรสิบปี'));
      expect(text, contains('壬午 · 2541–2550'));
      expect(text, contains('癸未 · 2551–2560'));
      expect(text, contains('จังหวะชีวิตปัจจุบัน · 甲申 (2561–2570)'));
      expect(text, contains('ปี 2569 · 丙午'));
      expect(text, contains('ปีนี้เด่นเรื่องทีม คู่แข่ง หุ้นส่วน'));
      expect(text, contains('แนวโน้ม 5 ปีข้างหน้า'));
      expect(text, contains('ปี 2570 · 丁未'));
      expect(text, contains('ปี 2571 · 戊申'));
      expect(text, contains('ปี 2572 · 己酉'));
      expect(text, contains('ปี 2573 · 庚戌'));
      expect(text, contains('ปี 2574 · 辛亥'));
      expect(text, contains('ภาพระยะยาว · สองดวงจรถัดไป'));
      expect(text, contains('乙酉 · 2571–2580'));
      expect(text, contains('丙戌 · 2581–2590'));
      expect(
        RegExp(
          'คำอ่านนี้เป็นแนวโน้มเพื่อช่วยวางแผน ไม่ได้หมายความว่าเหตุการณ์จะต้องเกิดขึ้น',
        ).allMatches(text),
        hasLength(1),
      );
      expect(text, isNot(contains('ข้อมูลที่ใช้คำนวณ')));
      expect(text, isNot(contains('ข้อมูลดวงที่ใช้ประกอบคำอ่าน')));
      expect(text, isNot(contains('กติกาและข้อมูลสำหรับตรวจซ้ำ')));
      expect(text, isNot(contains('ที่มาของผลคำนวณและคำอ่าน')));
      expect(text, isNot(contains('ข้อจำกัดและคำเตือน')));
      expect(text, isNot(contains(' ช่อง')));
      expect(text, isNot(contains('หลักที่ใช้: Day Master')));
      expect(
        text,
        contains(
          'แต่ละปีมีเรื่องเด่นต่างกัน ถ้าช่วงปีทับกับดวงจรสิบปี ให้อ่านรายปีเป็นเรื่องใกล้ตัว',
        ),
      );
      expect(report.sections.last.title, 'ภาพระยะยาว · สองดวงจรถัดไป');
      for (final phrase in const [
        'แบบจำลอง',
        'กรอบคำอ่าน',
        'สัญญาณรายปี',
        'สัญญาณเสียดทาน',
        'แนวทางที่ควรพิจารณา',
      ]) {
        expect(text, isNot(contains(phrase)), reason: phrase);
      }

      final readerParagraphs = <String>[
        report.subtitle,
        for (final section in report.sections) ...[
          if (section.intro != null && section.intro!.isNotEmpty)
            section.intro!,
          ...section.paragraphs,
          ...section.rows.map((row) => row.value),
        ],
      ].where((value) => value.length >= 40).toList(growable: false);
      expect(readerParagraphs.toSet(), hasLength(readerParagraphs.length));
    });

    test('central composer fixes joins and unsupported certainty', () {
      final reading = BaziReaderV2.build(
        _copyChart(
          topFamilies: const ['authority', 'output'],
          familyWeight: const {
            'resource': 0,
            'peer': 1,
            'output': 5,
            'wealth': 4,
            'authority': 6,
          },
          dayHiddenTenGod: '比肩',
          supportBand: 'lean',
        ),
        asOf: DateTime(2026, 9, 16),
      );

      expect(
        reading.overview,
        contains(
          'เรื่องที่เด่นในดวงนี้มี 2 ด้าน คือ มาตรฐาน ความรับผิดชอบ และแรงกดดัน กับความคิด การสื่อสาร และผลงาน',
        ),
      );
      expect(
        reading.overview,
        contains(
          'คุณใช้จุดเด่นนี้ได้ดีเมื่อมีข้อมูลและระบบช่วยเปลี่ยนแรงกดดันให้เป็นผลงานที่ตรวจสอบได้',
        ),
      );
      expect(
        reading.work,
        contains(
          'เรื่องงาน ดวงนี้หนุนงานที่ต้องตัดสินใจภายใต้ข้อจำกัด ตั้งมาตรฐาน และรับผิดชอบผลลัพธ์ และงานที่ต้องคิด อธิบาย ออกแบบ หรือแก้ปัญหาให้เกิดผลงานที่นำไปใช้ได้',
        ),
      );
      expect(
        reading.relationships,
        contains('ความสัมพันธ์เป็นเรื่องเด่นในดวงนี้'),
      );
      expect(
        reading.relationships,
        contains('ควรรักษาความเท่าเทียม พื้นที่ส่วนตัว'),
      );
      expect(reading.relationships, isNot(contains('เมื่อคบจริง คุณ')));
      expect(reading.relationships, isNot(contains('ความสัมพันธ์จึงมีผล')));
      expect(reading.money, isNot(contains('จุดทำเงินเด่น')));
      expect(reading.identity, isNot(contains('คุณมักตัดสินใจได้ดี')));
      expect(reading.annual, isNot(contains('สัญญาณรายปีมีสัญญาณ')));
    });

    test('current and annual clash copy is complementary, not repeated', () {
      final clash = BaziRelation(
        kind: 'branch_clash',
        roles: const ['decade', 'day'],
        symbols: const ['未', '丑'],
      );
      final base = BaziCompatibilityOwnerFixtures.readerV3Chart();
      final active = base.luck.cycles.firstWhere(
        (cycle) => cycle.startYear <= 2026 && cycle.endYear >= 2026,
      );
      final annual = BaziAnnualInfluence(
        year: 2026,
        age: 45,
        pillarLabel: '丙午',
        stem: '丙',
        branch: '午',
        stemTenGod: '七杀',
        natalRelations: [clash],
      );
      final reading = BaziReaderV2.build(
        _copyChart(
          luck: BaziLuck(
            gender: base.luck.gender,
            direction: base.luck.direction,
            onset: base.luck.onset,
            method: base.luck.method,
            cycles: [
              BaziLuckCycle(
                startYear: active.startYear,
                endYear: active.endYear,
                startAge: active.startAge,
                endAge: active.endAge,
                pillarLabel: active.pillarLabel,
                stem: active.stem,
                branch: active.branch,
                stemTenGod: active.stemTenGod,
                natalRelations: [clash],
                annual: [annual],
              ),
            ],
          ),
        ),
        asOf: DateTime(2026, 9, 16),
      );

      expect(
        reading.currentCycle,
        contains(
          'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน บทบาท หรือตารางชีวิต ควรเว้นจังหวะก่อนตัดสินใจเรื่องสำคัญ',
        ),
      );
      expect(
        reading.annual,
        'ปีนี้แรงกดดันและเส้นตายเด่น '
        'ปีนี้ย้ำว่าควรปรับระบบและเผื่อแผนสำรองจากช่วงปัจจุบัน '
        'จึงควรเลือกงานสำคัญหนึ่งเรื่องและกำหนดแผนดำเนินงานให้ชัด',
      );
      expect(
        reading.annual,
        isNot(contains('ไม่ควรตัดสินใจเพราะความกดดันชั่วคราว')),
      );
    });
  });
}

BaziChartModel _copyChart({
  List<String>? topFamilies,
  Map<String, int>? familyWeight,
  String? dayHiddenTenGod,
  String? supportBand,
  BaziLuck? luck,
}) {
  final base = BaziCompatibilityOwnerFixtures.readerV3Chart();
  final day = base.pillars.day;
  return BaziChartModel(
    version: base.version,
    contractId: base.contractId,
    contractName: base.contractName,
    engineVersion: base.engineVersion,
    generatedAt: base.generatedAt,
    inputHash: base.inputHash,
    completeness: base.completeness,
    dayMaster: base.dayMaster,
    yearAnimal: base.yearAnimal,
    dominantElement: base.dominantElement,
    pillars: BaziPillars(
      year: base.pillars.year,
      month: base.pillars.month,
      day: BaziPillar(
        stem: day.stem,
        branch: day.branch,
        stemRoman: day.stemRoman,
        branchRoman: day.branchRoman,
        stemElement: day.stemElement,
        branchElement: day.branchElement,
        pillarLabel: day.pillarLabel,
        hiddenStems: day.hiddenStems,
        stemTenGod: day.stemTenGod,
        hiddenTenGods: [
          if (dayHiddenTenGod != null)
            dayHiddenTenGod
          else
            ...day.hiddenTenGods,
        ],
        growthStage: day.growthStage,
        nayin: day.nayin,
      ),
      hour: base.pillars.hour,
    ),
    elementBalance: base.elementBalance,
    timeKnown: base.timeKnown,
    enginePolicy: base.enginePolicy,
    input: base.input,
    solarTime: base.solarTime,
    ambiguities: base.ambiguities,
    suppressedFields: base.suppressedFields,
    tenGodBalance: BaziTenGodBalance(
      visible: base.tenGodBalance.visible,
      hidden: base.tenGodBalance.hidden,
      familyWeight: familyWeight ?? base.tenGodBalance.familyWeight,
      topFamilies: topFamilies ?? base.tenGodBalance.topFamilies,
      method: base.tenGodBalance.method,
    ),
    dayMasterSupport: BaziDayMasterSupport(
      score: base.dayMasterSupport.score,
      maxScore: base.dayMasterSupport.maxScore,
      band: supportBand ?? base.dayMasterSupport.band,
      seasonScore: base.dayMasterSupport.seasonScore,
      groundScore: base.dayMasterSupport.groundScore,
      visibleSupportScore: base.dayMasterSupport.visibleSupportScore,
      resourceElement: base.dayMasterSupport.resourceElement,
      method: base.dayMasterSupport.method,
    ),
    natalRelations: base.natalRelations,
    luck: luck ?? base.luck,
  );
}
