import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
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

const _fixtureIds = <String>[
  'known',
  'unknown',
  'owner-known-0035',
  'owner-unknown',
  'regression-known-0003',
  'comparison-known-bangkok',
  'comparison-known-khon-kaen',
  'stress-known-longest',
  'stress-unknown-longest',
  'stress-opportunity-caution-longest',
  'stress-disclaimer-longest',
  'stress-thai-multiline',
  'stress-regression-1972',
  'year-boundary-2569',
  'year-boundary-2570',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('browser print resets the fixed Flutter host before pagination', () {
    expect(
      browserPrintCss,
      contains(
        'html, body { width: auto !important; height: auto !important; '
        'overflow: visible !important; position: static !important; }',
      ),
    );
    expect(
      browserPrintCss,
      contains('body > :not(#knowme-print-root) { display: none !important; }'),
      reason: 'Only the semantic shared-report print tree may be paginated.',
    );
    expect(
      browserPrintCss,
      contains('body { margin: 8px !important; }'),
      reason:
          'The live Flutter host must match the approved standalone geometry.',
    );
  });

  test('title-integrity gate rejects all five evidence mutations', () {
    final valid = _ArtifactProbe.valid();
    _validateArtifactProbe(valid);
    expect(
      () => _validateArtifactProbe(valid.copyWith(titleCreamPixels: 0)),
      throwsStateError,
      reason: 'omitted title must fail',
    );
    expect(
      () => _validateArtifactProbe(
        valid.copyWith(titleBounds: const Rect.fromLTWH(138, -5, 894, 90)),
      ),
      throwsStateError,
      reason: 'title outside the canvas must fail',
    );
    expect(
      () => _validateArtifactProbe(valid.copyWith(sidecarFixtureId: 'unknown')),
      throwsStateError,
      reason: 'fixture/output swap must fail',
    );
    expect(
      () => _validateArtifactProbe(valid.copyWith(sidecarPngSha256: 'stale')),
      throwsStateError,
      reason: 'stale PNG identity must fail',
    );
    expect(
      () => _validateArtifactSet(
        [valid, valid.copyWith(fixtureId: 'unknown')],
        const {'known', 'unknown'},
      ),
      throwsStateError,
      reason: 'basename collision must fail',
    );
  });

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
      final sourceHead =
          Platform.environment['KNOWME_REPORT_VNEXT_SOURCE_HEAD'] ?? 'test';
      final controlledOutputIdentity =
          Platform.environment['KNOWME_REPORT_VNEXT_OUTPUT_ID'] ?? 'test';
      final supported = _fixtureIds.toSet();
      expect(requested == 'all' || supported.contains(requested), isTrue);
      final requestedFixtures = requested == 'all'
          ? _fixtureIds
          : <String>[requested];
      if (output != null && output.isNotEmpty) {
        expect(
          outputDirectory.listSync(),
          isEmpty,
          reason: 'Revision output directory must be empty before generation',
        );
        expect(sourceHead, isNot('test'));
        expect(controlledOutputIdentity, isNot('test'));
      }
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
      final semanticsHandle = tester.ensureSemantics();
      final probes = <_ArtifactProbe>[];

      for (final fixtureId in requestedFixtures) {
        final analysis = _analysisFor(fixtureId);
        final document = ThaiBetaReportExportDocument.candidate(analysis);
        final infographic = document.infographic!;
        expect(infographic.title.trim(), isNotEmpty, reason: fixtureId);
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
        final titleFinder = find.byKey(
          ThaiBetaAnnualInfographicLayoutKeys.title,
        );
        expect(titleFinder, findsOneWidget, reason: fixtureId);
        expect(find.text(infographic.title), findsOneWidget, reason: fixtureId);
        expect(
          tester.getSemantics(titleFinder).label,
          contains(infographic.title),
          reason: '$fixtureId title semantics',
        );
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        expect(boundary.debugNeedsPaint, isFalse);
        final sectionRegions = _assertLayoutAndCollectRegions(
          tester,
          infographic,
        );

        final firstPng = await tester.runAsync(
          () => ThaiBetaAnnualInfographicCapture.png(boundaryKey),
        );
        final secondPng = await tester.runAsync(
          () => ThaiBetaAnnualInfographicCapture.png(boundaryKey),
        );
        expect(firstPng, isNotNull);
        final renderedPng = firstPng!;
        expect(secondPng, orderedEquals(renderedPng), reason: fixtureId);
        final rasterEvidence = await tester.runAsync(
          () => _assertCapturedSections(
            renderedPng,
            sectionRegions,
            expectedTitle: infographic.title,
          ),
        );
        expect(rasterEvidence, isNotNull);
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

        final pngSha256 = sha256.convert(renderedPng).toString().toUpperCase();
        final inputIdentity = sha256
            .convert(
              utf8.encode(
                jsonEncode({
                  'fixtureId': fixtureId,
                  'input': analysis.input.toMap(),
                  'asOf': analysis.asOf.toIso8601String(),
                }),
              ),
            )
            .toString()
            .toUpperCase();
        final titleBounds = sectionRegions
            .singleWhere((section) => section.id == 'title')
            .region;
        final themeBounds = sectionRegions
            .singleWhere((section) => section.id == 'theme')
            .region;
        final outputName = 'annual-infographic-$fixtureId.png';
        final probe = _ArtifactProbe(
          fixtureId: fixtureId,
          sidecarFixtureId: fixtureId,
          outputFileName: outputName,
          currentPngSha256: pngSha256,
          sidecarPngSha256: pngSha256,
          sourceHead: sourceHead,
          expectedSourceHead: sourceHead,
          title: infographic.title,
          titleBounds: _scaleRect(titleBounds, 1080, 1920),
          themeBounds: _scaleRect(themeBounds, 1080, 1920),
          titleCreamPixels: rasterEvidence!.titleCreamPixels,
          titleRegionSha256: rasterEvidence.titleRegionSha256,
          backgroundControlSha256: rasterEvidence.backgroundControlSha256,
          inputIdentitySha256: inputIdentity,
          controlledOutputIdentity: controlledOutputIdentity,
        );
        _validateArtifactProbe(probe);
        probes.add(probe);

        final identity = <String, Object?>{
          'fixtureId': fixtureId,
          'sourceHead': sourceHead,
          'controlledOutputIdentity': controlledOutputIdentity,
          'artifactRelativePath': outputName,
          'inputIdentitySha256': inputIdentity,
          'pngSha256': pngSha256,
          'pngDimensions': const {'width': 1080, 'height': 1920},
          'captureRepeatByteIdentical': true,
          'titleWidgetCount': 1,
          'titleSemanticContains': infographic.title,
          'titleCreamPixelCount': rasterEvidence.titleCreamPixels,
          'titleRasterSampleBounds': {
            'left': rasterEvidence.titleSampleBounds.left.toInt(),
            'top': rasterEvidence.titleSampleBounds.top.toInt(),
            'right': rasterEvidence.titleSampleBounds.right.toInt(),
            'bottom': rasterEvidence.titleSampleBounds.bottom.toInt(),
          },
          'titleRegionSha256': rasterEvidence.titleRegionSha256,
          'titleBackgroundControlSha256':
              rasterEvidence.backgroundControlSha256,
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
          'layoutBounds1080x1920': {
            for (final section in sectionRegions)
              section.id: {
                'left': (section.region.left * 1080).round(),
                'top': (section.region.top * 1920).round(),
                'right': (section.region.right * 1080).round(),
                'bottom': (section.region.bottom * 1920).round(),
              },
          },
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
      _validateArtifactSet(probes, requestedFixtures.toSet());
      if (output != null && output.isNotEmpty) {
        File(
          '${outputDirectory.path}${Platform.pathSeparator}infographic-title-integrity.json',
        ).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert({
            'sourceHead': sourceHead,
            'controlledOutputIdentity': controlledOutputIdentity,
            'fixtureCount': probes.length,
            'fixtures': [for (final probe in probes) probe.toJson()],
            'missing': 0,
            'mismatch': 0,
            'duplicateOutputPaths': 0,
            'titleRasterFailures': 0,
          }),
          flush: true,
        );
      }
      semanticsHandle.dispose();
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
  final absolute = <({String id, Rect rect})>[];
  Rect? previous;
  for (final (id, finder) in sections) {
    expect(finder, findsOneWidget, reason: id);
    final rect = tester.getRect(finder);
    const safeMargin = 12.0;
    expect(
      rect.left,
      greaterThanOrEqualTo(canvas.left + safeMargin),
      reason: '$id violates the left safe area',
    );
    expect(
      rect.top,
      greaterThanOrEqualTo(canvas.top + safeMargin),
      reason: '$id violates the top safe area',
    );
    expect(
      rect.right,
      lessThanOrEqualTo(canvas.right - safeMargin),
      reason: '$id violates the right safe area',
    );
    expect(
      rect.bottom,
      lessThanOrEqualTo(canvas.bottom - safeMargin),
      reason: '$id violates the bottom safe area',
    );
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
    absolute.add((id: id, rect: rect));
    previous = rect;
  }
  for (var left = 0; left < absolute.length; left++) {
    for (var right = left + 1; right < absolute.length; right++) {
      expect(
        absolute[left].rect.overlaps(absolute[right].rect),
        isFalse,
        reason:
            '${absolute[left].id} overlaps ${absolute[right].id}: '
            '${absolute[left].rect} / ${absolute[right].rect}',
      );
    }
  }
  final canvasFinder = find.byKey(const Key('thai_annual_infographic_canvas'));
  final textWidgets = tester.widgetList<Text>(
    find.descendant(of: canvasFinder, matching: find.byType(Text)),
  );
  expect(textWidgets, isNotEmpty);
  for (final text in textWidgets) {
    expect(
      text.style?.fontSize,
      isNotNull,
      reason: 'Every infographic text style must declare its design size',
    );
    expect(
      text.style!.fontSize,
      greaterThanOrEqualTo(7.8),
      reason:
          'Infographic text is below the mobile design minimum: ${text.data}',
    );
  }
  final visibleText = textWidgets.map((text) => text.data ?? '').join(' ');
  for (final month in const [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ]) {
    expect(visibleText, isNot(contains(month)));
  }
  expect(data.monthlyTimelineAvailable, isFalse);
  return regions;
}

Future<
  ({
    int titleCreamPixels,
    Rect titleSampleBounds,
    String titleRegionSha256,
    String backgroundControlSha256,
  })
>
_assertCapturedSections(
  Uint8List png,
  List<({String id, Rect region})> sections, {
  required String expectedTitle,
}) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    expect(image.width, ThaiBetaAnnualInfographicCapture.targetWidth);
    expect(image.height, ThaiBetaAnnualInfographicCapture.targetHeight);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(data, isNotNull);
    final rgba = data!.buffer.asUint8List();
    var titleCreamPixels = 0;
    var titleSampleBounds = Rect.zero;
    var titleRegionSha256 = '';
    var backgroundControlSha256 = '';
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
      final regionBytes = BytesBuilder(copy: false);
      final backgroundBytes = BytesBuilder(copy: false);
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
      if (section.id == 'title') {
        titleSampleBounds = Rect.fromLTRB(
          left.toDouble(),
          top.toDouble(),
          right.toDouble(),
          bottom.toDouble(),
        );
        for (var y = top; y < bottom; y++) {
          for (var x = left; x < right; x++) {
            final offset = (y * image.width + x) * 4;
            final red = rgba[offset];
            final green = rgba[offset + 1];
            final blue = rgba[offset + 2];
            final alpha = rgba[offset + 3];
            regionBytes.add([red, green, blue, alpha]);
            backgroundBytes.add(const [16, 24, 50, 255]);
            if (red >= 210 && green >= 200 && blue >= 170 && alpha >= 240) {
              titleCreamPixels++;
            }
          }
        }
        titleRegionSha256 = sha256
            .convert(regionBytes.takeBytes())
            .toString()
            .toUpperCase();
        backgroundControlSha256 = sha256
            .convert(backgroundBytes.takeBytes())
            .toString()
            .toUpperCase();
        expect(expectedTitle, matches(RegExp(r'^ดวงชะตาปี 25\d{2}$')));
        expect(
          titleCreamPixels,
          greaterThan(4000),
          reason: 'title glyphs are absent from the final raster',
        );
        expect(
          titleRegionSha256,
          isNot(backgroundControlSha256),
          reason: 'title region matches a background-only control',
        );
      }
    }
    expect(titleRegionSha256, isNotEmpty);
    return (
      titleCreamPixels: titleCreamPixels,
      titleSampleBounds: titleSampleBounds,
      titleRegionSha256: titleRegionSha256,
      backgroundControlSha256: backgroundControlSha256,
    );
  } finally {
    image.dispose();
    codec.dispose();
  }
}

Rect _scaleRect(Rect normalized, double width, double height) => Rect.fromLTRB(
  normalized.left * width,
  normalized.top * height,
  normalized.right * width,
  normalized.bottom * height,
);

class _ArtifactProbe {
  const _ArtifactProbe({
    required this.fixtureId,
    required this.sidecarFixtureId,
    required this.outputFileName,
    required this.currentPngSha256,
    required this.sidecarPngSha256,
    required this.sourceHead,
    required this.expectedSourceHead,
    required this.title,
    required this.titleBounds,
    required this.themeBounds,
    required this.titleCreamPixels,
    required this.titleRegionSha256,
    required this.backgroundControlSha256,
    required this.inputIdentitySha256,
    required this.controlledOutputIdentity,
  });

  factory _ArtifactProbe.valid() => const _ArtifactProbe(
    fixtureId: 'known',
    sidecarFixtureId: 'known',
    outputFileName: 'annual-infographic-known.png',
    currentPngSha256: 'CURRENT',
    sidecarPngSha256: 'CURRENT',
    sourceHead: 'SOURCE',
    expectedSourceHead: 'SOURCE',
    title: 'ดวงชะตาปี 2569',
    titleBounds: Rect.fromLTRB(138, 39, 1032, 129),
    themeBounds: Rect.fromLTRB(48, 141, 1032, 222),
    titleCreamPixels: 8937,
    titleRegionSha256: 'TITLE',
    backgroundControlSha256: 'BACKGROUND',
    inputIdentitySha256: 'INPUT',
    controlledOutputIdentity: 'REVISION4',
  );

  final String fixtureId;
  final String sidecarFixtureId;
  final String outputFileName;
  final String currentPngSha256;
  final String sidecarPngSha256;
  final String sourceHead;
  final String expectedSourceHead;
  final String title;
  final Rect titleBounds;
  final Rect themeBounds;
  final int titleCreamPixels;
  final String titleRegionSha256;
  final String backgroundControlSha256;
  final String inputIdentitySha256;
  final String controlledOutputIdentity;

  _ArtifactProbe copyWith({
    String? fixtureId,
    String? sidecarFixtureId,
    String? outputFileName,
    String? currentPngSha256,
    String? sidecarPngSha256,
    String? sourceHead,
    String? expectedSourceHead,
    String? title,
    Rect? titleBounds,
    Rect? themeBounds,
    int? titleCreamPixels,
    String? titleRegionSha256,
    String? backgroundControlSha256,
    String? inputIdentitySha256,
    String? controlledOutputIdentity,
  }) => _ArtifactProbe(
    fixtureId: fixtureId ?? this.fixtureId,
    sidecarFixtureId: sidecarFixtureId ?? this.sidecarFixtureId,
    outputFileName: outputFileName ?? this.outputFileName,
    currentPngSha256: currentPngSha256 ?? this.currentPngSha256,
    sidecarPngSha256: sidecarPngSha256 ?? this.sidecarPngSha256,
    sourceHead: sourceHead ?? this.sourceHead,
    expectedSourceHead: expectedSourceHead ?? this.expectedSourceHead,
    title: title ?? this.title,
    titleBounds: titleBounds ?? this.titleBounds,
    themeBounds: themeBounds ?? this.themeBounds,
    titleCreamPixels: titleCreamPixels ?? this.titleCreamPixels,
    titleRegionSha256: titleRegionSha256 ?? this.titleRegionSha256,
    backgroundControlSha256:
        backgroundControlSha256 ?? this.backgroundControlSha256,
    inputIdentitySha256: inputIdentitySha256 ?? this.inputIdentitySha256,
    controlledOutputIdentity:
        controlledOutputIdentity ?? this.controlledOutputIdentity,
  );

  Map<String, Object?> toJson() => {
    'fixtureId': fixtureId,
    'outputFileName': outputFileName,
    'pngSha256': currentPngSha256,
    'title': title,
    'titleBounds': {
      'left': titleBounds.left.round(),
      'top': titleBounds.top.round(),
      'right': titleBounds.right.round(),
      'bottom': titleBounds.bottom.round(),
    },
    'titleCreamPixels': titleCreamPixels,
    'titleRegionSha256': titleRegionSha256,
    'titleBackgroundControlSha256': backgroundControlSha256,
    'inputIdentitySha256': inputIdentitySha256,
  };
}

void _validateArtifactProbe(_ArtifactProbe probe) {
  if (probe.fixtureId != probe.sidecarFixtureId) {
    throw StateError('fixture/output identity mismatch');
  }
  if (probe.outputFileName != 'annual-infographic-${probe.fixtureId}.png') {
    throw StateError('fixture output filename mismatch');
  }
  if (probe.currentPngSha256 != probe.sidecarPngSha256) {
    throw StateError('stale PNG hash mismatch');
  }
  if (probe.sourceHead != probe.expectedSourceHead) {
    throw StateError('source HEAD mismatch');
  }
  if (!RegExp(r'^ดวงชะตาปี 25\d{2}$').hasMatch(probe.title)) {
    throw StateError('title contract mismatch');
  }
  const canvas = Rect.fromLTWH(0, 0, 1080, 1920);
  const safeInset = 36.0;
  if (!canvas.contains(probe.titleBounds.topLeft) ||
      !canvas.contains(
        probe.titleBounds.bottomRight - const Offset(.01, .01),
      ) ||
      probe.titleBounds.left < safeInset ||
      probe.titleBounds.top < safeInset) {
    throw StateError('title outside the canvas safe area');
  }
  if (probe.titleBounds.overlaps(probe.themeBounds)) {
    throw StateError('title overlaps the annual theme');
  }
  if (probe.titleCreamPixels <= 4000 ||
      probe.titleRegionSha256 == probe.backgroundControlSha256) {
    throw StateError('title missing from final raster');
  }
  if (probe.inputIdentitySha256.isEmpty ||
      probe.controlledOutputIdentity.isEmpty) {
    throw StateError('artifact provenance is incomplete');
  }
}

void _validateArtifactSet(
  List<_ArtifactProbe> probes,
  Set<String> expectedFixtures,
) {
  if (probes
          .map((probe) => probe.fixtureId)
          .toSet()
          .difference(expectedFixtures)
          .isNotEmpty ||
      expectedFixtures
          .difference(probes.map((probe) => probe.fixtureId).toSet())
          .isNotEmpty) {
    throw StateError('fixture inventory mismatch');
  }
  final outputNames = probes.map((probe) => probe.outputFileName).toList();
  if (outputNames.toSet().length != outputNames.length) {
    throw StateError('duplicate output basename');
  }
  for (final probe in probes) {
    _validateArtifactProbe(probe);
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
