import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

import '../copy/thai_mirror_evidence_composer.dart';
import 'period_composite_score.dart';
import 'past_retrospective_composer.dart';
import 'thai_life_stage_context.dart';

/// Human narrative for one life period.
class PeriodNarrative {
  const PeriodNarrative({
    required this.summary,
    required this.whatChanges,
    required this.easier,
    required this.harder,
    required this.comparison,
    required this.evidenceLine,
    this.advice = '',
    this.stageLabel = '',
  });

  final String summary;

  /// Highlight themes ("เรื่องที่เด่น") — complete Thai sentences.
  final String whatChanges;

  /// Kept for compatibility; mirrors highlight-friendly wording.
  final String easier;

  /// Cautions ("สิ่งที่ควรระวัง").
  final String harder;

  /// Previous → current bridge (empty for first period).
  final String comparison;

  /// Soft evidence line (no engine keys).
  final String evidenceLine;

  /// Actionable guidance ("คำแนะนำ" / "แนวทางส่งเสริม").
  final String advice;

  /// Human life-stage label (presentation only).
  final String stageLabel;
}

/// V1.2.6 — Period Narrative Composer (age-aware, natural Thai).
///
/// Uses engine scores/signals only. Does not change calculation or Canon.
abstract final class PeriodNarrativeComposer {
  static PeriodNarrative compose({
    required PeriodState period,
    required int narrativeAge,
    required PeriodScores scores,
    required LifePlanet? lagnaLord,
    required EvidenceProfile evidence,
    required List<String> topThemeTags,
    required int seed,
  }) {
    final data = LifePlanets.of(period.planet);
    final band = ThaiLifeStageContext.fromAge(narrativeAge);
    final s = seed.abs();
    final top = ThaiLifeStageContext.narrativeDomain(scores.topDomain, band);
    final weak = ThaiLifeStageContext.narrativeDomain(
      scores.weakestDomain,
      band,
    );
    final stageLabel = ThaiLifeStageContext.bandLabelTh(band);

    // Past: life-breadth retrospective — no advice / caution / prompts.
    if (period.isPast) {
      return PeriodNarrative(
        summary: PastRetrospectiveComposer.compose(
          band: band,
          data: data,
          scores: scores,
          seed: s,
          periodIndex: period.index,
        ),
        whatChanges: '',
        easier: '',
        harder: '',
        comparison: '',
        evidenceLine: '',
        advice: '',
        stageLabel: stageLabel,
      );
    }

    final isFuture = !period.isCurrent && !period.isPast;
    final summary = _pick(
      isFuture ? _futureSummaryBank(band, data) : _summaryBank(band, data),
      s,
    );
    final highlights = _pick(
      isFuture ? _futureHighlightBank(band, top) : _highlightBank(band, top),
      s ~/ 3,
    );
    final caution = _pick(_cautionBank(band, weak), s ~/ 7);
    final advice = _pick(
      isFuture ? _futureAdviceBank(band) : _adviceBank(band, top),
      s ~/ 11,
    );
    final comparison = period.isCurrent ? _comparison(period, band, s) : '';
    final evidenceLine = period.isCurrent
        ? _evidenceLine(period, lagnaLord, evidence, topThemeTags, seed, band)
        : '';

    return PeriodNarrative(
      summary: summary,
      whatChanges: highlights,
      easier: highlights,
      harder: caution,
      comparison: comparison,
      evidenceLine: evidenceLine,
      advice: advice,
      stageLabel: stageLabel,
    );
  }

  static List<String> _futureSummaryBank(
    ThaiLifeStageBand band,
    LifePlanetData data,
  ) {
    final phase = data.phaseName;
    final essence = data.phaseEssence;
    switch (band) {
      case ThaiLifeStageBand.earlyChildhood:
        return [
          'เมื่อถึงวัยเด็กเล็กในจังหวะ$phase ซึ่ง$essence อาจเห็นพัฒนาการอารมณ์และการปรับตัวเด่นขึ้น',
          'จังหวะ$phase ในวัยเด็กเล็กอาจเปิดโอกาสให้สร้างความมั่นคงทางใจผ่านการดูแลที่สม่ำเสมอ',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'เมื่อถึงวัยเรียนในจังหวะ$phase ซึ่ง$essence อาจเห็นเรื่องการเรียนรู้ เพื่อน และวินัยเด่นขึ้น',
          'จังหวะ$phase ในวัยเรียนอาจเป็นช่วงที่ความสนใจและความมั่นใจถูกหล่อเลี้ยงได้ชัด',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'เมื่อถึงวัยรุ่นในจังหวะ$phase ซึ่ง$essence อาจเห็นเรื่องตัวตน เพื่อน และทิศทางอนาคตสำคัญขึ้น',
          'จังหวะ$phase ในวัยรุ่นอาจเป็นช่วงที่การตัดสินใจและขอบเขตส่วนตัวถูกทดลองมากขึ้น',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'เมื่อถึงวัยเริ่มต้นผู้ใหญ่ในจังหวะ$phase ซึ่ง$essence อาจเห็นการสร้างตัวตนและความรับผิดชอบเด่นขึ้น',
          'จังหวะ$phase อาจเป็นช่วงทดลองบทบาทผู้ใหญ่และวางรากฐานระยะต้น',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'เมื่อถึงวัยทำงานในจังหวะ$phase ซึ่ง$essence อาจเห็นงาน ความมั่นคง และสมดุลชีวิตเป็นแกนหลัก',
          'จังหวะ$phase อาจเปิดโอกาสให้เลือกทางที่สอดคล้องกับพลังและความรับผิดชอบที่มี',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'เมื่อถึงวัยกลางคนในจังหวะ$phase ซึ่ง$essence อาจเห็นการทบทวนทิศทางและการบริหารพลังงานสำคัญขึ้น',
          'จังหวะ$phase อาจเป็นช่วงต่อยอดประสบการณ์และปรับบทบาทให้พอดีกับชีวิตจริง',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'เมื่อถึงวัยสูงอายุในจังหวะ$phase ซึ่ง$essence อาจเห็นคุณภาพชีวิตและความสัมพันธ์เด่นขึ้น',
          'จังหวะ$phase อาจเอื้อต่อการรักษาสมดุลใจและปรับบทบาทอย่างให้เกียรติตัวเอง',
        ];
    }
  }

  static List<String> _futureHighlightBank(
    ThaiLifeStageBand band,
    String domain,
  ) {
    final base = _highlightBank(band, domain);
    return [
      for (final line in base)
        line
            .replaceFirst('เรื่องที่เด่นคือ', 'แนวโน้มที่อาจเด่นคือ')
            .replaceFirst('จังหวะนี้ส่งเสริม', 'จังหวะนี้อาจส่งเสริม')
            .replaceFirst('จังหวะนี้ช่วย', 'จังหวะนี้อาจช่วย')
            .replaceFirst('จังหวะนี้เอื้อ', 'จังหวะนี้อาจเอื้อ'),
    ];
  }

  static List<String> _futureAdviceBank(ThaiLifeStageBand band) {
    final base = _adviceBank(band, 'growth');
    return [for (final line in base) 'เมื่อถึงช่วงนั้น $line'];
  }

  static String _pick(List<String> list, int n) {
    if (list.isEmpty) {
      return 'ช่วงนี้เป็นจังหวะที่ควรสังเกตตัวเองอย่างนุ่มนวลและค่อยเป็นค่อยไป';
    }
    return list[n.abs() % list.length];
  }

  static List<String> _summaryBank(
    ThaiLifeStageBand band,
    LifePlanetData data,
  ) {
    final phase = data.phaseName;
    final essence = data.phaseEssence;
    switch (band) {
      case ThaiLifeStageBand.earlyChildhood:
        return [
          'ในวัยเด็กเล็ก ช่วงอายุนี้เป็น$phase ซึ่ง$essence ผู้ปกครองจะสังเกตพัฒนาการอารมณ์และการปรับตัวของเด็กได้ชัดขึ้น',
          'ช่วงนี้ของวัยเด็กเล็กคือ$phase — $essence เหมาะกับการสร้างความมั่นคงทางใจผ่านการดูแลที่สม่ำเสมอ',
          'สำหรับเด็กเล็ก ช่วงนี้เป็น$phase ที่$essence โดยเน้นความอบอุ่น การเล่น และการเรียนรู้จากสิ่งรอบตัว',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'ในวัยเรียน ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องการเรียนรู้ เพื่อน และการฝึกวินัยมักเด่นขึ้น',
          'ช่วงวัยเรียนนี้คือ$phase — $essence เหมาะกับการสนับสนุนความสนใจและความมั่นใจของเด็ก',
          'สำหรับเด็กโต ช่วงนี้เป็น$phase ที่$essence โดยเน้นการเรียน การเข้าสังคม และการค้นหาสิ่งที่ถนัด',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'ในวัยรุ่น ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องตัวตน เพื่อน และทิศทางอนาคตมักสำคัญขึ้น',
          'ช่วงวัยรุ่นนี้คือ$phase — $essence เหมาะกับการเรียนรู้การตัดสินใจและการวางขอบเขตอย่างเหมาะสม',
          'สำหรับวัยรุ่น ช่วงนี้เป็น$phase ที่$essence โดยเน้นการค้นหาตัวตนและความเป็นอิสระอย่างมีที่พึ่ง',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'ในวัยเริ่มต้นผู้ใหญ่ ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องการสร้างตัวตน ความรับผิดชอบ และทางเลือกหลักของชีวิตมักเด่นขึ้น',
          'ช่วงนี้คือ$phase — $essence เหมาะกับการทดลองบทบาทผู้ใหญ่และการวางรากฐานระยะต้น',
          'สำหรับวัยเริ่มทำงานหรือเรียนต่อ ช่วงนี้เป็น$phase ที่$essence โดยเน้นการตัดสินใจที่ส่งผลต่อทิศทางระยะยาว',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'ในวัยทำงาน ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องงาน ความมั่นคง และสมดุลชีวิตมักเป็นแกนหลัก',
          'ช่วงนี้คือ$phase — $essence เหมาะกับการเลือกโอกาสที่สอดคล้องกับพลังและความรับผิดชอบที่มีอยู่',
          'สำหรับวัยสร้างฐานชีวิต ช่วงนี้เป็น$phase ที่$essence โดยเน้นการบริหารภาระและโอกาสไปพร้อมกัน',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'ในวัยกลางคน ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องการทบทวนทิศทาง การดูแลคนรอบตัว และการบริหารพลังงานมักสำคัญขึ้น',
          'ช่วงนี้คือ$phase — $essence เหมาะกับการต่อยอดประสบการณ์และปรับบทบาทให้พอดีกับชีวิตจริง',
          'สำหรับวัยกลางคน ช่วงนี้เป็น$phase ที่$essence โดยเน้นความมั่นคงและการเลือกสิ่งที่คุ้มค่าแก่เวลา',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'ในวัยสูงอายุ ช่วงนี้เป็น$phase ซึ่ง$essence เรื่องคุณภาพชีวิต ความสัมพันธ์ และการใช้ประสบการณ์ส่งต่อมักเด่นขึ้น',
          'ช่วงนี้คือ$phase — $essence เหมาะกับการรักษาสมดุลใจและปรับบทบาทอย่างให้เกียรติตัวเอง',
          'สำหรับวัยสูงอายุ ช่วงนี้เป็น$phase ที่$essence โดยเน้นความมั่นคงทางใจและการดูแลชีวิตประจำวันอย่างพอดี',
        ];
    }
  }

  static List<String> _highlightBank(ThaiLifeStageBand band, String domain) {
    final child = ThaiLifeStageContext.isChildOriented(band);
    final teen = band == ThaiLifeStageBand.teen;
    switch (domain) {
      case 'career':
        if (child) {
          return [
            'เรื่องที่เด่นคือการเรียนรู้ผ่านการลงมือทำและการฝึกความรับผิดชอบเล็ก ๆ ในชีวิตประจำวัน',
            'จังหวะนี้ส่งเสริมให้เด็กได้ลองบทบาทและความสามารถใหม่ในสภาพแวดล้อมที่ปลอดภัย',
          ];
        }
        if (teen) {
          return [
            'เรื่องที่เด่นคือการค้นหาทิศทางอนาคตผ่านการเรียน กิจกรรม และความสนใจของตนเอง',
            'จังหวะนี้ช่วยให้วัยรุ่นเห็นภาพบทบาทที่อยากลองในอนาคตได้ชัดขึ้น',
          ];
        }
        return [
          'เรื่องที่เด่นคืองาน เป้าหมาย และบทบาทที่ต้องรับผิดชอบในสังคม',
          'จังหวะนี้เอื้อให้การผลักดันเป้าหมายและการตัดสินใจเรื่องหน้าที่ลื่นขึ้น',
        ];
      case 'money':
        if (child || teen) {
          return [
            'เรื่องที่เด่นคือความรู้สึกมั่นคง การดูแลพื้นฐาน และการจัดระเบียบชีวิตประจำวัน',
            'จังหวะนี้ส่งเสริมวินัยเล็ก ๆ และการเข้าใจคุณค่าของสิ่งของอย่างค่อยเป็นค่อยไป',
          ];
        }
        return [
          'เรื่องที่เด่นคือความมั่นคง การวางแผน และการสร้างฐานชีวิตให้จับต้องได้',
          'จังหวะนี้เอื้อให้การจัดการทรัพยากรและการวางแผนระยะยาวชัดขึ้น',
        ];
      case 'love':
        if (child) {
          return [
            'เรื่องที่เด่นคือความผูกพันกับผู้ดูแล ความอบอุ่น และการเรียนรู้การไว้ใจผู้อื่น',
            'จังหวะนี้ส่งเสริมความสัมพันธ์ในครอบครัวและการสื่อสารอย่างอ่อนโยน',
          ];
        }
        if (teen) {
          return [
            'เรื่องที่เด่นคือมิตรภาพ การยอมรับจากกลุ่ม และความสัมพันธ์ที่กำลังเรียนรู้ขอบเขต',
            'จังหวะนี้ช่วยให้เข้าใจความรู้สึกของตนเองและผู้อื่นมากขึ้น โดยยังควรเดินอย่างค่อยเป็นค่อยไป',
          ];
        }
        return [
          'เรื่องที่เด่นคือความสัมพันธ์ ความเข้าใจกัน และการดูแลคนสำคัญ',
          'จังหวะนี้เอื้อให้การเชื่อมใจและการสร้างความผูกพันมีความหมายมากขึ้น',
        ];
      case 'health':
        return child || teen
            ? [
                'เรื่องที่เด่นคือพลังกายใจ จังหวะพักผ่อน และการดูแลตัวเองตามวัย',
                'จังหวะนี้ส่งเสริมการฟังสัญญาณร่างกายและอารมณ์อย่างสม่ำเสมอ',
              ]
            : [
                'เรื่องที่เด่นคือสมดุลของใจและร่างกาย รวมถึงการพักที่พอเพียง',
                'จังหวะนี้เอื้อให้การดูแลสุขภาพและพลังงานกลายเป็นเรื่องสำคัญขึ้น',
              ];
      case 'opportunity':
        return [
          'เรื่องที่เด่นคือโอกาสใหม่ ๆ และการได้ลองทางเลือกที่เหมาะกับจังหวะชีวิต',
          'จังหวะนี้เปิดช่องให้ได้พบคนหรือโอกาสที่สอดคล้องกับทิศทางปัจจุบัน',
        ];
      case 'growth':
      default:
        return [
          'เรื่องที่เด่นคือการเรียนรู้ การเข้าใจตัวเอง และการเติบโตจากประสบการณ์',
          'จังหวะนี้ส่งเสริมการปรับมุมมองและพัฒนาทักษะที่ใช้ได้จริงในชีวิตประจำวัน',
        ];
    }
  }

  static List<String> _cautionBank(ThaiLifeStageBand band, String domain) {
    final child = ThaiLifeStageContext.isChildOriented(band);
    final teen = band == ThaiLifeStageBand.teen;
    switch (domain) {
      case 'career':
        if (child) {
          return [
            'สิ่งที่ควรระวังคือการกดดันเด็กเรื่องผลงานหรือความเก่งจนเกินวัย',
            'ควรหลีกเลี่ยงการเปรียบเทียบกับเด็กคนอื่นจนบั่นทอนความมั่นใจ',
          ];
        }
        if (teen) {
          return [
            'สิ่งที่ควรระวังคือการเร่งตัดสินใจเรื่องอนาคตโดยยังไม่เข้าใจตัวเองพอ',
            'ควรระวังการแบกความคาดหวังจากคนรอบตัวจนเครียดเกินควร',
          ];
        }
        return [
          'สิ่งที่ควรระวังคือการแบกงานหรือความรับผิดชอบไว้คนเดียวจนลืมพัก',
          'ควรระวังการกดดันตัวเองเรื่องผลงานจนเสียสมดุลชีวิต',
        ];
      case 'money':
        if (child || teen) {
          return [
            'สิ่งที่ควรระวังคือความไม่แน่นอนของกิจวัตรที่ทำให้เด็กรู้สึกไม่มั่นคง',
            'ควรจัดสภาพแวดล้อมให้คาดเดาได้ และอธิบายการเปลี่ยนแปลงด้วยภาษาที่เข้าใจง่าย',
          ];
        }
        return [
          'สิ่งที่ควรระวังคือการตัดสินใจเรื่องเงินหรือข้อผูกมัดใหญ่โดยรีบร้อน',
          'ควรชะลอการใช้จ่ายตามอารมณ์ และทบทวนแผนก่อนผูกพันระยะยาว',
        ];
      case 'love':
        if (child) {
          return [
            'สิ่งที่ควรระวังคือการขาดความสม่ำเสมอในการดูแล ซึ่งอาจทำให้เด็กรู้สึกไม่แน่ใจ',
            'ควรสื่อสารด้วยความอ่อนโยนและให้เวลาเด็กปรับตัวเมื่อสภาพแวดล้อมเปลี่ยน',
          ];
        }
        if (teen) {
          return [
            'สิ่งที่ควรระวังคือการเปรียบเทียบตัวเองกับเพื่อนจนกระทบความมั่นใจ',
            'ควรระวังการเปิดใจเร็วเกินไปโดยยังไม่มีขอบเขตที่ชัดเจน',
          ];
        }
        return [
          'สิ่งที่ควรระวังคือการคาดหวังเงียบ ๆ โดยไม่สื่อสาร จนเกิดความเข้าใจผิด',
          'ควรดูแลไม่ให้ความน้อยใจเล็ก ๆ สะสมจนกลายเป็นระยะห่าง',
        ];
      case 'health':
        return [
          'สิ่งที่ควรระวังคือการฝืนตัวเองจนสะสมความล้าโดยไม่ทันสังเกต',
          'ควรจัดเวลาพักและกิจกรรมที่เติมพลังให้สมดุลกับภาระที่มี',
        ];
      case 'opportunity':
        return [
          'สิ่งที่ควรระวังคือการรับทุกโอกาสไว้จนโฟกัสกระจาย',
          'ควรเลือกเฉพาะทางที่สอดคล้องกับพลังและลำดับความสำคัญในตอนนี้',
        ];
      case 'growth':
      default:
        return [
          'สิ่งที่ควรระวังคือการเร่งผลลัพธ์จนลืมชื่นชมพัฒนาการทีละขั้น',
          'ควรหลีกเลี่ยงการเปรียบเทียบตัวเองกับคนอื่นจนท้อโดยไม่จำเป็น',
        ];
    }
  }

  static List<String> _adviceBank(ThaiLifeStageBand band, String domain) {
    switch (band) {
      case ThaiLifeStageBand.earlyChildhood:
        return [
          'ผู้ปกครองหรือผู้ดูแลควรให้เวลาร่วมเล่น สื่อสารอย่างนุ่มนวล และสร้างกิจวัตรที่เด็กคาดเดาได้',
          'ควรเปิดโอกาสให้เด็กได้สำรวจอย่างปลอดภัย และสะท้อนความรู้สึกของเด็กด้วยคำที่เข้าใจง่าย',
          'เน้นความสม่ำเสมอในการดูแลมากกว่าการเร่งทักษะเกินวัย',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'ผู้ปกครองและครูควรสนับสนุนความสนใจของเด็ก พร้อมฝึกวินัยแบบค่อยเป็นค่อยไป',
          'ควรช่วยจัดเวลาเรียน พัก และกิจกรรมเพื่อนให้สมดุล โดยไม่เปรียบเทียบกับเด็กคนอื่น',
          'เปิดโอกาสให้เด็กได้ลองสิ่งที่ถนัดและได้รับคำชมที่เฉพาะเจาะจง',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'ควรให้พื้นที่คิดและตัดสินใจในเรื่องที่เหมาะสม พร้อมเป็นที่ปรึกษาเมื่อต้องการ',
          'ช่วยวางขอบเขตที่ชัดเจนโดยไม่ตีตรา และสนับสนุนการสำรวจตัวตนอย่างปลอดภัย',
          'ชวนพูดคุยเรื่องอนาคตแบบเปิด ไม่เร่งฟันธงเส้นทางเดียว',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'ควรทดลองบทบาทและทางเลือกอย่างมีขอบเขต แล้วทบทวนสิ่งที่ได้เรียนรู้เป็นระยะ',
          'วางวินัยเล็ก ๆ เรื่องเวลา เงิน และสุขภาพ เพื่อรองรับการเริ่มต้นชีวิตผู้ใหญ่',
          'เลือกความสัมพันธ์และโอกาสที่สอดคล้องกับค่าที่ตนเองยึดถือ',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'จัดลำดับงานและความรับผิดชอบให้เหลือพลังดูแลตัวเองและคนสำคัญ',
          'เลือกโอกาสที่คุ้มค่าแก่เวลา แทนการรับทุกอย่างไว้',
          'ทบทวนสมดุลงาน การเงิน และสุขภาพอย่างสม่ำเสมอ',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'ทบทวนทิศทางชีวิตและภาระที่มี แล้วเลือกลงแรงกับสิ่งที่สร้างคุณค่าจริง',
          'ดูแลพลังงานและสุขภาพควบคู่กับการสนับสนุนครอบครัวหรือทีม',
          'ใช้ประสบการณ์ที่มีในการตัดสินใจระยะยาวอย่างใจเย็น',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'จัดชีวิตประจำวันให้เอื้อต่อคุณภาพชีวิต ความสัมพันธ์ และความสงบใจ',
          'เลือกกิจกรรมที่เติมความหมาย โดยไม่ฝืนร่างกายเกินควร',
          'แบ่งปันประสบการณ์กับคนรุ่นหลังในจังหวะที่ตนเองสบายใจ',
        ];
    }
  }

  static String _comparison(
    PeriodState period,
    ThaiLifeStageBand band,
    int seed,
  ) {
    final prev = period.previousPlanet;
    if (prev == null) return '';
    final p = LifePlanets.of(prev);
    final current = LifePlanets.of(period.planet);
    final frames = ThaiLifeStageContext.isChildOriented(band)
        ? [
            'เทียบกับช่วงก่อนหน้า (${p.phaseName}) ที่เน้นเรื่อง${p.keyword} ช่วงนี้ (${current.phaseName}) จะเห็นจังหวะของ${current.keyword} ชัดขึ้นในชีวิตประจำวันของเด็ก',
            'จากช่วง${p.phaseName} มาสู่ช่วง${current.phaseName} พัฒนาการจะขยับจาก${p.keyword} ไปสู่${current.keyword} มากขึ้น',
          ]
        : [
            'เทียบกับช่วงก่อนหน้า (${p.phaseName}) ที่เน้นเรื่อง${p.keyword} ช่วงนี้ (${current.phaseName}) จะให้ความสำคัญกับ${current.keyword} มากขึ้น',
            'จากจังหวะ${p.phaseName} สู่${current.phaseName} โฟกัสของชีวิตจะค่อย ๆ ย้ายจาก${p.keyword} ไปสู่${current.keyword}',
          ];
    return frames[seed.abs() % frames.length];
  }

  static const _relationTails = <PlanetRelation, List<String>>{
    PlanetRelation.friend: [
      'จังหวะนี้จึงเอื้อให้จุดเด่นข้อนี้ทำงานได้อย่างลื่นไหล',
      'ช่วงนี้จุดเด่นข้อนี้มักช่วยให้เดินทางได้สบายขึ้น',
    ],
    PlanetRelation.enemy: [
      'จังหวะนี้อาจรู้สึกฝืนบ้าง แต่ก็เป็นโอกาสฝึกความอดทนและการปรับตัว',
      'ช่วงนี้อาจต้องออกแรงกับตัวเองมากขึ้น โดยยังเดินอย่างค่อยเป็นค่อยไป',
    ],
    PlanetRelation.neutral: [
      'จังหวะนี้เปิดทางให้เลือกได้ว่าจะใช้จุดเด่นข้อนี้อย่างไร',
      'ช่วงนี้ผลลัพธ์จะชัดขึ้นเมื่อนำจุดเด่นข้อนี้มาใช้จริง',
    ],
  };

  static String _evidenceLine(
    PeriodState period,
    LifePlanet? lagnaLord,
    EvidenceProfile evidence,
    List<String> topThemeTags,
    int seed,
    ThaiLifeStageBand band,
  ) {
    final relation = lagnaLord == null
        ? PlanetRelation.neutral
        : PlanetRelationshipMatrix.relation(period.planet, lagnaLord);
    final relationTail =
        _relationTails[relation]![(seed.abs() ~/ 3) %
            _relationTails[relation]!.length];
    final tags = topThemeTags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tags.isEmpty) return relationTail;
    final tag = tags[(period.index + seed.abs() ~/ 5) % tags.length];
    if (ThaiLifeStageContext.isChildOriented(band)) {
      return 'จุดเด่นที่สัมพันธ์กับภาพรวมของคนคนนี้คือ “$tag” $relationTail';
    }
    final frames = <String>[
      'เพราะจุดเด่นที่เห็นชัดคือ “$tag” $relationTail',
      'ด้วยนิสัย “$tag” ที่เป็นทุนเดิม $relationTail',
    ];
    return frames[seed.abs() % frames.length];
  }
}
