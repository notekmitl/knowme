/// Safe, plain-text export document built only from consumer-facing report copy.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

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

enum ThaiBetaReportExportSectionKind {
  body,
  timeline,
  disclaimer,
}

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

    sections.add(
      _section(
        view.hero.identityBadge,
        [
          view.hero.headline,
          view.hero.summary,
          if (view.hero.tags.isNotEmpty) view.hero.tags.join(' · '),
          view.hero.identitySubtitle,
        ],
      ),
    );

    sections.add(
      _section(view.birthDataConfidence.title, [view.birthDataConfidence.body]),
    );

    if (!view.signatureInsight.isEmpty) {
      sections.add(
        _section(
          view.signatureInsight.eyebrow,
          [
            _stripMarkdown(view.signatureInsight.body),
            view.signatureInsight.signature,
          ],
        ),
      );
    }

    if (view.strengths.cards.isNotEmpty) {
      sections.add(
        _section(
          view.strengths.title,
          [
            for (final card in view.strengths.cards) ..._insightCardLines(card),
          ],
        ),
      );
    }

    if (view.cautions.cards.isNotEmpty) {
      sections.add(
        _section(
          view.cautions.title,
          [
            for (final card in view.cautions.cards) ..._insightCardLines(card),
          ],
        ),
      );
    }

    sections.add(
      _section(view.advice.title, [_stripMarkdown(view.advice.body)]),
    );

    if (view.lifeDashboard.isNotEmpty) {
      sections.add(
        _section(
          'ภาพรวมด้านชีวิต',
          [
            for (final item in view.lifeDashboard) ...[
              '${item.label} — ${item.status.labelTh}',
              item.currentState,
              item.whyItAppears,
              item.suggestedAction,
            ],
          ],
        ),
      );
    }

    final timeline = view.lifeTimeline;
    if (timeline != null) {
      sections.addAll(_timelineSections(timeline));
    }

    final prediction = view.futurePrediction;
    if (prediction != null) {
      sections.addAll(_predictionSections(prediction));
    }

    for (final narrative in view.narrativeSections) {
      sections.add(
        _section(
          narrative.label,
          [
            if (narrative.hasTransition) narrative.transitionIn,
            if (narrative.pullQuote.isNotEmpty)
              _stripMarkdown(narrative.pullQuote),
            if (narrative.hasDiscovery) _stripMarkdown(narrative.discovery),
            _stripMarkdown(narrative.overview),
            if (narrative.hasTension) _stripMarkdown(narrative.tension),
            _stripMarkdown(narrative.whyItAppears),
            if (narrative.hasReasoning) ...[
              narrative.reasoningTitle,
              ...narrative.reasoningSignals.map(_stripMarkdown),
            ],
            _stripMarkdown(narrative.advice),
            _stripMarkdown(narrative.example),
            if (narrative.hasReflectionQuestion) narrative.reflectionQuestion,
          ],
        ),
      );
    }

    sections.add(
      _section(
        view.reflectionSummary.title,
        [
          view.reflectionSummary.intro,
          ...view.reflectionSummary.points,
        ],
      ),
    );

    if (!view.closingMessage.isEmpty) {
      sections.add(
        _section(
          view.closingMessage.eyebrow,
          [
            _stripMarkdown(view.closingMessage.message),
            view.closingMessage.signature,
          ],
        ),
      );
    }

    sections.add(
      _section(
        'ที่มาของผลวิเคราะห์',
        [
          view.sourceTransparency.dataUsed,
          view.sourceTransparency.calculation,
          view.sourceTransparency.meaning,
        ],
      ),
    );

    if (view.secretTip.trim().isNotEmpty) {
      sections.add(_section('ข้อควรรู้', [view.secretTip]));
    }

    if (view.disclaimers.isNotEmpty) {
      sections.add(
        _section(
          'ข้อจำกัด',
          view.disclaimers,
          kind: ThaiBetaReportExportSectionKind.disclaimer,
        ),
      );
    }

    final safeBadges = badges
        .where((b) => b.eligible)
        .map((b) => _section(b.badgeLabel, [b.cautionCopy]))
        .toList();
    if (safeBadges.isNotEmpty) {
      sections.add(
        _section(
          'หลักฐานสนับสนุน (สรุปสาธารณะ)',
          ['ป้ายหลักฐานด้านล่างเป็นสรุประดับที่อนุญาตในเบต้าเท่านั้น'],
        ),
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
        subtitle: 'ส่งออกจากโหมด capture / screenshot (งานวิจัยเบต้า)',
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
      paragraphs:
          ThaiBetaReportExportPolish.dedupeParagraphs(polishedTitle, paragraphs),
      kind: kind,
    );
  }

  /// Prefer full expanded body over UI-truncated card body.
  static List<String> _insightCardLines(ThaiMirrorInsightCardState card) {
    final lines = <String>[card.title];
    final expanded = card.expandedBody?.trim();
    if (expanded != null && expanded.isNotEmpty) {
      lines.add(_stripMarkdown(expanded));
    } else {
      final body = _stripMarkdown(card.body);
      if (!ThaiBetaReportExportPolish.isUiTruncated(body)) {
        lines.add(body);
      }
    }
    return lines;
  }

  static List<ThaiBetaReportExportSection> _timelineSections(
    ThaiMirrorLifeTimelineState timeline,
  ) {
    final out = <ThaiBetaReportExportSection>[
      _section(
        timeline.sectionTitle,
        [timeline.sectionIntro],
        kind: ThaiBetaReportExportSectionKind.timeline,
      ),
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
        _section(
          analysis.title,
          [
            analysis.stageLabel,
            analysis.dominantInfluences,
            ...analysis.reasons,
          ],
          kind: ThaiBetaReportExportSectionKind.timeline,
        ),
      );
    }

    final preview = timeline.futurePreview;
    if (preview != null) {
      out.add(
        _section(
          preview.title,
          [
            preview.intro,
            preview.transitionLabel,
            if (preview.elementShiftLine.isNotEmpty) preview.elementShiftLine,
            preview.opportunitiesLine,
            preview.challengesLine,
          ],
          kind: ThaiBetaReportExportSectionKind.timeline,
        ),
      );
    }

    for (final period in timeline.periods) {
      out.add(
        _section(
          '${period.phaseName} (${period.ageLabel})',
          [
            period.planetLine,
            // Keyword already appears after "•" on planetLine.
            period.summary,
            period.whatChanges,
            period.easier,
            period.harder,
            period.comparison,
            period.evidenceLine,
          ],
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
      _section(
        prediction.sectionTitle,
        [
          prediction.sectionIntro,
          if (prediction.transitionLine.isNotEmpty) prediction.transitionLine,
        ],
      ),
    ];
    for (final window in prediction.windows) {
      out.add(
        _section(
          '${window.windowLabel} — ${window.timeframeLabel}',
          [
            window.summary,
            window.topOpportunity,
            window.topRisk,
            window.confidenceLabel,
            window.why,
            window.whyNow,
            window.whatToWatch,
            window.evidenceDetail,
          ],
        ),
      );
    }
    if (prediction.closingAdvice.isNotEmpty) {
      out.add(_section('คำแนะนำปิดท้ายช่วงถัดไป', [prediction.closingAdvice]));
    }
    return out;
  }

  static String _stripMarkdown(String input) {
    return input.replaceAll('**', '').trim();
  }
}
