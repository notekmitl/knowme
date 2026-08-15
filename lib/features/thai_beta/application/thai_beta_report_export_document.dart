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
    final reportHook = view.hero.summary
        .split('\n\n')
        .map((paragraph) => paragraph.trim())
        .firstWhere((paragraph) => paragraph.isNotEmpty, orElse: () => '');
    if (view.hero.headline.trim().isNotEmpty && reportHook.isNotEmpty) {
      sections.add(_section(view.hero.headline, [reportHook]));
    }
    sections.addAll(
      coreReading.sections
          .where((section) => !section.isMethodology)
          .map((section) => _section(section.title, section.publicParagraphs)),
    );

    // Thai Beta owns one lifelong Core Reading. Only time-dependent material
    // and non-duplicated transparency/disclaimer content follows it.
    final timeline = view.lifeTimeline;
    if (timeline != null) {
      sections.addAll(_timelinePastAndCurrentSections(timeline));
    }

    final prediction = view.futurePrediction;
    if (prediction != null) {
      sections.addAll(_predictionSections(prediction));
    }

    if (timeline != null) {
      sections.addAll(_timelineLongTermSections(timeline));
    }

    final methodology = coreReading.sections.singleWhere(
      (section) => section.isMethodology,
    );
    sections.add(
      _section(methodology.title, [
        'ข้อมูลวัน เวลา และสถานที่เกิด',
        'วิธีนับวันทางโหราศาสตร์ไทย',
        ...methodology.claims.map((claim) => claim.text),
        if (methodology.factRows.isNotEmpty) ...[
          ThaiBirthProfileCoreReadingCopy.chartStructureTitle,
          ...methodology.factRows.map((row) => row.publicText),
        ],
        'ความหมายและข้อจำกัดของผลลัพธ์',
      ]),
    );

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

    if (coreReading.omissions.isNotEmpty) {
      sections.add(
        _section(
          ThaiBirthProfileCoreReadingCopy.omissionsTitle,
          [
            'ระบบตัดหัวข้อต่อไปนี้ออกแทนการเติมคำทำนายที่ไม่มีข้อมูลรองรับ',
            ...coreReading.omissions.map((omission) => omission.publicText),
          ],
          kind: ThaiBetaReportExportSectionKind.disclaimer,
        ),
      );
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

  static List<ThaiBetaReportExportSection> _timelinePastAndCurrentSections(
    ThaiMirrorLifeTimelineState timeline,
  ) {
    final out = <ThaiBetaReportExportSection>[
      _section('แผนที่ชีวิต', [
        timeline.sectionIntro,
      ], kind: ThaiBetaReportExportSectionKind.timeline),
    ];

    final past = timeline.periods.where((period) => period.isPast).toList();
    if (past.isNotEmpty) {
      out.add(
        _section('ธีมสำหรับทบทวนอดีต', const [
          'ส่วนนี้ใช้ตั้งคำถามกับความทรงจำจริง ไม่ใช่ข้อสรุปว่าเหตุการณ์ใดเคยเกิดขึ้น',
        ], kind: ThaiBetaReportExportSectionKind.timeline),
      );
      for (final period in past) {
        out.add(_pastReflectionSection(period));
      }
    }

    final stage = timeline.currentStage;
    final stageLines = <String>[
      stage.eyebrow,
      '${stage.phaseName} · อายุ ${stage.ageLabel} · ${stage.planetLine}',
      ThaiBetaReportExportPolish.polishTimingCopy(stage.intro),
    ];

    final analysis = timeline.currentAnalysis;
    if (analysis != null && !analysis.isEmpty) {
      stageLines.add(analysis.dominantInfluences);
    }

    for (final period in timeline.periods.where((period) => period.isCurrent)) {
      if (period.lifeDomains.isNotEmpty) {
        for (final domain in period.lifeDomains) {
          stageLines.addAll([domain.title, domain.body]);
        }
      } else {
        stageLines.addAll([period.summary, period.whatChanges]);
      }
    }
    out.add(
      _section(
        'ช่วงปัจจุบัน',
        stageLines,
        kind: ThaiBetaReportExportSectionKind.timeline,
      ),
    );
    return out;
  }

  static List<ThaiBetaReportExportSection> _timelineLongTermSections(
    ThaiMirrorLifeTimelineState timeline,
  ) {
    final out = <ThaiBetaReportExportSection>[];
    final preview = timeline.futurePreview;
    out.add(
      _section('แนวโน้มระยะยาว', [
        if (preview != null) ...[
          preview.intro,
          preview.transitionLabel,
          if (preview.elementShiftLine.isNotEmpty) preview.elementShiftLine,
          preview.opportunitiesLine,
          preview.challengesLine,
        ] else
          'ใช้ช่วงชีวิตข้างหน้าเป็นภาพกว้างสำหรับเตรียมตัว ไม่ใช่ข้อสรุปตายตัว',
      ], kind: ThaiBetaReportExportSectionKind.timeline),
    );
    for (final period in timeline.periods.where(
      (period) => !period.isPast && !period.isCurrent,
    )) {
      out.add(_concisePeriodSection(period));
    }
    return out;
  }

  static ThaiBetaReportExportSection _concisePeriodSection(
    ThaiMirrorLifePeriodState period,
  ) {
    final meaning = period.summary.trim().isNotEmpty
        ? period.summary.trim()
        : period.whatChanges.trim();
    return _section(
      '${period.phaseName} (${period.ageLabel})',
      [
        [
          period.planetLine.trim(),
          meaning,
        ].where((part) => part.isNotEmpty).join(' — '),
      ],
      kind: ThaiBetaReportExportSectionKind.timeline,
    );
  }

  static ThaiBetaReportExportSection _pastReflectionSection(
    ThaiMirrorLifePeriodState period,
  ) => _section(
    '${period.phaseName} (${period.ageLabel})',
    [
      if (period.planetLine.trim().isNotEmpty) period.planetLine,
      if (period.summary.trim().isNotEmpty) period.summary,
      if (period.whatChanges.trim().isNotEmpty) period.whatChanges,
    ],
    kind: ThaiBetaReportExportSectionKind.timeline,
  );

  static List<ThaiBetaReportExportSection> _predictionSections(
    PredictionSectionModel prediction,
  ) {
    final hasDetailedDomains = prediction.windows.any(
      (window) => window.domains.isNotEmpty,
    );
    final evidenceBoundary = prediction.windows
        .expand((window) => window.domains)
        .map((domain) => domain.uncertaintyDisclosure.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final out = <ThaiBetaReportExportSection>[
      _section(prediction.sectionTitle, [
        hasDetailedDomains && prediction.detailedSectionIntro.isNotEmpty
            ? prediction.detailedSectionIntro
            : prediction.sectionIntro,
        if (prediction.transitionLine.isNotEmpty) prediction.transitionLine,
        if (evidenceBoundary.isNotEmpty) evidenceBoundary,
      ]),
    ];
    for (var i = 0; i < prediction.windows.length; i++) {
      final window = prediction.windows[i];
      out.add(
        _section(
          switch (i) {
            0 => 'สิ่งที่ต้องตัดสินใจตอนนี้',
            1 => 'แนวโน้ม 12 เดือนข้างหน้า',
            _ => 'ช่วงชีวิตถัดไป',
          },
          [
            window.summary,
            for (final domain in window.domains) ...[domain.title, domain.body],
          ],
        ),
      );
    }
    final closing =
        hasDetailedDomains && prediction.detailedClosingAdvice.isNotEmpty
        ? prediction.detailedClosingAdvice
        : prediction.closingAdvice;
    if (closing.isNotEmpty) {
      out.add(_section('คำแนะนำปิดท้ายช่วงถัดไป', [closing]));
    }
    return out;
  }
}
