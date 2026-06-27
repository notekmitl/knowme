import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

import 'prediction_reason_copy.dart';
import 'prediction_section_model.dart';

/// V10.5 — Prediction Composer.
///
/// Turns the copy-free [PredictionIntelligence] evidence into the Future
/// Prediction section's consumer copy. It **consumes `PredictionIntelligence`
/// only** and never touches the engine. All wording is tendency language and the
/// copy boundary is preserved (the engine emits codes, this composer emits
/// prose). Deterministic — driven by a profile seed so output is stable.
abstract final class PredictionComposer {
  /// Horizons shown, in reading order.
  static const _order = <PredictionWindowKind>[
    PredictionWindowKind.current,
    PredictionWindowKind.next12Months,
    PredictionWindowKind.nextLifePeriod,
  ];

  static String _pick(List<String> options, int n) =>
      options[n.abs() % options.length];

  static PredictionSectionModel? compose({
    required PredictionIntelligence intelligence,
    required int seed,
  }) {
    final cards = <PredictionWindowCardModel>[];
    for (var i = 0; i < _order.length; i++) {
      final kind = _order[i];
      final preds = intelligence.forWindow(kind);
      if (preds.isEmpty) continue;
      final window = _windowFor(intelligence, kind);
      if (window == null) continue;
      cards.add(_card(kind, window, preds, seed + i * 97));
    }
    if (cards.isEmpty) return null;

    return PredictionSectionModel(
      sectionTitle: 'แนวโน้มชีวิตในระยะข้างหน้า',
      sectionIntro:
          'ต่อไปนี้คือแนวโน้มกว้าง ๆ ของช่วงข้างหน้า อ่านเป็นแนวทางพอให้เตรียมใจ '
          'ไม่ใช่คำทำนายที่ตายตัว',
      windows: cards,
      transitionLine: _transitionLine(seed),
      closingAdvice: _closingAdvice(seed),
    );
  }

  static PredictionWindow? _windowFor(
    PredictionIntelligence intelligence,
    PredictionWindowKind kind,
  ) {
    for (final w in intelligence.windows) {
      if (w.kind == kind) return w;
    }
    return null;
  }

  static PredictionWindowCardModel _card(
    PredictionWindowKind kind,
    PredictionWindow window,
    List<Prediction> preds,
    int seed,
  ) {
    final lead = _lead(preds);
    final oppDomain = _topOpportunityDomain(preds);
    final riskDomain = _topRiskDomain(preds);
    final oppLabel = oppDomain?.labelTh ?? 'ภาพรวมของชีวิต';
    final riskLabel = riskDomain?.labelTh ?? 'จังหวะที่เปลี่ยนไป';
    final confidence = _confidence(lead.score.confidence);

    final lifePeriodText =
        PredictionReasonCopy.lifePeriod(lead.lifePeriodReason, seed);
    final whatToWatch = lifePeriodText.isEmpty
        ? 'ลองจับตาเรื่อง$riskLabel ไว้เป็นพิเศษ'
        : '$lifePeriodText ลองจับตาเรื่อง$riskLabel ไว้เป็นพิเศษ';

    return PredictionWindowCardModel(
      windowLabel: _windowLabel(kind),
      timeframeLabel: _timeframe(kind, window),
      summary: _summary(kind, oppLabel, seed),
      topOpportunity: _opportunityLine(oppLabel, seed),
      topRisk: _riskLine(riskLabel, seed),
      confidenceLabel: confidence.label,
      confidenceLevel: confidence.level,
      why: PredictionReasonCopy.why(lead.planetReason, seed),
      whyNow: PredictionReasonCopy.whyNow(lead.timingReason, seed),
      whatToWatch: whatToWatch,
      evidenceDetail: _evidenceDetail(lead, seed),
    );
  }

  // --- Selection (deterministic) ------------------------------------------

  /// The window's lead category = highest strength, ties broken by category
  /// order. Drives the window-level "why / why now / evidence".
  static Prediction _lead(List<Prediction> preds) {
    final list = [...preds]..sort((a, b) {
        final c = b.score.strength.compareTo(a.score.strength);
        return c != 0 ? c : a.category.index.compareTo(b.category.index);
      });
    return list.first;
  }

  static LifeDomain? _topOpportunityDomain(List<Prediction> preds) {
    LifeDomain? best;
    var bestMag = -1;
    for (final p in preds) {
      for (final o in p.opportunities) {
        if (o.magnitude > bestMag ||
            (o.magnitude == bestMag &&
                (best == null || o.domain.index < best.index))) {
          bestMag = o.magnitude;
          best = o.domain;
        }
      }
    }
    return best;
  }

  static LifeDomain? _topRiskDomain(List<Prediction> preds) {
    LifeDomain? best;
    var bestMag = -1;
    for (final p in preds) {
      for (final r in p.risks) {
        if (r.magnitude > bestMag ||
            (r.magnitude == bestMag &&
                (best == null || r.domain.index < best.index))) {
          bestMag = r.magnitude;
          best = r.domain;
        }
      }
    }
    return best;
  }

  // --- Copy slots ----------------------------------------------------------

  static ({String label, int level}) _confidence(int confidence) {
    if (confidence >= 78) {
      return (label: 'พอเห็นแนวโน้มได้ค่อนข้างชัด', level: 3);
    }
    if (confidence >= 60) {
      return (label: 'พอจับทิศทางได้', level: 2);
    }
    return (label: 'ยังเป็นภาพกว้าง ๆ ที่ยังเปลี่ยนได้', level: 1);
  }

  static String _windowLabel(PredictionWindowKind kind) => switch (kind) {
        PredictionWindowKind.current => 'ช่วงนี้',
        PredictionWindowKind.next12Months => 'ใน 12 เดือนข้างหน้า',
        PredictionWindowKind.nextLifePeriod => 'ช่วงชีวิตถัดไป',
      };

  static String _timeframe(PredictionWindowKind kind, PredictionWindow window) {
    switch (kind) {
      case PredictionWindowKind.current:
        return 'ช่วงอายุ ${window.startAge}–${window.endAge}';
      case PredictionWindowKind.next12Months:
        return 'ราว 12 เดือนข้างหน้า';
      case PredictionWindowKind.nextLifePeriod:
        return 'ช่วงอายุ ${window.startAge}–${window.endAge}';
    }
  }

  static String _summary(PredictionWindowKind kind, String oppLabel, int seed) {
    switch (kind) {
      case PredictionWindowKind.current:
        return _pick([
          'ช่วงนี้โดยรวมมักเป็นจังหวะที่เรื่อง$oppLabel ได้รับแรงหนุนมากเป็นพิเศษ',
          'ในช่วงนี้ เรื่อง$oppLabel มักเป็นด้านที่เดินหน้าได้ดีที่สุด',
        ], seed);
      case PredictionWindowKind.next12Months:
        return _pick([
          'ในราว 1 ปีข้างหน้า เรื่อง$oppLabel มักเป็นด้านที่มีจังหวะให้ขยับ',
          'ระยะใกล้นี้ แนวโน้มที่เด่นมักอยู่ที่เรื่อง$oppLabel',
        ], seed);
      case PredictionWindowKind.nextLifePeriod:
        return _pick([
          'เมื่อก้าวสู่ช่วงชีวิตถัดไป เรื่อง$oppLabel มักเป็นประตูที่เปิดกว้างขึ้น',
          'ในช่วงชีวิตถัดไป เรื่อง$oppLabel มักกลายเป็นจุดที่คุณได้เปรียบ',
        ], seed);
    }
  }

  static String _opportunityLine(String oppLabel, int seed) => _pick([
        'จุดที่มักได้แรงหนุนเป็นพิเศษคือเรื่อง$oppLabel',
        'ด้านที่มักเปิดโอกาสให้มากที่สุดคือเรื่อง$oppLabel',
      ], seed);

  static String _riskLine(String riskLabel, int seed) => _pick([
        'เรื่องที่ควรเผื่อใจไว้คือ$riskLabel',
        'อีกด้านที่อยากให้ดูแลเป็นพิเศษคือ$riskLabel',
      ], seed);

  static String _evidenceDetail(Prediction lead, int seed) {
    final planet = lead.planetReason.planet;
    final bond = lead.planetReason.bond;
    if (planet == null) return '';
    final name = PredictionReasonCopy.planetName(planet);
    final category = PredictionReasonCopy.categoryLabel(lead.category);
    final bondLabel = bond == null ? '' : ' ในระดับ “${bond.labelTh}”';
    return _pick([
      'ที่มาเชิงเทคนิค: แนวโน้มนี้อ้างอิงจากอิทธิพลของ$name ในช่วงดังกล่าว '
          'ซึ่งสัมพันธ์กับดาวประจำวันเกิดของคุณ$bondLabel '
          'และสะท้อนออกมาชัดที่สุดในด้าน$category',
      'ที่มาเชิงเทคนิค: ช่วงนี้อยู่ภายใต้อิทธิพลของ$name ความสัมพันธ์กับ '
          'พื้นฐานวันเกิดของคุณ$bondLabel จึงปรากฏเป็นแนวโน้มด้าน$category',
    ], seed);
  }

  static String _transitionLine(int seed) => _pick([
        'การก้าวจากช่วงนี้ไปสู่ช่วงข้างหน้า มักเป็นแบบค่อยเป็นค่อยไป '
            'มากกว่าจะเปลี่ยนแบบกะทันหัน',
        'รอยต่อระหว่างช่วงนี้กับช่วงหน้า มักให้เวลาคุณปรับตัวพอสมควร',
      ], seed);

  static String _closingAdvice(int seed) => _pick([
        'ทั้งหมดนี้เป็นเพียงแนวโน้ม ไม่ใช่คำตัดสิน คุณยังเป็นคนกำหนดทิศทาง '
            'ของตัวเองได้เสมอ',
        'อ่านสิ่งเหล่านี้เป็นแนวทางพอให้เตรียมใจ ส่วนการเลือกยังอยู่ในมือคุณเสมอ',
      ], seed);
}
