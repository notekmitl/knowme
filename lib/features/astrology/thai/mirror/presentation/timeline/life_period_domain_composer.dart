import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_mirror_life_timeline_state.dart';

/// Thai Beta V3 — detailed past/future life-domain copy.
///
/// This stays inside the presentation boundary. It translates the existing
/// [PeriodScores] and period ruler metadata into direct, readable Thai without
/// inventing dated events, diagnoses, houses, degrees, or new calculations.
abstract final class LifePeriodDomainComposer {
  static const titleWork = 'การงาน';
  static const titleMoney = 'การเงิน';
  static const titleLove = 'ความรัก';
  static const titleHealth = 'สุขภาพ';

  static const requiredTitles = <String>[
    titleWork,
    titleMoney,
    titleLove,
    titleHealth,
  ];

  static List<ThaiMirrorLifeDomainBlock> compose({
    required LifeMapVerdictSemantics semantics,
    required PeriodScores scores,
    required LifePlanetData data,
  }) {
    if (semantics.tense == LifeMapVerdictTense.current) return const [];

    final past = semantics.tense == LifeMapVerdictTense.past;
    return [
      _block(
        title: titleWork,
        body: _work(scores, data, past: past),
        score: scores.career,
        data: data,
        tense: semantics.tense,
      ),
      _block(
        title: titleMoney,
        body: _money(scores, data, past: past),
        score: scores.money,
        data: data,
        tense: semantics.tense,
      ),
      _block(
        title: titleLove,
        body: _love(scores, data, past: past),
        score: scores.love,
        data: data,
        tense: semantics.tense,
      ),
      _block(
        title: titleHealth,
        body: _health(scores, data, past: past),
        score: scores.health,
        data: data,
        tense: semantics.tense,
      ),
    ];
  }

  static ThaiMirrorLifeDomainBlock _block({
    required String title,
    required String body,
    required int score,
    required LifePlanetData data,
    required LifeMapVerdictTense tense,
  }) {
    return ThaiMirrorLifeDomainBlock(
      title: title,
      body: body,
      evidenceKeys: [
        'score:${_domainKey(title)}:$score',
        'planet:${data.planet.name}',
        'period_tense:${tense.name}',
      ],
    );
  }

  static String _work(
    PeriodScores scores,
    LifePlanetData data, {
    required bool past,
  }) {
    final strength = _band(scores.career);
    final pressure = _band(scores.pressure);
    if (past) {
      final lead = _pastLead(data);
      if (strength == _Band.strong) {
        return '$lead ทำให้งานหรือหน้าที่เป็นแกนหลักของชีวิต คุณต้องรับผิดชอบมากขึ้น '
            'และถูกคาดหวังให้ทำผลงานให้เห็นชัด '
            '${_pastPressure(pressure)}';
      }
      if (strength == _Band.active) {
        return '$lead ทำให้งานเดินหน้าแบบค่อยเป็นค่อยไป สิ่งที่ได้มาจากความสม่ำเสมอ '
            'มากกว่าการเปลี่ยนครั้งใหญ่ ${_pastPressure(pressure)}';
      }
      return '$lead แต่งานยังไม่ใช่ด้านที่เปิดทางง่าย คุณต้องใช้เวลาเรียนรู้ '
          'ปรับวิธีทำงาน และคัดเลือกภาระที่คุ้มแรงมากขึ้น';
    }

    if (strength == _Band.strong) {
      return 'ดวงชี้ว่าใน${data.phaseName} งานจะขยายตัวและมีบทบาทใหม่เข้ามา '
          'ผลงานจะถูกมองเห็นชัดขึ้น แต่ต้องเลือกงานสำคัญแทนการรับทุกอย่างพร้อมกัน';
    }
    if (strength == _Band.active) {
      return 'ใน${data.phaseName} งานจะเดินหน้าได้ต่อเนื่องและมั่นคงขึ้น '
          'ความสำเร็จมาจากการทำของเดิมให้ชัดและเสร็จ มากกว่าการเปลี่ยนทิศบ่อย';
    }
    return 'ใน${data.phaseName} งานจะช้ากว่าที่คาดและต้องแก้ข้อจำกัดเดิมก่อน '
        'ยังไม่ใช่จังหวะรับภาระก้อนใหญ่โดยไม่เห็นผลตอบแทนชัดเจน';
  }

  static String _money(
    PeriodScores scores,
    LifePlanetData data, {
    required bool past,
  }) {
    final strength = _band(scores.money);
    final career = _band(scores.career);
    final pressure = _band(scores.pressure);
    if (past) {
      final lead = _pastLead(data);
      if (strength == _Band.strong) {
        return '$lead ทำให้การเงินขยับตามงานและความรับผิดชอบ รายรับมีทางเพิ่ม '
            'แต่เงินที่ได้ต้องถูกนำไปจัดการภาระหรือสร้างความมั่นคงต่อ';
      }
      if (pressure == _Band.strong) {
        return '$lead แต่เงินตึงเพราะภาระหลายด้านเข้ามาพร้อมกัน '
            'คุณต้องระวังรายจ่ายสะสมและเรียนรู้การกันเงินสำรองให้จริงจัง';
      }
      return '$lead และการเงินอยู่ในระดับประคองได้ รายรับผูกกับงานที่ทำสม่ำเสมอ '
          'และยังไม่ใช่จังหวะใช้เงินตามความมั่นใจเพียงอย่างเดียว';
    }

    if (strength == _Band.strong && career == _Band.strong) {
      return 'ดวงชี้ว่าใน${data.phaseName} รายได้จะเพิ่มตามงานและหน้าที่ที่ขยายขึ้น '
          'เงินเข้ามากขึ้นจริง แต่ต้องกันส่วนหนึ่งไว้รับต้นทุนและภาระที่ตามมา';
    }
    if (strength == _Band.strong) {
      return 'ใน${data.phaseName} ฐานะจะตั้งหลักได้ดีขึ้นเมื่อจัดเงินเป็นระบบ '
          'เหมาะกับการสะสมและลดหนี้ มากกว่าทุ่มเงินก้อนเดียวกับความเสี่ยงสูง';
    }
    if (pressure == _Band.strong) {
      return 'ใน${data.phaseName} เงินจะถูกใช้กับภาระมากกว่าการขยายทรัพย์ '
          'ต้องรักษาสภาพคล่องและหลีกเลี่ยงข้อผูกมัดระยะยาวที่เกินกำลัง';
    }
    return 'ใน${data.phaseName} การเงินจะพอเดินได้แต่ยังไม่เด่น '
        'รายได้หลักยังมาจากงานประจำและความสามารถ มากกว่าโชคหรือเงินก้อนฉับพลัน';
  }

  static String _love(
    PeriodScores scores,
    LifePlanetData data, {
    required bool past,
  }) {
    final strength = _band(scores.love);
    final pressure = _band(scores.pressure);
    if (past) {
      final lead = _pastLead(data);
      if (strength == _Band.strong) {
        return '$lead ทำให้ความสัมพันธ์มีน้ำหนักต่อการตัดสินใจของคุณมาก '
            'มีทั้งแรงสนับสนุนและความคาดหวังที่ทำให้ต้องกำหนดขอบเขตให้ชัด';
      }
      if (pressure == _Band.strong) {
        return '$lead แต่ความสัมพันธ์ถูกกดดันจากภาระและเวลาที่ไม่ลงตัว '
            'ประเด็นสำคัญคือการพูดตรง ๆ แทนการปล่อยให้ความไม่พอใจสะสม';
      }
      return '$lead และความรักไม่ได้เป็นศูนย์กลางเท่างานหรือหน้าที่ '
          'ความสัมพันธ์จึงค่อย ๆ ชัดจากการกระทำและความสม่ำเสมอมากกว่าคำพูด';
    }

    if (strength == _Band.strong) {
      return 'ดวงชี้ว่าใน${data.phaseName} ความสัมพันธ์จะชัดขึ้น '
          'คนที่ใช่จะเข้ามามีบทบาทจริง ส่วนความสัมพันธ์ที่ค้างคาจะถูกบังคับให้ตัดสินใจ';
    }
    if (pressure == _Band.strong) {
      return 'ใน${data.phaseName} ความรักจะถูกทดสอบด้วยภาระ เวลา และความคาดหวัง '
          'ความสัมพันธ์ที่ไม่พูดกันตรง ๆ มีโอกาสห่าง แต่คู่ที่ร่วมมือกันจะผ่านได้';
    }
    return 'ใน${data.phaseName} ความสัมพันธ์จะค่อย ๆ พัฒนา ไม่ใช่จังหวะเร่งคำตอบ '
        'คนที่สม่ำเสมอและเคารพพื้นที่กันจะไปต่อได้ดีกว่าความสัมพันธ์ที่มาเร็วไปเร็ว';
  }

  static String _health(
    PeriodScores scores,
    LifePlanetData data, {
    required bool past,
  }) {
    final strength = _band(scores.health);
    final pressure = _band(scores.pressure);
    final pastLead = _pastLead(data);
    final body = past
        ? pressure == _Band.strong
              ? '$pastLead แต่ภาระและความเครียดใช้พลังมากกว่าปกติ ความล้าสะสมง่ายเมื่อพักไม่พอ'
              : strength == _Band.strong
              ? '$pastLead และพลังชีวิตโดยรวมยังดี คุณฟื้นตัวได้เมื่อรักษาเวลาพักและกิจวัตรให้สม่ำเสมอ'
              : '$pastLead แต่พลังชีวิตขึ้นลงตามภาระ การพักไม่เป็นเวลาทำให้ร่างกายอ่อนล้าง่าย'
        : pressure == _Band.strong
        ? 'ดวงชี้ว่าใน${data.phaseName} ภาระจะใช้พลังมาก ต้องจัดเวลานอนและพักก่อนความล้าสะสม'
        : strength == _Band.strong
        ? 'ใน${data.phaseName} พลังชีวิตจะรับมือกิจกรรมได้ดี หากรักษาการนอนและไม่ทำงานต่อเนื่องเกินไป'
        : 'ใน${data.phaseName} พลังชีวิตจะขึ้นลงง่าย ต้องลดการฝืนและเว้นช่วงพักให้เป็นกิจวัตร';
    return '$body ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ ไม่ใช่คำวินิจฉัยทางการแพทย์';
  }

  static String _pastPressure(_Band pressure) => switch (pressure) {
    _Band.strong => 'แรงกดดันทำให้ต้องเลือกว่าจะรักษาคุณภาพหรือรับภาระเพิ่ม',
    _Band.active => 'ภาระเพิ่มขึ้นเป็นระยะ แต่ยังจัดลำดับและรับมือได้',
    _Band.quiet => 'แรงกดดันไม่ใช่ตัวแปรหลักเท่าความต่อเนื่องของผลงาน',
  };

  static String _pastLead(LifePlanetData data) =>
      'ใน${data.phaseName} จังหวะ${data.keyword}เด่นชัด';

  static _Band _band(int score) {
    if (score >= 68) return _Band.strong;
    if (score >= 48) return _Band.active;
    return _Band.quiet;
  }

  static String _domainKey(String title) => switch (title) {
    titleWork => 'career',
    titleMoney => 'money',
    titleLove => 'love',
    titleHealth => 'health',
    _ => 'unknown',
  };
}

enum _Band { strong, active, quiet }
