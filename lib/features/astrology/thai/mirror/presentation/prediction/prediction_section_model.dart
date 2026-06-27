// V10.5 — UI-facing view state for the Future Prediction section.
//
// These models carry only strings/ints the widget renders. No engine, planet or
// prediction enums leak into the UI layer — the PredictionComposer flattens
// everything here (copy boundary preserved).

/// One prediction horizon card (Current · Next 12 Months · Next Life Period).
///
/// The main card stays scannable (article style, < 2 min read): timeframe,
/// summary, top opportunity, top risk, a qualitative confidence meter. The
/// reasoning ("ทำไม / ทำไมตอนนี้ / สิ่งที่ควรจับตา") and the technical planet
/// evidence live behind an expandable detail.
class PredictionWindowCardModel {
  const PredictionWindowCardModel({
    required this.windowLabel,
    required this.timeframeLabel,
    required this.summary,
    required this.topOpportunity,
    required this.topRisk,
    required this.confidenceLabel,
    required this.confidenceLevel,
    required this.why,
    required this.whyNow,
    required this.whatToWatch,
    required this.evidenceDetail,
  });

  /// Short tag for the horizon ("ช่วงนี้", "ใน 12 เดือนข้างหน้า").
  final String windowLabel;

  /// Human timeframe ("ช่วงอายุ 36–56", "ราว 12 เดือนข้างหน้า").
  final String timeframeLabel;

  /// One-line tendency summary (no planet/astrology terms).
  final String summary;

  /// Top opportunity sentence (tendency language).
  final String topOpportunity;

  /// Top risk / caution sentence (tendency language).
  final String topRisk;

  /// Qualitative confidence label — never a number ("พอเห็นแนวโน้มได้ชัด").
  final String confidenceLabel;

  /// 1–3 segments for the confidence meter (no raw percentage shown).
  final int confidenceLevel;

  /// "ทำไม" — plain-language reason (planet evidence excluded).
  final String why;

  /// "ทำไมตอนนี้" — timing reason.
  final String whyNow;

  /// "สิ่งที่ควรจับตา" — life-period reason + the specific risk area.
  final String whatToWatch;

  /// Technical planet evidence — shown only inside the expandable detail.
  final String evidenceDetail;
}

/// The whole Future Prediction section view state.
class PredictionSectionModel {
  const PredictionSectionModel({
    required this.sectionTitle,
    required this.sectionIntro,
    required this.windows,
    required this.transitionLine,
    required this.closingAdvice,
  });

  final String sectionTitle;
  final String sectionIntro;

  /// Up to three horizon cards in order: current → next 12 months → next period.
  final List<PredictionWindowCardModel> windows;

  /// A bridging line from the current chapter into what is ahead.
  final String transitionLine;

  /// A gentle, non-deterministic closing note (tendency, not a verdict).
  final String closingAdvice;

  bool get isEmpty => windows.isEmpty;
}
