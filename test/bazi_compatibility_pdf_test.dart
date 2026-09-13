import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
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
    },
  );
}
