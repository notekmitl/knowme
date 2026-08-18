import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/presentation/export/thai_beta_browser_print.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_shared_report_view.dart';

import 'narrative/thai_beta_narrative_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'writes Known and Unknown vNext review artifacts from one shared model',
    (tester) async {
      final output = Platform.environment['KNOWME_REPORT_VNEXT_OUTPUT'];
      final outputDirectory = output == null || output.isEmpty
          ? Directory.systemTemp.createTempSync('knowme-report-vnext-test-')
          : (Directory(output)..createSync(recursive: true));
      if (output == null || output.isEmpty) {
        addTearDown(() {
          if (outputDirectory.existsSync()) {
            outputDirectory.deleteSync(recursive: true);
          }
        });
      }
      final identities = <Map<String, Object?>>[];
      await tester.runAsync(() async {
        final loader = FontLoader('KnowMeNotoSansThai')
          ..addFont(
            rootBundle.load(
              'assets/fonts/noto_sans_thai/NotoSansThai-Regular.ttf',
            ),
          );
        await loader.load();
        final latinLoader = FontLoader('KnowMeNotoSans')
          ..addFont(
            rootBundle.load('assets/fonts/noto_sans_thai/NotoSans-Regular.ttf'),
          );
        await latinLoader.load();
      });

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final fixture in <(String, ThaiBetaAnalysis)>[
        ('known', ThaiBetaNarrativeFixtures.fixtureA()),
        ('unknown', ThaiBetaNarrativeFixtures.fixtureB()),
      ]) {
        final mode = fixture.$1;
        final document = ThaiBetaReportExportDocument.candidate(fixture.$2);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThaiBetaAnnualInfographicPanel(
                  data: document.infographic!,
                  boundaryKey: boundaryKey,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final png = await tester.runAsync(
          () => ThaiBetaAnnualInfographicCapture.png(boundaryKey),
        );
        expect(png, isNotNull);
        final renderedPng = png!;
        final pngFile = File(
          '${outputDirectory.path}${Platform.pathSeparator}annual-infographic-$mode.png',
        )..writeAsBytesSync(renderedPng, flush: true);

        final pdf = await tester.runAsync(
          () => ThaiBetaReportPdfExporter.build(
            document,
            infographicPng: renderedPng,
          ),
        );
        expect(pdf, isNotNull);
        final renderedPdf = pdf!;
        final pdfFile = File(
          '${outputDirectory.path}${Platform.pathSeparator}dedicated-report-$mode.pdf',
        )..writeAsBytesSync(renderedPdf.bytes, flush: true);

        final htmlFile =
            File(
              '${outputDirectory.path}${Platform.pathSeparator}browser-print-$mode.html',
            )..writeAsStringSync(
              browserPrintDocumentHtml(document, infographicPng: renderedPng),
              flush: true,
            );

        identities.add({
          'mode': mode,
          'sectionCount': document.sections.length,
          'paragraphCount': document.sections.fold<int>(
            0,
            (total, section) => total + section.paragraphs.length,
          ),
          'dedicatedPdfPageCount': renderedPdf.pageCount,
          'pngBytes': pngFile.lengthSync(),
          'pdfBytes': pdfFile.lengthSync(),
          'browserPrintHtmlBytes': htmlFile.lengthSync(),
          'opportunity': document.infographic!.opportunity,
          'caution': document.infographic!.caution,
          'monthlyTimelineAvailable':
              document.infographic!.monthlyTimelineAvailable,
          'monthlyGapReason': document.infographic!.monthlyGapReason,
        });

        // Unmount the composited RepaintBoundary between fixtures. Replacing
        // structurally similar canvases in place lets the test raster cache
        // retain unchanged layers, which makes a later toImage() capture only
        // the dirty text regions instead of the complete review artifact.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }

      File(
        '${outputDirectory.path}${Platform.pathSeparator}artifact-generation-identities.json',
      ).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(identities),
        flush: true,
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
