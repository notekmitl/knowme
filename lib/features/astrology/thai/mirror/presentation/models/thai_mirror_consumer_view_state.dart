import 'package:flutter/material.dart' show Color, IconData, Icons;

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
  });

  final String title;
  final String body;
  final ThaiMirrorInsightAccent accent;
  final IconData? icon;
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
    required this.sourceTransparency,
    required this.birthDataConfidence,
    required this.secretTip,
    required this.disclaimers,
  });

  final ThaiMirrorConsumerHeroState hero;
  final ThaiMirrorInsightSectionState strengths;
  final ThaiMirrorInsightSectionState cautions;
  final ThaiMirrorAdviceState advice;
  final List<ThaiMirrorLifeDashboardItemState> lifeDashboard;
  final ThaiMirrorSourceTransparencyState sourceTransparency;
  final ThaiMirrorBirthDataConfidenceState birthDataConfidence;
  final String secretTip;
  final List<String> disclaimers;
}
