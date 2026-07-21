import 'package:flutter/material.dart';

import '../../application/thai_beta_analysis.dart';
import '../../application/thai_beta_evidence_badge_audience.dart';
import '../../domain/thai_beta_input.dart';
import 'thai_beta_report_page.dart';

/// QA-only capture route with fixed sample birth data — **not** real user data.
///
/// Route: `/beta/thai/capture-qa`
class ThaiBetaQaSampleCapturePage extends StatelessWidget {
  const ThaiBetaQaSampleCapturePage({super.key});

  @visibleForTesting
  static ThaiBetaAnalysis sampleAnalysis() {
    return ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Capture',
        lastName: 'Preview',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThaiBetaReportPage(
      analysis: sampleAnalysis(),
      audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      screenshotModeOverride: true,
      showCaptureModeBanner: true,
      captureBannerMessage: 'QA Sample Report — ไม่ใช่ข้อมูลของผู้ใช้',
    );
  }
}
