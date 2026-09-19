import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_input_fingerprint.dart';

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
      expect(text, isNot(contains('จะเกิด')));
      expect(text, contains('ข้อมูลที่ใช้คำนวณ'));
      expect(text, isNot(contains('ข้อมูลดวงที่ใช้ประกอบคำอ่าน')));
      expect(text, isNot(contains('กติกาและข้อมูลสำหรับตรวจซ้ำ')));
      expect(text, isNot(contains('ที่มาของผลคำนวณและคำอ่าน')));
      expect(text, isNot(contains('ข้อจำกัดและคำเตือน')));
      expect(text, isNot(contains(' ช่อง')));
      expect(text, isNot(contains('หลักที่ใช้: Day Master')));
      expect(report.sections.last.title, 'ข้อมูลที่ใช้คำนวณ');
    });
  });
}
