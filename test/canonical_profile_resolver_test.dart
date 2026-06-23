import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';

void main() {
  group('CanonicalProfileResolver.profileFromLegacyRoot', () {
    test('normalizes ISO birthDate to storage format', () {
      final profile = CanonicalProfileResolver.profileFromLegacyRoot({
        'name': 'Legacy User',
        'gender': 'female',
        'birthDate': '1990-05-12T00:00:00.000',
        'birthTime': '15:30',
        'birthPlace': 'Bangkok',
        'latitude': 13.7563,
        'longitude': 100.5018,
      });

      expect(profile.birthDate, '1990-05-12');
      expect(BirthProfileReadiness.isComplete(profile), isTrue);
    });
  });

  group('CanonicalProfileResolver.explorationInput', () {
    test('uses BirthProfileReadiness for completeness', () {
      const incomplete = ProfileModel(
        name: 'A',
        gender: 'male',
        birthDate: 'not-a-date',
        birthTime: '12:00',
        birthPlace: 'Bangkok',
        latitude: 13.0,
        longitude: 100.0,
        timezone: 'Asia/Bangkok',
      );

      final input = CanonicalProfileResolver.explorationInput(incomplete);
      expect(input.hasBirthDate, isTrue);
      expect(input.isBirthProfileComplete, isFalse);
    });

    test('marks complete profile as birth ready', () {
      final complete = CanonicalProfileResolver.profileFromLegacyRoot({
        'birthDate': BirthProfileFormat.storageDate(DateTime(1990, 5, 12)),
        'birthTime': '08:00',
        'birthPlace': 'Bangkok',
        'latitude': 13.7563,
        'longitude': 100.5018,
      });

      final input = CanonicalProfileResolver.explorationInput(complete);
      expect(input.isBirthProfileComplete, isTrue);
    });
  });
}
