import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import '../export/thai_beta_browser_print.dart';

/// Print-friendly full-report layout (browser Save as PDF fallback).
///
/// No progress stepper, no fixed feedback bar, no nested scroll tricks —
/// one long column for Ctrl+P / Save as PDF.
class ThaiBetaExportPrintPage extends StatelessWidget {
  const ThaiBetaExportPrintPage({super.key, required this.document});

  final ThaiBetaReportExportDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์ / บันทึกเป็น PDF'),
        actions: [
          TextButton.icon(
            key: const Key('thai_beta_export_print_action'),
            onPressed: () {
              if (kIsWeb) {
                triggerBrowserPrint();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ใช้เมนู Print ของระบบเพื่อบันทึกเป็น PDF'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('พิมพ์'),
          ),
        ],
      ),
      body: ListView(
        key: const Key('thai_beta_export_print_page'),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        children: [
          Text(document.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            document.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'หากดาวน์โหลด PDF อัตโนมัติไม่ได้ ให้กดพิมพ์ แล้วเลือก Save as PDF',
            style: theme.textTheme.bodySmall,
          ),
          const Divider(height: 32),
          for (final section in document.sections) ...[
            Text(
              section.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs) ...[
              Text(paragraph, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
