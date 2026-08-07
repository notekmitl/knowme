import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

void main() {
  final outputPath = Platform.environment['KNOWME_ACCEPTANCE_OUTPUT'];

  testWidgets('acceptance export and screenshots exit without pending timers', (
    tester,
  ) async {
    if (outputPath == null || outputPath.isEmpty) return;
    final output = Directory(outputPath)..createSync(recursive: true);
    final fixtures = <String, ThaiBetaAnalysis>{
      'known-time': _analysis(knownTime: true),
      'unknown-time': _analysis(knownTime: false),
    };

    for (final entry in fixtures.entries) {
      final document = ThaiBetaReportExportDocument.fromAnalysis(entry.value);
      final pdf = await ThaiBetaReportPdfExporter.build(document);
      File(
        '${output.path}/${entry.key}-report.pdf',
      ).writeAsBytesSync(pdf.bytes);
      File(
        '${output.path}/${entry.key}-web-text.txt',
      ).writeAsStringSync(document.fullPlainText);
      File(
        '${output.path}/${entry.key}-pdf-text.txt',
      ).writeAsStringSync(pdf.plainText);
    }

    await _capture(
      tester,
      analysis: fixtures['known-time']!,
      size: const Size(1440, 1000),
      file: File('${output.path}/known-time-desktop.png'),
    );
    await _capture(
      tester,
      analysis: fixtures['unknown-time']!,
      size: const Size(390, 844),
      file: File('${output.path}/unknown-time-mobile.png'),
    );
  });
}

ThaiBetaAnalysis _analysis({required bool knownTime}) {
  return ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'Acceptance',
      lastName: 'Fixture',
      birthDate: DateTime(1982, 6, 6),
      birthHour: knownTime ? 0 : null,
      birthMinute: knownTime ? 3 : 0,
      birthTimeUnknown: !knownTime,
      province: 'เชียงใหม่',
      provinceKey: 'chiang_mai',
    ),
    startedAt: DateTime(2026, 8, 7),
  );
}

Future<void> _capture(
  WidgetTester tester, {
  required ThaiBetaAnalysis analysis,
  required Size size,
  required File file,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repaintKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: repaintKey,
      child: MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          screenshotModeOverride: true,
          showCaptureModeBanner: false,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final boundary =
      repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  file.writeAsBytesSync(data!.buffer.asUint8List());
}
