import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_life_reading.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/astrology/fusion/presentation/western_natal_life_semantics.dart';
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

  test('Western sign registry covers every Reader V2 sign', () {
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
    for (final sign in signs) {
      final chart = _westernChart(mercurySign: sign, venusSign: sign);
      expect(WesternNatalLifeSemantics.workMethod(chart), isNotEmpty);
      expect(WesternNatalLifeSemantics.moneyValue(chart), isNotEmpty);
      expect(WesternNatalLifeSemantics.relationshipStyle(chart), isNotEmpty);
      expect(WesternNatalLifeSemantics.recoveryAction(chart), isNotEmpty);
    }
  });

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
      expect(topic.reading, contains(opening));
      expect(result.gaps, isEmpty);
    }
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
}

ThaiBirthProfileCoreReading _thaiCore(String wording, {int? omitHouse}) {
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
                    rawValue: lord,
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
}) => AstrologyChartModel(
  version: WesternReaderV2Copy.chartVersion,
  contractId: WesternReaderV2Copy.contractId,
  engineVersion: 'fixture',
  inputHash: 'fixture',
  big3: {if (withMoon) 'moon': venusSign},
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

BaziChartModel _copyBazi(
  BaziChartModel base, {
  String? gender,
  BaziTenGodBalance? balance,
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
  dayMasterSupport: base.dayMasterSupport,
  natalRelations: base.natalRelations,
  luck: BaziLuck(
    gender: gender ?? base.luck.gender,
    direction: base.luck.direction,
    onset: base.luck.onset,
    cycles: base.luck.cycles,
    method: base.luck.method,
  ),
);
