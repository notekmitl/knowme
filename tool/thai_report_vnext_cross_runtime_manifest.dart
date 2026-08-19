import 'dart:convert';

import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

Map<String, Object?> buildThaiReportVnextCrossRuntimeManifest() => {
  'schema': 'thai-report-experience-infographic-vnext/1',
  'cases': [
    for (final known in [true, false]) _case(known),
  ],
};

String encodeThaiReportVnextCrossRuntimeManifest() =>
    const JsonEncoder.withIndent(
      ' ',
    ).convert(buildThaiReportVnextCrossRuntimeManifest());

Map<String, Object?> _case(bool known) {
  final asOf = DateTime.utc(2026, 8, 18, 8);
  final analysis = ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'CrossRuntime',
      lastName: known ? 'Known' : 'Unknown',
      birthDate: DateTime(1982, 6, 6),
      birthHour: known ? 10 : null,
      birthMinute: known ? 30 : 0,
      birthTimeUnknown: !known,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
    startedAt: asOf,
    asOf: asOf,
  );
  final document = ThaiBetaReportExportDocument.candidate(analysis);
  final annual = document.infographic!;
  return {
    'mode': known ? 'Known' : 'Unknown',
    'title': document.title,
    'subtitle': document.subtitle,
    'fullPlainText': document.fullPlainText,
    'infographicInsertionSectionIndex':
        document.infographicInsertionSectionIndex,
    'sections': [
      for (final section in document.sections)
        {
          'id': section.id,
          'kind': section.kind.name,
          'title': section.title,
          'paragraphIds': section.paragraphIds,
          'paragraphs': section.paragraphs,
          'fieldSource': section.fieldSource,
          'visibilityRule': section.visibilityRule,
          'knownUnknownRule': section.knownUnknownRule,
          'traceIds': section.traceIds,
        },
    ],
    'annual': {
      'year': annual.buddhistYear,
      'theme': annual.theme,
      'overview': annual.overview,
      'categories': [
        for (final category in annual.categories)
          {
            'id': category.id,
            'title': category.title,
            'summary': category.summary,
            'iconName': category.iconName,
            'traceIds': category.traceIds,
          },
      ],
      'opportunity': annual.opportunity,
      'caution': annual.caution,
      'primaryAdvice': annual.primaryAdvice,
      'disclaimer': annual.disclaimer,
      'monthlyTimelineAvailable': annual.monthlyTimelineAvailable,
      'monthlyGapReason': annual.monthlyGapReason,
      'traceIds': annual.traceIds,
    },
  };
}
