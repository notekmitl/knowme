import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_reader_v2.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/presentation/pages/astrology/western_reader_v2_copy.dart';

import 'three_tradition_meaning_alignment.dart';
import 'three_tradition_core_conflict.dart';
import 'western_natal_life_semantics.dart';

/// A life-area interpretation with its three existing reader claims attached.
/// These are complementary perspectives; consensus is decided separately.
class ThreeTraditionLifeTopic {
  const ThreeTraditionLifeTopic({
    required this.title,
    required this.reading,
    required this.thai,
    required this.thaiEvidenceKeys,
    required this.chinese,
    required this.chineseEvidenceKeys,
    required this.western,
    required this.westernBasis,
  });

  final String title;
  final String reading;
  final String thai;
  final List<String> thaiEvidenceKeys;
  final String chinese;
  final List<String> chineseEvidenceKeys;
  final String western;
  final String westernBasis;
}

class ThreeTraditionLifeReading {
  const ThreeTraditionLifeReading({
    required this.topics,
    required this.gaps,
    this.conflicts = const [],
  });

  final List<ThreeTraditionLifeTopic> topics;
  final List<String> gaps;
  final List<ThreeTraditionCoreConflict> conflicts;
}

/// Uses the already calculated single-tradition readers and fails closed when
/// a life-area claim or its calculation basis is absent. No time period from
/// one tradition is promoted into a three-tradition forecast.
abstract final class ThreeTraditionLifeReadingComposer {
  static ThreeTraditionLifeReading compose({
    required ThaiBetaAnalysis thai,
    required BaziChartModel bazi,
    required AstrologyChartModel western,
    ThreeTraditionReading? comparison,
  }) {
    final gaps = <String>[];
    if (!thai.isSuccess || !thai.input.hasBirthTime) {
      return const ThreeTraditionLifeReading(
        topics: [],
        gaps: ['ดวงไทยไม่มีเวลาเกิดหรือผลวิเคราะห์ที่ใช้ตรวจเรือนชีวิต'],
      );
    }
    final core = ThaiBirthProfileCoreReading.fromAnalysis(thai);
    if (!core.hasBirthTime) {
      return const ThreeTraditionLifeReading(
        topics: [],
        gaps: ['ดวงไทยไม่มีเรือนชีวิตที่คำนวณจากเวลาเกิด'],
      );
    }
    if (bazi.contractId != 'knowme_bazi_reader_v3' ||
        !bazi.timeKnown ||
        bazi.tenGodBalance.topFamilies.isEmpty) {
      gaps.add(
        'ดวงจีนยังไม่มีผังสี่เสาและสมดุล Ten God รุ่นที่ตรวจคำอ่านรายด้านได้',
      );
    }
    if (!WesternReaderV2Copy.isCurrent(western)) {
      gaps.add('ดวงตะวันตกยังไม่มี Reader V2 พร้อมฐานดาวของคำอ่านรายด้าน');
    }
    if (gaps.isNotEmpty) {
      return ThreeTraditionLifeReading(topics: const [], gaps: gaps);
    }

    return composeFromReadings(
      core: core,
      bazi: bazi,
      western: western,
      chinese: BaziReaderV2.build(bazi, asOf: thai.asOf),
      westernSections: WesternReaderV2Copy.sections(western),
      comparison: comparison,
    );
  }

  /// Keeps the source reports visible while deriving the combined wording
  /// from typed atoms and chart codes. Also permits prose-change regression
  /// tests without changing any calculated evidence.
  static ThreeTraditionLifeReading composeFromReadings({
    required ThaiBirthProfileCoreReading core,
    required BaziChartModel bazi,
    required AstrologyChartModel western,
    required BaziReaderV2Reading chinese,
    required List<WesternReaderSection> westernSections,
    ThreeTraditionReading? comparison,
  }) {
    final gaps = <String>[];
    final topics = <ThreeTraditionLifeTopic>[];
    final conflicts = <ThreeTraditionCoreConflict>[];
    if (!core.hasBirthTime) {
      return const ThreeTraditionLifeReading(
        topics: [],
        gaps: ['ดวงไทยไม่มีเรือนชีวิตที่คำนวณจากเวลาเกิด'],
      );
    }
    if (bazi.contractId != 'knowme_bazi_reader_v3' ||
        !bazi.timeKnown ||
        bazi.tenGodBalance.topFamilies.isEmpty) {
      gaps.add(
        'ดวงจีนยังไม่มีผังสี่เสาและสมดุล Ten God รุ่นที่ตรวจคำอ่านรายด้านได้',
      );
    }
    if (!WesternReaderV2Copy.isCurrent(western)) {
      gaps.add('ดวงตะวันตกยังไม่มี Reader V2 พร้อมฐานดาวของคำอ่านรายด้าน');
    }
    if (gaps.isNotEmpty) {
      return ThreeTraditionLifeReading(topics: const [], gaps: gaps);
    }
    void add(ThreeTraditionLifeTopic? topic, String title) {
      if (topic == null) {
        gaps.add(
          '$title: ยังขาดคำอ่านรายด้านหรือความเชื่อมโยงที่ตรวจย้อนกลับได้จากทั้งสามศาสตร์',
        );
      } else {
        final conflict = comparison == null
            ? null
            : ThreeTraditionCoreConflictGuard.find(
                title: title,
                reading: comparison,
              );
        if (conflict == null) {
          topics.add(topic);
        } else {
          conflicts.add(conflict);
        }
      }
    }

    add(_work(core, chinese, bazi, western, westernSections), 'การงาน');
    add(_money(core, chinese, bazi, western, westernSections), 'การเงิน');
    add(
      _relationships(core, chinese, bazi, western, westernSections),
      'ความสัมพันธ์',
    );
    add(
      _wellbeing(core, chinese, bazi, western, westernSections),
      'การดูแลพลังและกิจวัตร',
    );
    if (comparison != null) {
      final aligned = ThreeTraditionMeaningAlignment.select(comparison);
      if (aligned != null) {
        final thai = aligned.sources[AstrologyLens.thaiAstrology.lensId]!;
        final chinese = aligned.sources[AstrologyLens.chineseBazi.lensId]!;
        final western = aligned.sources[AstrologyLens.westernNatal.lensId]!;
        topics.add(
          ThreeTraditionLifeTopic(
            title: aligned.title,
            reading: aligned.reading,
            thai: thai.themeId,
            thaiEvidenceKeys: thai.evidence,
            chinese: chinese.themeId,
            chineseEvidenceKeys: chinese.evidence,
            western: western.themeId,
            westernBasis: western.evidence.join(' · '),
          ),
        );
      }
    }
    return ThreeTraditionLifeReading(
      topics: List.unmodifiable(topics),
      gaps: List.unmodifiable(gaps),
      conflicts: List.unmodifiable(conflicts),
    );
  }

  static ThreeTraditionLifeTopic? _work(
    ThaiBirthProfileCoreReading core,
    BaziReaderV2Reading chinese,
    BaziChartModel bazi,
    AstrologyChartModel western,
    List<WesternReaderSection> westernSections,
  ) {
    final thai = _thaiClaim(core, ThaiBirthProfileCoreDomain.work, 10);
    final west = _western(westernSections, 'work');
    if (thai == null ||
        west == null ||
        chinese.work.trim().isEmpty ||
        !{'balanced', 'supported'}.contains(bazi.dayMasterSupport.band)) {
      return null;
    }
    final thaiMethod = _houseMode(thai, 10);
    final chineseFocus = BaziReaderV2.natalWorkFocus(bazi);
    final westernMethod = WesternNatalLifeSemantics.workMethod(western);
    if (thaiMethod.isEmpty || chineseFocus.isEmpty || westernMethod.isEmpty) {
      return null;
    }
    return ThreeTraditionLifeTopic(
      title: 'การงาน',
      reading:
          'คุณมีแนวโน้มไปได้ดีกับ$chineseFocus '
          'เมื่อได้ใช้$thaiMethod คุณ$westernMethod '
          'งานลักษณะนี้ควรมีขอบเขตความรับผิดชอบ มาตรฐานคุณภาพ '
          'และเกณฑ์จบงานที่ตกลงกันไว้ มิฉะนั้นงานที่รับเพิ่มอาจกระจาย'
          'แทนที่จะสะสมเป็นผลงาน',
      thai: thai.text,
      thaiEvidenceKeys: thai.evidenceKeys,
      chinese: chinese.work,
      chineseEvidenceKeys: const [
        'BaziChartModel.tenGodBalance.topFamilies',
        'BaziChartModel.dayMasterSupport.band',
      ],
      western: west.body,
      westernBasis: west.basis,
    );
  }

  static ThreeTraditionLifeTopic? _money(
    ThaiBirthProfileCoreReading core,
    BaziReaderV2Reading chinese,
    BaziChartModel bazi,
    AstrologyChartModel western,
    List<WesternReaderSection> westernSections,
  ) {
    final thai = _thaiClaim(core, ThaiBirthProfileCoreDomain.money, 2);
    final west = _western(westernSections, 'money');
    final weights = bazi.tenGodBalance.familyWeight;
    if (thai == null ||
        west == null ||
        chinese.money.trim().isEmpty ||
        !weights.containsKey('wealth') ||
        !weights.containsKey('peer')) {
      return null;
    }
    final thaiBasis = _houseMode(thai, 2);
    final westernValue = WesternNatalLifeSemantics.moneyValue(western);
    final chineseBase = weights['wealth']! >= 4
        ? 'การจัดเวลา งบ และทรัพยากรให้เกิดผลต่อเนื่อง'
        : 'ผลงานและความรับผิดชอบที่จับต้องได้';
    final chineseBoundary = weights['peer']! >= weights['wealth']!
        ? 'แยกเงินส่วนตัวกับเงินร่วม'
        : 'กำหนดเพดานลงทุนและจุดหยุด';
    final chineseRisk = weights['peer']! >= weights['wealth']!
        ? 'ค่าใช้จ่ายจากทีม หุ้นส่วน หรือการขยายงานอาจโตเร็วกว่าที่เห็น'
        : 'โอกาสใหม่อาจดึงเงินออกจากงานหลัก';
    if (thaiBasis.isEmpty || westernValue.isEmpty) return null;
    return ThreeTraditionLifeTopic(
      title: 'การเงิน',
      reading:
          'ฐานการเงินของคุณมีแนวโน้มพึ่ง$chineseBase '
          'คุณวางแผนจาก$thaiBasis และให้ค่ากับ$westernValue '
          'หากจะขยายแผน ควร$chineseBoundary เพราะ$chineseRisk',
      thai: thai.text,
      thaiEvidenceKeys: thai.evidenceKeys,
      chinese: chinese.money,
      chineseEvidenceKeys: const ['BaziChartModel.tenGodBalance.familyWeight'],
      western: west.body,
      westernBasis: west.basis,
    );
  }

  static ThreeTraditionLifeTopic? _relationships(
    ThaiBirthProfileCoreReading core,
    BaziReaderV2Reading chinese,
    BaziChartModel bazi,
    AstrologyChartModel western,
    List<WesternReaderSection> westernSections,
  ) {
    final thai = _thaiClaim(core, ThaiBirthProfileCoreDomain.relationships, 7);
    final west = _western(westernSections, 'love');
    if (thai == null ||
        west == null ||
        chinese.relationships.trim().isEmpty ||
        bazi.pillars.day.hiddenTenGods.isEmpty) {
      return null;
    }
    final thaiTrust = _houseMode(thai, 7);
    final westernStyle = WesternNatalLifeSemantics.relationshipStyle(western);
    final chineseOpening = BaziReaderV2.natalRelationshipOpening(bazi);
    if (thaiTrust.isEmpty || westernStyle.isEmpty || chineseOpening.isEmpty) {
      return null;
    }
    final spouseFamily = switch (bazi.luck.gender) {
      'male' => 'wealth',
      'female' => 'authority',
      _ => null,
    };
    final spouseWeight = spouseFamily == null
        ? null
        : bazi.tenGodBalance.familyWeight[spouseFamily];
    final chinesePace = spouseWeight == null
        ? ''
        : spouseWeight >= 4
        ? 'เรื่องคู่สัมพันธ์มีน้ำหนักในพื้นดวงนี้ '
        : 'ความผูกพันมีแนวโน้มค่อย ๆ เติบโตจากการทำสิ่งที่ตกลงกันไว้ ';
    return ThreeTraditionLifeTopic(
      title: 'ความสัมพันธ์',
      reading:
          'คุณมักมองความสัมพันธ์ผ่าน$thaiTrust '
          'ขณะเดียวกันคุณ$westernStyle '
          '$chinesePace'
          'ความรักจะลงตัวขึ้นเมื่อคุยเรื่องเวลา บทบาท และความคาดหวัง'
          'ให้ตรงกัน พร้อมแบ่งความรับผิดชอบและพื้นที่ตัดสินใจ '
          'ความตั้งใจดูแลกันจึงไม่กลายเป็นภาระที่ต้องเดาใจ',
      thai: thai.text,
      thaiEvidenceKeys: thai.evidenceKeys,
      chinese: chinese.relationships,
      chineseEvidenceKeys: const [
        'BaziChartModel.pillars.day.hiddenTenGods',
        'BaziChartModel.luck.gender',
      ],
      western: west.body,
      westernBasis: west.basis,
    );
  }

  static ThreeTraditionLifeTopic? _wellbeing(
    ThaiBirthProfileCoreReading core,
    BaziReaderV2Reading chinese,
    BaziChartModel bazi,
    AstrologyChartModel western,
    List<WesternReaderSection> westernSections,
  ) {
    final thai = _thaiClaim(core, ThaiBirthProfileCoreDomain.wellbeing, 6);
    final west = _western(westernSections, 'wellbeing');
    if (thai == null ||
        west == null ||
        chinese.balance.trim().isEmpty ||
        bazi.dayMaster.stem.isEmpty) {
      return null;
    }
    final thaiMode = _houseMode(thai, 6);
    final chineseAction = BaziReaderV2.natalBalanceAction(bazi);
    final westernAction = WesternNatalLifeSemantics.recoveryAction(western);
    if (thaiMode.isEmpty || chineseAction.isEmpty || westernAction.isEmpty) {
      return null;
    }
    return ThreeTraditionLifeTopic(
      title: 'การดูแลพลังและกิจวัตร',
      reading:
          'การดูแลพลังของคุณเริ่มจาก$thaiMode '
          'การ$westernActionช่วยให้คุณกลับมาตั้งหลัก '
          'ขณะเดียวกัน $chineseAction',
      thai: thai.text,
      thaiEvidenceKeys: thai.evidenceKeys,
      chinese: chinese.balance,
      chineseEvidenceKeys: const [
        'BaziChartModel.dayMaster.stem',
        'BaziChartModel.dayMasterSupport.band',
      ],
      western: west.body,
      westernBasis: west.basis,
    );
  }

  static ThaiBirthProfileCoreParagraph? _thaiClaim(
    ThaiBirthProfileCoreReading core,
    ThaiBirthProfileCoreDomain domain,
    int house,
  ) {
    for (final section in core.sections) {
      if (section.domain != domain) continue;
      for (final claim in section.claims) {
        if (claim.semanticKey != 'computed:house:$house:analysis' ||
            claim.evidenceKeys.isEmpty ||
            !claim.evidenceKeys.contains(
              'HouseEngine.calculate.house[$house].signKey',
            ) ||
            !claim.evidenceKeys.contains(
              'HouseEngine.calculate.house[$house].lordKey',
            ) ||
            !claim.sourceAtoms.any(
              (atom) =>
                  atom.kind == ThaiBirthProfileCoreAtomKind.houseSign &&
                  atom.houseNumber == house &&
                  atom.sourceRef ==
                      'HouseEngine.calculate.house[$house].signKey' &&
                  atom.rawValue.isNotEmpty,
            ) ||
            !claim.sourceAtoms.any(
              (atom) =>
                  atom.kind == ThaiBirthProfileCoreAtomKind.houseLord &&
                  atom.houseNumber == house &&
                  atom.sourceRef ==
                      'HouseEngine.calculate.house[$house].lordKey' &&
                  atom.rawValue.isNotEmpty,
            )) {
          continue;
        }
        return claim;
      }
    }
    return null;
  }

  static WesternReaderSection? _western(
    List<WesternReaderSection> sections,
    String id,
  ) {
    for (final section in sections) {
      if (section.id == id &&
          section.body.isNotEmpty &&
          section.basis.isNotEmpty) {
        return section;
      }
    }
    return null;
  }

  static String _houseMode(ThaiBirthProfileCoreParagraph claim, int house) {
    for (final atom in claim.sourceAtoms) {
      if (atom.kind == ThaiBirthProfileCoreAtomKind.houseLord &&
          atom.houseNumber == house &&
          atom.sourceRef == 'HouseEngine.calculate.house[$house].lordKey') {
        return ThaiBirthProfileCoreReading.houseModeForLordKey(atom.rawValue);
      }
    }
    return '';
  }
}
