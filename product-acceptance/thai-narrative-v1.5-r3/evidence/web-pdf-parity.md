# Web/PDF canonical parity

All five acceptance fixtures use one `ThaiBetaReportExportDocument`. For each fixture, `*-web-text.txt` and `*-pdf-text.txt` are byte-identical, and the PDF exporter's `plainText` equals the document `fullPlainText`.

Parity pairs: 5/5 passed. The report-level hook and cautious past synthesis are therefore present in both canonical Web/export text and PDF text. Unknown-time omissions remain identical across both paths.
