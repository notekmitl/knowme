import 'dart:convert';
import 'dart:typed_data';

import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_browser_print_stub.dart'
    if (dart.library.html) 'thai_beta_browser_print_web.dart'
    as bridge;

void triggerBrowserPrint() => bridge.triggerBrowserPrint();

void removeBrowserPrintDocument() => bridge.removeBrowserPrintMarkup();

void installBrowserPrintDocument(
  ThaiBetaReportExportDocument document, {
  Uint8List? infographicPng,
}) {
  bridge.installBrowserPrintMarkup(
    browserPrintMarkup(document, infographicPng: infographicPng),
    browserPrintCss,
  );
}

const browserPrintCss = '''
@media screen {
  #knowme-print-root { display: none !important; }
}
@media print {
  @page { size: A4; margin: 14mm 16mm 16mm; }
  html, body { width: auto !important; height: auto !important; overflow: visible !important; position: static !important; }
  body { margin: 8px !important; }
  body > :not(#knowme-print-root) { display: none !important; }
  #knowme-print-root { display: block !important; color: #151515; background: white; }
  #knowme-print-root * { box-sizing: border-box; }
  .knowme-print-report { width: 100%; font-family: "Noto Sans Thai", Tahoma, sans-serif; font-size: 10.5pt; line-height: 1.55; }
  .knowme-print-report header { border-bottom: 1px solid #a8a8a8; padding-bottom: 12pt; margin-bottom: 14pt; }
  .knowme-print-report h1 { font-size: 20pt; margin: 0 0 5pt; color: #111936; }
  .knowme-print-report .subtitle { color: #555; margin: 0; }
  .report-section { break-inside: avoid-page; page-break-inside: avoid; margin: 0 0 12pt; }
  .report-section h2 { break-after: avoid-page; page-break-after: avoid; font-size: 13.5pt; color: #18203f; margin: 0 0 6pt; }
  .report-section p { orphans: 3; widows: 3; margin: 0 0 5pt; overflow-wrap: anywhere; }
  .report-section.timeline { border: 1px solid #d9d5c9; border-radius: 6pt; padding: 9pt; background: #f7f5ef; }
  .report-section.disclaimer { border: 1px solid #d7a84d; border-radius: 6pt; padding: 9pt; background: #fff9ed; }
  .infographic-page { break-before: page; break-after: page; page-break-before: always; page-break-after: always; height: 265mm; margin: 0; display: flex; align-items: center; justify-content: center; }
  .infographic-page img { display: block; max-width: 100%; max-height: 258mm; object-fit: contain; }
}
''';

String browserPrintDocumentHtml(
  ThaiBetaReportExportDocument document, {
  Uint8List? infographicPng,
}) =>
    '<!doctype html><html lang="th"><head><meta charset="utf-8">'
    '<meta name="viewport" content="width=device-width,initial-scale=1">'
    '<title>${const HtmlEscape().convert(document.title)}</title>'
    '<style>$browserPrintCss</style></head><body>'
    '<div id="knowme-print-root">'
    '${browserPrintMarkup(document, infographicPng: infographicPng)}'
    '</div></body></html>';

String browserPrintMarkup(
  ThaiBetaReportExportDocument document, {
  Uint8List? infographicPng,
}) {
  final escapedTitle = const HtmlEscape().convert(document.title);
  final escapedSubtitle = const HtmlEscape().convert(document.subtitle);
  final body = StringBuffer()
    ..write('<article class="knowme-print-report">')
    ..write('<header><h1>$escapedTitle</h1>')
    ..write('<p class="subtitle">$escapedSubtitle</p></header>');
  var infographicInserted = false;
  for (
    var sectionIndex = 0;
    sectionIndex < document.sections.length;
    sectionIndex++
  ) {
    final section = document.sections[sectionIndex];
    body
      ..write('<section class="report-section ${section.kind.name}" ')
      ..write('data-section-id="${const HtmlEscape().convert(section.id)}">')
      ..write('<h2>${const HtmlEscape().convert(section.title)}</h2>');
    for (var index = 0; index < section.paragraphs.length; index++) {
      body
        ..write('<p data-paragraph-id="')
        ..write(const HtmlEscape().convert(section.paragraphIds[index]))
        ..write('">')
        ..write(const HtmlEscape().convert(section.paragraphs[index]))
        ..write('</p>');
    }
    body.write('</section>');
    if (!infographicInserted &&
        infographicPng != null &&
        sectionIndex == document.infographicInsertionSectionIndex) {
      _writeInfographic(body, document, infographicPng);
      infographicInserted = true;
    }
  }
  if (!infographicInserted && infographicPng != null) {
    _writeInfographic(body, document, infographicPng);
  }
  body.write('</article>');
  return body.toString();
}

void _writeInfographic(
  StringBuffer body,
  ThaiBetaReportExportDocument document,
  Uint8List png,
) {
  final label = const HtmlEscape().convert(
    document.infographic?.title ?? 'ภาพสรุปรายปี',
  );
  body
    ..write('<figure class="infographic-page">')
    ..write('<img alt="$label" src="data:image/png;base64,')
    ..write(base64Encode(png))
    ..write('"></figure>');
}
