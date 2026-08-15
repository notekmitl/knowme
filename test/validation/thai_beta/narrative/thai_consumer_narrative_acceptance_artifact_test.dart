import 'dart:convert';
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

import 'thai_beta_v15_r4_acceptance_audit.dart';

void main() {
  final outputPath = Platform.environment['KNOWME_ACCEPTANCE_OUTPUT'];
  final captureVariant = Platform.environment['KNOWME_CAPTURE_VARIANT'] ?? '';

  testWidgets('acceptance export and screenshots exit without pending timers', (
    tester,
  ) async {
    if (outputPath == null || outputPath.isEmpty) return;
    _stage('fixture-loading', 'start');
    final output = Directory(outputPath)..createSync(recursive: true);
    _stage('known-canonical-analysis', 'start');
    final knownAnalysis = _analysis(knownTime: true, minute: 35);
    _stage('known-canonical-analysis', 'complete');
    _stage('unknown-canonical-analysis', 'start');
    final unknownAnalysis = _analysis(knownTime: false);
    _stage('unknown-canonical-analysis', 'complete');
    final fixtures = <String, ThaiBetaAnalysis>{
      'owner-known-0035': knownAnalysis,
      'owner-unknown': unknownAnalysis,
      'regression-known-0003': _analysis(knownTime: true, minute: 3),
      'comparison-known-bangkok': _comparisonAnalysis(
        date: DateTime(1991, 11, 18),
        hour: 14,
        minute: 20,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      'comparison-known-khon-kaen': _comparisonAnalysis(
        date: DateTime(1974, 2, 27),
        hour: 6,
        minute: 45,
        province: 'ขอนแก่น',
        provinceKey: 'khon_kaen',
      ),
    };
    _stage('fixture-loading', 'complete');

    if (captureVariant.isEmpty) {
      final webTexts = <String, String>{};
      final pdfTexts = <String, String>{};
      for (final entry in fixtures.entries) {
        _stage('pdf-generation:${entry.key}', 'start');
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
        webTexts[entry.key] = document.fullPlainText;
        pdfTexts[entry.key] = pdf.plainText;
        _stage('web-pdf-canonical:${entry.key}', 'complete');
      }
      final known = fixtures['owner-known-0035']!;
      final regression = fixtures['regression-known-0003']!;
      Map<String, Object?> factFor(
        ThaiBetaAnalysis analysis, {
        required String fixtureId,
        required String birthTime,
      }) {
        final longitude = analysis.profile!.siderealAscendantDeg!;
        final withinSign = ((longitude % 30) + 30) % 30;
        final totalMinutes = (withinSign * 60).round();
        final degree =
            '${totalMinutes ~/ 60}°${(totalMinutes % 60).toString().padLeft(2, '0')}′';
        return <String, Object?>{
          'fixtureId': fixtureId,
          'birthDate': '1982-06-06',
          'birthTime': birthTime,
          'provinceKey': 'chiang_mai',
          'lagnaKey': analysis.profile!.lagnaKey,
          'lagnaSignThai': 'ราศีกุมภ์',
          'lagnaDegree': degree,
        };
      }

      final knownFacts = factFor(
        known,
        fixtureId: 'owner-known-1982-06-06-0035-chiang-mai',
        birthTime: '00:35',
      );
      final regressionFacts = factFor(
        regression,
        fixtureId: 'regression-known-1982-06-06-0003-chiang-mai',
        birthTime: '00:03',
      );
      final facts = <String, Object?>{
        'schema': 'knowme-thai-narrative-v1.5-r5-engine-facts',
        'fixtures': [knownFacts, regressionFacts],
      };
      final factualJson = const JsonEncoder.withIndent('  ').convert(facts);
      File(
        '${output.path}/engine-factual-result.json',
      ).writeAsStringSync('$factualJson\n');
      for (final check in <(String, Map<String, Object?>)>[
        ('owner-known-0035', knownFacts),
        ('regression-known-0003', regressionFacts),
      ]) {
        final factText =
            '${check.$2['lagnaSignThai']} ${check.$2['lagnaDegree']}';
        for (final suffix in ['web-text.txt', 'pdf-text.txt']) {
          final name = '${check.$1}-$suffix';
          if (!File(
            '${output.path}/$name',
          ).readAsStringSync().contains(factText)) {
            throw StateError('$name disagrees with engine fact $factText');
          }
        }
      }
      File('${output.path}/MANIFEST.generated.md').writeAsStringSync(
        '# Generated acceptance facts\n\n'
        '- Owner Known fixture: `${knownFacts['fixtureId']}`\n'
        '- Owner Known ascendant: `${knownFacts['lagnaSignThai']} ${knownFacts['lagnaDegree']}`\n'
        '- Regression fixture: `${regressionFacts['fixtureId']}`\n'
        '- Regression ascendant: `${regressionFacts['lagnaSignThai']} ${regressionFacts['lagnaDegree']}`\n'
        '- Factual source: `engine-factual-result.json`\n',
      );
      writeR5AcceptanceAudits(
        output: output,
        fixtures: fixtures,
        webTexts: webTexts,
        pdfTexts: pdfTexts,
      );
      _stage('manifest-generation', 'complete');
    }

    if (captureVariant == 'desktop') {
      _stage('screenshot-capture:desktop', 'start');
      for (final entry in fixtures.entries) {
        await _capture(
          tester,
          analysis: entry.value,
          size: const Size(1440, 1000),
          file: File('${output.path}/${entry.key}-desktop.png'),
        );
      }
      _stage('screenshot-capture:desktop', 'complete');
    }
    if (captureVariant == 'mobile') {
      _stage('screenshot-capture:mobile', 'start');
      for (final entry in fixtures.entries) {
        await _capture(
          tester,
          analysis: entry.value,
          size: const Size(390, 844),
          file: File('${output.path}/${entry.key}-mobile.png'),
        );
      }
      _stage('screenshot-capture:mobile', 'complete');
    }
  });
}

ThaiBetaAnalysis _comparisonAnalysis({
  required DateTime date,
  required int hour,
  required int minute,
  required String province,
  required String provinceKey,
}) => ThaiBetaAnalysisRunner.run(
  ThaiBetaInput(
    firstName: 'Comparison',
    lastName: 'Fixture',
    birthDate: date,
    birthHour: hour,
    birthMinute: minute,
    province: province,
    provinceKey: provinceKey,
  ),
  startedAt: DateTime(2026, 8, 7),
);

void _stage(String name, String state) {
  stderr.writeln(
    '[V14_STAGE] ${DateTime.now().toUtc().toIso8601String()} $name $state',
  );
}

ThaiBetaAnalysis _analysis({required bool knownTime, int minute = 0}) {
  return ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'Acceptance',
      lastName: 'Fixture',
      birthDate: DateTime(1982, 6, 6),
      birthHour: knownTime ? 0 : null,
      birthMinute: knownTime ? minute : 0,
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
