// V8 — UI-facing view state for the Life Timeline section.
//
// These models carry only strings/numbers the widgets render. No engine or
// planet enums leak into the UI layer — the TimelinePresenter flattens
// everything here.

/// A single life-domain score for the mini bar charts (0–100).
class ThaiMirrorPeriodScoreBar {
  const ThaiMirrorPeriodScoreBar({required this.label, required this.value});

  final String label;
  final int value;
}

/// One compact segment in the horizontal timeline strip.
class ThaiMirrorTimelineSegmentState {
  const ThaiMirrorTimelineSegmentState({
    required this.ageLabel,
    required this.phaseName,
    required this.planetName,
    required this.strength,
    required this.isCurrent,
    required this.isPast,
    required this.progress,
    required this.accentIndex,
  });

  final String ageLabel;
  final String phaseName;
  final String planetName;
  final int strength;
  final bool isCurrent;
  final bool isPast;
  final double progress;

  /// Stable index used to pick an accent colour in the widget.
  final int accentIndex;
}

/// Nested ดาวแทรก row for Life Map V1.2.3 (presentation strings only).
class ThaiMirrorLifeSubPeriodState {
  const ThaiMirrorLifeSubPeriodState({
    required this.label,
    required this.durationLabel,
  });

  final String label;
  final String durationLabel;
}

/// Nested ทักษาจร year row for Life Map V1.2.3.
class ThaiMirrorAnnualTaksaYearState {
  const ThaiMirrorAnnualTaksaYearState({
    required this.ageLabel,
    required this.boriwanLabel,
    required this.houseLabel,
    required this.isTagklang,
  });

  final String ageLabel;
  final String boriwanLabel;
  final String houseLabel;
  final bool isTagklang;
}

/// A full, expandable life-period card.
class ThaiMirrorLifePeriodState {
  const ThaiMirrorLifePeriodState({
    required this.ageLabel,
    required this.phaseName,
    required this.planetLine,
    required this.keyword,
    required this.isCurrent,
    required this.isPast,
    required this.summary,
    required this.whatChanges,
    required this.easier,
    required this.harder,
    required this.comparison,
    required this.evidenceLine,
    required this.scores,
    required this.easeIndex,
    required this.accentIndex,
    this.advice = '',
    this.stageLabel = '',
    this.timeBucketLabel = '',
    this.mahabhutPositionLabel = '',
    this.subPeriods = const [],
    this.annualTaksaYears = const [],
  });

  final String ageLabel;
  final String phaseName;
  final String planetLine;
  final String keyword;
  final bool isCurrent;
  final bool isPast;

  final String summary;
  final String whatChanges;
  final String easier;
  final String harder;
  final String comparison;
  final String evidenceLine;

  /// V1.2.6 — actionable guidance (age-appropriate).
  final String advice;

  /// V1.2.6 — presentation life-stage label.
  final String stageLabel;

  final List<ThaiMirrorPeriodScoreBar> scores;
  final int easeIndex;
  final int accentIndex;

  /// V1.2.3 — อดีต / ปัจจุบัน / อนาคต (empty on legacy callers).
  final String timeBucketLabel;

  /// V1.2.3 — Canon Mahabhut name or soft unknown copy.
  final String mahabhutPositionLabel;

  /// V1.2.3 — ดาวแทรก (8 rows when Life Map wired).
  final List<ThaiMirrorLifeSubPeriodState> subPeriods;

  /// V1.2.3 — ทักษาจร years inside this major window.
  final List<ThaiMirrorAnnualTaksaYearState> annualTaksaYears;
}

/// The premium "where are you in life" header card.
class ThaiMirrorCurrentStageState {
  const ThaiMirrorCurrentStageState({
    required this.eyebrow,
    required this.currentAge,
    required this.ageLabel,
    required this.phaseName,
    required this.planetLine,
    required this.keyword,
    required this.yearsRemaining,
    required this.progress,
    required this.intro,
    required this.previousLabel,
    required this.nextLabel,
    required this.accentIndex,
  });

  final String eyebrow;
  final int currentAge;
  final String ageLabel;
  final String phaseName;
  final String planetLine;
  final String keyword;
  final int yearsRemaining;
  final double progress;
  final String intro;

  /// "ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)" — empty if none.
  final String previousLabel;

  /// "ช่วงถัดไป: ช่วงเก็บเกี่ยวความสุข (42–62)" — empty if none.
  final String nextLabel;

  final int accentIndex;
}

/// V9 — "why this period matters" + the dominant influences acting now.
class ThaiMirrorCurrentAnalysisState {
  const ThaiMirrorCurrentAnalysisState({
    required this.title,
    required this.stageLabel,
    required this.dominantInfluences,
    required this.reasons,
  });

  /// "ทำไมช่วงนี้ถึงสำคัญ"
  final String title;

  /// "คุณอยู่ช่วงกลางของจังหวะนี้"
  final String stageLabel;

  /// One line naming the dominant influences acting on the person now.
  final String dominantInfluences;

  /// Bullet reasons this period matters (1–4 lines).
  final List<String> reasons;

  bool get isEmpty => reasons.isEmpty && dominantInfluences.isEmpty;
}

/// V9 — preview of the next life period (transition, opportunities, challenges).
class ThaiMirrorFuturePreviewState {
  const ThaiMirrorFuturePreviewState({
    required this.title,
    required this.intro,
    required this.transitionLabel,
    required this.elementShiftLine,
    required this.opportunitiesLine,
    required this.challengesLine,
  });

  /// "ช่วงต่อไปของคุณ"
  final String title;

  /// "อีกประมาณ N ปี คุณจะก้าวเข้าสู่<ช่วง>"
  final String intro;

  /// Human transition quality ("เปลี่ยนผ่านอย่างราบรื่น").
  final String transitionLabel;

  /// Optional element-shift line — empty when the element does not change.
  final String elementShiftLine;

  final String opportunitiesLine;
  final String challengesLine;
}

/// The whole Life Timeline section view state.
class ThaiMirrorLifeTimelineState {
  const ThaiMirrorLifeTimelineState({
    required this.sectionTitle,
    required this.sectionIntro,
    required this.currentStage,
    required this.segments,
    required this.periods,
    this.currentAnalysis,
    this.futurePreview,
  });

  final String sectionTitle;
  final String sectionIntro;
  final ThaiMirrorCurrentStageState currentStage;
  final List<ThaiMirrorTimelineSegmentState> segments;
  final List<ThaiMirrorLifePeriodState> periods;

  /// V9 — current-age analysis (optional; null on older callers).
  final ThaiMirrorCurrentAnalysisState? currentAnalysis;

  /// V9 — next-period preview (optional; null when in the final period).
  final ThaiMirrorFuturePreviewState? futurePreview;

  bool get isEmpty => segments.isEmpty;
}
