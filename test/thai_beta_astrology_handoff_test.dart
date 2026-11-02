import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_astrology_handoff.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  group('Thai beta astrology handoff', () {
    test('maps known birth data into the canonical profile', () {
      final profile = ThaiBetaAstrologyHandoff.profileFromInput(_knownInput);

      expect(profile.name, 'เจ้าของ ดวง');
      expect(profile.gender, 'female');
      expect(profile.birthDate, '1990-05-12');
      expect(profile.birthTime, '00:35');
      expect(profile.birthPlace, 'เชียงใหม่');
      expect(profile.latitude, closeTo(18.7883, 0.0001));
      expect(profile.longitude, closeTo(98.9853, 0.0001));
      expect(profile.timezone, 'Asia/Bangkok');
    });

    test('preserves place, coordinates, timezone, and time for QA cities', () {
      final cases = [
        (
          place: 'กรุงเทพมหานคร',
          key: 'bangkok',
          date: DateTime(1990, 12, 5),
          hour: 15,
          minute: 30,
          latitude: 13.7563,
          longitude: 100.5018,
        ),
        (
          place: 'เชียงใหม่',
          key: 'chiang mai',
          date: DateTime(1982, 6, 6),
          hour: 0,
          minute: 35,
          latitude: 18.7883,
          longitude: 98.9853,
        ),
        (
          place: 'ภูเก็ต',
          key: 'phuket',
          date: DateTime(2001, 3, 3),
          hour: 23,
          minute: 45,
          latitude: 7.8804,
          longitude: 98.3923,
        ),
      ];

      for (final fixture in cases) {
        final profile = ThaiBetaAstrologyHandoff.profileFromInput(
          ThaiBetaInput(
            firstName: 'Owner',
            lastName: 'QA',
            birthDate: fixture.date,
            birthHour: fixture.hour,
            birthMinute: fixture.minute,
            province: fixture.place,
            provinceKey: fixture.key,
            gender: 'ชาย',
          ),
        );

        expect(profile.birthPlace, fixture.place, reason: fixture.key);
        expect(profile.latitude, fixture.latitude, reason: fixture.key);
        expect(profile.longitude, fixture.longitude, reason: fixture.key);
        expect(profile.timezone, 'Asia/Bangkok', reason: fixture.key);
        expect(
          profile.birthTime,
          '${fixture.hour.toString().padLeft(2, '0')}:'
          '${fixture.minute.toString().padLeft(2, '0')}',
          reason: fixture.key,
        );
      }
    });

    test('Unknown time stays empty and never persists noon sentinel', () {
      final profile = ThaiBetaAstrologyHandoff.profileFromInput(_unknownInput);

      expect(profile.birthTime, isEmpty);
      expect(profile.toMap().values, isNot(contains('12:00')));
    });

    test(
      'anonymous overall handoff uses only normalized calculation input',
      () async {
        final calls = <String>[];
        final baziChart = BaziCompatibilityOwnerFixtures.chart(
          BaziOwnerCase.known,
        );
        final handoff = ThaiBetaAstrologyHandoff(
          calculateBazi: (profile) async {
            calls.add('bazi');
            expect(profile.birthTime, '00:35');
            expect(profile.timezone, 'Asia/Bangkok');
            return baziChart;
          },
          calculateWestern: (profile) async {
            calls.add('western');
            expect(profile.latitude, closeTo(18.7883, 0.0001));
            return _westernChart;
          },
        );
        final bazi = await handoff.prepareAnonymous(
          input: _knownInput,
          systemId: 'bazi',
        );
        final western = await handoff.prepareAnonymous(
          input: _knownInput,
          systemId: 'western',
        );
        expect(calls, ['bazi', 'western']);
        expect(bazi.baziChart, same(baziChart));
        expect(western.westernChart, same(_westernChart));
        await expectLater(
          handoff.prepareAnonymous(input: _unknownInput, systemId: 'western'),
          throwsStateError,
        );
      },
    );

    test(
      'delegates BaZi profile persistence to the authenticated API',
      () async {
        final events = <String>[];
        final chart = BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known);
        final handoff = ThaiBetaAstrologyHandoff(
          generateBazi: (uid, profile) async {
            events.add('generate:$uid:bazi');
            expect(profile.birthTime, isEmpty);
            return chart;
          },
        );

        final prepared = await handoff.prepare(
          userId: 'uid-1',
          input: _unknownInput,
          systemId: 'bazi',
        );

        expect(events, ['generate:uid-1:bazi']);
        expect(prepared.baziChart, same(chart));
        expect(prepared.westernChart, isNull);
      },
    );

    test('rejects Unknown-time Western before generation', () async {
      var generateCalls = 0;
      final handoff = ThaiBetaAstrologyHandoff(
        generateWestern: (_, _) async {
          generateCalls++;
          return _westernChart;
        },
      );

      await expectLater(
        handoff.prepare(
          userId: 'uid-1',
          input: _unknownInput,
          systemId: 'western',
        ),
        throwsStateError,
      );
      expect(generateCalls, 0);
    });

    test('returns Western API chart directly for the destination', () async {
      var generateCalls = 0;
      final handoff = ThaiBetaAstrologyHandoff(
        generateWestern: (uid, profile) async {
          generateCalls++;
          expect(uid, 'uid-1');
          expect(profile.birthTime, '00:35');
          expect(profile.timezone, 'Asia/Bangkok');
          return _westernChart;
        },
      );

      final prepared = await handoff.prepare(
        userId: 'uid-1',
        input: _knownInput,
        systemId: 'western',
      );

      expect(generateCalls, 1);
      expect(prepared.westernChart, same(_westernChart));
      expect(prepared.baziChart, isNull);
    });

    test('fails closed when selected BaZi generation fails', () async {
      final handoff = ThaiBetaAstrologyHandoff(
        generateBazi: (_, _) async => throw StateError('generation failed'),
      );

      await expectLater(
        handoff.prepare(userId: 'uid-1', input: _knownInput, systemId: 'bazi'),
        throwsStateError,
      );
    });
  });
}

final _knownInput = ThaiBetaInput(
  firstName: 'เจ้าของ',
  lastName: 'ดวง',
  birthDate: DateTime(1990, 5, 12),
  birthHour: 0,
  birthMinute: 35,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
  gender: 'หญิง',
);

final _westernChart = AstrologyChartModel(
  version: 'western_natal_v2',
  contractId: 'knowme_western_reader_v2',
  engineVersion: 'engine-v2',
  inputHash: 'hash',
  big3: const {'sun': 'Gemini', 'moon': 'Sagittarius', 'rising': 'Pisces'},
  planets: const {},
  insight: const {},
  overallSummary: const {},
  reader: const {'version': 'western_reader_th_v2_r2'},
);

final _unknownInput = ThaiBetaInput(
  firstName: 'เจ้าของ',
  lastName: 'ดวง',
  birthDate: DateTime(1990, 5, 12),
  birthTimeUnknown: true,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
);
