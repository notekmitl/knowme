import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

// V10.5 — UI-facing view state for the Future Prediction section.
//
// These models carry only strings/ints the widget renders. No engine, planet or
// prediction enums leak into the UI layer — the PredictionComposer flattens
// everything here (copy boundary preserved).

/// One evidence-derived life-domain forecast inside a prediction horizon.
class PredictionDomainModel {
  const PredictionDomainModel({
    required this.title,
    required this.body,
    required this.caution,
    this.claim = '',
    this.risk = '',
    this.decisionImpact = '',
    this.preparationAction = '',
    this.material,
  });

  /// One of การงาน / การเงิน / ความรัก / สุขภาพ.
  final String title;

  /// Direct forecast copy grounded in the category strength and reasons.
  final String body;

  /// The concrete pressure or boundary to watch in this domain.
  final String caution;

  /// Structured Thai Beta consumer fields. Empty on legacy Thai Mirror cards.
  final String claim;
  final String risk;
  final String decisionImpact;
  final String preparationAction;

  /// Typed consumer-material inputs. Serialized only for acceptance audits.
  final ForecastMaterialFingerprint? material;

  String get materialFingerprint => material?.serialize() ?? '';
}

enum ForecastHorizon { current, next12Months, nextLifePeriod }

enum ForecastDomain { career, finance, relationship, health }

enum ForecastBand { strong, active, quiet }

enum ForecastEvidenceAvailability { full, noLagna }

enum ForecastField { claim, risk, decisionImpact, action }

/// Canonical authority for forecast materiality and field-level projection.
class ForecastMaterialFingerprint {
  const ForecastMaterialFingerprint({
    required this.horizon,
    required this.domain,
    required this.band,
    required this.riskDomain,
    required this.evidenceAvailability,
    required this.spansTransition,
  });

  final ForecastHorizon horizon;
  final ForecastDomain domain;
  final ForecastBand band;
  final LifeDomain? riskDomain;
  final ForecastEvidenceAvailability evidenceAvailability;
  final bool spansTransition;

  Map<String, Object?> projection(ForecastField field) => switch (field) {
    ForecastField.claim => {'horizon': horizon, 'domain': domain, 'band': band},
    ForecastField.risk => {
      'horizon': horizon,
      'domain': domain,
      'riskDomain': riskDomain,
    },
    ForecastField.decisionImpact => {
      'horizon': horizon,
      'domain': domain,
      'band': band,
      'riskDomain': riskDomain,
    },
    ForecastField.action => {
      'horizon': horizon,
      'domain': domain,
      'band': band,
      'riskDomain': riskDomain,
      'evidenceAvailability': evidenceAvailability,
      'spansTransition': spansTransition,
    },
  };

  String serialize() => [
    'h=${horizon.name}',
    'd=${domain.name}',
    'b=${band.name}',
    'r=${riskDomain?.name ?? 'none'}',
    'e=${evidenceAvailability.name}',
    't=$spansTransition',
  ].join('|');
}

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
    this.domains = const [],
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

  /// Thai Beta V3 detailed reading. Existing callers render this only when
  /// their product mode opts in, preserving the standalone Thai Mirror UI.
  final List<PredictionDomainModel> domains;
}

/// The whole Future Prediction section view state.
class PredictionSectionModel {
  const PredictionSectionModel({
    required this.sectionTitle,
    required this.sectionIntro,
    required this.windows,
    required this.transitionLine,
    required this.closingAdvice,
    this.detailedSectionIntro = '',
    this.detailedClosingAdvice = '',
  });

  final String sectionTitle;
  final String sectionIntro;

  /// Up to three horizon cards in order: current → next 12 months → next period.
  final List<PredictionWindowCardModel> windows;

  /// A bridging line from the current chapter into what is ahead.
  final String transitionLine;

  /// A gentle, non-deterministic closing note (tendency, not a verdict).
  final String closingAdvice;

  /// Thai Beta V3 copy for the expanded four-domain presentation.
  final String detailedSectionIntro;
  final String detailedClosingAdvice;

  bool get isEmpty => windows.isEmpty;
}
