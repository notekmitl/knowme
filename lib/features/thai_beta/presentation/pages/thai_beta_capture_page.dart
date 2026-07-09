import 'package:flutter/material.dart';

import '../../application/thai_beta_evidence_badge_audience.dart';
import '../../application/thai_beta_analysis.dart';
import '../../domain/thai_beta_input.dart';
import 'thai_beta_report_page.dart';

/// Static long-page report for GoFullPage / full-page capture extensions.
///
/// Route: `/beta/thai/capture` — does not change the normal beta flow output.
class ThaiBetaCapturePage extends StatelessWidget {
  const ThaiBetaCapturePage({super.key});

  static ThaiBetaAnalysis _sampleAnalysis() {
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
    final analysis = _sampleAnalysis();
    return ThaiBetaReportPage(
      analysis: analysis,
      audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      screenshotModeOverride: true,
      showCaptureModeBanner: true,
    );
  }
}
