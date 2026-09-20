import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_assets.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_exporter.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'PDF export builds known and fail-closed Unknown reports offline',
    () async {
      final fonts = await BaziCompatibilityPdfAssets.load();
      expect(fonts.cjkRegular.length, greaterThan(100000));

      for (final ownerCase in BaziOwnerCase.values) {
        final report = BaziCompatibilityReportBuilder.build(
          BaziCompatibilityOwnerFixtures.chart(ownerCase),
        );
        final bytes = await BaziCompatibilityPdfExporter.build(
          report: report,
          fonts: fonts,
        );

        expect(bytes.length, greaterThan(1000), reason: ownerCase.id);
        expect(
          String.fromCharCodes(bytes.take(5)),
          '%PDF-',
          reason: ownerCase.id,
        );
        final outputPath = Platform.environment['BAZI_OWNER_PDF_OUTPUT'];
        if (ownerCase == BaziOwnerCase.known && outputPath != null) {
          final output = File(outputPath);
          output.parent.createSync(recursive: true);
          output.writeAsBytesSync(bytes, flush: true);
        }
        final outputDirectory =
            Platform.environment['BAZI_OWNER_PDF_DIRECTORY'];
        if (outputDirectory != null) {
          final output = File(
            '$outputDirectory/knowme-bazi-${ownerCase.id}.pdf',
          );
          output.parent.createSync(recursive: true);
          output.writeAsBytesSync(bytes, flush: true);
        }
        if (ownerCase != BaziOwnerCase.known) {
          expect(report.plainText, isNot(contains('戊申')), reason: ownerCase.id);
        }
      }

      final readerV4Report = BaziCompatibilityReportBuilder.build(
        BaziCompatibilityOwnerFixtures.readerV3Chart(),
        asOf: DateTime(2026, 9, 16),
      );
      final readerV4Bytes = await BaziCompatibilityPdfExporter.build(
        report: readerV4Report,
        fonts: fonts,
      );
      expect(readerV4Bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(readerV4Bytes.take(5)), '%PDF-');
      expect(
        readerV4Report.plainText,
        isNot(contains('คำอ่านนี้ใช้สี่เสาครบ รวมเสาชั่วโมง')),
      );
      expect(readerV4Report.plainText, contains('แนวโน้ม 5 ปีข้างหน้า'));
      expect(readerV4Report.plainText, contains('ภาพระยะยาว · สองดวงจรถัดไป'));
      expect(readerV4Report.plainText, isNot(contains('ข้อมูลที่ใช้คำนวณ')));
      for (final hiddenTitle in const [
        'ข้อมูลดวงที่ใช้ประกอบคำอ่าน',
        'กติกาและข้อมูลสำหรับตรวจซ้ำ',
        'ที่มาของผลคำนวณและคำอ่าน',
        'ข้อจำกัดและคำเตือน',
      ]) {
        expect(readerV4Report.plainText, isNot(contains(hiddenTitle)));
      }

      final outputDirectory = Platform.environment['BAZI_OWNER_PDF_DIRECTORY'];
      if (outputDirectory != null) {
        final output = File('$outputDirectory/knowme-bazi-reader-v4.pdf');
        output.parent.createSync(recursive: true);
        output.writeAsBytesSync(readerV4Bytes, flush: true);
      }

      final qaChartDirectory =
          Platform.environment['BAZI_READER_V4_QA_CHART_DIRECTORY'];
      if (qaChartDirectory != null && outputDirectory != null) {
        for (final caseId in const [
          'owner-chiang-mai-0003',
          'bangkok',
          'chiang-mai',
          'phuket',
        ]) {
          final map =
              jsonDecode(
                    File('$qaChartDirectory/$caseId.json').readAsStringSync(),
                  )
                  as Map<String, dynamic>;
          final report = BaziCompatibilityReportBuilder.build(
            BaziChartModel.fromMap(map),
            asOf: DateTime(2026, 9, 20),
          );
          final bytes = await BaziCompatibilityPdfExporter.build(
            report: report,
            fonts: fonts,
          );

          expect(bytes.length, greaterThan(1000), reason: caseId);
          expect(report.plainText, isNot(contains('ข้อมูลที่ใช้คำนวณ')));
          for (final phrase in const [
            'แบบจำลอง',
            'กรอบคำอ่าน',
            'สัญญาณรายปี',
            'สัญญาณเสียดทาน',
            'แนวทางที่ควรพิจารณา',
          ]) {
            expect(report.plainText, isNot(contains(phrase)), reason: caseId);
          }
          expect(
            RegExp(
              'คำอ่านนี้เป็นแนวโน้มเพื่อช่วยวางแผน ไม่ได้หมายความว่าเหตุการณ์จะต้องเกิดขึ้น',
            ).allMatches(report.plainText),
            hasLength(1),
            reason: caseId,
          );

          final paragraphs = <String>[
            report.subtitle,
            for (final section in report.sections) ...[
              if (section.intro != null && section.intro!.isNotEmpty)
                section.intro!,
              ...section.paragraphs,
              ...section.rows.map((row) => row.value),
            ],
          ].where((value) => value.length >= 40).toList(growable: false);
          expect(
            paragraphs.toSet(),
            hasLength(paragraphs.length),
            reason: '$caseId has duplicate full paragraphs',
          );

          File(
            '$outputDirectory/knowme-bazi-reader-v4-$caseId.pdf',
          ).writeAsBytesSync(bytes, flush: true);
          File(
            '$outputDirectory/knowme-bazi-reader-v4-$caseId.txt',
          ).writeAsStringSync(report.plainText, flush: true);
        }
      }
    },
  );
}
