import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import '../export/thai_beta_browser_print.dart';
import '../widgets/thai_beta_shared_report_view.dart';

/// Print-friendly full-report preview backed by the same presentation model as
/// the on-screen report and dedicated PDF. On Web, the semantic print DOM is
/// what Chrome paginates; Flutter remains the interactive preview.
class ThaiBetaExportPrintPage extends StatefulWidget {
  const ThaiBetaExportPrintPage({
    super.key,
    required this.document,
    this.infographicPng,
  });

  final ThaiBetaReportExportDocument document;
  final Uint8List? infographicPng;

  @override
  State<ThaiBetaExportPrintPage> createState() =>
      _ThaiBetaExportPrintPageState();
}

class _ThaiBetaExportPrintPageState extends State<ThaiBetaExportPrintPage> {
  final GlobalKey _infographicBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      installBrowserPrintDocument(
        widget.document,
        infographicPng: widget.infographicPng,
      );
    }
  }

  @override
  void dispose() {
    if (kIsWeb) removeBrowserPrintDocument();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์ / บันทึกหน้าเว็บเป็น PDF'),
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
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          ThaiBetaSharedReportView(
            document: widget.document,
            infographicBoundaryKey: _infographicBoundaryKey,
          ),
        ],
      ),
    );
  }
}
