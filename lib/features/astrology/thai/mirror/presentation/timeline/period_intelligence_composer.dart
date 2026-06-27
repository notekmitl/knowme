import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/future_period_preview.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_element.dart';

import 'thai_mirror_life_timeline_state.dart';

/// V9 — Period Intelligence Composer.
///
/// Turns the copy-free [CurrentAgeAnalysis] / [FuturePeriodPreview] evidence
/// into Thai consumer copy (tendency language — "มัก / มีแนวโน้ม / อาจ", never
/// fate/destiny/certainty). Lives in the presentation layer to preserve the copy
/// boundary: the engine emits structure, the composer emits prose. Deterministic
/// — every slot is selected by a profile seed so it is stable and testable.
abstract final class PeriodIntelligenceComposer {
  static String _pick(List<String> options, int n) =>
      options[n.abs() % options.length];

  // ---- Current age analysis ------------------------------------------------

  static ThaiMirrorCurrentAnalysisState composeCurrent({
    required CurrentAgeAnalysis analysis,
    required int seed,
  }) {
    final reasons = <String>[
      for (final f in analysis.factors) _reasonFor(f, seed),
    ].where((s) => s.isNotEmpty).toList(growable: false);

    return ThaiMirrorCurrentAnalysisState(
      title: 'ทำไมช่วงนี้ถึงสำคัญ',
      stageLabel: 'ตอนนี้คุณอยู่${analysis.stage.labelTh}',
      dominantInfluences: _dominantInfluences(analysis, seed),
      reasons: reasons,
    );
  }

  static String _reasonFor(CurrentAgeFactor factor, int seed) {
    switch (factor) {
      case CurrentAgeFactor.longDefiningPeriod:
        return _pick([
          'ช่วงนี้เป็นช่วงยาวที่ค่อย ๆ วางโครงให้ชีวิตของคุณไปอีกหลายปี',
          'เพราะเป็นช่วงที่ยาวและเข้มข้น สิ่งที่คุณสร้างตอนนี้มักอยู่กับคุณไปนาน',
        ], seed ~/ 2);
      case CurrentAgeFactor.briefIntensePeriod:
        return _pick([
          'ช่วงนี้สั้นแต่เข้มข้น สิ่งที่เกิดขึ้นมักส่งผลชัดเจนในเวลาไม่นาน',
          'เป็นช่วงสั้น ๆ ที่จังหวะชีวิตมักเดินเร็วกว่าปกติ',
        ], seed ~/ 3);
      case CurrentAgeFactor.alignedWithNature:
        return _pick([
          'จังหวะของช่วงนี้ค่อนข้างเข้ากับตัวตนของคุณ คุณจึงมักได้ใช้จุดแข็งอย่างเป็นธรรมชาติ',
          'ช่วงนี้เสริมกับพื้นฐานในตัวคุณ ทำให้หลายอย่างมักลื่นไหลกว่าที่คิด',
        ], seed ~/ 5);
      case CurrentAgeFactor.testsYourNature:
        return _pick([
          'ช่วงนี้มีแนวโน้มท้าทายนิสัยเดิมของคุณอยู่บ้าง ซึ่งมักกลายเป็นบทเรียนที่ทำให้โตขึ้น',
          'บางจังหวะอาจรู้สึกต้องปรับตัวมากกว่าปกติ แต่ก็เป็นช่วงที่หล่อหลอมคุณให้แกร่งขึ้น',
        ], seed ~/ 7);
      case CurrentAgeFactor.openingMomentum:
        return _pick([
          'คุณเพิ่งเข้าสู่ช่วงนี้ จึงยังมีพื้นที่ให้ตั้งหลักและเลือกทิศทางได้เต็มที่',
          'ตอนนี้เป็นช่วงต้น ทุกการเริ่มต้นมักวางรากฐานให้กับทั้งช่วง',
        ], seed ~/ 11);
      case CurrentAgeFactor.midPeak:
        return _pick([
          'คุณอยู่กลางช่วงพอดี เป็นจังหวะที่พลังของช่วงนี้มักเด่นที่สุด',
          'ช่วงกลางแบบนี้มักเป็นตอนที่สิ่งที่ทำมาเริ่มเห็นผล',
        ], seed ~/ 13);
      case CurrentAgeFactor.transitionApproaching:
        return _pick([
          'คุณใกล้จบช่วงนี้แล้ว อีกไม่นานชีวิตมักจะค่อย ๆ เปลี่ยนจังหวะ',
          'เป็นช่วงปลายที่เหมาะกับการสรุปบทเรียนก่อนก้าวสู่จังหวะใหม่',
        ], seed ~/ 17);
    }
  }

  static String _dominantInfluences(CurrentAgeAnalysis analysis, int seed) {
    final intel = analysis.intelligence;
    final element = intel.element.labelTh;
    if (intel.isNatalHarmonious) {
      return _pick([
        'อิทธิพลหลักตอนนี้คือพลังธาตุ$element ที่ส่งเสริมพื้นฐานในตัวคุณ คุณจึงมักรู้สึกว่าได้เป็นตัวเองมากขึ้น',
        'ช่วงนี้พลังธาตุ$element กำลังทำงานเข้าขากับตัวตนของคุณ ทำให้หลายเรื่องมักไปต่อได้ง่าย',
      ], seed ~/ 19);
    }
    if (intel.isNatalChallenging) {
      return _pick([
        'อิทธิพลหลักตอนนี้คือพลังธาตุ$element ที่ค่อนข้างต่างจากพื้นฐานของคุณ จึงมักเป็นช่วงของการปรับตัวและเรียนรู้',
        'ช่วงนี้พลังธาตุ$element กำลังท้าทายแนวทางเดิมของคุณอยู่บ้าง ซึ่งมักเปิดมุมมองใหม่ให้',
      ], seed ~/ 23);
    }
    return _pick([
      'อิทธิพลหลักตอนนี้คือพลังธาตุ$element ที่เปิดให้คุณเลือกได้ว่าจะหยิบจุดแข็งของตัวเองมาใช้แบบไหน',
      'ช่วงนี้พลังธาตุ$element วางตัวเป็นกลาง ทิศทางจึงขึ้นอยู่กับการตัดสินใจของคุณเป็นหลัก',
    ], seed ~/ 29);
  }

  // ---- Future preview ------------------------------------------------------

  static ThaiMirrorFuturePreviewState? composeFuture({
    required FuturePeriodPreview preview,
    required int seed,
  }) {
    if (!preview.hasNext) return null;
    final next = preview.nextPeriod!;
    final nextData = LifePlanets.of(next.planet);
    final transition = preview.transition!;
    final shift = preview.elementShift!;

    final intro = _pick([
      'อีกประมาณ ${preview.yearsUntil} ปี คุณจะค่อย ๆ ก้าวเข้าสู่${nextData.phaseName}',
      'ในราว ${preview.yearsUntil} ปีข้างหน้า ชีวิตของคุณมักจะเริ่มเปลี่ยนเข้าสู่${nextData.phaseName}',
    ], seed ~/ 31);

    final elementShiftLine = shift.changes
        ? 'พลังงานจะค่อย ๆ เปลี่ยนจากธาตุ${shift.from.labelTh}ไปสู่ธาตุ${shift.to.labelTh} '
            '(${shift.relation.labelTh})'
        : '';

    final opps = preview.opportunities.map((d) => d.labelTh).join(' · ');
    final chals = preview.challenges.map((d) => d.labelTh).join(' · ');

    return ThaiMirrorFuturePreviewState(
      title: 'ช่วงต่อไปของคุณ',
      intro: intro,
      transitionLabel: transition.labelTh,
      elementShiftLine: elementShiftLine,
      opportunitiesLine: opps.isEmpty
          ? ''
          : _pick([
              'ช่วงนั้นมักเปิดโอกาสด้าน $opps',
              'จุดที่มักได้เปรียบในช่วงหน้าคือเรื่อง $opps',
            ], seed ~/ 37),
      challengesLine: chals.isEmpty
          ? ''
          : _pick([
              'สิ่งที่ควรดูแลเป็นพิเศษคือเรื่อง $chals',
              'อีกด้านที่อยากให้เผื่อใจไว้คือเรื่อง $chals',
            ], seed ~/ 41),
    );
  }
}
