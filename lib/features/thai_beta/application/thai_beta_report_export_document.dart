/// Safe, plain-text export document built only from consumer-facing report copy.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';

import 'thai_beta_report_export_polish.dart';
import 'thai_beta_report_export_safety.dart';
import 'narrative/thai_beta_narrative_composer.dart';

class ThaiBetaReportExportSection {
  const ThaiBetaReportExportSection({
    required this.title,
    required this.paragraphs,
    this.kind = ThaiBetaReportExportSectionKind.body,
  });

  final String title;
  final List<String> paragraphs;
  final ThaiBetaReportExportSectionKind kind;
}

enum ThaiBetaReportExportSectionKind { body, timeline, disclaimer }

/// Structured export payload — no engine/Canon/raw ids.
class ThaiBetaReportExportDocument {
  const ThaiBetaReportExportDocument({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.filenameStem,
  });

  final String title;
  final String subtitle;
  final List<ThaiBetaReportExportSection> sections;
  final String filenameStem;

  String get fullPlainText {
    final buf = StringBuffer()
      ..writeln(title)
      ..writeln(subtitle);
    for (final section in sections) {
      buf.writeln(section.title);
      for (final p in section.paragraphs) {
        buf.writeln(p);
      }
    }
    return buf.toString();
  }

  /// Builds from existing [ThaiBetaAnalysis] consumer view only.
  static ThaiBetaReportExportDocument fromAnalysis(
    ThaiBetaAnalysis analysis, {
    List<ThaiPublicEvidenceBadgeBetaViewModel> badges = const [],
  }) {
    if (analysis.consumerViewState == null) {
      return const ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'ไม่พบข้อมูลรายงาน',
        sections: [],
        filenameStem: 'knowme-thai-report',
      );
    }

    final view = ThaiBetaNarrativeComposer.narrativeView(analysis);

    final sections = <ThaiBetaReportExportSection>[];
    final coreReading = ThaiBirthProfileCoreReading.fromAnalysis(
      analysis,
      consumerView: view,
    );
    sections.add(_section(coreReading.title, [coreReading.subtitle]));
    sections.addAll(
      coreReading.sections.map(
        (section) => _section(section.title, section.publicParagraphs),
      ),
    );

    // Thai Beta owns one lifelong Core Reading. Only time-dependent material
    // and non-duplicated transparency/disclaimer content follows it.
    final timeline = view.lifeTimeline;
    if (timeline != null) {
      sections.addAll(_timelineSections(timeline));
    }

    final prediction = view.futurePrediction;
    if (prediction != null) {
      sections.addAll(_predictionSections(prediction));
    }

    sections.add(
      _section('ที่มาของผลวิเคราะห์', [
        view.sourceTransparency.dataUsed,
        view.sourceTransparency.calculation,
        view.sourceTransparency.meaning,
      ]),
    );

    if (view.disclaimers.isNotEmpty) {
      sections.add(
        _section(
          'ข้อจำกัด',
          view.disclaimers,
          kind: ThaiBetaReportExportSectionKind.disclaimer,
        ),
      );
    }

    final uniqueSafeBadges = <String, ThaiPublicEvidenceBadgeBetaViewModel>{};
    for (final badge in badges.where((badge) => badge.eligible)) {
      uniqueSafeBadges.putIfAbsent(
        '${badge.badgeLabel}\u0000${badge.cautionCopy}',
        () => badge,
      );
    }
    final safeBadges = uniqueSafeBadges.values
        .map(
          (b) => _section('รายละเอียดหลักฐาน', [
            b.badgeLabel == 'มีแหล่งอ้างอิงใน Canon'
                ? 'มีที่มาจากตำราอ้างอิง'
                : b.badgeLabel,
            b.cautionCopy,
          ]),
        )
        .toList();
    if (safeBadges.isNotEmpty) {
      sections.add(
        _section('ที่มาของคำวิเคราะห์', [
          'รายงานนี้มีข้อมูลอ้างอิงจากตำรา รายละเอียดนี้ช่วยบอกที่มา '
              'แต่ไม่ใช่การรับรองความแม่นยำ',
        ]),
      );
      sections.addAll(safeBadges);
    }

    final scrubbed = sections
        .map(
          (s) => ThaiBetaReportExportSection(
            title: ThaiBetaReportExportSafety.scrub(s.title),
            paragraphs: s.paragraphs
                .map(ThaiBetaReportExportSafety.scrub)
                .where((p) => p.trim().isNotEmpty)
                .toList(),
            kind: s.kind,
          ),
        )
        .where((s) => s.title.trim().isNotEmpty || s.paragraphs.isNotEmpty)
        .toList();

    // Final presentation polish (also re-applied in PDF exporter).
    return polishForPdf(
      ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'รายงานฉบับสำหรับอ่านและบันทึกส่วนตัว',
        sections: scrubbed,
        filenameStem: 'knowme-thai-report',
      ),
    );
  }

  /// Re-apply presentation polish before PDF bytes are written.
  static ThaiBetaReportExportDocument polishForPdf(
    ThaiBetaReportExportDocument document,
  ) {
    final sections = <ThaiBetaReportExportSection>[];
    for (final section in document.sections) {
      final title = ThaiBetaReportExportPolish.polishTitle(section.title);
      final paragraphs = ThaiBetaReportExportPolish.dedupeParagraphs(
        title,
        section.paragraphs,
      );
      if (title.isEmpty && paragraphs.isEmpty) continue;
      sections.add(
        ThaiBetaReportExportSection(
          title: title,
          paragraphs: paragraphs,
          kind: section.kind,
        ),
      );
    }
    return ThaiBetaReportExportDocument(
      title: ThaiBetaReportExportPolish.polishTitle(document.title),
      subtitle: ThaiBetaReportExportPolish.polishLine(document.subtitle),
      sections: sections,
      filenameStem: document.filenameStem,
    );
  }

  static ThaiBetaReportExportSection _section(
    String title,
    List<String> paragraphs, {
    ThaiBetaReportExportSectionKind kind = ThaiBetaReportExportSectionKind.body,
  }) {
    final polishedTitle = ThaiBetaReportExportPolish.polishTitle(title);
    return ThaiBetaReportExportSection(
      title: polishedTitle,
      paragraphs: ThaiBetaReportExportPolish.dedupeParagraphs(
        polishedTitle,
        paragraphs,
      ),
      kind: kind,
    );
  }

  static List<ThaiBetaReportExportSection> _timelineSections(
    ThaiMirrorLifeTimelineState timeline,
  ) {
    final out = <ThaiBetaReportExportSection>[
      _section(timeline.sectionTitle, [
        timeline.sectionIntro,
      ], kind: ThaiBetaReportExportSectionKind.timeline),
    ];

    final stage = timeline.currentStage;
    final stageLines = <String>[
      '${stage.phaseName} · อายุ ${stage.ageLabel}',
      stage.planetLine,
      // Keyword is already on planetLine after "•" — do not echo it again.
      ThaiBetaReportExportPolish.polishTimingCopy(stage.intro),
    ];

    if (stage.yearsRemaining > 0) {
      stageLines.add(
        'เหลืออีกประมาณ ${stage.yearsRemaining} ปีก่อนเปลี่ยนช่วง',
      );
    } else if (!stageLines.any(
      (line) => line.contains('กำลังอยู่ช่วงปลายของจังหวะนี้'),
    )) {
      stageLines.add('กำลังอยู่ช่วงปลายของจังหวะนี้');
    }

    final previous = ThaiBetaReportExportPolish.neighbourLabel(
      stage.previousLabel,
      prefix: 'ช่วงก่อนหน้า: ',
    );
    final next = ThaiBetaReportExportPolish.neighbourLabel(
      stage.nextLabel,
      prefix: 'ช่วงถัดไป: ',
    );
    if (previous.isNotEmpty) stageLines.add(previous);
    if (next.isNotEmpty) stageLines.add(next);

    out.add(
      _section(
        stage.eyebrow,
        stageLines,
        kind: ThaiBetaReportExportSectionKind.timeline,
      ),
    );

    final analysis = timeline.currentAnalysis;
    if (analysis != null && !analysis.isEmpty) {
      out.add(
        _section(analysis.title, [
          analysis.stageLabel,
          analysis.dominantInfluences,
          ...analysis.reasons,
        ], kind: ThaiBetaReportExportSectionKind.timeline),
      );
    }

    final preview = timeline.futurePreview;
    if (preview != null) {
      out.add(
        _section(preview.title, [
          preview.intro,
          preview.transitionLabel,
          if (preview.elementShiftLine.isNotEmpty) preview.elementShiftLine,
          preview.opportunitiesLine,
          preview.challengesLine,
        ], kind: ThaiBetaReportExportSectionKind.timeline),
      );
    }

    for (final period in timeline.periods) {
      final body = <String>[
        period.planetLine,
        if (period.isCurrent && period.lifeDomains.isNotEmpty)
          for (final domain in period.lifeDomains) ...[
            domain.title,
            domain.body,
          ]
        else ...[
          period.summary,
          period.whatChanges,
          period.easier,
          period.harder,
          period.comparison,
          period.evidenceLine,
          if (period.advice.isNotEmpty) period.advice,
        ],
      ];
      out.add(
        _section(
          '${period.phaseName} (${period.ageLabel})',
          body,
          kind: ThaiBetaReportExportSectionKind.timeline,
        ),
      );
    }
    return out;
  }

  static List<ThaiBetaReportExportSection> _predictionSections(
    PredictionSectionModel prediction,
  ) {
    final out = <ThaiBetaReportExportSection>[
      _section(prediction.sectionTitle, [
        prediction.sectionIntro,
        if (prediction.transitionLine.isNotEmpty) prediction.transitionLine,
      ]),
    ];
    for (final window in prediction.windows) {
      out.add(
        _section('${window.windowLabel} — ${window.timeframeLabel}', [
          window.summary,
          window.topOpportunity,
          window.topRisk,
          window.confidenceLabel,
          window.why,
          window.whyNow,
          window.whatToWatch,
          window.evidenceDetail,
        ]),
      );
    }
    if (prediction.closingAdvice.isNotEmpty) {
      out.add(_section('คำแนะนำปิดท้ายช่วงถัดไป', [prediction.closingAdvice]));
    }
    return out;
  }
}
