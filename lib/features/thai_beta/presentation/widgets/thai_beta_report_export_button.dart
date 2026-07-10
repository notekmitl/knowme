import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_download.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_export_print_page.dart';

/// Capture/screenshot-only export chrome — not gated by evidence badge flags.
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
  String? _errorMessage;

  ThaiBetaReportExportDocument _document() {
    return ThaiBetaReportExportDocument.fromAnalysis(
      widget.analysis,
      badges: widget.badges,
    );
  }

  Future<void> _openPrintPage([ThaiBetaReportExportDocument? document]) async {
    final doc = document ?? _document();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThaiBetaExportPrintPage(document: doc),
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    final document = _document();

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
        setState(() {
          _errorMessage =
              'ดาวน์โหลดอัตโนมัติไม่ได้ — ใช้ปุ่มเปิดหน้าพิมพ์ / Save as PDF';
        });
        await _openPrintPage(document);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'สร้าง PDF ไม่สำเร็จ — กด “เปิดหน้าพิมพ์” แล้ว Save as PDF';
      });
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'สร้าง PDF ไม่สำเร็จ — เปิดหน้าพิมพ์แทน (Ctrl+P / Save as PDF)',
          ),
        ),
      );
      await _openPrintPage(document);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      key: const Key('thai_beta_report_export_bar'),
      color: scheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              key: const Key('thai_beta_report_export_button'),
              onPressed: _busy ? null : _exportPdf,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              icon: _busy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _busy ? 'กำลังสร้าง PDF…' : 'ดาวน์โหลดรายงานเต็ม',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('thai_beta_report_export_print_button'),
              onPressed: _busy ? null : () => _openPrintPage(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.print_outlined),
              label: const Text('เปิดหน้าพิมพ์ / Save as PDF'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                key: const Key('thai_beta_report_export_error'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
