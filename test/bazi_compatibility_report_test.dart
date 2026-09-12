import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_input_fingerprint.dart';

void main() {
  group('KnowMe BaZi Compatibility V1 report', () {
    test(
      'known-time report contains traceable facts without personality copy',
      () {
        final report = BaziCompatibilityReportBuilder.build(
          BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
        );
        final text = report.plainText;

        expect(text, contains('KnowMe BaZi Compatibility V1'));
        expect(text, contains('ไม่ใช่มาตรฐานสากล'));
        expect(text, contains('庚午 (geng/wu)'));
        expect(text, contains('Li Chun (立春)'));
        expect(text, contains('Jie (節)'));
        expect(text, contains('00:00 ตามเวลาท้องถิ่น (sect=2)'));
        expect(text, isNot(contains('บุคลิกของคุณ')));
        expect(text, isNot(contains('จุดแข็งของคุณ')));
        expect(text, isNot(contains('คุณจะ')));
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
