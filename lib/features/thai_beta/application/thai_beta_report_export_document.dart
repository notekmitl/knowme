/// Safe, plain-text export document built only from consumer-facing report copy.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';

import 'thai_beta_report_export_polish.dart';
import 'thai_beta_reader_copy_repair.dart';
import 'thai_beta_report_export_safety.dart';
import 'narrative/predictive_narrative_plan.dart';
import 'narrative/thai_beta_narrative_composer.dart';

class ThaiBetaReportExportSection {
  const ThaiBetaReportExportSection({
    required this.title,
    required this.paragraphs,
    this.kind = ThaiBetaReportExportSectionKind.body,
    this.id = '',
    this.fieldSource = 'shared-report-presentation',
    this.visibilityRule = 'visible-when-non-empty',
    this.knownUnknownRule = 'same-order; omit unsupported claims',
    this.traceIds = const [],
  });

  final String title;
  final List<String> paragraphs;
  final ThaiBetaReportExportSectionKind kind;
  final String id;
  final String fieldSource;
  final String visibilityRule;
  final String knownUnknownRule;
  final List<String> traceIds;

  List<String> get paragraphIds => List<String>.generate(
    paragraphs.length,
    (index) => '$id.p${(index + 1).toString().padLeft(2, '0')}',
    growable: false,
  );
}

enum ThaiBetaReportExportSectionKind { chapter, body, timeline, disclaimer }

class ThaiBetaAnnualInfographicCategory {
  const ThaiBetaAnnualInfographicCategory({
    required this.id,
    required this.title,
    required this.summary,
    required this.iconName,
    required this.traceIds,
  });

  final String id;
  final String title;
  final String summary;
  final String iconName;
  final List<String> traceIds;
}

class ThaiBetaAnnualInfographicData {
  const ThaiBetaAnnualInfographicData({
    required this.buddhistYear,
    required this.periodLabel,
    required this.theme,
    required this.overview,
    required this.categories,
    required this.opportunity,
    required this.caution,
    required this.primaryAdvice,
    required this.disclaimer,
    required this.monthlyTimelineAvailable,
    required this.monthlyGapReason,
    required this.traceIds,
  });

  final int buddhistYear;
  final String periodLabel;
  final String theme;
  final String overview;
  final List<ThaiBetaAnnualInfographicCategory> categories;
  final String opportunity;
  final String caution;
  final String primaryAdvice;
  final String disclaimer;
  final bool monthlyTimelineAvailable;
  final String monthlyGapReason;
  final List<String> traceIds;

  String get title => 'แนวโน้ม 12 เดือนข้างหน้า';
}

/// Structured export payload — no engine/Canon/raw ids.
class ThaiBetaReportExportDocument {
  const ThaiBetaReportExportDocument({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.filenameStem,
    this.infographic,
    this.narrativePlan,
  });

  final String title;
  final String subtitle;
  final List<ThaiBetaReportExportSection> sections;
  final String filenameStem;
  final ThaiBetaAnnualInfographicData? infographic;
  final PredictiveNarrativePlan? narrativePlan;

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

  /// Shared insertion point for the rolling 12-month image across Web, PDF and
  /// browser print. The image follows the narrative it summarizes.
  int get infographicInsertionSectionIndex {
    final twelveMonthIndex = sections.indexWhere(
      (section) =>
          section.title == 'แนวโน้ม 12 เดือนข้างหน้า' ||
          section.title == 'คำทำนาย 12 เดือนข้างหน้า',
    );
    if (twelveMonthIndex >= 0) return twelveMonthIndex;
    if (narrativePlan?.isKnownTime == false) {
      final futureChapter = sections.indexWhere(
        (section) => section.title == 'ส่วนที่ 3 · แนวโน้มข้างหน้า',
      );
      if (futureChapter >= 0) return futureChapter;
    }
    if (sections.isEmpty) return -1;
    return sections.length - 1;
  }

  /// Builds from existing [ThaiBetaAnalysis] consumer view only.
  static ThaiBetaReportExportDocument fromAnalysis(
    ThaiBetaAnalysis analysis, {
    List<ThaiPublicEvidenceBadgeBetaViewModel> badges = const [],
    bool applyReaderCopy = false,
  }) {
    if (analysis.consumerViewState == null) {
      return const ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'ไม่พบข้อมูลรายงาน',
        sections: [],
        filenameStem: 'knowme-thai-report',
        infographic: null,
        narrativePlan: null,
      );
    }

    final view = ThaiBetaNarrativeComposer.narrativeView(analysis);

    final sections = <ThaiBetaReportExportSection>[
      if (applyReaderCopy)
        _chapter(
          number: 1,
          title: 'พื้นดวงของคุณ',
          orientation: 'ทำความรู้จักตัวตน จุดแข็ง และแนวโน้มหลักจากดวงกำเนิด',
        ),
    ];
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
          .map(
            (section) => _section(section.title, [
              ...section.factRows.map((row) => row.publicText),
              ...section.claims.map(
                (claim) => applyReaderCopy
                    ? ThaiBetaReaderCopyRepair.refineCoreClaim(
                        claim.text,
                        semanticKey: claim.semanticKey,
                      )
                    : claim.text,
              ),
            ]),
          ),
    );

    // Thai Beta owns one lifelong Core Reading. Only time-dependent material
    // and non-duplicated transparency/disclaimer content follows it.
    final timeline = view.lifeTimeline;
    if (timeline != null) {
      if (applyReaderCopy) {
        sections.add(
          _chapter(
            number: 2,
            title: 'จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
            orientation: 'ทบทวนช่วงวัยสำคัญ แล้วดูว่าตอนนี้คุณอยู่ตรงไหน',
          ),
        );
      }
      sections.addAll(
        _timelinePastAndCurrentSections(
          timeline,
          applyReaderCopy: applyReaderCopy,
        ),
      );
    }

    final prediction = view.futurePrediction;
    if (applyReaderCopy && (prediction != null || timeline != null)) {
      sections.add(
        _chapter(
          number: 3,
          title: 'แนวโน้มข้างหน้า',
          orientation:
              'แยกสิ่งที่ควรตัดสินใจตอนนี้ แนวโน้ม 12 เดือน และช่วงชีวิตถัดไป',
        ),
      );
    }
    if (prediction != null) {
      sections.addAll(
        applyReaderCopy
            ? _predictionNearTermSections(prediction)
            : _predictionSectionsLegacy(prediction),
      );
    }
    if (timeline != null) {
      sections.addAll(
        _timelineLongTermSections(timeline, applyReaderCopy: applyReaderCopy),
      );
    }
    if (applyReaderCopy && prediction != null) {
      sections.addAll(_predictionLongTermSections(prediction));
    }

    if (applyReaderCopy) {
      sections.add(
        _chapter(
          number: 4,
          title: 'ที่มาและข้อจำกัด',
          orientation: 'ดูข้อมูลที่ใช้ วิธีอ่าน และขอบเขตของรายงานฉบับนี้',
        ),
      );
    }

    final methodology = coreReading.sections.singleWhere(
      (section) => section.isMethodology,
    );
    sections.add(
      _section(methodology.title, [
        if (analysis.input.hasBirthTime) ...[
          'ข้อมูลวัน เวลา และสถานที่เกิด',
          'วิธีนับวันทางโหราศาสตร์ไทย',
        ] else
          'ข้อมูลวันเกิดที่บันทึกไว้',
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
            title: ThaiBetaReportExportSafety.scrub(
              applyReaderCopy
                  ? ThaiBetaReaderCopyRepair.refine(s.title)
                  : s.title,
            ),
            paragraphs: s.paragraphs
                .map(
                  (paragraph) => applyReaderCopy
                      ? ThaiBetaReaderCopyRepair.refine(paragraph)
                      : paragraph,
                )
                .map(ThaiBetaReportExportSafety.scrub)
                .where((p) => p.trim().isNotEmpty)
                .toList(),
            kind: s.kind,
            id: s.id,
            fieldSource: s.fieldSource,
            visibilityRule: s.visibilityRule,
            knownUnknownRule: s.knownUnknownRule,
            traceIds: s.traceIds,
          ),
        )
        .where((s) => s.title.trim().isNotEmpty || s.paragraphs.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => ThaiBetaReportExportSection(
            title: entry.value.title,
            paragraphs: entry.value.paragraphs,
            kind: entry.value.kind,
            id: 'report-${entry.value.kind.name}-${(entry.key + 1).toString().padLeft(2, '0')}',
            fieldSource: entry.value.fieldSource,
            visibilityRule: entry.value.visibilityRule,
            knownUnknownRule: entry.value.knownUnknownRule,
            traceIds: entry.value.traceIds,
          ),
        )
        .toList(growable: false);

    final infographic = _annualInfographic(
      analysis,
      prediction,
      applyReaderCopy: applyReaderCopy,
    );

    // Final presentation polish (also re-applied in PDF exporter).
    return polishForPdf(
      ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'รายงานฉบับสำหรับอ่านและบันทึกส่วนตัว',
        sections: scrubbed,
        filenameStem: 'knowme-thai-report',
        infographic: infographic,
      ),
    );
  }

  static ThaiBetaReportExportDocument beforeReaderCopy(
    ThaiBetaAnalysis analysis, {
    List<ThaiPublicEvidenceBadgeBetaViewModel> badges = const [],
  }) => fromAnalysis(analysis, badges: badges, applyReaderCopy: false);

  /// Candidate reader-visible projection for the vNext Owner review surface.
  ///
  /// Keeping this opt-in preserves the accepted V1.5 factory and its R1-R7.1
  /// evidence while the candidate wording remains pending Owner approval.
  static ThaiBetaReportExportDocument candidate(
    ThaiBetaAnalysis analysis, {
    List<ThaiPublicEvidenceBadgeBetaViewModel> badges = const [],
  }) {
    if (analysis.consumerViewState == null) {
      return fromAnalysis(analysis, badges: badges, applyReaderCopy: true);
    }
    final plan = PredictiveNarrativePlan.fromAnalysis(analysis);
    final baseline = fromAnalysis(
      analysis,
      badges: badges,
      applyReaderCopy: true,
    );
    return polishForPdf(_withNarrativePlan(analysis, baseline, plan));
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
          id: section.id,
          fieldSource: section.fieldSource,
          visibilityRule: section.visibilityRule,
          knownUnknownRule: section.knownUnknownRule,
          traceIds: section.traceIds,
        ),
      );
    }
    return ThaiBetaReportExportDocument(
      title: ThaiBetaReportExportPolish.polishTitle(document.title),
      subtitle: ThaiBetaReportExportPolish.polishLine(document.subtitle),
      sections: sections,
      filenameStem: document.filenameStem,
      infographic: document.infographic,
      narrativePlan: document.narrativePlan,
    );
  }

  static ThaiBetaReportExportDocument _withNarrativePlan(
    ThaiBetaAnalysis analysis,
    ThaiBetaReportExportDocument baseline,
    PredictiveNarrativePlan plan,
  ) {
    ThaiBetaReportExportSection project(NarrativeSection section) =>
        ThaiBetaReportExportSection(
            title: section.title,
            paragraphs: [
              for (final block in section.blocks) ...[
                ?block.heading,
                ...block.atoms.map((atom) => atom.readerText),
              ],
            ],
            kind:
                section.role == NarrativeSectionRole.disclaimer ||
                    section.role == NarrativeSectionRole.omission
                ? ThaiBetaReportExportSectionKind.disclaimer
                : section.role == NarrativeSectionRole.past ||
                      section.role == NarrativeSectionRole.current ||
                      section.role == NarrativeSectionRole.nextLifePeriod
                ? ThaiBetaReportExportSectionKind.timeline
                : ThaiBetaReportExportSectionKind.body,
            id: 'predictive-${section.id}',
            fieldSource: 'PredictiveNarrativePlan',
            visibilityRule: 'visible-when-plan-section-has-atoms',
            knownUnknownRule: plan.isKnownTime
                ? 'known-plan; time-dependent-atoms-eligible'
                : 'unknown-plan; time-dependent-atoms-filtered-before-prose',
            traceIds: section.atoms
                .expand((atom) => [atom.owner.id, ...atom.evidence.refs])
                .toSet()
                .toList(growable: false),
          );

    final part2 = baseline.sections.indexWhere(
      (section) =>
          section.title == 'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
    );
    final part3 = baseline.sections.indexWhere(
      (section) => section.title == 'ส่วนที่ 3 · แนวโน้มข้างหน้า',
    );
    final part4 = baseline.sections.indexWhere(
      (section) => section.title == 'ส่วนที่ 4 · ที่มาและข้อจำกัด',
    );
    if (part4 < 0) {
      throw StateError('Full report baseline is missing Part 4.');
    }

    final firstPredictiveChapter = [part2, part3]
        .where((index) => index >= 0)
        .fold<int>(part4, (best, index) => index < best ? index : best);
    final sections = <ThaiBetaReportExportSection>[
      ...baseline.sections.take(firstPredictiveChapter),
    ];
    final part2Chapter = part2 >= 0 ? baseline.sections[part2] : null;
    final part3Chapter = part3 >= 0 ? baseline.sections[part3] : null;

    if (plan.isKnownTime) {
      if (part2Chapter != null) sections.add(part2Chapter);
      sections.addAll(
        plan.sections
            .where(
              (section) => switch (section.role) {
                NarrativeSectionRole.overview ||
                NarrativeSectionRole.past ||
                NarrativeSectionRole.current ||
                NarrativeSectionRole.work ||
                NarrativeSectionRole.finance ||
                NarrativeSectionRole.relationship ||
                NarrativeSectionRole.health ||
                NarrativeSectionRole.support => true,
                _ => false,
              },
            )
            .map(project),
      );
      if (part3Chapter != null) sections.add(part3Chapter);
      sections.addAll(
        plan.sections
            .where(
              (section) => switch (section.role) {
                NarrativeSectionRole.horizon ||
                NarrativeSectionRole.nextLifePeriod ||
                NarrativeSectionRole.summary ||
                NarrativeSectionRole.advice => true,
                _ => false,
              },
            )
            .map(project),
      );
    } else {
      if (part2Chapter != null) sections.add(part2Chapter);
      sections.addAll(
        plan.sections
            .where((section) => section.role == NarrativeSectionRole.omission)
            .map(project),
      );
      if (part3Chapter != null) sections.add(part3Chapter);
    }
    sections.addAll(baseline.sections.skip(part4));

    return ThaiBetaReportExportDocument(
      title: baseline.title,
      subtitle: baseline.subtitle,
      sections: sections,
      filenameStem: baseline.filenameStem,
      infographic: _annualInfographicFromPlan(analysis, plan),
      narrativePlan: plan,
    );
  }

  static ThaiBetaAnnualInfographicData _annualInfographicFromPlan(
    ThaiBetaAnalysis analysis,
    PredictiveNarrativePlan plan,
  ) {
    NarrativeAtom? firstFor(NarrativeSectionRole role) {
      for (final section in plan.sections) {
        if (section.role == role && section.atoms.isNotEmpty) {
          return section.atoms.first;
        }
      }
      return null;
    }

    final omission = firstFor(NarrativeSectionRole.omission);
    final fallback =
        omission ?? firstFor(NarrativeSectionRole.overview) ?? plan.atoms.first;
    final categoryBindings = <(String, String, NarrativeSectionRole)>[
      ('work', 'การงาน', NarrativeSectionRole.work),
      ('savings', 'การเงิน', NarrativeSectionRole.finance),
      ('favorite', 'ความรัก', NarrativeSectionRole.relationship),
      ('self_improvement', 'สุขภาพ', NarrativeSectionRole.health),
    ];
    final categories = <ThaiBetaAnnualInfographicCategory>[
      for (final binding in categoryBindings)
        () {
          final atom = firstFor(binding.$3) ?? fallback;
          return ThaiBetaAnnualInfographicCategory(
            id: 'plan-${binding.$3.name}',
            title: binding.$2,
            summary: atom.compactText,
            iconName: binding.$1,
            traceIds: [atom.owner.id, ...atom.evidence.refs],
          );
        }(),
    ];
    final horizon = firstFor(NarrativeSectionRole.horizon) ?? fallback;
    final support = firstFor(NarrativeSectionRole.support) ?? horizon;
    final caution = firstFor(NarrativeSectionRole.health) ?? fallback;
    final advice = firstFor(NarrativeSectionRole.advice) ?? fallback;
    final disclosure = plan.atoms.firstWhere(
      (atom) => atom.role == NarrativeAtomRole.disclosure,
      orElse: () => fallback,
    );
    final theme =
        firstFor(NarrativeSectionRole.overview)?.compactText ??
        fallback.compactText;
    return ThaiBetaAnnualInfographicData(
      buddhistYear: analysis.asOf.year + 543,
      periodLabel: _twelveMonthPeriodLabel(analysis.asOf),
      theme: theme,
      overview: _twelveMonthPeriodLabel(analysis.asOf),
      categories: List.unmodifiable(categories),
      opportunity: support.compactText,
      caution: caution.compactText,
      primaryAdvice: advice.compactText,
      disclaimer: disclosure.compactText,
      monthlyTimelineAvailable: plan.monthlyTimelineAvailable,
      monthlyGapReason:
          'ไม่มีคะแนนหรือหลักฐานที่ผูกคำทำนายกับเดือนปฏิทินทั้ง 12 เดือน',
      traceIds: plan.atoms
          .expand((atom) => [atom.owner.id, ...atom.evidence.refs])
          .toSet()
          .toList(growable: false),
    );
  }

  static ThaiBetaAnnualInfographicData? _annualInfographic(
    ThaiBetaAnalysis analysis,
    PredictionSectionModel? prediction, {
    required bool applyReaderCopy,
  }) {
    if (prediction == null || prediction.windows.length < 2) return null;
    final window = prediction.windows[1];
    final categories = <ThaiBetaAnnualInfographicCategory>[];
    var hasTransitionReserve = false;
    var hasUnknownRepeatedBoundary = false;
    const iconNames = <String, String>{
      'การงาน': 'work',
      'การเงิน': 'savings',
      'ความรัก': 'favorite',
      'สุขภาพ': 'self_improvement',
    };
    for (final domain in window.domains) {
      if (!iconNames.containsKey(domain.title)) continue;
      // The annual card needs a short, decision-useful sentence at mobile
      // scale. Reuse the already accepted next-12-month decision projection;
      // do not truncate the longer claim or synthesize new horoscope copy.
      final raw = domain.decisionImpact.trim().isNotEmpty
          ? domain.decisionImpact
          : domain.claim.trim().isNotEmpty
          ? domain.claim
          : domain.body;
      hasTransitionReserve =
          hasTransitionReserve ||
          raw.contains('และกันแรงไว้สำหรับรอยต่อของช่วงชีวิต');
      hasUnknownRepeatedBoundary =
          hasUnknownRepeatedBoundary ||
          raw.contains('จึงควรยืนยันจากผลที่เกิดซ้ำก่อนตัดสินใจ');
      final categoryField =
          'infographic.categories[${categories.length}].summary';
      final summary = applyReaderCopy
          ? ThaiBetaReaderCopyRepair.refineForField(
              raw,
              fieldPath: categoryField,
            )
          : raw;
      final material = domain.material;
      categories.add(
        ThaiBetaAnnualInfographicCategory(
          id: 'annual-${material?.domain.name ?? domain.title}',
          title: domain.title,
          summary: summary,
          iconName: iconNames[domain.title]!,
          traceIds: [
            if (material != null) material.serialize(),
            if (material != null && material.evidenceKey.isNotEmpty)
              material.evidenceKey,
          ],
        ),
      );
    }
    if (categories.length != 4) return null;
    String repair(String value, String fieldPath) => applyReaderCopy
        ? ThaiBetaReaderCopyRepair.refineForField(value, fieldPath: fieldPath)
        : value;
    int bandScore(PredictionDomainModel domain) =>
        switch (domain.material?.band ?? ForecastBand.active) {
          ForecastBand.strong => 2,
          ForecastBand.active => 1,
          ForecastBand.quiet => 0,
        };
    final opportunityDomain = window.domains.reduce(
      (best, candidate) =>
          bandScore(candidate) > bandScore(best) ? candidate : best,
    );
    final cautionDomain = window.domains.reduce(
      (best, candidate) =>
          bandScore(candidate) < bandScore(best) ? candidate : best,
    );
    final opportunity = window.topOpportunity.trim().isNotEmpty
        ? window.topOpportunity
        : opportunityDomain.decisionImpact.trim().isNotEmpty
        ? opportunityDomain.decisionImpact
        : opportunityDomain.claim;
    final caution = window.topRisk.trim().isNotEmpty
        ? window.topRisk
        : cautionDomain.risk.trim().isNotEmpty
        ? cautionDomain.risk
        : cautionDomain.caution;
    final rawDisclaimer = analysis.input.hasBirthTime
        ? 'แนวโน้มนี้ใช้เพื่อวางแผนและทบทวน ไม่ใช่ข้อสรุปตายตัว'
        : 'ไม่มีเวลาเกิด จึงแสดงเฉพาะแนวโน้มที่ข้อมูลรองรับและไม่เติมรายละเอียดที่ขาดหาย';
    return ThaiBetaAnnualInfographicData(
      buddhistYear: analysis.asOf.year + 543,
      periodLabel: _twelveMonthPeriodLabel(analysis.asOf),
      theme: repair(window.summary, 'infographic.theme'),
      overview: [
        _twelveMonthPeriodLabel(analysis.asOf),
        if (hasTransitionReserve) 'ควรเผื่อแรงไว้เมื่อหน้าที่เปลี่ยน',
      ].join(' • '),
      categories: List.unmodifiable(categories),
      opportunity: repair(opportunity, 'infographic.opportunity'),
      caution: repair(caution, 'infographic.caution'),
      primaryAdvice: repair(
        prediction.detailedClosingAdvice.trim().isNotEmpty
            ? prediction.detailedClosingAdvice
            : prediction.closingAdvice,
        'infographic.primaryAdvice',
      ),
      disclaimer: applyReaderCopy && hasUnknownRepeatedBoundary
          ? repair(rawDisclaimer, 'infographic.disclaimer')
          : rawDisclaimer,
      monthlyTimelineAvailable: false,
      monthlyGapReason:
          'engine ปัจจุบันมีกรอบ 12 เดือนและทักษาจรรายปี แต่ไม่มีคะแนนหรือหลักฐานที่ผูกกับเดือนปฏิทินทั้ง 12 เดือน',
      traceIds: window.domains
          .expand(
            (domain) => [
              if (domain.material != null) domain.material!.serialize(),
              if (domain.material != null &&
                  domain.material!.evidenceKey.isNotEmpty)
                domain.material!.evidenceKey,
            ],
          )
          .toSet()
          .toList(growable: false),
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

  static ThaiBetaReportExportSection _chapter({
    required int number,
    required String title,
    required String orientation,
  }) => _section('ส่วนที่ $number · $title', [
    orientation,
  ], kind: ThaiBetaReportExportSectionKind.chapter);

  static String _twelveMonthPeriodLabel(DateTime asOf) {
    final nextYear = asOf.year + 1;
    final lastDayOfTargetMonth = asOf.isUtc
        ? DateTime.utc(nextYear, asOf.month + 1, 0).day
        : DateTime(nextYear, asOf.month + 1, 0).day;
    final anniversaryDay = asOf.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : asOf.day;
    final anniversary = asOf.isUtc
        ? DateTime.utc(nextYear, asOf.month, anniversaryDay)
        : DateTime(nextYear, asOf.month, anniversaryDay);
    final periodEnd = anniversary.subtract(const Duration(days: 1));
    return '${_thaiDate(asOf)} – ${_thaiDate(periodEnd)}';
  }

  static String _thaiDate(DateTime value) {
    const months = <String>[
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year + 543}';
  }

  static List<ThaiBetaReportExportSection> _timelinePastAndCurrentSections(
    ThaiMirrorLifeTimelineState timeline, {
    required bool applyReaderCopy,
  }) {
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
      if (applyReaderCopy) ...[
        '${stage.phaseName} (อายุ ${stage.ageLabel})',
        if (stage.planetLine.trim().isNotEmpty) stage.planetLine,
      ] else ...[
        stage.eyebrow,
        '${stage.phaseName} · อายุ ${stage.ageLabel} · ${stage.planetLine}',
      ],
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
    ThaiMirrorLifeTimelineState timeline, {
    required bool applyReaderCopy,
  }) {
    final out = <ThaiBetaReportExportSection>[];
    final preview = timeline.futurePreview;
    out.add(
      _section(
        applyReaderCopy ? 'จังหวะชีวิตระยะต่อไป' : 'แนวโน้มระยะยาว',
        [
          if (preview != null) ...[
            preview.intro,
            preview.transitionLabel,
            if (preview.elementShiftLine.isNotEmpty) preview.elementShiftLine,
            preview.opportunitiesLine,
            preview.challengesLine,
          ] else
            'ใช้ช่วงชีวิตข้างหน้าเป็นภาพกว้างสำหรับเตรียมตัว ไม่ใช่ข้อสรุปตายตัว',
        ],
        kind: ThaiBetaReportExportSectionKind.timeline,
      ),
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

  static List<ThaiBetaReportExportSection> _predictionNearTermSections(
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
    final nearTermCount = prediction.windows.length < 2
        ? prediction.windows.length
        : 2;
    for (var i = 0; i < nearTermCount; i++) {
      final window = prediction.windows[i];
      out.add(
        _section(
          i == 0 ? 'สิ่งที่ต้องตัดสินใจตอนนี้' : 'แนวโน้ม 12 เดือนข้างหน้า',
          [
            window.summary,
            for (final domain in window.domains) ...[domain.title, domain.body],
          ],
        ),
      );
    }
    return out;
  }

  static List<ThaiBetaReportExportSection> _predictionSectionsLegacy(
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

  static List<ThaiBetaReportExportSection> _predictionLongTermSections(
    PredictionSectionModel prediction,
  ) {
    final out = <ThaiBetaReportExportSection>[];
    for (var i = 2; i < prediction.windows.length; i++) {
      final window = prediction.windows[i];
      out.add(
        _section('สิ่งที่ควรเตรียมสำหรับช่วงถัดไป', [
          window.summary,
          for (final domain in window.domains) ...[domain.title, domain.body],
        ]),
      );
    }
    final hasDetailedDomains = prediction.windows.any(
      (window) => window.domains.isNotEmpty,
    );
    final closing =
        hasDetailedDomains && prediction.detailedClosingAdvice.isNotEmpty
        ? prediction.detailedClosingAdvice
        : prediction.closingAdvice;
    if (closing.isNotEmpty) {
      out.add(_section('ข้อสรุปสำหรับช่วงข้างหน้า', [closing]));
    }
    return out;
  }
}
