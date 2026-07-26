import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_plain_thai_renderer.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_mirror_life_timeline_state.dart';

/// V1.3.4 — Current card: always การงาน / การเงิน / สุขภาพ / โชคลาภ.
///
/// Built from [PeriodScores], planet affinity, and structured verdict claims.
/// Never invents natal houses, degrees, or gambling advice.
abstract final class LifeMapCurrentDomainComposer {
  static const titleWork = 'การงาน';
  static const titleMoney = 'การเงิน';
  static const titleHealth = 'สุขภาพ';
  static const titleFortune = 'โชคลาภ';

  /// Product titles in required display order.
  static const allowedTitles = <String>[
    titleWork,
    titleMoney,
    titleHealth,
    titleFortune,
  ];

  /// Legacy V1.3.3 titles — must not appear on Current UI.
  static const legacyTitles = <String>['การดำเนินชีวิต', 'ความรัก'];

  /// Build exactly four domain blocks for Current.
  static List<ThaiMirrorLifeDomainBlock> compose({
    required LifeMapVerdictSemantics semantics,
    required PeriodScores scores,
    required LifePlanetData data,
    String comparison = '',
    int seed = 0,
  }) {
    if (semantics.tense != LifeMapVerdictTense.current) {
      return const [];
    }

    final s = seed.abs();
    final work = _work(semantics, scores, data, s);
    final money = _money(semantics, scores, data, s);
    final health = _health(semantics, scores, data, s);
    final fortune = _fortune(semantics, scores, data, s);

    return [
      ThaiMirrorLifeDomainBlock(
        title: titleWork,
        body: work.body,
        evidenceKeys: work.keys,
      ),
      ThaiMirrorLifeDomainBlock(
        title: titleMoney,
        body: money.body,
        evidenceKeys: money.keys,
      ),
      ThaiMirrorLifeDomainBlock(
        title: titleHealth,
        body: health.body,
        evidenceKeys: health.keys,
      ),
      ThaiMirrorLifeDomainBlock(
        title: titleFortune,
        body: fortune.body,
        evidenceKeys: fortune.keys,
      ),
    ];
  }

  static ({String body, List<String> keys}) _work(
    LifeMapVerdictSemantics semantics,
    PeriodScores scores,
    LifePlanetData data,
    int seed,
  ) {
    final level = _band(scores.career);
    final pressure = _band(scores.pressure);
    final direction = _workDirection(scores);
    final keys = <String>[
      'score:career:${scores.career}',
      'score:pressure:${scores.pressure}',
      'direction:${direction.id}',
      'planet:${data.planet.name}',
      'signal:$level',
    ];

    final situation = _pickClaim(
      semantics,
      prefer: {
        LifeMapClaimDomain.workRole,
        LifeMapClaimDomain.opportunityExpand,
        LifeMapClaimDomain.learningPath,
        LifeMapClaimDomain.dutyBurden,
      },
    );

    final parts = <String>[];
    parts.add(_workSituation(direction, level, data, situation, seed));
    parts.add(_workTrend(direction, scores, data, seed));
    parts.add(_workCaution(direction, pressure, scores, seed));
    return (body: _joinUnique(parts, min: 2, max: 4), keys: keys);
  }

  static ({String body, List<String> keys}) _money(
    LifeMapVerdictSemantics semantics,
    PeriodScores scores,
    LifePlanetData data,
    int seed,
  ) {
    final level = _band(scores.money);
    final career = _band(scores.career);
    final keys = <String>[
      'score:money:${scores.money}',
      'score:career:${scores.career}',
      'score:opportunity:${scores.opportunity}',
      'planet:${data.planet.name}',
      'signal:$level',
    ];

    final situation = _pickClaim(
      semantics,
      prefer: {LifeMapClaimDomain.moneySecurity, LifeMapClaimDomain.dutyBurden},
    );

    final parts = <String>[];
    parts.add(_moneySituation(level, career, data, situation, seed));
    parts.add(_moneyTrend(level, scores, seed));
    parts.add(_moneyCaution(level, scores, seed));
    return (body: _joinUnique(parts, min: 2, max: 4), keys: keys);
  }

  static ({String body, List<String> keys}) _health(
    LifeMapVerdictSemantics semantics,
    PeriodScores scores,
    LifePlanetData data,
    int seed,
  ) {
    final level = _band(scores.health);
    final pressure = _band(scores.pressure);
    final keys = <String>[
      'score:health:${scores.health}',
      'score:pressure:${scores.pressure}',
      'planet:${data.planet.name}',
      'signal:$level',
    ];

    final situation = _pickClaim(
      semantics,
      prefer: {LifeMapClaimDomain.healthEnergy},
    );

    final parts = <String>[];
    parts.add(_healthSituation(level, pressure, data, situation, seed));
    parts.add(_healthTrend(level, pressure, scores, seed));
    parts.add(_healthCaution(pressure, seed));
    final body = _joinUnique(parts, min: 2, max: 4);
    // Safety: never emit diagnosis terms.
    if (_hasBannedHealth(body)) {
      return (
        body:
            'ช่วงนี้ภาระและความเครียดมีผลต่อพลังชีวิตโดยรวม '
            'ควรจัดเวลานอนและพักเป็นระยะ '
            'ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ ไม่ใช่คำบอกจากแพทย์',
        keys: [...keys, 'safety:conservative_health'],
      );
    }
    return (body: body, keys: keys);
  }

  static ({String body, List<String> keys}) _fortune(
    LifeMapVerdictSemantics semantics,
    PeriodScores scores,
    LifePlanetData data,
    int seed,
  ) {
    final opp = _band(scores.opportunity);
    final money = _band(scores.money);
    final career = _band(scores.career);
    final keys = <String>[
      'score:opportunity:${scores.opportunity}',
      'score:money:${scores.money}',
      'score:career:${scores.career}',
      'planet:${data.planet.name}',
      'signal:$opp',
    ];

    final parts = <String>[];
    if (opp == _Signal.quiet && money != _Signal.strong) {
      parts.add('ช่วงนี้ยังไม่มีสัญญาณโชคเด่นจากจังหวะดาวเสวยอายุ');
      parts.add(
        'รายได้หลักยังน่าจะมาจากงานและความสามารถที่ลงมือทำเองมากกว่าเหตุบังเอิญ',
      );
      parts.add(
        'หากมีโอกาสจากคนรู้จัก ให้ถือเป็นโชคเล็กน้อยแล้วประเมินภาระก่อนรับ',
      );
      return (
        body: _joinUnique(parts, min: 2, max: 4),
        keys: [...keys, 'fortune:quiet'],
      );
    }

    parts.add(_fortuneSituation(opp, data, seed));
    parts.add(_fortuneVsWork(career, money, seed));
    parts.add(_fortuneCaution(opp, seed));
    return (body: _joinUnique(parts, min: 2, max: 4), keys: keys);
  }

  // --- work copy from typed direction ---

  static _WorkDirection _workDirection(PeriodScores scores) {
    final c = scores.career;
    final p = scores.pressure;
    final o = scores.opportunity;
    if (p >= 72 && c < 55) return _WorkDirection.weigh;
    if (o >= 70 && c >= 60) return _WorkDirection.advance;
    if ((c - scores.growth).abs() <= 8 && p < 55) return _WorkDirection.steady;
    if (o >= 65 || scores.growth >= 68) return _WorkDirection.shift;
    if (c >= 65) return _WorkDirection.advance;
    if (p >= 65) return _WorkDirection.weigh;
    return _WorkDirection.steady;
  }

  static String _workSituation(
    _WorkDirection d,
    _Signal level,
    LifePlanetData data,
    String? claim,
    int seed,
  ) {
    if (claim != null && claim.isNotEmpty && !_tooAbstract(claim)) {
      final cleaned = _stripLead(claim);
      if (cleaned.startsWith('คุณ') ||
          cleaned.startsWith('มี') ||
          cleaned.startsWith('งาน')) {
        return 'ช่วงนี้$cleaned';
      }
      return 'ช่วงนี้งาน$cleaned';
    }
    return switch (d) {
      _WorkDirection.advance =>
        'ช่วงนี้งานมีแนวโน้มขยายตัวและมีหน้าที่เข้ามามากขึ้นในจังหวะ${data.keyword}',
      _WorkDirection.steady =>
        'ช่วงนี้งานค่อนข้างทรงตัว โฟกัสอยู่ที่รักษาคุณภาพมากกว่าเร่งขยาย',
      _WorkDirection.shift =>
        'ช่วงนี้งานมีสัญญาณเปลี่ยนแปลง ทิศทางและหน้าที่อาจไม่เหมือนช่วงก่อน',
      _WorkDirection.weigh =>
        'ช่วงนี้งานมีแรงกดดันสูง ควรพิจารณาก่อนรับภาระเพิ่ม',
    };
  }

  static String _workTrend(
    _WorkDirection d,
    PeriodScores scores,
    LifePlanetData data,
    int seed,
  ) {
    return switch (d) {
      _WorkDirection.advance =>
        'มีโอกาสรับงานหรือความรับผิดชอบเพิ่มตามจังหวะ${data.phaseName} แต่ไม่จำเป็นต้องรับทุกทางพร้อมกัน',
      _WorkDirection.steady =>
        'แนวโน้มคือเดินหน้าแบบค่อยเป็นค่อยไป และวัดผลจากสิ่งที่ทำต่อเนื่อง',
      _WorkDirection.shift =>
        'หากคิดเปลี่ยนงานหรือเปิดโครงการใหม่ ให้เทียบภาระปัจจุบันกับผลที่จะได้ก่อนตัดสินใจ',
      _WorkDirection.weigh =>
        'ทิศทางที่เหมาะคือชะลอการขยาย แล้วจัดลำดับงานที่สำคัญจริงก่อน',
    };
  }

  static String _workCaution(
    _WorkDirection d,
    _Signal pressure,
    PeriodScores scores,
    int seed,
  ) {
    if (pressure == _Signal.strong || d == _WorkDirection.weigh) {
      return 'จุดเสี่ยงคือรับมากจนเวลาและพลังไม่พอ ควรตั้งเกณฑ์ว่างานใดรับได้ในรอบนี้';
    }
    if (d == _WorkDirection.advance) {
      return 'ควรระวังการรับงานซ้อนจนกระทบคุณภาพและความต่อเนื่อง';
    }
    return 'ใช้ช่วงนี้ทบทวนว่าหน้าที่ใดสร้างผลจริง และหน้าที่ใดควรวางลง';
  }

  // --- money ---

  static String _moneySituation(
    _Signal level,
    _Signal career,
    LifePlanetData data,
    String? claim,
    int seed,
  ) {
    if (claim != null && claim.isNotEmpty && !_tooAbstract(claim)) {
      return 'ด้านการเงิน${_stripLead(claim)}';
    }
    if (level == _Signal.quiet) {
      return 'ช่วงนี้สัญญาณการเงินไม่เด่นชัดจากจังหวะดาวเสวยอายุ';
    }
    if (level == _Signal.strong && career == _Signal.strong) {
      return 'ช่วงนี้มีแนวโน้มหารายได้ได้มากขึ้นตามปริมาณงานและความรับผิดชอบ';
    }
    if (level == _Signal.strong) {
      return 'ช่วงนี้ฐานะมีโอกาสตั้งหลักได้ชัดขึ้นเมื่อจัดรายรับรายจ่ายเป็นระบบ';
    }
    if (level == _Signal.mild) {
      return 'ช่วงนี้รายรับมีได้บ้าง แต่ยังไม่เสถียรพอจะขยายการใช้จ่ายเร็ว';
    }
    return 'ช่วงนี้การเงินอยู่ในระดับพอไปได้ ควรรักษาสภาพคล่องเป็นหลัก';
  }

  static String _moneyTrend(_Signal level, PeriodScores scores, int seed) {
    if (scores.money >= 65 && scores.pressure >= 60) {
      return 'รายจ่ายและต้นทุนมีแนวโน้มเพิ่มตามภาระ เงินเข้ามาแล้วไม่ควรรีบใช้หมด';
    }
    if (level == _Signal.strong) {
      return 'เหมาะกับการสะสมและกันเงินสำรองมากกว่าการเสี่ยงทั้งหมดในคราวเดียว';
    }
    if (level == _Signal.quiet) {
      return 'รายได้หลักยังผูกกับงานที่ทำสม่ำเสมอ ควรวางแผนค่าใช้จ่ายให้เห็นภาพล่วงหน้า';
    }
    return 'แนวโน้มคือรักษาสภาพคล่อง และแยกเงินใช้จ่ายออกจากเงินสำรองให้ชัด';
  }

  static String _moneyCaution(_Signal level, PeriodScores scores, int seed) {
    if (scores.pressure >= 68) {
      return 'ควรระวังเงินรั่วจากภาระซ้อน หรือค่าใช้จ่ายที่เพิ่มขึ้นโดยไม่ทันสังเกต';
    }
    if (level == _Signal.strong) {
      return 'แม้รายรับดูดีขึ้น ก็ยังควรกันส่วนหนึ่งไว้ก่อนขยายการใช้';
    }
    return 'หลีกเลี่ยงการก่อภาระระยะยาวเมื่อกระแสเงินยังไม่นิ่ง';
  }

  // --- health ---

  static String _healthSituation(
    _Signal level,
    _Signal pressure,
    LifePlanetData data,
    String? claim,
    int seed,
  ) {
    if (claim != null &&
        claim.isNotEmpty &&
        !_tooAbstract(claim) &&
        !_hasBannedHealth(claim)) {
      return 'ด้านพลังชีวิต${_stripLead(claim)}';
    }
    if (pressure == _Signal.strong) {
      return 'ช่วงนี้ภาระหลายด้านทำให้พักผ่อนน้อย และความเหนื่อยมีแนวโน้มสะสม';
    }
    if (level == _Signal.strong) {
      return 'ช่วงนี้พลังชีวิตพอไปได้หากจัดจังหวะพักสม่ำเสมอ';
    }
    if (level == _Signal.quiet) {
      return 'ช่วงนี้สัญญาณสุขภาพตามจังหวะดาวเสวยอายุไม่เด่น โฟกัสที่การพักและภาระประจำวัน';
    }
    return 'ช่วงนี้พลังชีวิตถูกใช้ไปกับหน้าที่และความรับผิดชอบค่อนข้างมาก';
  }

  static String _healthTrend(
    _Signal level,
    _Signal pressure,
    PeriodScores scores,
    int seed,
  ) {
    if (pressure == _Signal.strong) {
      return 'แนวโน้มคือเครียดสะสมเมื่อทำงานต่อเนื่องโดยไม่เว้นช่วงพัก';
    }
    return 'ควรรักษาเวลานอนและเว้นช่วงพักสั้น ๆ เพื่อไม่ให้ความล้าสะสม';
  }

  static String _healthCaution(_Signal pressure, int seed) {
    return 'ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ ไม่ใช่คำบอกจากแพทย์ '
        'หากร่างกายส่งสัญญาณผิดปกติควรปรึกษาผู้เชี่ยวชาญ';
  }

  // --- fortune ---

  static String _fortuneSituation(_Signal opp, LifePlanetData data, int seed) {
    if (opp == _Signal.strong) {
      return 'ช่วงนี้อาจมีโอกาสจากคนรู้จักหรือช่องทางที่เปิดขึ้นในจังหวะ${data.keyword}';
    }
    if (opp == _Signal.mild || opp == _Signal.active) {
      return 'ช่วงนี้อาจมีโชคเล็กน้อยจากเครือข่ายหรือโอกาสที่เข้ามาโดยไม่คาดคิดมากนัก';
    }
    return 'ช่วงนี้ยังไม่มีสัญญาณโชคก้อนใหญ่จากจังหวะดาวเสวยอายุ';
  }

  static String _fortuneVsWork(_Signal career, _Signal money, int seed) {
    return 'รายได้หลักยังแยกจากโชคเหตุบังเอิญ — ส่วนใหญ่มาจากงานและความสามารถที่ลงมือเอง';
  }

  static String _fortuneCaution(_Signal opp, int seed) {
    return 'ไม่ควรใช้ช่วงนี้เป็นเหตุผลไปเสี่ยงพนันหรือลงทุนเกินกำลัง '
        'ให้ประเมินโอกาสจากหลักฐานและภาระจริงก่อนรับ';
  }

  // --- helpers ---

  static String? _pickClaim(
    LifeMapVerdictSemantics semantics, {
    required Set<LifeMapClaimDomain> prefer,
  }) {
    if (prefer.contains(semantics.primary.domain)) {
      return semantics.primary.situationTh;
    }
    if (semantics.secondary != null &&
        prefer.contains(semantics.secondary!.domain)) {
      return semantics.secondary!.situationTh;
    }
    if (semantics.pressure != null &&
        prefer.contains(semantics.pressure!.domain)) {
      return semantics.pressure!.pressureTh;
    }
    return null;
  }

  static _Signal _band(int score) {
    if (score >= 72) return _Signal.strong;
    if (score >= 58) return _Signal.active;
    if (score >= 45) return _Signal.mild;
    return _Signal.quiet;
  }

  static String _joinUnique(List<String> parts, {int min = 2, int max = 4}) {
    final out = <String>[];
    for (final p in parts) {
      final t = p.trim();
      if (t.isEmpty) continue;
      if (LifeMapVerdictCopy.violatesPrimaryBody(t)) continue;
      if (LifeMapPlainThaiRenderer.hasVagueRelationshipForm(t)) continue;
      if (out.any((e) => LifeMapPlainThaiRenderer.sameMeaningPublic(e, t))) {
        continue;
      }
      out.add(t);
      if (out.length >= max) break;
    }
    while (out.length < min) {
      // Conservative filler from typed quiet state — not invented events.
      out.add('ใช้ข้อมูลช่วงนี้ประกอบการตัดสินใจ ไม่ใช่คำฟันธงเหตุการณ์เฉพาะ');
      if (out.length >= min) break;
    }
    return out.take(max).join(' ');
  }

  static String _stripLead(String raw) {
    var t = raw.trim();
    for (final lead in ['ตอนนี้', 'ขณะนี้', 'ต่อไป', 'ช่วงนี้']) {
      if (t.startsWith(lead)) t = t.substring(lead.length).trimLeft();
    }
    return t;
  }

  static bool _tooAbstract(String text) {
    const banned = [
      'เรียนรู้และเชื่อมโยง',
      'เก็บเกี่ยวความสุขที่เน้น',
      'พลังชีวิตกำลังทำงาน',
      'ค่อย ๆ วางโครงให้ชีวิต',
      'เปิดรับสิ่งที่เข้ามา',
      'เลือกสิ่งสำคัญจริง ๆ',
    ];
    return banned.any(text.contains);
  }

  static bool _hasBannedHealth(String text) {
    const banned = [
      'โรค',
      'มะเร็ง',
      'หัวใจวาย',
      'เบาหวาน',
      'ความดัน',
      'ผ่าตัด',
      'ติดเชื้อ',
      'อวัยวะ',
    ];
    return banned.any(text.contains);
  }
}

enum _Signal { quiet, mild, active, strong }

enum _WorkDirection {
  advance('advance'),
  steady('steady'),
  shift('shift'),
  weigh('weigh');

  const _WorkDirection(this.id);
  final String id;
}
