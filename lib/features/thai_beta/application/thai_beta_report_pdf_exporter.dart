import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'thai_beta_report_export_document.dart';

class _PdfSemanticBlock {
  const _PdfSemanticBlock({this.heading, required this.paragraphs});

  final String? heading;
  final List<String> paragraphs;
}

const _domainHeadings = {'การงาน', 'การเงิน', 'ความรัก', 'สุขภาพ', 'โชคลาภ'};

final _isoDatePattern = RegExp(r'(?<!\d)\d{4}-\d{2}-\d{2}(?!\d)');

/// Keeps each ISO date in an inline widget so the visible token uses ordinary
/// ASCII hyphens but can move only as a whole to the next line.
pw.Widget _pdfText(String value, {required pw.TextStyle style}) {
  final matches = _isoDatePattern.allMatches(value).toList(growable: false);
  if (matches.isEmpty) return pw.Text(value, style: style);
  final spans = <pw.InlineSpan>[];
  var offset = 0;
  for (final match in matches) {
    if (match.start > offset) {
      spans.add(pw.TextSpan(text: value.substring(offset, match.start)));
    }
    spans.add(
      pw.WidgetSpan(
        child: pw.Text(match.group(0)!, style: style),
        style: style,
      ),
    );
    offset = match.end;
  }
  if (offset < value.length) {
    spans.add(pw.TextSpan(text: value.substring(offset)));
  }
  return pw.RichText(
    text: pw.TextSpan(style: style, children: spans),
  );
}

// Build a fresh, height-bounded semantic unit. Each unit is small enough for
// MultiPage to keep together while still allowing several units on one page.
pw.Widget _atomicPaginationUnit(pw.Widget Function() buildChild) => pw.Table(
  columnWidths: const {0: pw.FlexColumnWidth()},
  children: [
    pw.TableRow(children: [buildChild()]),
  ],
);

pw.Widget _timelineFrame({
  required bool isTimeline,
  required pw.Widget child,
  required pw.EdgeInsets padding,
  required PdfColor color,
}) {
  if (!isTimeline) {
    // The outer atomic container hides this Column's spanning interface from
    // MultiPage, so it is laid out once with fresh child coordinates.
    return child;
  }
  return pw.Container(
    width: double.infinity,
    padding: padding,
    margin: const pw.EdgeInsets.only(bottom: 7),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
    ),
    child: child,
  );
}

/// Splits a display paragraph without changing its characters. The limit is a
/// layout budget, not fixture-specific pagination: at the report's font size
/// Thai prose has few whitespace break opportunities. A 360-character bound
/// plus both headings stays comfortably below one printable A4 page, while
/// every source character is preserved across continuation units.
List<String> _boundedPdfParagraphs(String paragraph) {
  const maxCharacters = 360;
  if (paragraph.length <= maxCharacters) return [paragraph];
  final tokens = RegExp(r'\S+\s*').allMatches(paragraph);
  final chunks = <String>[];
  var current = StringBuffer();
  for (final match in tokens) {
    final token = match.group(0)!;
    if (current.isNotEmpty && current.length + token.length > maxCharacters) {
      chunks.add(current.toString());
      current = StringBuffer();
    }
    current.write(token);
  }
  if (current.isNotEmpty) chunks.add(current.toString());
  return chunks.isEmpty ? [paragraph] : chunks;
}

List<_PdfSemanticBlock> _semanticBlocks(List<String> paragraphs) {
  if (paragraphs.isEmpty) return const [];
  final blocks = <_PdfSemanticBlock>[];
  final preamble = <String>[];
  String? heading;
  var body = <String>[];
  for (final paragraph in paragraphs) {
    if (_domainHeadings.contains(paragraph.trim())) {
      if (heading != null) {
        blocks.add(_PdfSemanticBlock(heading: heading, paragraphs: body));
      }
      heading = paragraph;
      body = <String>[];
    } else if (heading == null) {
      preamble.add(paragraph);
    } else {
      body.add(paragraph);
    }
  }
  if (heading != null) {
    blocks.add(_PdfSemanticBlock(heading: heading, paragraphs: body));
  }
  if (blocks.isEmpty) {
    return [_PdfSemanticBlock(paragraphs: preamble)];
  }
  // Section/horizon summaries are not domain claims. Keep the preamble in a
  // separate semantic unit so it can never render under the first domain.
  return [
    if (preamble.isNotEmpty) _PdfSemanticBlock(paragraphs: preamble),
    ...blocks,
  ];
}

/// Result of the real download-button PDF path.
class ThaiBetaPdfRenderResult {
  const ThaiBetaPdfRenderResult({
    required this.bytes,
    required this.plainText,
    required this.document,
    required this.pageCount,
  });

  final Uint8List bytes;

  /// Exact text written into PDF widgets (Unicode source of the PDF content).
  /// Custom font embedding prevents reliable raw-byte Thai extraction, so
  /// regression tests assert on this render text from the same exporter path.
  final String plainText;

  final ThaiBetaReportExportDocument document;

  /// Number of pages produced by the same renderer used by the download
  /// button. Captured from the final MultiPage footer after layout completes.
  final int pageCount;
}

/// Builds a downloadable PDF from a [ThaiBetaReportExportDocument].
///
/// Uses bundled Noto Sans Thai assets so export remains deterministic and does
/// not depend on a runtime network request or a non-Thai fallback font.
abstract final class ThaiBetaReportPdfExporter {
  static const String defaultFilename = 'knowme-thai-report.pdf';
  static const String _regularFontAsset =
      'assets/fonts/noto_sans_thai/NotoSansThai-Regular.ttf';
  static const String _boldFontAsset =
      'assets/fonts/noto_sans_thai/NotoSansThai-Bold.ttf';
  static const String _latinRegularFontAsset =
      'assets/fonts/noto_sans_thai/NotoSans-Regular.ttf';
  static const String _latinBoldFontAsset =
      'assets/fonts/noto_sans_thai/NotoSans-Bold.ttf';

  static Future<(pw.Font, pw.Font, pw.Font, pw.Font)>? _fonts;

  /// Continuation headings are kept atomic with their paragraph and rely on
  /// MultiPage's measured boundary. A forced NewPage can create an empty page
  /// when the preceding content already ends exactly at a page boundary.
  static const bool debugUsesForcedContinuationPageForTest = false;

  /// Semantic pagination units used by the PDF renderer. Exposed so regression
  /// tests can prove that a period/domain heading travels with its first body
  /// paragraph without repeating the parent heading for every domain block.
  static List<String> debugPaginationUnitsForTest(
    ThaiBetaReportExportSection section,
  ) {
    final blocks = _semanticBlocks(section.paragraphs);
    return [
      for (var i = 0; i < blocks.length; i++)
        [
          if (i == 0) section.title,
          if (blocks[i].heading != null) blocks[i].heading!,
          ...blocks[i].paragraphs,
        ].join('\n'),
    ];
  }

  static List<String> debugIsoDateTokensForTest(String value) => _isoDatePattern
      .allMatches(value)
      .map((match) => match.group(0)!)
      .toList(growable: false);

  static ({int paragraphIndex, String heading})?
  debugReadingBasisContinuationForTest(ThaiBetaReportExportSection section) {
    if (section.title != 'รายงานนี้ดูจากอะไร') return null;
    final lacksBirthTime = section.paragraphs.any(
      (paragraph) => paragraph.contains('ไม่มีเวลาเกิด'),
    );
    return (
      paragraphIndex: lacksBirthTime ? 3 : 5,
      heading: lacksBirthTime
          ? '${section.title} — ต่อ'
          : 'โครงสร้างดวงหลัก — ต่อ',
    );
  }

  /// Geometry contract for disclaimer/omission cards. The former one-column
  /// intrinsic table could shrink the border around short Known-time copy.
  static Map<String, Object> debugDisclaimerGeometryForTest() => const {
    'column': 'flex',
    'width': 'page',
    'bodyInsideBorder': true,
  };

  /// Disclaimer sections are one atomic card whenever their complete topic
  /// list fits on a fresh page. This prevents the V1.3 four-line chunker from
  /// creating an unlabelled, mostly-empty continuation page.
  static List<List<String>> debugDisclaimerChunksForTest(
    ThaiBetaReportExportSection section,
  ) => [List<String>.unmodifiable(section.paragraphs)];

  static Future<(pw.Font, pw.Font, pw.Font, pw.Font)> _loadFonts() {
    return _fonts ??= () async {
      final regular = await rootBundle.load(_regularFontAsset);
      final bold = await rootBundle.load(_boldFontAsset);
      final latinRegular = await rootBundle.load(_latinRegularFontAsset);
      final latinBold = await rootBundle.load(_latinBoldFontAsset);
      return (
        pw.Font.ttf(regular),
        pw.Font.ttf(bold),
        pw.Font.ttf(latinRegular),
        pw.Font.ttf(latinBold),
      );
    }();
  }

  /// Same path as [ThaiBetaReportExportButton] download.
  static Future<Uint8List> buildBytes(
    ThaiBetaReportExportDocument document, {
    Uint8List? infographicPng,
  }) async {
    final result = await build(document, infographicPng: infographicPng);
    return result.bytes;
  }

  /// Builds PDF bytes and returns the exact polished text fed to PDF widgets.
  static Future<ThaiBetaPdfRenderResult> build(
    ThaiBetaReportExportDocument document, {
    Uint8List? infographicPng,
  }) async {
    final polished = ThaiBetaReportExportDocument.polishForPdf(document);
    final (regular, bold, latinRegular, latinBold) = await _loadFonts();

    final plain = StringBuffer()
      ..writeln(polished.title)
      ..writeln(polished.subtitle);
    for (final section in polished.sections) {
      plain.writeln(section.title);
      for (final paragraph in section.paragraphs) {
        plain.writeln(paragraph);
      }
    }

    final pdf = pw.Document();
    var pageCount = 0;
    final baseStyle = pw.TextStyle(
      font: regular,
      fontFallback: [latinRegular],
      fontSize: 10.8,
      height: 1.5,
    );
    final titleStyle = pw.TextStyle(
      font: bold,
      fontFallback: [latinBold],
      fontSize: 20,
      height: 1.35,
    );
    final sectionStyle = pw.TextStyle(
      font: bold,
      fontFallback: [latinBold],
      fontSize: 13.5,
      height: 1.4,
    );
    final subtitleStyle = pw.TextStyle(
      font: regular,
      fontFallback: [latinRegular],
      fontSize: 10,
      color: PdfColors.grey700,
      height: 1.4,
    );
    final disclaimerStyle = pw.TextStyle(
      font: regular,
      fontFallback: [latinRegular],
      fontSize: 10,
      color: PdfColors.grey800,
      height: 1.5,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 48, 44, 48),
        footer: (context) {
          pageCount = context.pagesCount;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'หน้า ${context.pageNumber} / ${context.pagesCount}',
              style: subtitleStyle,
              textAlign: pw.TextAlign.center,
            ),
          );
        },
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(polished.title, style: titleStyle),
            pw.SizedBox(height: 6),
            pw.Text(polished.subtitle, style: subtitleStyle),
            pw.SizedBox(height: 18),
            pw.Divider(thickness: 0.8, color: PdfColors.grey400),
            pw.SizedBox(height: 18),
          ];
          for (var i = 0; i < polished.sections.length; i++) {
            final section = polished.sections[i];
            final isDisclaimer =
                section.kind == ThaiBetaReportExportSectionKind.disclaimer;
            final isTimeline =
                section.kind == ThaiBetaReportExportSectionKind.timeline;

            if (isDisclaimer) {
              widgets.add(pw.SizedBox(height: 10));
              // Keep the complete omission/disclaimer card atomic. The real
              // Unknown fixture fits on a fresh A4 page; arbitrary groups of
              // four caused V1.3 page 6 to lose its parent heading.
              final chunks = debugDisclaimerChunksForTest(section);
              for (
                var chunkIndex = 0;
                chunkIndex < chunks.length;
                chunkIndex++
              ) {
                if (chunkIndex > 0) widgets.add(pw.SizedBox(height: 6));
                final chunk = chunks[chunkIndex];
                widgets.add(
                  _atomicPaginationUnit(
                    () => pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey400,
                          width: 0.7,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            chunkIndex == 0
                                ? section.title
                                : '${section.title} (ต่อ)',
                            style: sectionStyle,
                          ),
                          for (final paragraph in chunk) ...[
                            pw.SizedBox(height: 8),
                            _pdfText(paragraph, style: disclaimerStyle),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }
              continue;
            }

            final blocks = _semanticBlocks(section.paragraphs);
            final continuation = debugReadingBasisContinuationForTest(section);
            for (var blockIndex = 0; blockIndex < blocks.length; blockIndex++) {
              final block = blocks[blockIndex];
              final renderParagraphs = block.paragraphs
                  .expand(_boundedPdfParagraphs)
                  .toList(growable: false);
              final heading = blockIndex == 0 ? section.title : null;
              final firstParagraphCount = renderParagraphs.length.clamp(0, 1);
              final firstParagraphs = renderParagraphs
                  .take(firstParagraphCount)
                  .toList(growable: false);
              final firstUnitChildren = <pw.Widget>[
                if (heading != null) _pdfText(heading, style: sectionStyle),
                if (block.heading != null) ...[
                  pw.SizedBox(height: 8),
                  _pdfText(block.heading!, style: sectionStyle),
                ],
                for (final paragraph in firstParagraphs) ...[
                  pw.SizedBox(height: 8),
                  _pdfText(paragraph, style: baseStyle),
                ],
              ];
              if (isTimeline) {
                widgets.add(
                  _atomicPaginationUnit(
                    () => _timelineFrame(
                      isTimeline: true,
                      padding: const pw.EdgeInsets.all(12),
                      color: blockIndex == 0
                          ? PdfColors.grey100
                          : PdfColors.white,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: firstUnitChildren,
                      ),
                    ),
                  ),
                );
              } else {
                widgets.add(
                  _atomicPaginationUnit(
                    () => _timelineFrame(
                      isTimeline: false,
                      padding: pw.EdgeInsets.zero,
                      color: PdfColors.white,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: firstUnitChildren,
                      ),
                    ),
                  ),
                );
              }
              // Remaining paragraphs are bounded atomic units. Parent and
              // domain headings are not repeated merely because content was
              // split into another unit; block index is not a page boundary.
              for (
                var paragraphIndex = firstParagraphCount;
                paragraphIndex < renderParagraphs.length;
                paragraphIndex++
              ) {
                final continuationHeading =
                    continuation != null &&
                        paragraphIndex == continuation.paragraphIndex
                    ? continuation.heading
                    : null;
                final remaining = renderParagraphs
                    .skip(paragraphIndex)
                    .take(1)
                    .toList(growable: false);
                widgets.add(pw.SizedBox(height: 5));
                widgets.add(
                  _atomicPaginationUnit(
                    () => pw.Padding(
                      padding: pw.EdgeInsets.fromLTRB(
                        isTimeline ? 12 : 0,
                        3,
                        isTimeline ? 12 : 0,
                        5,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (continuationHeading != null) ...[
                            _pdfText(continuationHeading, style: sectionStyle),
                            pw.SizedBox(height: 8),
                          ],
                          for (final paragraph in remaining)
                            _pdfText(paragraph, style: baseStyle),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
            // Section spacing belongs only between sections. A trailing spacer
            // has no content but MultiPage still lays it out; when the final
            // content exactly fills a page it can create a footer-only page.
            if (i < polished.sections.length - 1) {
              widgets.add(pw.SizedBox(height: 12));
            }
            if (infographicPng != null &&
                i == polished.infographicInsertionSectionIndex) {
              widgets.add(pw.NewPage());
              widgets.add(
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(infographicPng),
                    // 9:16 within the printable A4 body. The previous 728pt
                    // height exceeded MultiPage's body once the footer was
                    // reserved and retried until TooManyPagesException.
                    width: 382,
                    height: 679,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              );
              widgets.add(pw.NewPage());
            }
          }

          return widgets;
        },
      ),
    );

    final bytes = await pdf.save();
    return ThaiBetaPdfRenderResult(
      bytes: bytes,
      plainText: plain.toString(),
      document: polished,
      pageCount: pageCount,
    );
  }

  static String filenameFor(ThaiBetaReportExportDocument document) {
    return '${document.filenameStem}.pdf';
  }
}
