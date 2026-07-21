import 'package:flutter/material.dart';

import '../../application/thai_beta_analysis.dart';
import '../widgets/thai_beta_debug_panel.dart';
import '../widgets/thai_beta_progress_bar.dart';
import '../widgets/thai_beta_summary_card.dart';
import '../widgets/thai_beta_transparency_banner.dart';
import 'thai_beta_report_page.dart';

/// Reassurance step shown immediately *before* the report: it tells the user
/// exactly what was used to analyze them (birth info, sunrise, Thai astrological
/// date, and why the date may have shifted) before they start reading.
class ThaiBetaSummaryPage extends StatelessWidget {
  const ThaiBetaSummaryPage({super.key, required this.analysis});

  final ThaiBetaAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    if (!analysis.isSuccess || analysis.normalizedSnapshot == null) {
      return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false, title: const Text('ข้อมูลที่ใช้วิเคราะห์')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              analysis.errorMessage ?? 'เกิดข้อผิดพลาดในการวิเคราะห์',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final snapshot = analysis.normalizedSnapshot!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ดูดวงไทย — งานวิจัย'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ThaiBetaProgressBar(current: ThaiBetaStep.review),
            Expanded(
              child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              children: [
                ThaiBetaSummaryCard(input: analysis.input, snapshot: snapshot),
                const SizedBox(height: 16),
                ThaiBetaTransparencyBanner(
                  input: analysis.input,
                  snapshot: snapshot,
                ),
                const SizedBox(height: 16),
                ThaiBetaDebugPanel(
                  snapshot: snapshot,
                  reportHash: analysis.reportHash,
                ),
              ],
            ),
          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ThaiBetaReportPage(analysis: analysis),
            ),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('ยืนยันข้อมูลและดูผล'),
        ),
      ),
    );
  }
}
