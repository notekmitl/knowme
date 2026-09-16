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
      subject: 'KnowMe Chinese Astrology BaZi Reader V2',
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
          for (var index = 0; index < report.sections.length; index++) ...[
            ..._sectionWidgets(report.sections[index]),
            if (index < report.sections.length - 1) pw.SizedBox(height: 8),
          ],
        ],
      ),
    );
    return document.save();
  }

  static List<pw.Widget> _sectionWidgets(
    BaziCompatibilityReportSection section,
  ) {
    final hasLongRows = section.rows.any((row) => row.value.contains('\n\n'));
    if (!hasLongRows) {
      return [pw.Inseparable(child: _section(section))];
    }

    final widgets = <pw.Widget>[
      pw.Inseparable(
        child: _longSectionLead(
          section,
          firstRow: section.rows.isEmpty ? null : section.rows.first,
        ),
      ),
    ];
    for (final row in section.rows.skip(1)) {
      widgets
        ..add(pw.SizedBox(height: 6))
        ..add(pw.Inseparable(child: _longRow(row)));
    }
    if (section.notes.isNotEmpty) {
      widgets
        ..add(pw.SizedBox(height: 6))
        ..add(pw.Inseparable(child: _notesCard(section.notes)));
    }
    return widgets;
  }

  static pw.Widget _longSectionLead(
    BaziCompatibilityReportSection section, {
    required BaziCompatibilityReportRow? firstRow,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: _cardDecoration(),
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
          for (final paragraph in section.paragraphs) ...[
            pw.SizedBox(height: 6),
            pw.Text(paragraph, style: const pw.TextStyle(fontSize: 10.5)),
          ],
          if (firstRow != null) ...[
            pw.SizedBox(height: 9),
            _longRowBody(firstRow),
          ],
        ],
      ),
    );
  }

  static pw.Widget _longRow(BaziCompatibilityReportRow row) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: _longRowBody(row),
    );
  }

  static pw.Widget _longRowBody(BaziCompatibilityReportRow row) {
    final parts = row.value.split('\n\n');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          row.label,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(parts.first, style: const pw.TextStyle(fontSize: 10.5)),
        for (final evidence in parts.skip(1)) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            evidence,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }

  static pw.Widget _notesCard(List<String> notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < notes.length; index++) ...[
            if (index > 0) pw.SizedBox(height: 4),
            pw.Text(
              '— ${notes[index]}',
              style: const pw.TextStyle(fontSize: 10.5),
            ),
          ],
        ],
      ),
    );
  }

  static pw.BoxDecoration _cardDecoration() => pw.BoxDecoration(
    border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
    borderRadius: pw.BorderRadius.circular(6),
  );

  static pw.Widget _section(BaziCompatibilityReportSection section) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: _cardDecoration(),
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
          for (final paragraph in section.paragraphs) ...[
            pw.SizedBox(height: 6),
            pw.Text(paragraph, style: const pw.TextStyle(fontSize: 10.5)),
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
            pw.SizedBox(height: 4),
            pw.Text('— $note', style: const pw.TextStyle(fontSize: 10.5)),
          ],
        ],
      ),
    );
  }
}
