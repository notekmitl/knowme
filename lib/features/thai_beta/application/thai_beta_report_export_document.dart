/// Safe, plain-text export document built only from consumer-facing report copy.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_report_export_safety.dart';

class ThaiBetaReportExportSection {
  const ThaiBetaReportExportSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
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
    final view = analysis.consumerViewState;
    if (view == null) {
      return const ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'ไม่พบข้อมูลรายงาน',
        sections: [],
        filenameStem: 'knowme-thai-report',
      );
    }

    final sections = <ThaiBetaReportExportSection>[];

    sections.add(
      ThaiBetaReportExportSection(
        title: view.hero.identityBadge,
        paragraphs: [
          view.hero.headline,
          view.hero.summary,
          if (view.hero.tags.isNotEmpty) view.hero.tags.join(' · '),
          view.hero.identitySubtitle,
        ],
      ),
    );

    sections.add(
      ThaiBetaReportExportSection(
        title: view.birthDataConfidence.title,
        paragraphs: [view.birthDataConfidence.body],
      ),
    );

    if (!view.signatureInsight.isEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: view.signatureInsight.eyebrow,
          paragraphs: [
            _stripMarkdown(view.signatureInsight.body),
            view.signatureInsight.signature,
          ],
        ),
      );
    }

    if (view.strengths.cards.isNotEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: view.strengths.title,
          paragraphs: [
            for (final card in view.strengths.cards) ...[
              card.title,
              _stripMarkdown(card.body),
              if (card.expandedBody != null)
                _stripMarkdown(card.expandedBody!),
            ],
          ],
        ),
      );
    }

    if (view.cautions.cards.isNotEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: view.cautions.title,
          paragraphs: [
            for (final card in view.cautions.cards) ...[
              card.title,
              _stripMarkdown(card.body),
              if (card.expandedBody != null)
                _stripMarkdown(card.expandedBody!),
            ],
          ],
        ),
      );
    }

    sections.add(
      ThaiBetaReportExportSection(
        title: view.advice.title,
        paragraphs: [_stripMarkdown(view.advice.body)],
      ),
    );

    if (view.lifeDashboard.isNotEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: 'ภาพรวมด้านชีวิต',
          paragraphs: [
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
        ThaiBetaReportExportSection(
          title: narrative.label,
          paragraphs: [
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
            if (narrative.hasReflectionQuestion)
              narrative.reflectionQuestion,
          ],
        ),
      );
    }

    sections.add(
      ThaiBetaReportExportSection(
        title: view.reflectionSummary.title,
        paragraphs: [
          view.reflectionSummary.intro,
          ...view.reflectionSummary.points,
        ],
      ),
    );

    if (!view.closingMessage.isEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: view.closingMessage.eyebrow,
          paragraphs: [
            _stripMarkdown(view.closingMessage.message),
            view.closingMessage.signature,
          ],
        ),
      );
    }

    sections.add(
      ThaiBetaReportExportSection(
        title: 'ที่มาของผลวิเคราะห์',
        paragraphs: [
          view.sourceTransparency.dataUsed,
          view.sourceTransparency.calculation,
          view.sourceTransparency.meaning,
        ],
      ),
    );

    if (view.secretTip.trim().isNotEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: 'ข้อควรรู้',
          paragraphs: [view.secretTip],
        ),
      );
    }

    if (view.disclaimers.isNotEmpty) {
      sections.add(
        ThaiBetaReportExportSection(
          title: 'ข้อจำกัด',
          paragraphs: view.disclaimers,
        ),
      );
    }

    final safeBadges = badges
        .where((b) => b.eligible)
        .map(
          (b) => ThaiBetaReportExportSection(
            title: b.badgeLabel,
            paragraphs: [b.cautionCopy],
          ),
        )
        .toList();
    if (safeBadges.isNotEmpty) {
      sections.add(
        const ThaiBetaReportExportSection(
          title: 'หลักฐานสนับสนุน (สรุปสาธารณะ)',
          paragraphs: [
            'ป้ายหลักฐานด้านล่างเป็นสรุประดับที่อนุญาตในเบต้าเท่านั้น',
          ],
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
          ),
        )
        .where((s) => s.title.trim().isNotEmpty || s.paragraphs.isNotEmpty)
        .toList();

    return ThaiBetaReportExportDocument(
      title: 'KnowMe — รายงานโหราไทย',
      subtitle: 'ส่งออกจากโหมด capture / screenshot (งานวิจัยเบต้า)',
      sections: scrubbed,
      filenameStem: 'knowme-thai-report',
    );
  }

  static List<ThaiBetaReportExportSection> _timelineSections(
    ThaiMirrorLifeTimelineState timeline,
  ) {
    final out = <ThaiBetaReportExportSection>[
      ThaiBetaReportExportSection(
        title: timeline.sectionTitle,
        paragraphs: [timeline.sectionIntro],
      ),
    ];
    final stage = timeline.currentStage;
    out.add(
      ThaiBetaReportExportSection(
        title: stage.eyebrow,
        paragraphs: [
          '${stage.phaseName} · ${stage.ageLabel}',
          stage.planetLine,
          stage.keyword,
          stage.intro,
          if (stage.previousLabel.isNotEmpty)
            'ช่วงก่อนหน้า: ${stage.previousLabel}',
          if (stage.nextLabel.isNotEmpty) 'ช่วงถัดไป: ${stage.nextLabel}',
        ],
      ),
    );

    for (final period in timeline.periods) {
      out.add(
        ThaiBetaReportExportSection(
          title: '${period.phaseName} (${period.ageLabel})',
          paragraphs: [
            period.planetLine,
            period.keyword,
            period.summary,
            period.whatChanges,
            period.easier,
            period.harder,
            period.comparison,
            // Consumer evidence line only — already scrubbed for public UI.
            period.evidenceLine,
          ],
        ),
      );
    }
    return out;
  }

  static List<ThaiBetaReportExportSection> _predictionSections(
    PredictionSectionModel prediction,
  ) {
    final out = <ThaiBetaReportExportSection>[
      ThaiBetaReportExportSection(
        title: prediction.sectionTitle,
        paragraphs: [
          prediction.sectionIntro,
          if (prediction.transitionLine.isNotEmpty) prediction.transitionLine,
        ],
      ),
    ];
    for (final window in prediction.windows) {
      out.add(
        ThaiBetaReportExportSection(
          title: '${window.windowLabel} — ${window.timeframeLabel}',
          paragraphs: [
            window.summary,
            window.topOpportunity,
            window.topRisk,
            window.confidenceLabel,
            window.why,
            window.whyNow,
            window.whatToWatch,
            // evidenceDetail is consumer expandable copy already on report.
            window.evidenceDetail,
          ],
        ),
      );
    }
    if (prediction.closingAdvice.isNotEmpty) {
      out.add(
        ThaiBetaReportExportSection(
          title: 'คำแนะนำปิดท้ายช่วงถัดไป',
          paragraphs: [prediction.closingAdvice],
        ),
      );
    }
    return out;
  }

  static String _stripMarkdown(String input) {
    return input.replaceAll('**', '').trim();
  }
}
