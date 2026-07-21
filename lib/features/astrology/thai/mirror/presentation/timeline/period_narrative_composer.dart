import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

import '../copy/thai_mirror_evidence_composer.dart';
import 'period_composite_score.dart';

/// Human narrative for one life period.
class PeriodNarrative {
  const PeriodNarrative({
    required this.summary,
    required this.whatChanges,
    required this.easier,
    required this.harder,
    required this.comparison,
    required this.evidenceLine,
  });

  final String summary;
  final String whatChanges;
  final String easier;
  final String harder;

  /// Previous → current → next bridge (may be empty for the very first period).
  final String comparison;

  /// A line that cites the person's existing strongest pattern.
  final String evidenceLine;
}

/// V8 — Period Narrative Composer.
///
/// Turns a [PeriodState] + its [PeriodScores] + the person's evidence into life
/// language ("ช่วงนี้เป็นช่วงที่...") rather than astrology terminology. Every
/// slot rotates across several variants by seed, phase, dominant domain and the
/// planet's relationship to the lagna lord, so periods don't read identically
/// across people or across a single life.
abstract final class PeriodNarrativeComposer {
  static const _domainNoun = {
    'career': 'การงานและเป้าหมาย',
    'money': 'ความมั่นคงและการเงิน',
    'love': 'ความรักและความสัมพันธ์',
    'health': 'การดูแลใจและร่างกาย',
    'growth': 'การเรียนรู้และการเติบโต',
    'opportunity': 'โอกาสใหม่ ๆ',
  };

  static const _domainFlourish = <String, List<String>>{
    'career': [
      'เรื่องงานและเป้าหมายกลายเป็นแกนหลักของชีวิต',
      'หน้าที่การงานและความสำเร็จเริ่มขึ้นมานำชีวิต',
      'ตัวตนในแบบ “คนทำงาน” ของคุณจะชัดเป็นพิเศษ',
    ],
    'money': [
      'ความมั่นคงและฐานการเงินเริ่มก่อตัวชัดขึ้น',
      'เรื่องเงินและการวางรากฐานชีวิตจะเด่นขึ้นมา',
      'การสร้างความมั่นคงให้ตัวเองกลายเป็นโจทย์หลัก',
    ],
    'love': [
      'ความสัมพันธ์และคนรอบตัวมีความหมายมากเป็นพิเศษ',
      'หัวใจและความผูกพันกับคนสำคัญจะเป็นศูนย์กลาง',
      'เรื่องของความรักและความเข้าใจกันจะเด่นขึ้น',
    ],
    'health': [
      'การกลับมาดูแลใจและร่างกายกลายเป็นเรื่องสำคัญ',
      'ชีวิตเรียกหาความสมดุลและการพักที่แท้จริง',
      'เสียงข้างในและสุขภาพของคุณจะดังขึ้นกว่าเดิม',
    ],
    'growth': [
      'การเรียนรู้และการเติบโตข้างในเดินหน้าอย่างเห็นได้ชัด',
      'คุณจะโตขึ้นจากข้างในแบบที่ตัวเองก็รู้สึกได้',
      'บทเรียนใหม่ ๆ จะค่อย ๆ เปลี่ยนวิธีมองโลกของคุณ',
    ],
    'opportunity': [
      'โอกาสใหม่ ๆ ทยอยเข้ามาให้ได้ลองคว้า',
      'ประตูหลายบานเริ่มเปิดให้คุณได้เลือกเดิน',
      'จังหวะและโอกาสจะวิ่งเข้าหาคุณมากกว่าช่วงอื่น',
    ],
  };

  static const _domainEasier = <String, List<String>>{
    'career': [
      'การผลักดันงานและการตัดสินใจเรื่องอาชีพจะลื่นไหลกว่าเดิม',
      'การลงมือทำเป้าหมายใหญ่ ๆ จะมีแรงส่งมากขึ้น',
      'การได้รับการยอมรับในสิ่งที่ทำจะมาง่ายกว่าช่วงก่อน',
    ],
    'money': [
      'การวางแผนและเก็บสะสมจะทำได้เป็นรูปเป็นร่างขึ้น',
      'การจัดการเรื่องเงินจะเริ่มอยู่มือมากขึ้น',
      'การมองเห็นช่องทางสร้างความมั่นคงจะชัดขึ้น',
    ],
    'love': [
      'การเปิดใจและเชื่อมความสัมพันธ์จะเป็นธรรมชาติมากขึ้น',
      'การเข้าใจและถูกเข้าใจจะเกิดง่ายกว่าเดิม',
      'การได้ใกล้ชิดกับคนที่ใช่จะรู้สึกอบอุ่นเป็นพิเศษ',
    ],
    'health': [
      'การฟังเสียงตัวเองและพักให้พอจะทำได้ง่ายขึ้น',
      'การกลับมาอยู่กับตัวเองจะช่วยเติมพลังได้ดี',
      'การดูแลใจและร่างกายจะค่อย ๆ กลับมาสมดุล',
    ],
    'growth': [
      'การเรียนรู้สิ่งใหม่และเข้าใจตัวเองจะไหลลื่น',
      'การปรับตัวและเปิดรับมุมใหม่จะทำได้สบายขึ้น',
      'การต่อยอดสิ่งที่รู้ให้กลายเป็นของตัวเองจะง่ายขึ้น',
    ],
    'opportunity': [
      'การมองเห็นและคว้าโอกาสจะคล่องตัวขึ้น',
      'การเริ่มต้นสิ่งใหม่จะมีจังหวะหนุนหลัง',
      'การพบเจอคนและโอกาสที่ใช่จะเกิดบ่อยกว่าเดิม',
    ],
  };

  static const _domainHarder = <String, List<String>>{
    'career': [
      'อาจต้องระวังการแบกงานไว้คนเดียวจนลืมพัก',
      'ระวังการกดดันตัวเองเรื่องผลงานมากเกินไป',
      'ระวังการรับงานมากกว่าที่เวลาและแรงจะไหว',
    ],
    'money': [
      'ต้องระวังการใช้จ่ายตามอารมณ์หรือรีบตัดสินใจเรื่องเงิน',
      'อย่าเพิ่งรีบลงทุนหรือผูกมัดการเงินก้อนใหญ่',
      'ระวังการตามใจตัวเองจนแผนการเงินรวน',
    ],
    'love': [
      'ความสัมพันธ์อาจต้องการเวลาและความเข้าใจมากกว่าที่คิด',
      'ระวังการคาดหวังจากคนอื่นเงียบ ๆ โดยไม่บอก',
      'ระวังการเก็บความน้อยใจเล็ก ๆ ไว้จนกลายเป็นกำแพง',
    ],
    'health': [
      'พลังใจอาจหมดเร็วถ้าไม่ดูแลตัวเองให้ทัน',
      'ระวังการฝืนตัวเองจนร่างกายส่งสัญญาณเตือน',
      'ระวังการละเลยการพักจนสะสมเป็นความล้า',
    ],
    'growth': [
      'อาจรู้สึกว่ายังไปไม่ถึงไหนทั้งที่จริงกำลังค่อย ๆ โต',
      'ระวังการเปรียบเทียบตัวเองกับคนอื่นจนท้อ',
      'ระวังการเร่งผลลัพธ์จนลืมชื่นชมระยะทางที่ผ่านมา',
    ],
    'opportunity': [
      'โอกาสที่เข้ามาเยอะอาจทำให้เลือกยากและไขว้เขว',
      'ระวังการรับทุกอย่างไว้จนโฟกัสหลุด',
      'ระวังการไล่ตามทุกโอกาสจนไม่มีอะไรได้ลงลึก',
    ],
  };

  static String _pick(Map<String, List<String>> bank, String domain, int n) {
    final list = bank[domain] ?? const [''];
    if (list.isEmpty) return '';
    return list[n.abs() % list.length];
  }

  static PeriodNarrative compose({
    required PeriodState period,
    required PeriodScores scores,
    required LifePlanet? lagnaLord,
    required EvidenceProfile evidence,
    required List<String> topThemeTags,
    required int seed,
  }) {
    final data = LifePlanets.of(period.planet);
    final top = scores.topDomain;
    final weak = scores.weakestDomain;
    final s = seed.abs();

    final flourish = _pick(_domainFlourish, top, s ~/ 2);
    final easierTop = _pick(_domainEasier, top, s ~/ 11);
    final harderWeak = _pick(_domainHarder, weak, s ~/ 13);

    final summaryFrames = <String>[
      'ช่วงนี้เป็นช่วงที่$flourish '
          '${data.phaseEssence.replaceFirst('ช่วง', 'เป็นจังหวะ')}',
      'ถ้าจะให้เรียกง่าย ๆ นี่คือ“${data.phaseName.replaceFirst('ช่วง', '')}” '
          'ของชีวิตคุณ — ช่วงที่$flourish',
      '${data.phaseEssence} และในช่วงนี้ $flourish',
      'ชีวิตช่วงนี้จะหมุนรอบเรื่อง${_domainNoun[top]} เป็นหลัก '
          'มันคือ${data.phaseName.replaceFirst('ช่วง', 'จังหวะ')}ของคุณ',
    ];

    // What *changes* describes the shift in focus toward this period's domain —
    // deliberately different from `easier` (which names what gets easier), so
    // the two lines don't read as the same sentence twice.
    final domainNoun = _domainNoun[top] ?? 'หลาย ๆ ด้าน';
    final changeFrames = <String>[
      'จังหวะเด่นจะค่อย ๆ ย้ายมาอยู่ที่เรื่อง$domainNoun',
      'โฟกัสของชีวิตจะขยับมาที่เรื่อง$domainNoun มากกว่าช่วงก่อน',
      'เทียบกับก่อนหน้านี้ เรื่อง$domainNoun จะเด่นขึ้นชัด',
    ];

    final easierFrames = <String>[
      'สิ่งที่จะง่ายขึ้นในช่วงนี้คือ $easierTop',
      'จุดที่คุณจะรู้สึกได้เปรียบคือ $easierTop',
    ];

    final harderFrames = <String>[
      'ส่วนสิ่งที่ต้องระวังคือ $harderWeak',
      'อีกด้านที่อยากให้ดูแลคือ $harderWeak',
      'สิ่งที่อาจหนักขึ้นเล็กน้อยคือ $harderWeak',
    ];

    final summary = summaryFrames[s % summaryFrames.length];
    final whatChanges = changeFrames[(s ~/ 3) % changeFrames.length];
    final easier = easierFrames[(s ~/ 5) % easierFrames.length];
    final harder = harderFrames[(s ~/ 7) % harderFrames.length];

    return PeriodNarrative(
      summary: summary,
      whatChanges: whatChanges,
      easier: easier,
      harder: harder,
      comparison: _comparison(period, seed),
      evidenceLine:
          _evidenceLine(period, lagnaLord, evidence, topThemeTags, seed),
    );
  }

  static String _comparison(PeriodState period, int seed) {
    final prev = period.previousPlanet;
    final next = period.nextPlanet;
    if (prev == null && next == null) return '';
    final parts = <String>[];
    if (prev != null) {
      final p = LifePlanets.of(prev);
      parts.add(
        'ถ้าช่วงก่อนหน้า (${p.phaseName}) คือช่วงของ${p.keyword} '
        'ช่วงนี้คือก้าวต่อจากตรงนั้น',
      );
    }
    if (next != null) {
      final n = LifePlanets.of(next);
      parts.add(
        'และเมื่อผ่านช่วงนี้ไป คุณจะเข้าสู่${n.phaseName} '
        'ที่ชีวิตจะเน้นเรื่อง${n.keyword}มากขึ้น',
      );
    }
    return parts.join(' ');
  }

  static const _relationTails = <PlanetRelation, List<String>>{
    PlanetRelation.friend: [
      'ช่วงนี้จึงเป็นจังหวะที่จุดแข็งของคุณได้ส่งเสริมกันพอดี',
      'ช่วงนี้จุดแข็งข้อนี้จะยิ่งทำงานให้คุณได้เต็มที่',
      'ช่วงนี้จึงเป็นจังหวะที่คุณได้ใช้ของดีในตัวอย่างลื่นไหล',
    ],
    PlanetRelation.enemy: [
      'ช่วงนี้จึงอาจรู้สึกฝืนอยู่บ้าง แต่ก็เป็นบทเรียนที่ทำให้คุณโตขึ้น',
      'ช่วงนี้อาจต้องออกแรงกับตัวเองมากขึ้น แต่ผลที่ได้ก็คุ้มค่า',
      'ช่วงนี้จึงท้าทายข้อนี้ของคุณ และนั่นแหละที่ทำให้คุณแกร่งขึ้น',
    ],
    PlanetRelation.neutral: [
      'ช่วงนี้จึงขึ้นอยู่กับว่าคุณจะหยิบจุดแข็งของตัวเองมาใช้แค่ไหน',
      'ช่วงนี้เปิดทางให้คุณเลือกได้ว่าจะเดินด้วยจุดแข็งข้อนี้แบบไหน',
      'ช่วงนี้จะเป็นอย่างไรก็อยู่ที่คุณจะวางจุดแข็งข้อนี้ตรงไหน',
    ],
  };

  static String _evidenceLine(
    PeriodState period,
    LifePlanet? lagnaLord,
    EvidenceProfile evidence,
    List<String> topThemeTags,
    int seed,
  ) {
    final relation = lagnaLord == null
        ? PlanetRelation.neutral
        : PlanetRelationshipMatrix.relation(period.planet, lagnaLord);

    final tailOptions = _relationTails[relation]!;
    final relationTail = tailOptions[(seed.abs() ~/ 3) % tailOptions.length];

    // Cite a *different* one of the person's strongest patterns per period
    // (keyed off the period index) so the same strength word isn't echoed in
    // every single card down the whole timeline.
    final tags = topThemeTags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tags.isEmpty) return relationTail;
    final tag = tags[(period.index + seed.abs() ~/ 5) % tags.length];

    final frames = <String>[
      'เพราะสิ่งที่โดดเด่นที่สุดในตัวคุณคือ“$tag” $relationTail',
      'ในเมื่อจุดเด่นของคุณคือ“$tag” $relationTail',
      'ด้วยความที่คุณเป็นคน“$tag”อยู่แล้ว $relationTail',
    ];
    return frames[seed.abs() % frames.length];
  }
}
