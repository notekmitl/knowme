import 'package:flutter/material.dart';

import 'features/thai_beta/application/thai_beta_analysis.dart';
import 'features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'features/thai_beta/domain/thai_beta_input.dart';
import 'features/thai_beta/presentation/pages/thai_beta_report_page.dart';

/// Local-only deterministic visual QA entrypoint for the report experience
/// candidate. Production continues to build from `lib/main.dart`.
void main() {
  final unknown = Uri.base.queryParameters['mode'] == 'unknown';
  final asOf = DateTime.utc(2026, 8, 7);
  final analysis = ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'QA',
      lastName: unknown ? 'Unknown' : 'Known',
      birthDate: DateTime(1982, 6, 6),
      birthHour: unknown ? null : 0,
      birthMinute: unknown ? 0 : 35,
      birthTimeUnknown: unknown,
      province: 'เชียงใหม่',
      provinceKey: 'chiang_mai',
    ),
    startedAt: asOf,
    asOf: asOf,
  );
  runApp(_ThaiReportVnextPreview(analysis: analysis, unknown: unknown));
}

class _ThaiReportVnextPreview extends StatelessWidget {
  const _ThaiReportVnextPreview({
    required this.analysis,
    required this.unknown,
  });

  final ThaiBetaAnalysis analysis;
  final bool unknown;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1b2852)),
        useMaterial3: true,
      ),
      home: ThaiBetaReportPage(
        analysis: analysis,
        audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        screenshotModeOverride: true,
        showCaptureModeBanner: true,
        captureBannerMessage: unknown
            ? 'QA Candidate — Unknown time'
            : 'QA Candidate — Known time',
      ),
    );
  }
}
