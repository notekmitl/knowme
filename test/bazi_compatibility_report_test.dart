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
        '7e5deacba21e9abc250024b1448bcf902b6efd41f1c4f4a121be0bdcc1a0154b',
      );
      expect(
        BaziInputFingerprint.forProfile(unknown),
        '140f0798ba12b456a449d4adf44cda3d2364d9b0c90af5a68520ca12f8409e37',
      );
    });
  });
}
