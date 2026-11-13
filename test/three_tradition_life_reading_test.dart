import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_life_reading.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/astrology/fusion/presentation/western_natal_life_semantics.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_overall_topic_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_reading_copy.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_reader_v2.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/presentation/pages/astrology/western_reader_v2_copy.dart';

void main() {
  final bazi = _unknownGender(BaziCompatibilityOwnerFixtures.readerV3Chart());
  final chinese = BaziReaderV2.build(bazi, asOf: DateTime(2026, 9, 25));
  final western = _westernChart();

  ThreeTraditionLifeReading compose({
    ThaiBirthProfileCoreReading? core,
    BaziChartModel? baziChart,
    BaziReaderV2Reading? chineseCopy,
    AstrologyChartModel? westernChart,
    List<WesternReaderSection>? westernCopy,
    ThreeTraditionReading? comparison,
  }) {
    final chart = baziChart ?? bazi;
    return ThreeTraditionLifeReadingComposer.composeFromReadings(
      core: core ?? _thaiCore('ต้นฉบับ'),
      bazi: chart,
      western: westernChart ?? western,
      chinese:
          chineseCopy ?? BaziReaderV2.build(chart, asOf: DateTime(2026, 9, 25)),
      westernSections: westernCopy ?? _westernSections('ต้นฉบับ'),
      comparison: comparison,
    );
  }

  test(
    'single-reader wording changes do not remove or rewrite life topics',
    () {
      final before = compose();
      final after = compose(
        core: _thaiCore('เรียบเรียงใหม่'),
        chineseCopy: _newChineseWording(chinese),
        westernCopy: _westernSections('เรียบเรียงใหม่'),
      );
      expect(before.gaps, isEmpty);
      expect(after.gaps, isEmpty);
      expect(before.topics.map((topic) => topic.title), [
        'การงาน',
        'การเงิน',
        'ความสัมพันธ์',
        'การดูแลพลังและกิจวัตร',
      ]);
      expect(
        after.topics.map((topic) => topic.reading),
        before.topics.map((topic) => topic.reading),
      );
      expect(after.topics.first.thai, isNot(before.topics.first.thai));
      expect(after.topics.first.chinese, isNot(before.topics.first.chinese));
      expect(after.topics.first.western, isNot(before.topics.first.western));
    },
  );

  test('missing calculated house evidence omits only that topic', () {
    final result = compose(core: _thaiCore('ต้นฉบับ', omitHouse: 2));
    expect(result.topics.map((topic) => topic.title), [
      'การงาน',
      'ความสัมพันธ์',
      'การดูแลพลังและกิจวัตร',
    ]);
    expect(result.gaps.single, startsWith('การเงิน:'));
  });

  test('r5 keeps independent work claims and the original conditional risk', () {
    // Branch inputs reproduce the recorded wording. They are synthetic and
    // contain no inferred birth details, personal placements, or scores.
    final chart = _copyBazi(
      bazi,
      support: const BaziDayMasterSupport(band: 'supported'),
      balance: const BaziTenGodBalance(
        familyWeight: {'wealth': 2, 'peer': 2, 'resource': 3},
        topFamilies: ['resource'],
      ),
    );
    final result = compose(
      core: _thaiCore(
        'fixture',
        lordOverrides: {
          7: ThaiContentKeys.lagnaLordSun,
          6: ThaiContentKeys.lagnaLordMoon,
        },
      ),
      baziChart: chart,
      westernChart: _westernChart(moonSign: 'Sagittarius'),
    );
    final source =
        jsonDecode(
              File(
                'test/fixtures/trial_readability/owner-overall-source.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(result.gaps, isEmpty);
    expect([
      for (final topic in result.topics)
        {'title': topic.title, 'reading': topic.reading},
    ], source['topics']);
    final work = result.topics[0].trialParagraphs;
    expect(work, hasLength(6));
    expect(
      work.first,
      'คุณมีแนวโน้มทำได้ดีกับงานที่ต้องค้นคว้าให้ละเอียด จัดข้อมูลให้คนอื่นใช้ได้ หรือช่วยคนอื่นหาข้อมูล',
    );
    expect(work[1], 'เวลาทำงาน คุณกล้าลงมือทำและรับมือกับเรื่องด่วน');
    expect(
      work[2],
      'คุณเรียนรู้เร็ว คุณเห็นว่าข้อมูลแต่ละส่วนเกี่ยวกันอย่างไร',
    );
    expect(work[3], 'คุณอธิบายเรื่องยากให้คนอื่นเข้าใจได้');
    expect(work[4], contains('ต้องทำอะไรครบจึงจะถือว่างานเสร็จ'));
    expect(
      work.last,
      'ถ้าคุยกันไม่ชัด งานที่รับเพิ่มอาจกระจายไปหลายเรื่อง '
      'จนเอาผลงานจากงานหนึ่งไปใช้ต่อกับอีกงานได้ยาก',
    );
    final money = result.topics[1].trialParagraphs;
    expect(money[1], 'เวลาวางแผนเรื่องเงิน คุณใช้สิ่งที่รู้และคิดเผื่ออนาคต');
    expect(
      money[2],
      'คุณดูเหตุผลก่อนขยายแผนเรื่องเงิน '
      'ตัวอย่างเช่น ถ้าคิดจะเพิ่มเงินที่ใช้กับงาน คุณดูก่อนว่าเพิ่มไปเพื่ออะไร',
    );
    expect(
      money.last,
      'ควรแยกเงินที่ใช้เองออกจากเงินที่ใช้ร่วมกับคนอื่น '
      'ค่าใช้จ่ายจากทีม คนที่ทำธุรกิจร่วมกับคุณ หรือการขยายงาน อาจเพิ่มเร็วจนคุณสังเกตไม่ทัน',
    );
    final relationships = result.topics[2].trialParagraphs;
    expect(relationships, hasLength(4));
    expect(relationships.first, contains('เช่น จับมือหรือกอด'));
    expect(relationships.join(' '), isNot(contains('ค่อย ๆ รู้สึกใกล้ชิด')));
    expect(relationships.join(' '), isNot(contains('เรื่องคู่เป็นเรื่องเด่น')));
    final wellbeing = result.topics[3].trialParagraphs;
    expect(wellbeing, hasLength(5));
    expect(wellbeing.first, contains('หรือเรียนรู้สิ่งใหม่'));
    expect(wellbeing[1], contains('พร้อมรับมือได้เหมือนกัน'));
    expect(wellbeing.last, contains('ความต้องการของคนรอบข้าง'));
    expect(
      wellbeing.last,
      contains('ไม่ได้บอกว่าการทำแบบนี้จะทำให้คุณมีแรงขึ้น'),
    );

    final path = const String.fromEnvironment('COPY_OWNER_SNAPSHOT');
    if (path.isNotEmpty) {
      File(path).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert([
          for (final topic in result.topics)
            {
              'title': TrialOverallTopicCopy.title(topic.title),
              'source': topic.reading,
              'r3': TrialReadingCopy.overall(topic.reading),
              'paragraphs': topic.trialParagraphs,
            },
        ]),
      );
    }
  });

  test('missing Western planet code omits dependent topics', () {
    final result = compose(westernChart: _westernChart(withVenus: false));
    expect(result.topics.map((topic) => topic.title), [
      'การงาน',
      'การดูแลพลังและกิจวัตร',
    ]);
    expect(result.gaps, hasLength(2));
    expect(result.gaps.join(' '), contains('การเงิน:'));
    expect(result.gaps.join(' '), contains('ความสัมพันธ์:'));
  });

  test('missing source report text still fails closed', () {
    final result = compose(
      westernCopy: [
        const WesternReaderSection(
          id: 'work',
          title: 'งาน',
          body: '',
          basis: 'ดาวพุธ',
        ),
        ..._westernSections('ต้นฉบับ').where((section) => section.id != 'work'),
      ],
    );
    expect(result.topics.map((topic) => topic.title), [
      'การเงิน',
      'ความสัมพันธ์',
      'การดูแลพลังและกิจวัตร',
    ]);
    expect(result.gaps.single, startsWith('การงาน:'));
  });

  test('screenshot branches use topic-specific openings with source limits', () {
    // Selected modes reproduce the two copy branches, not a person's chart.
    final result = compose(
      core: _thaiCore(
        'synthetic branch review',
        lordOverrides: {
          6: ThaiContentKeys.lagnaLordMercury,
          7: ThaiContentKeys.lagnaLordMoon,
        },
      ),
      westernChart: _westernChart(moonSign: 'Libra', venusSign: 'Virgo'),
    );
    final relationship = result.topics[2];
    final wellbeing = result.topics[3];
    expect(
      relationship.trialParagraphs.first,
      'คุณแสดงความรักด้วยการช่วยแก้ปัญหาและใส่ใจเรื่องเล็ก ๆ ของคนที่คบอยู่',
    );
    expect(relationship.trialParagraphs[1], contains('คนรอบข้างต้องการอะไร'));
    expect(
      relationship.trialParagraphs[1],
      contains('ไม่ได้ระบุว่าเป็นคนไหนหรือเรื่องอะไร'),
    );
    expect(relationship.trialParagraphs[1], isNot(contains('แฟน')));
    expect(
      relationship.trialParagraphs.join(' '),
      isNot(contains('ค่อย ๆ รู้สึกใกล้ชิด')),
    );
    expect(
      wellbeing.trialParagraphs.first,
      'การคุยกันอย่างเป็นธรรม และหาวิธีอยู่ร่วมกันที่ทั้งสองฝ่ายรับได้ช่วยให้คุณรู้สึกพร้อมรับมือกับเรื่องที่เจออีกครั้ง',
    );
    expect(
      wellbeing.trialParagraphs.last,
      contains('ใช้ข้อมูลเทียบสิ่งที่เลือกได้'),
    );
    expect(
      wellbeing.trialParagraphs.last,
      endsWith('มีแรงขึ้นหรือเหนื่อยกว่าเดิม'),
    );
    expect(
      TrialReadingCopy.overall(wellbeing.reading),
      contains('ไม่ได้บอกว่าการทำแบบนี้จะทำให้คุณมีแรงขึ้น'),
    );
    expect(wellbeing.reading, startsWith('การดูแลพลังของคุณเริ่มจากข้อมูล'));
    final path = const String.fromEnvironment(
      'COPY_SCREENSHOT_BRANCH_SNAPSHOT',
    );
    if (path.isNotEmpty) {
      File(path).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert([
          for (final topic in result.topics)
            {
              'title': topic.title,
              'source': topic.reading,
              'paragraphs': topic.trialParagraphs,
              'thaiEvidence': topic.thaiEvidenceKeys,
              'chineseEvidence': topic.chineseEvidenceKeys,
              'westernBasis': topic.westernBasis,
            },
        ]),
      );
    }
  });

  test('trial paragraphs cover every source wording branch', () {
    const signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];
    const observations = {
      ThaiContentKeys.lagnaLordSun: 'การตัดสินใจเอง',
      ThaiContentKeys.lagnaLordMoon: 'ความต้องการของคนรอบข้าง',
      ThaiContentKeys.lagnaLordMars: 'การจัดการเรื่องด่วน',
      ThaiContentKeys.lagnaLordMercury: 'เทียบสิ่งที่เลือกได้',
      ThaiContentKeys.lagnaLordJupiter: 'การคิดถึงอนาคต',
      ThaiContentKeys.lagnaLordVenus: 'ทำอย่างไรให้ทั้งสองฝ่ายทำด้วยกันได้',
      ThaiContentKeys.lagnaLordSaturn: 'เตรียมสิ่งจำเป็นทีละขั้น',
    };
    final lords = observations.keys.toList();
    const workFamilies = [
      ['resource'],
      ['peer'],
      ['output'],
      ['wealth'],
      ['authority'],
      ['resource', 'output'],
    ];
    final reviewed = <Map<String, dynamic>>[];
    for (final (index, sign) in signs.indexed) {
      final chart = _westernChart(mercurySign: sign, venusSign: sign);
      final lord = lords[index % lords.length];
      final families = workFamilies[index % workFamilies.length];
      final wealth = index % 2 == 0 ? 2 : 5;
      final peer = index % 4 < 2 ? 5 : 1;
      final band = index % 2 == 0 ? 'balanced' : 'supported';
      final result = compose(
        core: _thaiCore(
          'fixture',
          lordOverrides: {
            for (final house in [10, 2, 7, 6]) house: lord,
          },
        ),
        westernChart: chart,
        baziChart: _copyBazi(
          bazi,
          gender: 'female',
          balance: BaziTenGodBalance(
            familyWeight: {
              'wealth': wealth,
              'peer': peer,
              'authority': index % 2 == 0 ? 5 : 1,
            },
            topFamilies: families,
          ),
          support: BaziDayMasterSupport(band: band),
        ),
      );
      expect(result.gaps, isEmpty, reason: sign);
      expect(result.topics, hasLength(4));
      for (final topic in result.topics) {
        expect(topic.trialParagraphs, isNotEmpty);
        expect(
          topic.trialParagraphs.toSet(),
          hasLength(topic.trialParagraphs.length),
        );
        // Missing catalog mappings must not expose a raw source fragment.
        expect(topic.trialParagraphs.join(' '), isNot(contains('ตั้งหลัก')));
      }
      final work = result.topics.first.trialParagraphs;
      expect(work[1], startsWith('เวลาทำงาน คุณ'));
      expect(work[2], anyOf(startsWith('คุณ'), startsWith('เวลาคุณอธิบาย')));
      expect(result.topics[1].trialParagraphs[1], contains('เงิน'));
      expect(
        result.topics[2].trialParagraphs[1],
        anyOf(contains('คบกัน'), contains('ความสัมพันธ์')),
      );
      final coupleParagraph = result.topics[2].trialParagraphs[2];
      expect(
        coupleParagraph,
        index % 2 == 0
            ? 'เรื่องคู่เป็นเรื่องเด่นในดวงของคุณ'
            : 'เมื่อคุณกับคนที่คบอยู่ทำตามที่ตกลงกันไว้ '
                  'ทั้งสองคนมีแนวโน้มจะค่อย ๆ รู้สึกใกล้ชิดกันมากขึ้น',
      );
      final wellbeing = result.topics.last;
      final thaiAnalysisMode = ThaiBirthProfileCoreReading.houseModeForLordKey(
        lord,
      );
      expect(
        wellbeing.reading,
        startsWith('การดูแลพลังของคุณเริ่มจาก$thaiAnalysisMode'),
      );
      expect(
        wellbeing.trialParagraphs.first,
        contains('พร้อมรับมือ'),
        reason: lord,
      );
      expect(
        wellbeing.trialParagraphs.last,
        contains(observations[lord]),
        reason: lord,
      );
      expect(
        wellbeing.trialParagraphs.last,
        contains('ไม่ได้บอกว่าการทำแบบนี้จะทำให้คุณมีแรงขึ้น'),
      );
      reviewed.add({
        'sign': sign,
        'lord': lord,
        'families': families,
        'band': band,
        'topics': [
          for (final topic in result.topics)
            {
              'title': topic.title,
              'source': topic.reading,
              'paragraphs': topic.trialParagraphs,
            },
        ],
      });
    }
    final lean = compose(
      baziChart: _copyBazi(
        bazi,
        support: const BaziDayMasterSupport(band: 'lean'),
      ),
    );
    expect(lean.gaps.single, startsWith('การงาน:'));
    final wellbeing = lean.topics.last;
    expect(
      wellbeing.trialParagraphs,
      contains(contains('ก่อนรับหน้าที่เพิ่ม')),
    );
    reviewed.add({
      'band': 'lean',
      'topics': [
        {
          'title': wellbeing.title,
          'source': wellbeing.reading,
          'paragraphs': wellbeing.trialParagraphs,
        },
      ],
    });
    final path = const String.fromEnvironment('COPY_BRANCH_SNAPSHOT');
    if (path.isNotEmpty) {
      File(
        path,
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(reviewed));
    }
  });

  test(
    'unlisted copy uses a topic-specific opening and preserves source detail',
    () {
      const source = 'วิธีที่ยังไม่มีคำอธิบายแยก';
      final relationships = TrialOverallTopicCopy.relationships(
        thaiTrust: source,
        westernStyle: 'พูดถึงสิ่งที่ทั้งสองคนชอบ',
        coupleIsProminent: null,
      );
      expect(relationships.first, startsWith('คุณกับคนที่คบอยู่'));
      expect(relationships, contains(contains(source)));
      expect(relationships, contains(contains('พูดถึงสิ่งที่ทั้งสองคนชอบ')));
      final wellbeing = TrialOverallTopicCopy.wellbeing(
        thaiMode: source,
        westernAction: 'ได้พักอยู่เงียบ ๆ',
        chineseAction: 'ควรเผื่อเวลาพัก',
      );
      expect(wellbeing.first, endsWith('เมื่อได้พักอยู่เงียบ ๆ'));
      expect(wellbeing[1], 'ควรเผื่อเวลาพัก');
      expect(wellbeing.last, allOf(contains(source), contains('ไม่ได้บอกว่า')));
    },
  );

  test('male and female relationship branches both stay visible', () {
    for (final gender in ['male', 'female']) {
      final chart = _withGender(bazi, gender);
      final result = compose(baziChart: chart);
      final topic = result.topics.singleWhere(
        (item) => item.title == 'ความสัมพันธ์',
      );
      final opening = BaziReaderV2.natalRelationshipOpening(chart);
      expect(opening, isNotEmpty);
      expect(topic.chinese, contains(opening));
      final spouseFamily = gender == 'male' ? 'wealth' : 'authority';
      final emphasis = chart.tenGodBalance.familyWeight[spouseFamily]! >= 4
          ? 'เรื่องคู่สัมพันธ์มีน้ำหนักในพื้นดวงนี้'
          : 'ความผูกพันมีแนวโน้มค่อย ๆ เติบโต';
      expect(topic.reading, contains(emphasis));
      expect(topic.reading, isNot(contains('ความชัดเจนและความสม่ำเสมอ')));
      expect(result.gaps, isEmpty);
    }
  });

  test('trial money advice follows BaZi without a plan-expansion condition', () {
    for (final caseData in [
      (
        wealth: 1,
        peer: 5,
        base: 'ผลงานและความรับผิดชอบที่จับต้องได้',
        boundary: 'แยกเงินส่วนตัวกับเงินร่วม',
        risk: 'ค่าใช้จ่ายจากทีม หุ้นส่วน หรือการขยายงานอาจโตเร็วกว่าที่เห็น',
        sourceAdvice:
            'ต้องแยกเงินส่วนตัว เงินร่วม และอำนาจตัดสินใจให้ชัด เพราะค่าใช้จ่ายจากทีม หุ้นส่วน หรือการขยายงานอาจโตเร็วกว่าที่เห็น',
        trialAdvice:
            'ควรแยกเงินที่ใช้เองออกจากเงินที่ใช้ร่วมกับคนอื่น '
            'ค่าใช้จ่ายจากทีม คนที่ทำธุรกิจร่วมกับคุณ หรือการขยายงาน อาจเพิ่มเร็วจนคุณสังเกตไม่ทัน',
      ),
      (
        wealth: 5,
        peer: 1,
        base: 'การจัดเวลา งบ และทรัพยากรให้เกิดผลต่อเนื่อง',
        boundary: 'กำหนดเพดานลงทุนและจุดหยุด',
        risk: 'โอกาสใหม่อาจดึงเงินออกจากงานหลัก',
        sourceAdvice:
            'ควรกำหนดเพดานลงทุนและจุดหยุดไว้ล่วงหน้า เพื่อไม่ให้โอกาสใหม่ดึงเงินออกจากงานหลัก',
        trialAdvice:
            'คุณควรกำหนดไว้ล่วงหน้าว่าจะลงทุนได้ไม่เกินเท่าไร และจะหยุดลงทุนในกรณีไหน '
            'เหตุผลคือโอกาสใหม่อาจดึงเงินจากงานหลักไปใช้',
      ),
    ]) {
      final chart = _withMoneyWeights(bazi, caseData.wealth, caseData.peer);
      final result = compose(baziChart: chart);
      final money = result.topics.singleWhere(
        (topic) => topic.title == 'การเงิน',
      );
      expect(money.reading, contains(caseData.base));
      expect(money.reading, contains('หากจะขยายแผน ควร${caseData.boundary}'));
      expect(money.reading, contains(caseData.risk));
      expect(money.reading, isNot(contains('กันเงินสำรอง')));
      expect(money.chinese, endsWith(caseData.sourceAdvice));
      expect(money.trialParagraphs.last, caseData.trialAdvice);
    }
  });

  test('new copy retains calculated work and recovery meanings', () {
    final result = compose();
    final work = result.topics.singleWhere((topic) => topic.title == 'การงาน');
    final wellbeing = result.topics.singleWhere(
      (topic) => topic.title == 'การดูแลพลังและกิจวัตร',
    );
    expect(work.reading, contains(BaziReaderV2.natalWorkFocus(bazi)));
    expect(
      work.reading,
      contains(WesternNatalLifeSemantics.workMethod(western)),
    );
    expect(work.reading, isNot(contains('บทบาทที่คุ้ม')));
    expect(
      wellbeing.reading,
      contains(WesternNatalLifeSemantics.recoveryAction(western)),
    );
    expect(wellbeing.reading, contains(BaziReaderV2.natalBalanceAction(bazi)));
    expect(wellbeing.reading, isNot(contains('ฟื้นตัวช้าต่อเนื่อง')));
  });

  test('missing gender-specific Chinese weight omits relationship', () {
    final female = _withGender(bazi, 'female');
    final incomplete = _withoutFamilyWeight(female, 'authority');
    final result = compose(baziChart: incomplete);
    expect(
      result.topics.map((topic) => topic.title),
      isNot(contains('ความสัมพันธ์')),
    );
    expect(result.gaps.join(' '), contains('ความสัมพันธ์:'));
  });

  test('missing house-six or Moon evidence omits wellbeing', () {
    final noThai = compose(core: _thaiCore('ต้นฉบับ', omitHouse: 6));
    final noMoon = compose(westernChart: _westernChart(withMoon: false));
    for (final result in [noThai, noMoon]) {
      expect(
        result.topics.map((topic) => topic.title),
        isNot(contains('การดูแลพลังและกิจวัตร')),
      );
      expect(result.gaps.join(' '), contains('การดูแลพลังและกิจวัตร:'));
    }
  });

  test('reviewed near meaning adds at most one traceable life topic', () {
    LensThemeOutput source(String lens, String theme) {
      final registered = FusionThemeRegistry.getById(theme)!;
      return LensThemeOutput(
        lensId: lens,
        themeId: theme,
        category: registered.category,
        family: registered.family,
        confidence: 0.6,
        evidence: ['calculated fixture fact'],
      );
    }

    final comparison = ThreeTraditionConsensus.analyzeOutputs([
      source(AstrologyLens.thaiAstrology.lensId, 'independent'),
      source(AstrologyLens.chineseBazi.lensId, 'independent'),
      source(AstrologyLens.westernNatal.lensId, 'leadership'),
    ]);
    final result = compose(comparison: comparison);
    expect(result.topics.last.title, 'ทิศทางและการตัดสินใจ');
    expect(result.topics.last.western, 'leadership');
    expect(
      result.topics.last.westernBasis,
      contains('calculated fixture fact'),
    );
    expect(result.topics, hasLength(5));
  });

  test('same supported relationship meaning keeps every main topic', () {
    final comparison = ThreeTraditionConsensus.analyzeOutputs([
      _theme(AstrologyLens.thaiAstrology.lensId, 'expressive'),
      _theme(AstrologyLens.chineseBazi.lensId, 'expressive'),
      _theme(AstrologyLens.westernNatal.lensId, 'expressive'),
    ]);
    final baseline = compose();
    final result = compose(comparison: comparison);
    expect(
      result.topics.take(4).map((topic) => topic.title),
      baseline.topics.map((topic) => topic.title),
    );
    expect(result.conflicts, isEmpty);
    expect(result.gaps, isEmpty);
  });

  test('reviewed near meaning does not veto any main topic', () {
    final comparison = ThreeTraditionConsensus.analyzeOutputs([
      _theme(AstrologyLens.thaiAstrology.lensId, 'independent'),
      _theme(AstrologyLens.chineseBazi.lensId, 'independent'),
      _theme(AstrologyLens.westernNatal.lensId, 'leadership'),
    ]);
    final result = compose(comparison: comparison);
    expect(result.topics.take(4).map((topic) => topic.title), [
      'การงาน',
      'การเงิน',
      'ความสัมพันธ์',
      'การดูแลพลังและกิจวัตร',
    ]);
    expect(result.conflicts, isEmpty);
  });

  test(
    'direct supported opposition omits only the relationship prediction',
    () {
      final comparison = ThreeTraditionConsensus.analyzeOutputs([
        _theme(AstrologyLens.thaiAstrology.lensId, 'expressive'),
        _theme(AstrologyLens.chineseBazi.lensId, 'expressive'),
        _theme(AstrologyLens.westernNatal.lensId, 'reserved'),
      ]);
      final baseline = compose();
      final result = compose(comparison: comparison);
      expect(result.topics.map((topic) => topic.title), [
        'การงาน',
        'การเงิน',
        'การดูแลพลังและกิจวัตร',
      ]);
      for (final topic in result.topics) {
        expect(
          topic.reading,
          baseline.topics
              .singleWhere((item) => item.title == topic.title)
              .reading,
        );
      }
      expect(result.conflicts.single.title, 'ความสัมพันธ์');
      expect(result.conflicts.single.axis, 'relationship_disclosure');
      expect(
        result.conflicts.single.sources.values.map((item) => item.themeId),
        ['expressive', 'expressive', 'reserved'],
      );
      expect(
        result.conflicts.single.sources.values.every(
          (item) => item.evidence.single == 'calculated fixture fact',
        ),
        isTrue,
      );
      expect(result.gaps, isEmpty);
    },
  );

  test('difference without a reviewed opposition keeps main topics', () {
    final comparison = ThreeTraditionConsensus.analyzeOutputs([
      _theme(AstrologyLens.thaiAstrology.lensId, 'loyal'),
      _theme(AstrologyLens.chineseBazi.lensId, 'independent_connection'),
      _theme(AstrologyLens.westernNatal.lensId, 'supportive'),
    ]);
    final result = compose(comparison: comparison);
    expect(result.topics, hasLength(4));
    expect(result.conflicts, isEmpty);
  });

  test(
    'mixed disclosure evidence inside one lens is not a clear opposition',
    () {
      final comparison = ThreeTraditionConsensus.analyzeOutputs([
        _theme(AstrologyLens.thaiAstrology.lensId, 'expressive'),
        _theme(AstrologyLens.chineseBazi.lensId, 'expressive'),
        _theme(AstrologyLens.westernNatal.lensId, 'expressive'),
        _theme(AstrologyLens.westernNatal.lensId, 'reserved'),
      ]);
      final result = compose(comparison: comparison);
      expect(
        result.topics.any((topic) => topic.title == 'ความสัมพันธ์'),
        isTrue,
      );
      expect(result.conflicts, isEmpty);
    },
  );

  test('missing or weak opposition does not suppress source-backed topics', () {
    for (final third in <LensThemeOutput?>[
      null,
      _theme(AstrologyLens.westernNatal.lensId, 'reserved', confidence: 0.59),
      _theme(AstrologyLens.westernNatal.lensId, 'reserved', evidence: const []),
    ]) {
      final comparison = ThreeTraditionConsensus.analyzeOutputs([
        _theme(AstrologyLens.thaiAstrology.lensId, 'expressive'),
        _theme(AstrologyLens.chineseBazi.lensId, 'expressive'),
        ?third,
      ]);
      final result = compose(comparison: comparison);
      expect(
        result.topics.map((topic) => topic.title).contains('ความสัมพันธ์'),
        isTrue,
      );
      expect(result.conflicts, isEmpty);
    }
    expect(ThreeTraditionConsensus.minimumAgreementConfidence, 0.6);
  });
}

LensThemeOutput _theme(
  String lens,
  String theme, {
  double confidence = 0.6,
  List<String> evidence = const ['calculated fixture fact'],
}) {
  final registered = FusionThemeRegistry.getById(theme)!;
  return LensThemeOutput(
    lensId: lens,
    themeId: theme,
    category: registered.category,
    family: registered.family,
    confidence: confidence,
    evidence: evidence,
  );
}

ThaiBirthProfileCoreReading _thaiCore(
  String wording, {
  int? omitHouse,
  Map<int, String> lordOverrides = const {},
}) {
  final entries = <(int, ThaiBirthProfileCoreDomain, String)>[
    (10, ThaiBirthProfileCoreDomain.work, ThaiContentKeys.lagnaLordMars),
    (2, ThaiBirthProfileCoreDomain.money, ThaiContentKeys.lagnaLordJupiter),
    (7, ThaiBirthProfileCoreDomain.relationships, ThaiContentKeys.lagnaLordSun),
    (6, ThaiBirthProfileCoreDomain.wellbeing, ThaiContentKeys.lagnaLordVenus),
  ];
  return ThaiBirthProfileCoreReading(
    title: 'ตัวอย่าง',
    subtitle: '',
    hasBirthTime: true,
    omissions: const [],
    sections: [
      for (final (house, domain, lord) in entries)
        if (house != omitHouse)
          ThaiBirthProfileCoreSection(
            title: domain.name,
            domain: domain,
            claims: [
              ThaiBirthProfileCoreParagraph(
                text: '$wording — ${domain.name}',
                domain: domain,
                role: ThaiBirthProfileCoreClaimRole.synthesis,
                semanticKey: 'computed:house:$house:analysis',
                evidenceKeys: [
                  'HouseEngine.calculate.house[$house].signKey',
                  'HouseEngine.calculate.house[$house].lordKey',
                ],
                sourceAtoms: [
                  ThaiBirthProfileCoreClaimAtom(
                    kind: ThaiBirthProfileCoreAtomKind.houseSign,
                    domain: domain,
                    sourceRef: 'HouseEngine.calculate.house[$house].signKey',
                    rawValue: ThaiContentKeys.allLagna.first,
                    houseNumber: house,
                  ),
                  ThaiBirthProfileCoreClaimAtom(
                    kind: ThaiBirthProfileCoreAtomKind.houseLord,
                    domain: domain,
                    sourceRef: 'HouseEngine.calculate.house[$house].lordKey',
                    rawValue: lordOverrides[house] ?? lord,
                    houseNumber: house,
                  ),
                ],
              ),
            ],
          ),
    ],
  );
}

AstrologyChartModel _westernChart({
  bool withVenus = true,
  bool withMoon = true,
  String mercurySign = 'Gemini',
  String venusSign = 'Taurus',
  String? moonSign,
}) => AstrologyChartModel(
  version: WesternReaderV2Copy.chartVersion,
  contractId: WesternReaderV2Copy.contractId,
  engineVersion: 'fixture',
  inputHash: 'fixture',
  big3: {if (withMoon) 'moon': moonSign ?? venusSign},
  planets: {
    'mercury': {'sign': mercurySign},
    if (withVenus) 'venus': {'sign': venusSign},
  },
  insight: const {},
  overallSummary: const {},
  reader: const {'version': WesternReaderV2Copy.readerRevision},
);

List<WesternReaderSection> _westernSections(String wording) => [
  WesternReaderSection(
    id: 'work',
    title: 'งาน',
    body: '$wording งาน',
    basis: 'ดาวพุธ',
  ),
  WesternReaderSection(
    id: 'money',
    title: 'เงิน',
    body: '$wording เงิน',
    basis: 'ดาวศุกร์',
  ),
  WesternReaderSection(
    id: 'love',
    title: 'รัก',
    body: '$wording รัก',
    basis: 'ดาวศุกร์',
  ),
  WesternReaderSection(
    id: 'wellbeing',
    title: 'พลังใจ',
    body: '$wording พลังใจ',
    basis: 'ดวงจันทร์',
  ),
];

BaziChartModel _unknownGender(BaziChartModel base) => BaziChartModel(
  version: base.version,
  contractId: base.contractId,
  contractName: base.contractName,
  engineVersion: base.engineVersion,
  generatedAt: base.generatedAt,
  inputHash: base.inputHash,
  completeness: base.completeness,
  dayMaster: base.dayMaster,
  yearAnimal: base.yearAnimal,
  dominantElement: base.dominantElement,
  pillars: base.pillars,
  elementBalance: base.elementBalance,
  timeKnown: base.timeKnown,
  enginePolicy: base.enginePolicy,
  input: base.input,
  solarTime: base.solarTime,
  ambiguities: base.ambiguities,
  suppressedFields: base.suppressedFields,
  tenGodBalance: base.tenGodBalance,
  dayMasterSupport: base.dayMasterSupport,
  natalRelations: base.natalRelations,
  luck: BaziLuck(
    gender: '',
    direction: base.luck.direction,
    onset: base.luck.onset,
    cycles: base.luck.cycles,
    method: base.luck.method,
  ),
);

BaziReaderV2Reading _newChineseWording(BaziReaderV2Reading original) =>
    BaziReaderV2Reading(
      overview: original.overview,
      identity: original.identity,
      work: 'คำอ่านการงานเรียบเรียงใหม่',
      money: 'คำอ่านการเงินเรียบเรียงใหม่',
      relationships: 'คำอ่านความสัมพันธ์เรียบเรียงใหม่',
      balance: 'คำอ่านสมดุลเรียบเรียงใหม่',
      currentCycleTitle: original.currentCycleTitle,
      currentCycle: original.currentCycle,
      annualTitle: original.annualTitle,
      annual: original.annual,
    );

BaziChartModel _withGender(BaziChartModel base, String gender) =>
    _copyBazi(base, gender: gender);

BaziChartModel _withoutFamilyWeight(BaziChartModel base, String family) =>
    _copyBazi(
      base,
      balance: BaziTenGodBalance(
        visible: base.tenGodBalance.visible,
        hidden: base.tenGodBalance.hidden,
        familyWeight: Map.of(base.tenGodBalance.familyWeight)..remove(family),
        topFamilies: base.tenGodBalance.topFamilies,
        method: base.tenGodBalance.method,
      ),
    );

BaziChartModel _withMoneyWeights(BaziChartModel base, int wealth, int peer) =>
    _copyBazi(
      base,
      balance: BaziTenGodBalance(
        visible: base.tenGodBalance.visible,
        hidden: base.tenGodBalance.hidden,
        familyWeight: {
          ...base.tenGodBalance.familyWeight,
          'wealth': wealth,
          'peer': peer,
        },
        topFamilies: base.tenGodBalance.topFamilies,
        method: base.tenGodBalance.method,
      ),
    );

BaziChartModel _copyBazi(
  BaziChartModel base, {
  String? gender,
  BaziTenGodBalance? balance,
  BaziDayMasterSupport? support,
}) => BaziChartModel(
  version: base.version,
  contractId: base.contractId,
  contractName: base.contractName,
  engineVersion: base.engineVersion,
  generatedAt: base.generatedAt,
  inputHash: base.inputHash,
  completeness: base.completeness,
  dayMaster: base.dayMaster,
  yearAnimal: base.yearAnimal,
  dominantElement: base.dominantElement,
  pillars: base.pillars,
  elementBalance: base.elementBalance,
  timeKnown: base.timeKnown,
  enginePolicy: base.enginePolicy,
  input: base.input,
  solarTime: base.solarTime,
  ambiguities: base.ambiguities,
  suppressedFields: base.suppressedFields,
  tenGodBalance: balance ?? base.tenGodBalance,
  dayMasterSupport: support ?? base.dayMasterSupport,
  natalRelations: base.natalRelations,
  luck: BaziLuck(
    gender: gender ?? base.luck.gender,
    direction: base.luck.direction,
    onset: base.luck.onset,
    cycles: base.luck.cycles,
    method: base.luck.method,
  ),
);
