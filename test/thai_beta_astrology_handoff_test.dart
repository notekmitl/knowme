import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
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

    test('Unknown time stays empty and never persists noon sentinel', () {
      final profile = ThaiBetaAstrologyHandoff.profileFromInput(_unknownInput);

      expect(profile.birthTime, isEmpty);
      expect(profile.toMap().values, isNot(contains('12:00')));
    });

    test(
      'delegates BaZi profile persistence to the authenticated API',
      () async {
        final events = <String>[];
        var saveCalls = 0;
        final chart = BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known);
        final handoff = ThaiBetaAstrologyHandoff(
          saveProfile: (_, _) async => saveCalls++,
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
        expect(saveCalls, 0);
        expect(prepared, same(chart));
      },
    );

    test('rejects Unknown-time Western before saving profile', () async {
      var saveCalls = 0;
      final handoff = ThaiBetaAstrologyHandoff(
        saveProfile: (_, _) async {
          saveCalls++;
        },
        generateWestern: (_, _) async => true,
      );

      await expectLater(
        handoff.prepare(
          userId: 'uid-1',
          input: _unknownInput,
          systemId: 'western',
        ),
        throwsStateError,
      );
      expect(saveCalls, 0);
    });

    test('fails closed when selected BaZi generation fails', () async {
      final handoff = ThaiBetaAstrologyHandoff(
        saveProfile: (_, _) async {},
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

final _unknownInput = ThaiBetaInput(
  firstName: 'เจ้าของ',
  lastName: 'ดวง',
  birthDate: DateTime(1990, 5, 12),
  birthTimeUnknown: true,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
);
