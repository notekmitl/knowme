import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_category.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_reason.dart';

/// V10.5 — translates the engine's [PredictionReasonCode]s into Thai consumer
/// copy. This is the **only** place reason codes become prose: the prediction
/// engine never emits wording (copy boundary, D-001/D-009/D-020).
///
/// All copy is **tendency language** ("มัก / มีแนวโน้ม / อาจ") — never
/// fate/destiny/certainty, never false precision, and never astrology jargon in
/// the headline-facing strings. Deterministic: every slot is chosen by a seed so
/// output is stable and testable.
abstract final class PredictionReasonCopy {
  static String _pick(List<String> options, int n) =>
      options[n.abs() % options.length];

  /// "Why" — translates the planet (natal-alignment) reason into plain language.
  /// Never names a planet here; planet evidence stays in the expandable detail.
  static String why(PredictionReason planetReason, int seed) {
    return switch (planetReason.code) {
      PredictionReasonCode.rulerSupportsNature => _pick([
          'แนวโน้มนี้มักสอดคล้องกับพื้นฐานนิสัยของคุณ คุณจึงได้ใช้จุดแข็งของตัวเองอย่างเป็นธรรมชาติ',
          'ช่วงนี้ค่อนข้างเข้ากับตัวตนของคุณ หลายเรื่องจึงมักลื่นไหลกว่าที่คิด',
          'จังหวะนี้เสริมกับสิ่งที่คุณเป็นอยู่แล้ว คุณจึงมักรู้สึกว่าได้เป็นตัวเองมากขึ้น',
        ], seed),
      PredictionReasonCode.rulerChallengesNature => _pick([
          'ช่วงนี้มักท้าทายแนวทางเดิมของคุณอยู่บ้าง ซึ่งหลายครั้งกลายเป็นบทเรียนที่ทำให้โตขึ้น',
          'บางจังหวะอาจรู้สึกต้องปรับตัวมากกว่าปกติ แต่ก็มักหล่อหลอมให้คุณแกร่งขึ้น',
          'แนวโน้มนี้ต่างจากความเคยชินของคุณอยู่บ้าง จึงมักเปิดมุมมองใหม่ให้',
        ], seed),
      PredictionReasonCode.rulerNeutralNature => _pick([
          'จังหวะนี้ค่อนข้างเป็นกลาง ทิศทางจึงมักขึ้นอยู่กับการเลือกของคุณเป็นหลัก',
          'ช่วงนี้ไม่ได้ผลักไปทางใดเป็นพิเศษ คุณจึงมีพื้นที่ตัดสินใจได้เต็มที่',
          'แนวโน้มยังเปิดกว้าง สิ่งที่คุณให้น้ำหนักมักกำหนดผลลัพธ์',
        ], seed),
      // Timing/life-period codes never drive the "why" line.
      _ => '',
    };
  }

  /// "Why now" — translates the timing reason for this window.
  static String whyNow(PredictionReason timingReason, int seed) {
    return switch (timingReason.code) {
      PredictionReasonCode.windowOpening => _pick([
          'คุณเพิ่งเข้าสู่จังหวะนี้ จึงยังมีพื้นที่ให้ตั้งหลักและเลือกทิศทางได้',
          'นี่เป็นช่วงต้นของจังหวะ ทุกการเริ่มต้นมักวางรากฐานให้กับช่วงที่เหลือ',
        ], seed),
      PredictionReasonCode.windowPeak => _pick([
          'ตอนนี้คุณอยู่กลางจังหวะพอดี เป็นช่วงที่พลังของมันมักเด่นที่สุด',
          'คุณอยู่จุดกลางของช่วง สิ่งที่ทำมามักเริ่มเห็นผลในตอนนี้',
        ], seed),
      PredictionReasonCode.windowClosing => _pick([
          'คุณอยู่ช่วงปลายของจังหวะนี้ หลายอย่างมักเริ่มค่อย ๆ เปลี่ยน',
          'เป็นช่วงท้าย เหมาะกับการสรุปบทเรียนก่อนก้าวสู่จังหวะใหม่',
        ], seed),
      PredictionReasonCode.transitionWithinWindow => _pick([
          'ช่วงนี้กำลังคาบเกี่ยวกับการเปลี่ยนผ่าน จังหวะชีวิตจึงมักขยับได้เร็ว',
          'เป็นรอยต่อระหว่างสองช่วง หลายเรื่องจึงมักอยู่ในช่วงปรับตัว',
        ], seed),
      PredictionReasonCode.steadyWindow => _pick([
          'จังหวะโดยรวมค่อนข้างนิ่ง แนวโน้มจึงมักต่อเนื่องไปในทิศทางเดิม',
          'ช่วงนี้ค่อนข้างคงที่ สิ่งที่เป็นอยู่มักดำเนินต่อไปอย่างราบเรียบ',
        ], seed),
      // Planet/life-period codes never drive "why now".
      _ => '',
    };
  }

  /// "What to watch" base — translates the life-period reason; the composer adds
  /// the specific risk area.
  static String lifePeriod(PredictionReason lifePeriodReason, int seed) {
    return switch (lifePeriodReason.code) {
      PredictionReasonCode.longDefiningPeriod => _pick([
          'เพราะเป็นช่วงยาวที่ค่อย ๆ วางโครงให้ชีวิต สิ่งที่ทำตอนนี้มักส่งผลไปอีกหลายปี',
          'ช่วงนี้ยาวและเข้มข้น สิ่งที่คุณสร้างไว้มักอยู่กับคุณไปนาน',
        ], seed),
      PredictionReasonCode.briefIntensePeriod => _pick([
          'เพราะเป็นช่วงสั้นแต่เข้มข้น เรื่องต่าง ๆ มักเปลี่ยนเร็วกว่าปกติ',
          'ช่วงนี้สั้น จังหวะจึงมักเดินไว สิ่งที่เกิดขึ้นมักเห็นผลเร็ว',
        ], seed),
      PredictionReasonCode.periodFavoursCategory => _pick([
          'โดยรวมเป็นจังหวะที่ค่อนข้างเปิดทางให้ด้านนี้',
          'ภาพรวมค่อนข้างเอื้อ คุณจึงมักผลักดันเรื่องนี้ได้ง่ายกว่าปกติ',
        ], seed),
      PredictionReasonCode.periodStrainsCategory => _pick([
          'ด้านนี้อาจต้องใช้แรงและความอดทนมากกว่าปกติสักหน่อย',
          'เรื่องนี้มักเรียกร้องการดูแลเป็นพิเศษในช่วงนี้',
        ], seed),
      // Timing/planet codes never drive the life-period note.
      _ => '',
    };
  }

  /// Short Thai label for a prediction category (a label, not prose). Safe for
  /// the consumer surface — no astrology terminology.
  static String categoryLabel(PredictionCategory category) => switch (category) {
        PredictionCategory.career => 'การงาน',
        PredictionCategory.finance => 'การเงิน',
        PredictionCategory.relationship => 'ความรัก',
        PredictionCategory.health => 'สุขภาพ',
        PredictionCategory.learning => 'การเรียนรู้',
        PredictionCategory.personalGrowth => 'การเติบโตภายใน',
        PredictionCategory.family => 'ครอบครัว',
      };

  /// Thai planet name — used **only** inside the expandable evidence detail.
  static String planetName(LifePlanet planet) =>
      LifePlanets.of(planet).thaiName;
}
