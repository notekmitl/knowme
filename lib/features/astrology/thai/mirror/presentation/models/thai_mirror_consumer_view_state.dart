import 'package:flutter/material.dart' show Color, IconData, Icons;

import '../prediction/prediction_section_model.dart';
import '../timeline/thai_mirror_life_timeline_state.dart';

/// Life-aspect status for the consumer dashboard.
enum ThaiMirrorLifeStatus {
  veryGood,
  good,
  bright,
  moderate,
}

extension ThaiMirrorLifeStatusLabels on ThaiMirrorLifeStatus {
  String get labelTh => switch (this) {
        ThaiMirrorLifeStatus.veryGood => 'ดีมาก',
        ThaiMirrorLifeStatus.good => 'ดี',
        ThaiMirrorLifeStatus.bright => 'สดใส',
        ThaiMirrorLifeStatus.moderate => 'ปานกลาง',
      };

  Color get dotColor => switch (this) {
        ThaiMirrorLifeStatus.veryGood => const Color(0xFF2E7D32),
        ThaiMirrorLifeStatus.good => const Color(0xFF43A047),
        ThaiMirrorLifeStatus.bright => const Color(0xFF66BB6A),
        ThaiMirrorLifeStatus.moderate => const Color(0xFFF9A825),
      };
}

/// Visual accent for insight cards.
enum ThaiMirrorInsightAccent {
  strength,
  caution,
  advice,
}

extension ThaiMirrorInsightAccentStyle on ThaiMirrorInsightAccent {
  Color get iconBackground => switch (this) {
        ThaiMirrorInsightAccent.strength => const Color(0xFFE8DEF8),
        ThaiMirrorInsightAccent.caution => const Color(0xFFFFEBEE),
        ThaiMirrorInsightAccent.advice => const Color(0xFFEDE7F6),
      };

  Color get iconColor => switch (this) {
        ThaiMirrorInsightAccent.strength => const Color(0xFF6750A4),
        ThaiMirrorInsightAccent.caution => const Color(0xFFC62828),
        ThaiMirrorInsightAccent.advice => const Color(0xFF5E35B1),
      };

  IconData get defaultIcon => switch (this) {
        ThaiMirrorInsightAccent.strength => Icons.star_rounded,
        ThaiMirrorInsightAccent.caution => Icons.flag_rounded,
        ThaiMirrorInsightAccent.advice => Icons.self_improvement_rounded,
      };
}

class ThaiMirrorConsumerHeroState {
  const ThaiMirrorConsumerHeroState({
    required this.headline,
    required this.summary,
    required this.tags,
    this.identityBadge = 'ดวงไทยของคุณ',
    this.identitySubtitle = 'จากดวงไทยตามวันเกิดของคุณ',
  });

  final String headline;
  final String summary;
  final List<String> tags;
  final String identityBadge;
  final String identitySubtitle;

  static const fallbackHeadline = 'คุณมีบุคลิกที่น่าสนใจในแบบของตัวเอง';

  static const fallbackSummary =
      'คุณมีวิธีคิดและวิธีใช้ชีวิตที่เป็นแบบฉบับของตัวเอง '
      'ลองอ่านด้านล่างแล้วดูว่าตรงกับตัวคุณตรงไหนบ้าง';
}

class ThaiMirrorInsightCardState {
  const ThaiMirrorInsightCardState({
    required this.title,
    required this.body,
    required this.accent,
    this.icon,
    this.expandedBody,
  });

  final String title;
  final String body;
  final ThaiMirrorInsightAccent accent;
  final IconData? icon;

  /// Richer multi-paragraph content shown when the card is expanded.
  /// Paragraphs are separated by a blank line. Null = not expandable.
  final String? expandedBody;

  bool get isExpandable =>
      expandedBody != null && expandedBody!.trim().isNotEmpty;
}

/// One long-form narrative life section (การงาน, ความรัก, ...).
///
/// Each section carries its own visual identity (icon + accent colour) and a
/// short pull-quote callout to break the "every card looks identical" feeling.
/// Body strings may contain `**bold**` inline emphasis markers.
class ThaiMirrorNarrativeSectionState {
  const ThaiMirrorNarrativeSectionState({
    required this.label,
    required this.icon,
    required this.accent,
    required this.pullQuote,
    required this.overview,
    required this.whyItAppears,
    required this.advice,
    required this.example,
    this.transitionIn = '',
    this.discovery = '',
    this.reasoningTitle = '',
    this.reasoningSignals = const [],
    this.reflectionQuestion = '',
    this.tension = '',
  });

  final String label;
  final IconData icon;

  /// Accent colour driving the icon tile, divider and block labels.
  final Color accent;

  /// A short, emphasised callout sentence for this life area.
  final String pullQuote;

  final String overview;
  final String whyItAppears;
  final String advice;
  final String example;

  /// V5: a bridging sentence connecting the previous section to this one, so
  /// the report reads as one continuous story rather than separate cards.
  final String transitionIn;

  /// V5: a "personal discovery" moment ("คุณอาจไม่เคยรู้ว่า...").
  final String discovery;

  /// V5: reasoning header + signals explaining *why* the report concludes
  /// this — in plain language, never astrology jargon.
  final String reasoningTitle;
  final List<String> reasoningSignals;

  /// V5: a reflective question to close the section.
  final String reflectionQuestion;

  /// V6: an internal-conflict / contradiction observation ("คุณอยาก...
  /// แต่ก็...") — what makes a person feel understood.
  final String tension;

  bool get hasTransition => transitionIn.trim().isNotEmpty;
  bool get hasDiscovery => discovery.trim().isNotEmpty;
  bool get hasReasoning => reasoningSignals.isNotEmpty;
  bool get hasReflectionQuestion => reflectionQuestion.trim().isNotEmpty;
  bool get hasTension => tension.trim().isNotEmpty;
}

/// Shareable "ถ้ามีคนถามว่าคุณเป็นคนแบบไหน ดวงไทยจะตอบประมาณนี้" summary.
class ThaiMirrorReflectionSummaryState {
  const ThaiMirrorReflectionSummaryState({
    required this.title,
    required this.intro,
    required this.points,
  });

  final String title;
  final String intro;
  final List<String> points;
}

/// V7: the "heart of the report" — one paragraph assembled from this exact
/// evidence combination (identity + contradiction + growth + future). It is the
/// passage most likely to make a reader think "how does it know this?".
class ThaiMirrorSignatureInsightState {
  const ThaiMirrorSignatureInsightState({
    required this.eyebrow,
    required this.body,
    required this.signature,
  });

  final String eyebrow;
  final String body;
  final String signature;

  bool get isEmpty => body.trim().isEmpty;
}

/// Emotional closing message — "สิ่งที่ดวงไทยอยากบอกคุณ".
///
/// One memorable, reflective note (not a prediction). The strongest, most
/// human moment in the report, placed near the end.
class ThaiMirrorClosingMessageState {
  const ThaiMirrorClosingMessageState({
    required this.eyebrow,
    required this.message,
    required this.signature,
  });

  final String eyebrow;
  final String message;
  final String signature;

  bool get isEmpty => message.trim().isEmpty;
}

class ThaiMirrorInsightSectionState {
  const ThaiMirrorInsightSectionState({
    required this.title,
    required this.cards,
    this.sectionIcon,
  });

  final String title;
  final List<ThaiMirrorInsightCardState> cards;
  final IconData? sectionIcon;
}

class ThaiMirrorAdviceState {
  const ThaiMirrorAdviceState({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static const defaultTitle = 'คำแนะนำสำหรับช่วงนี้';
}

class ThaiMirrorLifeDashboardItemState {
  const ThaiMirrorLifeDashboardItemState({
    required this.label,
    required this.currentState,
    required this.whyItAppears,
    required this.suggestedAction,
    required this.status,
  });

  final String label;
  final String currentState;
  final String whyItAppears;
  final String suggestedAction;
  final ThaiMirrorLifeStatus status;
}

class ThaiMirrorSourceTransparencyState {
  const ThaiMirrorSourceTransparencyState({
    required this.dataUsed,
    required this.calculation,
    required this.meaning,
  });

  final String dataUsed;
  final String calculation;
  final String meaning;
}

class ThaiMirrorBirthDataConfidenceState {
  const ThaiMirrorBirthDataConfidenceState({
    required this.isComplete,
    required this.title,
    required this.body,
  });

  final bool isComplete;
  final String title;
  final String body;
}

class ThaiMirrorConsumerViewState {
  const ThaiMirrorConsumerViewState({
    required this.hero,
    required this.strengths,
    required this.cautions,
    required this.advice,
    required this.lifeDashboard,
    required this.narrativeSections,
    required this.signatureInsight,
    required this.reflectionSummary,
    required this.closingMessage,
    required this.sourceTransparency,
    required this.birthDataConfidence,
    required this.secretTip,
    required this.disclaimers,
    this.lifeTimeline,
    this.futurePrediction,
  });

  final ThaiMirrorConsumerHeroState hero;
  final ThaiMirrorInsightSectionState strengths;
  final ThaiMirrorInsightSectionState cautions;
  final ThaiMirrorAdviceState advice;
  final List<ThaiMirrorLifeDashboardItemState> lifeDashboard;

  /// V8: lifelong Thai planetary-period timeline. Null when birth date is
  /// unavailable (e.g. some preview/QA states).
  final ThaiMirrorLifeTimelineState? lifeTimeline;

  /// V10.5: Future Prediction section (current / next 12 months / next life
  /// period). Null when no timeline evidence is available.
  final PredictionSectionModel? futurePrediction;

  /// Long-form narrative report sections (V3 content expansion).
  final List<ThaiMirrorNarrativeSectionState> narrativeSections;

  /// V7: the one profile-unique "heart of the report" insight.
  final ThaiMirrorSignatureInsightState signatureInsight;

  /// Shareable closing summary.
  final ThaiMirrorReflectionSummaryState reflectionSummary;

  /// Emotional closing message (V4). Optional.
  final ThaiMirrorClosingMessageState closingMessage;

  final ThaiMirrorSourceTransparencyState sourceTransparency;
  final ThaiMirrorBirthDataConfidenceState birthDataConfidence;
  final String secretTip;
  final List<String> disclaimers;
}
