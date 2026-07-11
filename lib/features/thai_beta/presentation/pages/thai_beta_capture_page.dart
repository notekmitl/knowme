import 'package:flutter/material.dart';

import '../../application/thai_beta_current_analysis.dart';
import '../../application/thai_beta_evidence_badge_audience.dart';
import 'thai_beta_landing_page.dart';
import 'thai_beta_report_page.dart';

/// Real-user capture/export route for GoFullPage debugging and PDF export.
///
/// Route: `/beta/thai/capture` — uses [ThaiBetaCurrentAnalysis] only.
/// Never falls back to QA sample data.
class ThaiBetaCapturePage extends StatelessWidget {
  const ThaiBetaCapturePage({super.key});

  void _goCreateReport(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ThaiBetaLandingPage()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ThaiBetaCurrentAnalysis.current;
    if (analysis == null || !analysis.isSuccess) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ยังไม่มีรายงานสำหรับส่งออก',
                      key: const Key('thai_beta_capture_no_report'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'สร้างรายงานจาก /beta/thai ก่อน แล้วกลับมาที่หน้านี้เพื่อดาวน์โหลด PDF',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('thai_beta_capture_back_to_create'),
                      onPressed: () => _goCreateReport(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('กลับไปสร้างรายงาน'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ThaiBetaReportPage(
      analysis: analysis,
      audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      screenshotModeOverride: true,
      showCaptureModeBanner: true,
    );
  }
}
