import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/export/thai_beta_browser_print.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_shared_report_view.dart';

import 'narrative/thai_beta_narrative_fixtures.dart';
import 'synthetic_audit/thai_beta_synthetic_matrix_300.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'writes isolated vNext review artifacts from one shared model',
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
      final requested =
          Platform.environment['KNOWME_REPORT_VNEXT_FIXTURE'] ?? 'known';
      final supported = <String>{
        'known',
        'unknown',
        'owner-known-0035',
        'owner-unknown',
        'regression-known-0003',
        'comparison-known-bangkok',
        'comparison-known-khon-kaen',
        'stress-known-longest',
        'stress-unknown-longest',
        'stress-thai-multiline',
        'stress-opportunity-caution-longest',
        'stress-disclaimer-longest',
        'stress-regression-1972',
        'year-boundary-2569',
        'year-boundary-2570',
      };
      expect(supported, contains(requested));
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

      for (final fixtureId in [requested]) {
        final document = ThaiBetaReportExportDocument.candidate(
          _analysisFor(fixtureId),
        );
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
        expect(tester.takeException(), isNull);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        expect(boundary.debugNeedsPaint, isFalse);
        final sectionRegions = _assertLayoutAndCollectRegions(
          tester,
          document.infographic!,
        );

        final png = await tester.runAsync(
          () => ThaiBetaAnnualInfographicCapture.png(boundaryKey),
        );
        expect(png, isNotNull);
        final renderedPng = png!;
        await tester.runAsync(
          () => _assertCapturedSections(renderedPng, sectionRegions),
        );
        final pngFile = File(
          '${outputDirectory.path}${Platform.pathSeparator}annual-infographic-$fixtureId.png',
        )..writeAsBytesSync(renderedPng, flush: true);

        ThaiBetaPdfRenderResult? renderedPdf;
        File? pdfFile;
        File? htmlFile;
        if (_requiresReportArtifacts(fixtureId)) {
          final pdf = await tester.runAsync(
            () => ThaiBetaReportPdfExporter.build(
              document,
              infographicPng: renderedPng,
            ),
          );
          expect(pdf, isNotNull);
          renderedPdf = pdf!;
          pdfFile = File(
            '${outputDirectory.path}${Platform.pathSeparator}dedicated-report-$fixtureId.pdf',
          )..writeAsBytesSync(renderedPdf.bytes, flush: true);

          htmlFile =
              File(
                '${outputDirectory.path}${Platform.pathSeparator}browser-print-$fixtureId.html',
              )..writeAsStringSync(
                browserPrintDocumentHtml(document, infographicPng: renderedPng),
                flush: true,
              );
        }

        final identity = <String, Object?>{
          'fixtureId': fixtureId,
          'sectionCount': document.sections.length,
          'paragraphCount': document.sections.fold<int>(
            0,
            (total, section) => total + section.paragraphs.length,
          ),
          'dedicatedPdfPageCount': renderedPdf?.pageCount,
          'pngBytes': pngFile.lengthSync(),
          'pdfBytes': pdfFile?.lengthSync(),
          'browserPrintHtmlBytes': htmlFile?.lengthSync(),
          'title': document.infographic!.title,
          'theme': document.infographic!.theme,
          'categories': [
            for (final category in document.infographic!.categories)
              {
                'id': category.id,
                'title': category.title,
                'summary': category.summary,
              },
          ],
          'opportunity': document.infographic!.opportunity,
          'caution': document.infographic!.caution,
          'primaryAdvice': document.infographic!.primaryAdvice,
          'disclaimer': document.infographic!.disclaimer,
          'monthlyTimelineAvailable':
              document.infographic!.monthlyTimelineAvailable,
          'monthlyGapReason': document.infographic!.monthlyGapReason,
        };
        File(
          '${outputDirectory.path}${Platform.pathSeparator}$fixtureId-identity.json',
        ).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(identity),
          flush: true,
        );

        // Unmount the composited RepaintBoundary between fixtures. Replacing
        // structurally similar canvases in place lets the test raster cache
        // retain unchanged layers, which makes a later toImage() capture only
        // the dirty text regions instead of the complete review artifact.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

List<({String id, Rect region})> _assertLayoutAndCollectRegions(
  WidgetTester tester,
  ThaiBetaAnnualInfographicData data,
) {
  final canvas = tester.getRect(
    find.byKey(const Key('thai_annual_infographic_canvas')),
  );
  final sections = <(String, Finder)>[
    ('title', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.title)),
    ('theme', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.theme)),
    ('overview', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.overview)),
    for (final category in data.categories)
      (
        'category-${category.id}',
        find.byKey(ThaiBetaAnnualInfographicLayoutKeys.category(category.id)),
      ),
    ('ornament', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.ornament)),
    (
      'opportunity',
      find.byKey(ThaiBetaAnnualInfographicLayoutKeys.opportunity),
    ),
    ('caution', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.caution)),
    ('advice', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.advice)),
    ('disclaimer', find.byKey(ThaiBetaAnnualInfographicLayoutKeys.disclaimer)),
  ];
  final regions = <({String id, Rect region})>[];
  Rect? previous;
  for (final (id, finder) in sections) {
    expect(finder, findsOneWidget, reason: id);
    final rect = tester.getRect(finder);
    expect(rect.left, greaterThanOrEqualTo(canvas.left), reason: id);
    expect(rect.top, greaterThanOrEqualTo(canvas.top), reason: id);
    expect(rect.right, lessThanOrEqualTo(canvas.right), reason: id);
    expect(rect.bottom, lessThanOrEqualTo(canvas.bottom), reason: id);
    if (previous != null) {
      expect(
        rect.top,
        greaterThanOrEqualTo(previous.bottom - .01),
        reason: '$id overlaps the preceding section',
      );
    }
    regions.add((
      id: id,
      region: Rect.fromLTRB(
        (rect.left - canvas.left) / canvas.width,
        (rect.top - canvas.top) / canvas.height,
        (rect.right - canvas.left) / canvas.width,
        (rect.bottom - canvas.top) / canvas.height,
      ),
    ));
    previous = rect;
  }
  return regions;
}

Future<void> _assertCapturedSections(
  Uint8List png,
  List<({String id, Rect region})> sections,
) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    expect(image.width, ThaiBetaAnnualInfographicCapture.targetWidth);
    expect(image.height, ThaiBetaAnnualInfographicCapture.targetHeight);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(data, isNotNull);
    final rgba = data!.buffer.asUint8List();
    for (final section in sections) {
      final left = (section.region.left * image.width).floor().clamp(
        0,
        image.width - 1,
      );
      final top = (section.region.top * image.height).floor().clamp(
        0,
        image.height - 1,
      );
      final right = (section.region.right * image.width).ceil().clamp(
        left + 1,
        image.width,
      );
      final bottom = (section.region.bottom * image.height).ceil().clamp(
        top + 1,
        image.height,
      );
      var sampled = 0;
      var nonNavy = 0;
      for (var y = top; y < bottom; y += 3) {
        for (var x = left; x < right; x += 3) {
          final offset = (y * image.width + x) * 4;
          final red = rgba[offset];
          final green = rgba[offset + 1];
          final blue = rgba[offset + 2];
          sampled++;
          if ((red - 16).abs() > 4 ||
              (green - 24).abs() > 4 ||
              (blue - 50).abs() > 4) {
            nonNavy++;
          }
        }
      }
      expect(
        nonNavy,
        greaterThan(sampled ~/ 250),
        reason: '${section.id} is missing from the captured PNG',
      );
    }
  } finally {
    image.dispose();
    codec.dispose();
  }
}

bool _requiresReportArtifacts(String fixtureId) =>
    !fixtureId.startsWith('stress-') && !fixtureId.startsWith('year-boundary-');

ThaiBetaAnalysis _analysisFor(String fixtureId) => switch (fixtureId) {
  'known' => ThaiBetaNarrativeFixtures.fixtureA(),
  'unknown' => ThaiBetaNarrativeFixtures.fixtureB(),
  'owner-known-0035' => _run(_owner(known: true, minute: 35)),
  'owner-unknown' => _run(_owner(known: false)),
  'regression-known-0003' => _run(_owner(known: true, minute: 3)),
  'comparison-known-bangkok' => _run(
    ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1991, 11, 18),
      birthHour: 14,
      birthMinute: 20,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
  ),
  'comparison-known-khon-kaen' => _run(
    ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1974, 2, 27),
      birthHour: 6,
      birthMinute: 45,
      province: 'ขอนแก่น',
      provinceKey: 'khon_kaen',
    ),
  ),
  'stress-known-longest' => _longestSynthetic(knownTime: true),
  'stress-unknown-longest' => _longestSynthetic(knownTime: false),
  'stress-thai-multiline' => _longestSynthetic(
    knownTime: null,
    themeAndCategoriesOnly: true,
  ),
  'stress-opportunity-caution-longest' => _longestSynthetic(
    knownTime: null,
    opportunityAndCautionOnly: true,
  ),
  'stress-disclaimer-longest' => _longestSynthetic(
    knownTime: null,
    disclaimerOnly: true,
  ),
  'stress-regression-1972' => _run(
    ThaiBetaInput(
      firstName: 'Regression',
      lastName: '1972',
      birthDate: DateTime(1972, 4, 4),
      birthHour: 10,
      birthMinute: 30,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
  ),
  'year-boundary-2569' => _run(
    _owner(known: true, minute: 35),
    asOf: DateTime.utc(2026, 12, 31),
  ),
  'year-boundary-2570' => _run(
    _owner(known: true, minute: 35),
    asOf: DateTime.utc(2027, 1, 1),
  ),
  _ => throw ArgumentError.value(fixtureId, 'fixtureId'),
};

ThaiBetaAnalysis _run(ThaiBetaInput input, {DateTime? asOf}) {
  final reference = asOf ?? DateTime.utc(2026, 8, 7);
  return ThaiBetaAnalysisRunner.run(
    input,
    startedAt: reference,
    asOf: reference,
  );
}

ThaiBetaInput _owner({required bool known, int minute = 0}) => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: known ? 0 : null,
  birthMinute: known ? minute : 0,
  birthTimeUnknown: !known,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);

ThaiBetaAnalysis _longestSynthetic({
  required bool? knownTime,
  bool opportunityAndCautionOnly = false,
  bool themeAndCategoriesOnly = false,
  bool disclaimerOnly = false,
}) {
  ThaiBetaAnalysis? longest;
  var longestScore = -1;
  for (final profile in ThaiBetaSyntheticMatrix.build()) {
    if (knownTime != null && profile.input.hasBirthTime != knownTime) continue;
    final analysis = _run(profile.input, asOf: DateTime.utc(2026, 8, 3));
    final data = ThaiBetaReportExportDocument.candidate(analysis).infographic!;
    final score = disclaimerOnly
        ? data.disclaimer.length
        : opportunityAndCautionOnly
        ? data.opportunity.length + data.caution.length
        : themeAndCategoriesOnly
        ? data.theme.length +
              data.categories.fold<int>(
                0,
                (total, category) => total + category.summary.length,
              )
        : data.theme.length +
              data.categories.fold<int>(
                0,
                (total, category) => total + category.summary.length,
              ) +
              data.opportunity.length +
              data.caution.length +
              data.primaryAdvice.length +
              data.disclaimer.length;
    if (score > longestScore) {
      longestScore = score;
      longest = analysis;
    }
  }
  if (longest == null) throw StateError('No synthetic stress fixture found.');
  return longest;
}
