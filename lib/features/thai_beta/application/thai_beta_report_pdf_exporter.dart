import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'thai_beta_report_export_document.dart';

/// Result of the real download-button PDF path.
class ThaiBetaPdfRenderResult {
  const ThaiBetaPdfRenderResult({
    required this.bytes,
    required this.plainText,
    required this.document,
  });

  final Uint8List bytes;

  /// Exact text written into PDF widgets (Unicode source of the PDF content).
  /// Custom font embedding prevents reliable raw-byte Thai extraction, so
  /// regression tests assert on this render text from the same exporter path.
  final String plainText;

  final ThaiBetaReportExportDocument document;
}

/// Builds a downloadable PDF from a [ThaiBetaReportExportDocument].
///
/// Uses Noto Sans Thai via [PdfGoogleFonts] so Thai glyphs render correctly.
abstract final class ThaiBetaReportPdfExporter {
  static const String defaultFilename = 'knowme-thai-report.pdf';

  /// Same path as [ThaiBetaReportExportButton] download.
  static Future<Uint8List> buildBytes(ThaiBetaReportExportDocument document) async {
    final result = await build(document);
    return result.bytes;
  }

  /// Builds PDF bytes and returns the exact polished text fed to PDF widgets.
  static Future<ThaiBetaPdfRenderResult> build(
    ThaiBetaReportExportDocument document,
  ) async {
    final polished = ThaiBetaReportExportDocument.polishForPdf(document);
    final regular = await PdfGoogleFonts.notoSansThaiRegular();
    final bold = await PdfGoogleFonts.notoSansThaiBold();

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
    final baseStyle = pw.TextStyle(font: regular, fontSize: 11, height: 1.55);
    final titleStyle = pw.TextStyle(font: bold, fontSize: 20, height: 1.35);
    final sectionStyle = pw.TextStyle(font: bold, fontSize: 13.5, height: 1.4);
    final subtitleStyle = pw.TextStyle(
      font: regular,
      fontSize: 10,
      color: PdfColors.grey700,
      height: 1.4,
    );
    final disclaimerStyle = pw.TextStyle(
      font: regular,
      fontSize: 10,
      color: PdfColors.grey800,
      height: 1.5,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 48, 44, 48),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'หน้า ${context.pageNumber} / ${context.pagesCount}',
            style: subtitleStyle,
            textAlign: pw.TextAlign.center,
          ),
        ),
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

            if (i > 0 &&
                (isDisclaimer ||
                    section.title.contains('เส้นทางชีวิต') ||
                    section.title.contains('แนวโน้ม') ||
                    section.title.startsWith('ข้อจำกัด'))) {
              widgets.add(pw.NewPage());
            }

            if (isTimeline) {
              widgets.add(
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  margin: const pw.EdgeInsets.only(bottom: 14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(section.title, style: sectionStyle),
                      pw.SizedBox(height: 8),
                      for (final paragraph in section.paragraphs) ...[
                        pw.Text(paragraph, style: baseStyle),
                        pw.SizedBox(height: 7),
                      ],
                    ],
                  ),
                ),
              );
              continue;
            }

            if (isDisclaimer) {
              widgets.add(pw.SizedBox(height: 10));
              widgets.add(
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.7),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(section.title, style: sectionStyle),
                      pw.SizedBox(height: 8),
                      for (final paragraph in section.paragraphs) ...[
                        pw.Text(paragraph, style: disclaimerStyle),
                        pw.SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
              );
              continue;
            }

            widgets.add(pw.Text(section.title, style: sectionStyle));
            widgets.add(pw.SizedBox(height: 8));
            for (final paragraph in section.paragraphs) {
              widgets.add(pw.Text(paragraph, style: baseStyle));
              widgets.add(pw.SizedBox(height: 7));
            }
            widgets.add(pw.SizedBox(height: 14));
          }

          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Divider(thickness: 0.6, color: PdfColors.grey400));
          widgets.add(pw.SizedBox(height: 10));
          widgets.add(
            pw.Text(
              'KnowMe Thai Beta — internal/beta export\n'
              'เนื้อหาจากรายงานที่มีอยู่แล้ว ไม่สร้างคำทำนายใหม่',
              style: subtitleStyle,
            ),
          );

          return widgets;
        },
      ),
    );

    final bytes = await pdf.save();
    return ThaiBetaPdfRenderResult(
      bytes: bytes,
      plainText: plain.toString(),
      document: polished,
    );
  }

  static String filenameFor(ThaiBetaReportExportDocument document) {
    return '${document.filenameStem}.pdf';
  }
}
