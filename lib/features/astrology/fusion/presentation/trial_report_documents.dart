import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'trial_reading_copy.dart';

/// Projects only display fields after the original report has selected claims.
/// The same Thai document feeds the visible report and browser-print sync.
abstract final class TrialReportDocuments {
  static ThaiBetaReportExportDocument thai(
    ThaiBetaReportExportDocument source,
  ) {
    final image = source.infographic;
    return ThaiBetaReportExportDocument(
      title: source.title,
      subtitle: source.subtitle,
      filenameStem: source.filenameStem,
      predictiveRuntimeV2: source.predictiveRuntimeV2,
      sections: [
        for (final section in source.sections)
          ThaiBetaReportExportSection(
            title: TrialReadingCopy.thai(section.title),
            paragraphs: section.paragraphs.map(TrialReadingCopy.thai).toList(),
            kind: section.kind,
            id: section.id,
            fieldSource: section.fieldSource,
            visibilityRule: section.visibilityRule,
            knownUnknownRule: section.knownUnknownRule,
            traceIds: section.traceIds,
          ),
      ],
      infographic: image == null
          ? null
          : ThaiBetaAnnualInfographicData(
              buddhistYear: image.buddhistYear,
              periodLabel: image.periodLabel,
              theme: TrialReadingCopy.thai(image.theme),
              overview: TrialReadingCopy.thai(image.overview),
              categories: [
                for (final category in image.categories)
                  ThaiBetaAnnualInfographicCategory(
                    id: category.id,
                    title: category.title,
                    summary: TrialReadingCopy.thai(category.summary),
                    iconName: category.iconName,
                    traceIds: category.traceIds,
                  ),
              ],
              opportunity: TrialReadingCopy.thai(image.opportunity),
              caution: TrialReadingCopy.thai(image.caution),
              primaryAdvice: TrialReadingCopy.thai(image.primaryAdvice),
              disclaimer: TrialReadingCopy.thai(image.disclaimer),
              monthlyTimelineAvailable: image.monthlyTimelineAvailable,
              monthlyGapReason: TrialReadingCopy.thai(image.monthlyGapReason),
              traceIds: image.traceIds,
            ),
    );
  }

  static BaziCompatibilityReport chinese(
    BaziCompatibilityReport source,
    BaziChartModel chart,
  ) {
    final profile = BaziSymbolicReadingEngine.profileFor(chart.dayMaster.stem);
    // This exact, known template introduces a decorative metaphor. Retain the
    // calculated Day Master and explain its role without inventing a trait.
    final metaphor =
        'แกนดวงของคุณคือ ${profile.name} เปรียบเหมือน “${profile.symbol}” ';
    String text(String value) => TrialReadingCopy.chinese(
      value.replaceAll(
        metaphor,
        'ดวงจีนใช้ ${profile.name} เป็นธาตุประจำวัน เพื่ออ่านลักษณะของคุณ ',
      ),
    );
    return BaziCompatibilityReport(
      title: source.title,
      subtitle: text(source.subtitle),
      sections: [
        for (final section in source.sections)
          BaziCompatibilityReportSection(
            title: text(section.title),
            intro: section.intro == null ? null : text(section.intro!),
            paragraphs: section.paragraphs.map(text).toList(),
            rows: [
              for (final row in section.rows)
                BaziCompatibilityReportRow(
                  label: row.label,
                  value: text(row.value),
                ),
            ],
            notes: section.notes.map(text).toList(),
          ),
      ],
    );
  }
}
