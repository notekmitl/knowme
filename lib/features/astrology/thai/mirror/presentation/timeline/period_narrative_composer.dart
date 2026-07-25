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

  /// Cautions / pressure ("แรงกดดันและความขัดแย้ง").
  final String harder;

  /// Previous → current bridge (empty for first period).
  final String comparison;

  /// Soft evidence line (no engine keys).
  final String evidenceLine;

  /// Life impact / consequence ("ผลต่อชีวิต").
  final String advice;

  /// Human life-stage label (presentation only).
  final String stageLabel;
}

/// V1.2.8 — Period Narrative Composer (verdict-style, age-aware Thai).
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
          'เมื่อถึงวัยเด็กเล็กในจังหวะ$phase ซึ่ง$essence พัฒนาการอารมณ์และการปรับตัวกลายเป็นแกนหลักของช่วงนั้น',
          'จังหวะ$phase ในวัยเด็กเล็กเปิดทางให้ความมั่นคงทางใจก่อตัวผ่านการดูแลที่สม่ำเสมอ และเปลี่ยนจังหวะชีวิตจากเดิมอย่างชัด',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'เมื่อถึงวัยเรียนในจังหวะ$phase ซึ่ง$essence การเรียนรู้ เพื่อน และวินัยกลายเป็นแรงหลักที่กำหนดชีวิตประจำวัน',
          'จังหวะ$phase ในวัยเรียนผลักความสนใจและความมั่นใจให้เด่น และเปลี่ยนวิธีที่เด็กยืนอยู่ในกลุ่ม',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'เมื่อถึงวัยรุ่นในจังหวะ$phase ซึ่ง$essence ตัวตน เพื่อน และทิศทางอนาคตถูกบังคับให้เลือกและทดสอบจริง',
          'จังหวะ$phase ในวัยรุ่นทำให้การตัดสินใจและขอบเขตส่วนตัวถูกทดลอง และเปลี่ยนบทบาทในกลุ่มอย่างชัด',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'เมื่อถึงวัยเริ่มต้นผู้ใหญ่ในจังหวะ$phase ซึ่ง$essence การสร้างตัวตนและความรับผิดชอบกลายเป็นแกนตัดสินใจหลัก',
          'จังหวะ$phase ผลักให้ทดลองบทบาทผู้ใหญ่และวางรากฐานระยะต้น จนเส้นทางชีวิตแยกจากวัยก่อนหน้า',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'เมื่อถึงวัยทำงานในจังหวะ$phase ซึ่ง$essence งาน ความมั่นคง และสมดุลชีวิตกลายเป็นแรงกดดันหลักที่ต้องจัดระเบียบ',
          'จังหวะ$phase เปิดทางเลือกที่สอดคล้องกับพลังและความรับผิดชอบที่มี และเปลี่ยนบทบาทหรือรายได้อย่างชัด',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'เมื่อถึงวัยกลางคนในจังหวะ$phase ซึ่ง$essence การทบทวนทิศทางและการบริหารพลังงานกลายเป็นวาระหลักของชีวิต',
          'จังหวะ$phase ต่อยอดประสบการณ์และปรับบทบาทให้พอดีกับชีวิตจริง จนลำดับความสำคัญเปลี่ยนจากเดิม',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'เมื่อถึงวัยสูงอายุในจังหวะ$phase ซึ่ง$essence คุณภาพชีวิตและความสัมพันธ์กลายเป็นแกนของช่วงนั้น',
          'จังหวะ$phase ผลักให้รักษาสมดุลใจและปรับบทบาทอย่างให้เกียรติตัวเอง จนจังหวะชีวิตเปลี่ยนจากวัยทำงาน',
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
            .replaceFirst('เรื่องที่เด่นคือ', 'ทิศทางหลักที่กำลังมาคือ')
            .replaceFirst('จังหวะนี้ส่งเสริมให้', 'จังหวะหน้าผลักให้')
            .replaceFirst('จังหวะนี้ส่งเสริม', 'จังหวะหน้าผลัก')
            .replaceFirst('จังหวะนี้ช่วยให้', 'จังหวะหน้าผลักให้')
            .replaceFirst('จังหวะนี้ช่วย', 'จังหวะหน้าผลัก')
            .replaceFirst('จังหวะนี้เอื้อให้', 'จังหวะหน้าเปิดทางให้')
            .replaceFirst('จังหวะนี้เอื้อ', 'จังหวะหน้าเปิดทางให้')
            .replaceFirst('จังหวะนี้เปิดช่อง', 'จังหวะหน้าเปิดทาง')
            .replaceFirst('จังหวะนี้ผลักให้', 'จังหวะหน้าผลักให้'),
    ];
  }

  static List<String> _futureAdviceBank(ThaiLifeStageBand band) {
    switch (band) {
      case ThaiLifeStageBand.earlyChildhood:
        return [
          'ผลที่ตามมาคือกิจวัตรและความอบอุ่นในช่วงนั้นกำหนดพื้นฐานอารมณ์ของเด็กอย่างชัด',
          'สภาพใหม่ที่ตามมาคือเด็กตอบสนองต่อความสม่ำเสมอของคนดูแลมากกว่าคำสั่งระยะสั้น',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'ผลที่ตามมาคือทักษะเรียนและความมั่นใจในกลุ่มถูกหล่อจากจังหวะนั้นโดยตรง',
          'สภาพใหม่ที่ตามมาคือเด็กเลือกทางที่ถนัดชัดขึ้น และรับรู้ขอบเขตจากผู้ใหญ่ได้จริง',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'ผลที่ตามมาคือตัวตนและขอบเขตส่วนตัวถูกตั้งหลักจากทางเลือกในช่วงนั้น',
          'สภาพใหม่ที่ตามมาคือวัยรุ่นแยกบทบาทตัวเองจากความคาดหวังรอบข้างได้ชัดขึ้น',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'ผลที่ตามมาคือรากฐานงาน การเรียน หรือความสัมพันธ์ระยะต้นถูกกำหนดจากทางเลือกนั้น',
          'สภาพใหม่ที่ตามมาคือชีวิตผู้ใหญ่เริ่มมีทิศทางที่วัดผลได้ และรับผิดชอบผลเอง',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'ผลที่ตามมาคือบทบาทงาน รายได้ หรือภาระครอบครัวถูกจัดใหม่จากทางเลือกนั้น',
          'สภาพใหม่ที่ตามมาคือสิ่งที่ไม่คุ้มถูกตัดออก และเส้นทางที่เหลือรับน้ำหนักมากขึ้น',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'ผลที่ตามมาคือลำดับความสำคัญของชีวิตถูกจัดใหม่ และพลังงานถูกใช้กับสิ่งที่คุ้มค่าจริง',
          'สภาพใหม่ที่ตามมาคือบทบาทที่เหลืออยู่ชัดขึ้น และภาระที่ไม่จำเป็นถูกปล่อยออก',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'ผลที่ตามมาคือคุณภาพชีวิตประจำวันและความสัมพันธ์ถูกจัดให้พอดีกับกำลังจริง',
          'สภาพใหม่ที่ตามมาคือจังหวะชีวิตช้าลงอย่างมีหลัก และประสบการณ์ถูกใช้ส่งต่ออย่างชัด',
        ];
    }
  }

  static String _pick(List<String> list, int n) {
    if (list.isEmpty) {
      return 'ช่วงนี้เป็นจังหวะที่แรงหลักของชีวิตถูกบังคับให้ชัด และผลต่อเส้นทางวัดได้จริง';
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
          'ขณะนี้ในวัยเด็กเล็กเป็น$phase ซึ่ง$essence พัฒนาการอารมณ์และการปรับตัวถูกผลักให้เด่น และกำหนดจังหวะชีวิตประจำวัน',
          'ขณะนี้คือ$phase — $essence ความมั่นคงทางใจผ่านการดูแลที่สม่ำเสมอเป็นแรงหลักที่เด็กตอบสนอง',
          'ขณะนี้เป็น$phase ที่$essence ความอบอุ่น การเล่น และการเรียนรู้จากสิ่งรอบตัวกลายเป็นแกนของช่วง',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'ขณะนี้ในวัยเรียนเป็น$phase ซึ่ง$essence การเรียนรู้ เพื่อน และการฝึกวินัยเป็นแรงหลักของชีวิต',
          'ขณะนี้คือ$phase — $essence ความสนใจและความมั่นใจถูกหล่อจากโรงเรียนและกลุ่มเพื่อนโดยตรง',
          'ขณะนี้เป็น$phase ที่$essence การเรียน การเข้าสังคม และการค้นหาสิ่งที่ถนัดถูกบังคับให้ชัด',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'ขณะนี้ในวัยรุ่นเป็น$phase ซึ่ง$essence ตัวตน เพื่อน และทิศทางอนาคตเป็นวาระหลักที่ต้องเลือก',
          'ขณะนี้คือ$phase — $essence การตัดสินใจและขอบเขตส่วนตัวถูกทดสอบ และเปลี่ยนบทบาทในกลุ่ม',
          'ขณะนี้เป็น$phase ที่$essence การค้นหาตัวตนและความเป็นอิสระถูกผลักให้เด่นภายใต้ที่พึ่งที่ยังมีอยู่',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'ขณะนี้ในวัยเริ่มต้นผู้ใหญ่เป็น$phase ซึ่ง$essence การสร้างตัวตน ความรับผิดชอบ และทางเลือกหลักถูกบังคับให้ตัดสิน',
          'ขณะนี้คือ$phase — $essence บทบาทผู้ใหญ่และรากฐานระยะต้นกลายเป็นแรงกดดันหลักของชีวิต',
          'ขณะนี้เป็น$phase ที่$essence การตัดสินใจส่งผลต่อทิศทางระยะยาว และแยกเส้นทางจากวัยก่อนหน้า',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'ขณะนี้ในวัยทำงานเป็น$phase ซึ่ง$essence งาน ความมั่นคง และสมดุลชีวิตเป็นแรงกดดันหลักที่ต้องจัดระเบียบ',
          'ขณะนี้คือ$phase — $essence คุณถูกบังคับให้เลือกโอกาสที่สอดคล้องกับพลังและความรับผิดชอบที่มีอยู่',
          'ขณะนี้เป็น$phase ที่$essence ภาระและโอกาสวิ่งคู่กัน และการเลือกครั้งนี้เปลี่ยนบทบาทหรือรายได้ชัด',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'ขณะนี้ในวัยกลางคนเป็น$phase ซึ่ง$essence การทบทวนทิศทาง การดูแลคนรอบตัว และการบริหารพลังงานเป็นวาระหลัก',
          'ขณะนี้คือ$phase — $essence ประสบการณ์ถูกนำมาปรับบทบาทให้พอดี และลำดับความสำคัญเปลี่ยนจากเดิม',
          'ขณะนี้เป็น$phase ที่$essence ความมั่นคงและการเลือกสิ่งที่คุ้มค่าแก่เวลากลายเป็นเกณฑ์ตัดสิน',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'ขณะนี้ในวัยสูงอายุเป็น$phase ซึ่ง$essence คุณภาพชีวิต ความสัมพันธ์ และการใช้ประสบการณ์ส่งต่อเป็นแกนหลัก',
          'ขณะนี้คือ$phase — $essence การรักษาสมดุลใจและปรับบทบาทอย่างให้เกียรติตัวเองเป็นแรงหลัก',
          'ขณะนี้เป็น$phase ที่$essence ความมั่นคงทางใจและการดูแลชีวิตประจำวันถูกจัดให้พอดีกับกำลังจริง',
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
            'จังหวะนี้ผลักให้เข้าใจความรู้สึกของตนเองและผู้อื่นชัดขึ้น ภายใต้ขอบเขตที่ต้องตั้งเอง',
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
            'แรงกดดันหลักคือความคาดหวังเรื่องผลงานหรือความเก่งที่เกินวัย',
            'ความขัดแย้งหลักอยู่ที่การเปรียบเทียบกับเด็กคนอื่นจนกระทบความมั่นใจ',
          ];
        }
        if (teen) {
          return [
            'แรงกดดันหลักคือการเร่งตัดสินใจเรื่องอนาคตโดยยังไม่เข้าใจตัวเองพอ',
            'ความขัดแย้งหลักอยู่ที่ความคาดหวังจากคนรอบตัวกับทิศทางที่ตนเองอยากเลือก',
          ];
        }
        return [
          'แรงกดดันหลักคือการแบกงานหรือความรับผิดชอบไว้คนเดียวจนเสียสมดุล',
          'ความขัดแย้งหลักอยู่ที่ผลงานกับพลังชีวิตที่เหลือจริง',
        ];
      case 'money':
        if (child || teen) {
          return [
            'แรงกดดันหลักคือความไม่แน่นอนของกิจวัตรที่ทำให้รู้สึกไม่มั่นคง',
            'ความขัดแย้งหลักอยู่ที่การเปลี่ยนแปลงสภาพแวดล้อมโดยยังอธิบายไม่ชัด',
          ];
        }
        return [
          'แรงกดดันหลักคือการตัดสินใจเรื่องเงินหรือข้อผูกมัดใหญ่ภายใต้เวลาจำกัด',
          'ความขัดแย้งหลักอยู่ที่การใช้จ่ายตามอารมณ์กับแผนระยะยาว',
        ];
      case 'love':
        if (child) {
          return [
            'แรงกดดันหลักคือการขาดความสม่ำเสมอในการดูแล',
            'ความขัดแย้งหลักอยู่ที่การเปลี่ยนสภาพแวดล้อมโดยยังไม่มีภาษาที่เด็กเข้าใจ',
          ];
        }
        if (teen) {
          return [
            'แรงกดดันหลักคือการเปรียบเทียบตัวเองกับเพื่อนจนกระทบความมั่นใจ',
            'ความขัดแย้งหลักอยู่ที่การเปิดใจเร็วโดยยังไม่มีขอบเขตชัด',
          ];
        }
        return [
          'แรงกดดันหลักคือการคาดหวังเงียบ ๆ โดยไม่สื่อสารจนเกิดระยะห่าง',
          'ความขัดแย้งหลักอยู่ที่ความน้อยใจสะสมกับการพูดตรง',
        ];
      case 'health':
        return [
          'แรงกดดันหลักคือการฝืนตัวเองจนสะสมความล้า',
          'ความขัดแย้งหลักอยู่ที่ภาระที่มีกับเวลาพักที่ร่างกายต้องการจริง',
        ];
      case 'opportunity':
        return [
          'แรงกดดันหลักคือการรับทุกโอกาสไว้จนโฟกัสกระจาย',
          'ความขัดแย้งหลักอยู่ที่ทางเลือกมากมายกับลำดับความสำคัญของช่วงนี้',
        ];
      case 'growth':
      default:
        return [
          'แรงกดดันหลักคือการเร่งผลลัพธ์จนมองข้ามพัฒนาการทีละขั้น',
          'ความขัดแย้งหลักอยู่ที่การเปรียบเทียบตัวเองกับคนอื่นจนท้อ',
        ];
    }
  }

  static List<String> _adviceBank(ThaiLifeStageBand band, String domain) {
    switch (band) {
      case ThaiLifeStageBand.earlyChildhood:
        return [
          'ผลต่อชีวิตคือกิจวัตรและความอบอุ่นในช่วงนี้กำหนดพื้นฐานอารมณ์ของเด็ก',
          'การเลือกของผู้ดูแลในช่วงนี้เปลี่ยนการตอบสนองของเด็กต่อความมั่นคงใกล้ตัว',
          'สิ่งที่ถูกบังคับให้ชัดคือความสม่ำเสมอในการดูแลมากกว่าการเร่งทักษะเกินวัย',
        ];
      case ThaiLifeStageBand.schoolAge:
        return [
          'ผลต่อชีวิตคือความสนใจ วินัย และการยืนในกลุ่มถูกหล่อจากจังหวะนี้',
          'การจัดเวลาเรียน พัก และเพื่อนในช่วงนี้เปลี่ยนความมั่นใจของเด็กโดยตรง',
          'สิ่งที่ถูกบังคับให้ชัดคือทางที่ถนัดและคำชมที่เฉพาะเจาะจง',
        ];
      case ThaiLifeStageBand.teen:
        return [
          'ผลต่อชีวิตคือตัวตนและขอบเขตส่วนตัวถูกตั้งหลักจากทางเลือกในช่วงนี้',
          'พื้นที่คิดและการปรึกษาในช่วงนี้เปลี่ยนบทบาทวัยรุ่นต่อความคาดหวังรอบข้าง',
          'สิ่งที่ถูกบังคับให้ชัดคือทิศทางอนาคตภายใต้ขอบเขตที่ยังมีที่พึ่ง',
        ];
      case ThaiLifeStageBand.youngAdult:
        return [
          'ผลต่อชีวิตคือรากฐานงาน การเรียน หรือความสัมพันธ์ระยะต้นถูกกำหนดตอนนี้',
          'วินัยเรื่องเวลา เงิน และสุขภาพในช่วงนี้เปลี่ยนความพร้อมของชีวิตผู้ใหญ่',
          'สิ่งที่ถูกบังคับให้ชัดคือความสัมพันธ์และโอกาสที่สอดคล้องกับค่าที่ยึดถือ',
        ];
      case ThaiLifeStageBand.workingAdult:
        return [
          'ผลต่อชีวิตคือบทบาทงาน รายได้ และภาระครอบครัวถูกจัดใหม่จากการเลือกตอนนี้',
          'การตัดสิ่งที่ไม่คุ้มในช่วงนี้เปลี่ยนน้ำหนักของเส้นทางที่เหลือ',
          'สิ่งที่ถูกบังคับให้ชัดคือสมดุลงาน การเงิน และสุขภาพภายใต้ภาระจริง',
        ];
      case ThaiLifeStageBand.midlife:
        return [
          'ผลต่อชีวิตคือลำดับความสำคัญถูกจัดใหม่ และพลังงานไปที่สิ่งที่คุ้มค่าจริง',
          'การดูแลสุขภาพควบคู่ภาระในช่วงนี้เปลี่ยนบทบาทระยะยาว',
          'สิ่งที่ถูกบังคับให้ชัดคือการตัดสินใจจากประสบการณ์ภายใต้เวลาที่เหลือ',
        ];
      case ThaiLifeStageBand.elder:
        return [
          'ผลต่อชีวิตคือคุณภาพชีวิตประจำวันและความสัมพันธ์ถูกจัดให้พอดีกับกำลัง',
          'กิจกรรมที่เติมความหมายในช่วงนี้เปลี่ยนจังหวะชีวิตจากวัยทำงาน',
          'สิ่งที่ถูกบังคับให้ชัดคือการส่งต่อประสบการณ์ในจังหวะที่ตนเองรับได้',
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
      'ช่วงนี้จุดเด่นข้อนี้ช่วยให้เดินทางได้สบายขึ้น',
    ],
    PlanetRelation.enemy: [
      'จังหวะนี้ฝืนกับนิสัยเดิม และบังคับให้ฝึกความอดทนกับการปรับตัว',
      'ช่วงนี้ออกแรงกับตัวเองมากขึ้น และผลของการปรับตัววัดได้ชัด',
    ],
    PlanetRelation.neutral: [
      'จังหวะนี้เปิดทางให้เลือกได้ว่าจะใช้จุดเด่นข้อนี้อย่างไร',
      'ช่วงนี้ผลลัพธ์ชัดขึ้นเมื่อนำจุดเด่นข้อนี้มาใช้จริง',
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
