import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';

void main() {
  group('BaZi symbolic reading V1', () {
    test('covers all ten Day Masters in Thai and English', () {
      expect(BaziSymbolicReadingEngine.supportedStems.length, 10);

      for (final stem in BaziSymbolicReadingEngine.supportedStems) {
        final thai = BaziSymbolicReadingEngine.profileFor(stem);
        final english = BaziSymbolicReadingEngine.profileFor(
          stem,
          languageCode: 'en',
        );

        expect(thai.stem, stem);
        expect(thai.name, isNotEmpty);
        expect(thai.symbol, isNotEmpty);
        expect(thai.overview, isNotEmpty);
        expect(thai.strengths, isNotEmpty);
        expect(thai.cautions, isNotEmpty);
        expect(thai.practices, isNotEmpty);
        expect(english.stem, stem);
        expect(english.name, isNotEmpty);
        expect(english.symbol, isNotEmpty);
        expect(english.overview, isNotEmpty);
      }
    });

    test('maps visible element counts into five Day Master relationships', () {
      final reading = BaziSymbolicReadingEngine.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
      );
      final counts = {
        for (final family in reading.relationships) family.id: family.count,
      };
      final elements = {
        for (final family in reading.relationships) family.id: family.element,
      };

      expect(counts, {
        'resource': 0,
        'peer': 3,
        'output': 2,
        'wealth': 3,
        'authority': 0,
      });
      expect(elements, {
        'resource': 'wood',
        'peer': 'fire',
        'output': 'earth',
        'wealth': 'metal',
        'authority': 'water',
      });
      expect(reading.hasChartEmphasis, isTrue);
      expect(reading.overview, contains('8 ช่อง'));
      expect(reading.natalAreas.map((area) => area.id), [
        'strengths',
        'work',
        'finance',
        'relationships',
        'cautions',
      ]);
      expect(
        reading.natalAreas.firstWhere((area) => area.id == 'work').reading,
        contains('รูปแบบงาน'),
      );
      expect(
        reading.natalAreas.firstWhere((area) => area.id == 'finance').reading,
        contains('จัดสรรเวลา งบ'),
      );
      expect(
        reading.natalAreas
            .firstWhere((area) => area.id == 'relationships')
            .reading,
        contains('รูปแบบปฏิสัมพันธ์'),
      );
    });

    test('maps the five relationship cycles for every Day Master element', () {
      const cases = <String, (String, Map<String, String>)>{
        'wood': (
          '甲',
          {
            'resource': 'water',
            'peer': 'wood',
            'output': 'fire',
            'wealth': 'earth',
            'authority': 'metal',
          },
        ),
        'fire': (
          '丙',
          {
            'resource': 'wood',
            'peer': 'fire',
            'output': 'earth',
            'wealth': 'metal',
            'authority': 'water',
          },
        ),
        'earth': (
          '戊',
          {
            'resource': 'fire',
            'peer': 'earth',
            'output': 'metal',
            'wealth': 'water',
            'authority': 'wood',
          },
        ),
        'metal': (
          '庚',
          {
            'resource': 'earth',
            'peer': 'metal',
            'output': 'water',
            'wealth': 'wood',
            'authority': 'fire',
          },
        ),
        'water': (
          '壬',
          {
            'resource': 'metal',
            'peer': 'water',
            'output': 'wood',
            'wealth': 'fire',
            'authority': 'earth',
          },
        ),
      };

      for (final entry in cases.entries) {
        final (stem, expected) = entry.value;
        final reading = BaziSymbolicReadingEngine.build(
          _chartFor(stem: stem, element: entry.key),
        );
        expect(
          {
            for (final family in reading.relationships)
              family.id: family.element,
          },
          expected,
          reason: entry.key,
        );
      }
    });

    test('Unknown time excludes Hour contribution', () {
      final reading = BaziSymbolicReadingEngine.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.unknown),
      );
      final counts = {
        for (final family in reading.relationships) family.id: family.count,
      };

      expect(counts, {
        'resource': 0,
        'peer': 3,
        'output': 1,
        'wealth': 2,
        'authority': 0,
      });
      expect(reading.coverageNote, contains('ไม่รวมบทบาทจากเสาชั่วโมง'));
      expect(reading.overview, contains('6 ช่อง'));
      expect(reading.natalAreas, hasLength(5));
      expect(
        reading.natalAreas.map((area) => area.evidence).join('\n'),
        isNot(contains('เสาชั่วโมง')),
      );
    });

    test('boundary-partial Unknown does not claim a chart-wide emphasis', () {
      for (final ownerCase in [
        BaziOwnerCase.lichunUnknown,
        BaziOwnerCase.jieUnknown,
      ]) {
        final reading = BaziSymbolicReadingEngine.build(
          BaziCompatibilityOwnerFixtures.chart(ownerCase),
        );

        expect(reading.hasChartEmphasis, isFalse, reason: ownerCase.id);
        expect(reading.relationships, isEmpty, reason: ownerCase.id);
        expect(reading.natalAreas, isEmpty, reason: ownerCase.id);
        expect(
          reading.overview,
          contains('ไม่พอสำหรับสรุปภาพรวมของดวง'),
          reason: ownerCase.id,
        );
      }
    });

    test('catalog does not promise events or domain outcomes', () {
      final profileText = BaziSymbolicReadingEngine.supportedStems
          .map((stem) => BaziSymbolicReadingEngine.profileFor(stem))
          .expand(
            (profile) => [
              profile.overview,
              ...profile.strengths,
              ...profile.cautions,
              ...profile.practices,
            ],
          )
          .join('\n');
      final reading = BaziSymbolicReadingEngine.build(
        BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
      );
      final text = [
        profileText,
        ...reading.natalAreas.expand(
          (area) => [area.title, area.reading, area.evidence],
        ),
      ].join('\n');

      for (final forbidden in [
        'คุณจะรวย',
        'จะเกิดเหตุ',
        'เนื้อคู่',
        'โรคประจำตัว',
        'รับประกัน',
      ]) {
        expect(text, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

BaziChartModel _chartFor({required String stem, required String element}) {
  final base = BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known);
  return BaziChartModel(
    version: base.version,
    contractId: base.contractId,
    contractName: base.contractName,
    engineVersion: base.engineVersion,
    generatedAt: base.generatedAt,
    inputHash: base.inputHash,
    completeness: base.completeness,
    dayMaster: BaziDayMaster(
      stem: stem,
      stemRoman: '',
      element: element,
      polarity: 'yang',
      pillarLabel: '$stem子',
    ),
    yearAnimal: base.yearAnimal,
    dominantElement: base.dominantElement,
    pillars: base.pillars,
    elementBalance: const BaziElementBalance(
      wood: 1,
      fire: 2,
      earth: 3,
      metal: 4,
      water: 5,
      totalSlots: 15,
      method: 'relationship-mapping-test',
    ),
    timeKnown: true,
    enginePolicy: base.enginePolicy,
    input: base.input,
    ambiguities: base.ambiguities,
    suppressedFields: base.suppressedFields,
  );
}
