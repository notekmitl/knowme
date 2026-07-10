import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'thai_beta_report_export_document.dart';

/// Builds a downloadable PDF from a [ThaiBetaReportExportDocument].
///
/// Uses Noto Sans Thai via [PdfGoogleFonts] so Thai glyphs render correctly.
abstract final class ThaiBetaReportPdfExporter {
  static const String defaultFilename = 'knowme-thai-report.pdf';

  static Future<Uint8List> buildBytes(ThaiBetaReportExportDocument document) async {
    final regular = await PdfGoogleFonts.notoSansThaiRegular();
    final bold = await PdfGoogleFonts.notoSansThaiBold();

    final pdf = pw.Document();
    final baseStyle = pw.TextStyle(font: regular, fontSize: 11, height: 1.4);
    final titleStyle = pw.TextStyle(font: bold, fontSize: 18, height: 1.3);
    final sectionStyle = pw.TextStyle(font: bold, fontSize: 13, height: 1.3);
    final subtitleStyle = pw.TextStyle(
      font: regular,
      fontSize: 10,
      color: PdfColors.grey700,
      height: 1.3,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(document.title, style: titleStyle),
            pw.SizedBox(height: 4),
            pw.Text(document.subtitle, style: subtitleStyle),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 12),
          ];

          for (final section in document.sections) {
            widgets.add(pw.Text(section.title, style: sectionStyle));
            widgets.add(pw.SizedBox(height: 6));
            for (final paragraph in section.paragraphs) {
              widgets.add(pw.Text(paragraph, style: baseStyle));
              widgets.add(pw.SizedBox(height: 4));
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          widgets.add(pw.SizedBox(height: 8));
          widgets.add(
            pw.Text(
              'KnowMe Thai Beta — internal/beta export. '
              'เนื้อหาจากรายงานที่มีอยู่แล้ว ไม่สร้างคำทำนายใหม่',
              style: subtitleStyle,
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  static String filenameFor(ThaiBetaReportExportDocument document) {
    return '${document.filenameStem}.pdf';
  }
}
