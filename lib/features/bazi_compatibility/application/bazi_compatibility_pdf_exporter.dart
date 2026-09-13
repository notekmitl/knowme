import 'dart:typed_data';

import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BaziCompatibilityPdfFonts {
  const BaziCompatibilityPdfFonts({
    required this.thaiRegular,
    required this.thaiBold,
    required this.cjkRegular,
  });

  final Uint8List thaiRegular;
  final Uint8List thaiBold;
  final Uint8List cjkRegular;
}

abstract final class BaziCompatibilityPdfExporter {
  static Future<Uint8List> build({
    required BaziCompatibilityReport report,
    required BaziCompatibilityPdfFonts fonts,
  }) async {
    final thaiRegular = pw.Font.ttf(ByteData.sublistView(fonts.thaiRegular));
    final thaiBold = pw.Font.ttf(ByteData.sublistView(fonts.thaiBold));
    final cjk = pw.Font.ttf(ByteData.sublistView(fonts.cjkRegular));
    final document = pw.Document(
      title: report.title,
      author: 'KnowMe',
      subject: 'KnowMe BaZi Compatibility V1 owner review',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 42, 42, 48),
        theme: pw.ThemeData.withFont(
          base: thaiRegular,
          bold: thaiBold,
          fontFallback: [cjk],
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(right: 8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ),
        build: (_) => [
          pw.Text(
            report.title,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(report.subtitle, style: const pw.TextStyle(fontSize: 11.5)),
          pw.SizedBox(height: 14),
          for (final section in report.sections) ...[
            pw.Inseparable(child: _section(section)),
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _section(BaziCompatibilityReportSection section) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            section.title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (section.intro case final intro?) ...[
            pw.SizedBox(height: 5),
            pw.Text(intro, style: const pw.TextStyle(fontSize: 10.5)),
          ],
          for (final row in section.rows) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 112,
                  child: pw.Text(
                    row.label,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    row.value,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
          for (final note in section.notes) ...[
            pw.SizedBox(height: 6),
            pw.Text('• $note', style: const pw.TextStyle(fontSize: 10.5)),
          ],
        ],
      ),
    );
  }
}
