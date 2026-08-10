import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

void main() {
  final outputPath = Platform.environment['KNOWME_ACCEPTANCE_OUTPUT'];
  final captureVariant = Platform.environment['KNOWME_CAPTURE_VARIANT'] ?? '';

  testWidgets('acceptance export and screenshots exit without pending timers', (
    tester,
  ) async {
    if (outputPath == null || outputPath.isEmpty) return;
    final output = Directory(outputPath)..createSync(recursive: true);
    final fixtures = <String, ThaiBetaAnalysis>{
      'known-time': _analysis(knownTime: true),
      'unknown-time': _analysis(knownTime: false),
    };

    if (captureVariant.isEmpty) {
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
    }

    if (captureVariant == 'desktop') {
      await _capture(
        tester,
        analysis: fixtures['known-time']!,
        size: const Size(1440, 1000),
        file: File('${output.path}/known-time-desktop.png'),
      );
    }
    if (captureVariant == 'mobile') {
      await _capture(
        tester,
        analysis: fixtures['unknown-time']!,
        size: const Size(390, 844),
        file: File('${output.path}/unknown-time-mobile.png'),
      );
    }
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
  // Widget-test captures do not automatically load the Material Icons font.
  // Load the SDK artifact before painting so icons do not become missing-glyph
  // squares in the acceptance screenshots.
  var ancestor = Directory(Platform.resolvedExecutable).parent;
  File? materialIcons;
  for (var depth = 0; depth < 6 && materialIcons == null; depth++) {
    for (final suffix in [
      'artifacts/material_fonts/materialicons-regular.otf',
      'material_fonts/materialicons-regular.otf',
    ]) {
      final candidate = File('${ancestor.path}/$suffix');
      if (candidate.existsSync()) materialIcons = candidate;
    }
    ancestor = ancestor.parent;
  }
  if (materialIcons == null) {
    throw StateError('Material Icons font is unavailable in the Flutter SDK');
  }
  await (FontLoader('MaterialIcons')..addFont(
        Future<ByteData>.value(
          ByteData.sublistView(materialIcons.readAsBytesSync()),
        ),
      ))
      .load();
  const acceptanceFontFamily = 'KnowMeAcceptanceThai';
  final thaiFont = File(r'C:\Windows\Fonts\tahoma.ttf');
  if (thaiFont.existsSync()) {
    final fontBytes = thaiFont.readAsBytesSync();
    await (FontLoader(
      acceptanceFontFamily,
    )..addFont(Future<ByteData>.value(ByteData.sublistView(fontBytes)))).load();
  }
  await tester.binding.setSurfaceSize(size);
  final repaintKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: repaintKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: thaiFont.existsSync() ? acceptanceFontFamily : null,
        ),
        home: ThaiBetaReportPage(
          analysis: analysis,
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          screenshotModeOverride: false,
          showCaptureModeBanner: false,
          badgeViewModelsOverride: const [],
        ),
      ),
    ),
  );
  // The report has optional async panels that are irrelevant in screenshot
  // mode. Fixed frames make the capture deterministic and avoid waiting on a
  // test-only timer that can keep pumpAndSettle alive after artifacts exist.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
  final previousComparator = goldenFileComparator;
  goldenFileComparator = _WritingGoldenComparator(file);
  try {
    await expectLater(
      find.byKey(repaintKey),
      matchesGoldenFile('acceptance-capture.png'),
    );
  } finally {
    goldenFileComparator = previousComparator;
  }
}

class _WritingGoldenComparator extends GoldenFileComparator {
  _WritingGoldenComparator(this.output);

  final File output;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    output.writeAsBytesSync(imageBytes);
    return true;
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    output.writeAsBytesSync(imageBytes);
  }

  @override
  Uri getTestUri(Uri key, int? version) => key;
}
