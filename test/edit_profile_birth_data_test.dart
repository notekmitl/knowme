import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/domain/models/profile_model.dart';

bool birthDataChanged(ProfileModel before, ProfileModel after) {
  return before.birthDate != after.birthDate ||
      before.birthTime != after.birthTime ||
      before.birthPlace != after.birthPlace ||
      before.latitude != after.latitude ||
      before.longitude != after.longitude ||
      before.timezone != after.timezone;
}

ProfileModel _sample() {
  return const ProfileModel(
    name: 'Test',
    gender: 'male',
    birthDate: '1990-05-12T00:00:00.000',
    birthTime: '15:30',
    birthPlace: 'Bangkok',
    latitude: 13.7563,
    longitude: 100.5018,
    timezone: 'Asia/Bangkok',
  );
}

void main() {
  test('name-only change does not trigger birth data changed', () {
    final before = _sample();
    final after = ProfileModel(
      name: 'New Name',
      gender: before.gender,
      birthDate: before.birthDate,
      birthTime: before.birthTime,
      birthPlace: before.birthPlace,
      latitude: before.latitude,
      longitude: before.longitude,
      timezone: before.timezone,
    );
    expect(birthDataChanged(before, after), isFalse);
  });

  test('gender-only change does not trigger birth data changed', () {
    final before = _sample();
    final after = ProfileModel(
      name: before.name,
      gender: 'female',
      birthDate: before.birthDate,
      birthTime: before.birthTime,
      birthPlace: before.birthPlace,
      latitude: before.latitude,
      longitude: before.longitude,
      timezone: before.timezone,
    );
    expect(birthDataChanged(before, after), isFalse);
  });

  test('birthTime change triggers birth data changed', () {
    final before = _sample();
    final after = ProfileModel(
      name: before.name,
      gender: before.gender,
      birthDate: before.birthDate,
      birthTime: '09:00',
      birthPlace: before.birthPlace,
      latitude: before.latitude,
      longitude: before.longitude,
      timezone: before.timezone,
    );
    expect(birthDataChanged(before, after), isTrue);
  });

  test('birthPlace change triggers birth data changed', () {
    final before = _sample();
    final after = ProfileModel(
      name: before.name,
      gender: before.gender,
      birthDate: before.birthDate,
      birthTime: before.birthTime,
      birthPlace: 'Chiang Mai',
      latitude: before.latitude,
      longitude: before.longitude,
      timezone: before.timezone,
    );
    expect(birthDataChanged(before, after), isTrue);
  });
}
