// MBTI Summary fusion constants (Phase 1 prep + confidence tiers).

/// Confidence checkpoints (aligned with progressive MBTI / Cognitive).
const int mbtiSummaryMiniCheckpoint = 16;
const int mbtiSummaryStandardCheckpoint = 40;
const int mbtiSummaryAccurateCheckpoint = 80;

/// Alignment scoring bands (Fusion Insight Phase 1).
const int mbtiSummaryAlignmentWeakMax = 1;
const int mbtiSummaryAlignmentMixedMax = 3;
const int mbtiSummaryAlignmentStrongMin = 4;

/// Theme weighting for summary insight composition (Phase 1).
const int mbtiSummaryTopFunctionWeight = 4;
const int mbtiSummaryMinThemeWeight = 3;

/// Current rule-based stack overlap (pre–Phase 1 engine).
const int mbtiSummaryAlignedTopTwoOverlapMin = 2;
const int mbtiSummaryPartialTopFourOverlapMin = 1;
