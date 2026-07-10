import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_download.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_export_print_page.dart';

/// Capture/screenshot-only CTA to download the full Thai Beta report as PDF.
class ThaiBetaReportExportButton extends StatefulWidget {
  const ThaiBetaReportExportButton({
    super.key,
    required this.analysis,
    this.badges = const [],
  });

  final ThaiBetaAnalysis analysis;
  final List<ThaiPublicEvidenceBadgeBetaViewModel> badges;

  @override
  State<ThaiBetaReportExportButton> createState() =>
      _ThaiBetaReportExportButtonState();
}

class _ThaiBetaReportExportButtonState extends State<ThaiBetaReportExportButton> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.maybeOf(context);
    final document = ThaiBetaReportExportDocument.fromAnalysis(
      widget.analysis,
      badges: widget.badges,
    );

    try {
      final bytes = await ThaiBetaReportPdfExporter.buildBytes(document);
      final filename = ThaiBetaReportPdfExporter.filenameFor(document);
      final downloaded = await downloadBytesAsFile(
        bytes: bytes,
        filename: filename,
      );

      if (!mounted) return;

      if (downloaded) {
        messenger?.showSnackBar(
          SnackBar(content: Text('ดาวน์โหลดแล้ว: $filename')),
        );
      } else {
        // Non-web or download blocked — open print-friendly page.
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ThaiBetaExportPrintPage(document: document),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'สร้าง PDF ไม่สำเร็จ — เปิดหน้าพิมพ์แทน (Ctrl+P / Save as PDF)',
          ),
        ),
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ThaiBetaExportPrintPage(document: document),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.tonalIcon(
          key: const Key('thai_beta_report_export_button'),
          onPressed: _busy ? null : _export,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_busy ? 'กำลังสร้างรายงาน…' : 'ดาวน์โหลดรายงานเต็ม'),
        ),
      ),
    );
  }
}
