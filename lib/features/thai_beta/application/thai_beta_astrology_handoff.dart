import 'package:firebase_auth/firebase_auth.dart';
import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/services/bazi_api_service.dart';
import 'package:knowme/services/profile_service.dart';

typedef ThaiBetaProfileSaver =
    Future<void> Function(String userId, ProfileModel profile);
typedef ThaiBetaBaziGenerator =
    Future<BaziChartModel> Function(String userId, ProfileModel profile);
typedef ThaiBetaWesternGenerator =
    Future<bool> Function(String userId, ProfileModel profile);

/// Converts the anonymous Thai-beta form into the canonical signed-in profile
/// used by the Chinese and Western engines, then generates only the selected
/// system.
///
/// Unknown time stays empty in the stored profile. The noon value used inside
/// birth normalization for Thai day resolution is never persisted or sent to
/// BaZi.
class ThaiBetaAstrologyHandoff {
  ThaiBetaAstrologyHandoff({
    ThaiBetaProfileSaver? saveProfile,
    ThaiBetaBaziGenerator? generateBazi,
    ThaiBetaWesternGenerator? generateWestern,
  }) : _saveProfile = saveProfile ?? _saveForAuthenticatedUser,
       _generateBazi = generateBazi ?? _generateBaziOnly,
       _generateWestern = generateWestern ?? _generateWesternOnly;

  final ThaiBetaProfileSaver _saveProfile;
  final ThaiBetaBaziGenerator _generateBazi;
  final ThaiBetaWesternGenerator _generateWestern;

  Future<BaziChartModel?> prepare({
    required String userId,
    required ThaiBetaInput input,
    required String systemId,
  }) async {
    final uid = userId.trim();
    if (uid.isEmpty) throw StateError('Authentication is required');
    if (systemId != 'bazi' && systemId != 'western') {
      throw ArgumentError.value(systemId, 'systemId', 'Unsupported system');
    }

    final profile = profileFromInput(input);
    if (systemId == 'western' &&
        (!input.hasBirthTime || (input.provinceKey?.trim().isEmpty ?? true))) {
      throw StateError(
        'Western astrology requires a known birth time and province',
      );
    }

    if (systemId == 'bazi') {
      // The authenticated endpoint persists this exact canonical profile,
      // chart, result snapshot, and Fusion invalidation in one server batch.
      return _generateBazi(uid, profile);
    }

    await _saveProfile(uid, profile);
    final ready = await _generateWestern(uid, profile);
    if (!ready) {
      throw StateError('Selected astrology result is not ready');
    }
    return null;
  }

  static ProfileModel profileFromInput(ThaiBetaInput input) {
    final normalized = BirthNormalizer.normalize(
      RawBirthInput(
        birthDate: input.birthDate,
        birthHour: input.hasBirthTime ? input.birthHour : null,
        birthMinute: input.hasBirthTime ? input.birthMinute : 0,
        province: input.provinceKey,
        placeLabel: input.province,
        country: 'thailand',
        timeZoneId: 'Asia/Bangkok',
      ),
    );
    final birth = normalized.birth;
    if (!normalized.isValid || birth == null) {
      throw StateError(normalized.error ?? 'Birth normalization failed');
    }

    final birthTime = input.hasBirthTime
        ? '${input.birthHour!.toString().padLeft(2, '0')}:'
              '${input.birthMinute.toString().padLeft(2, '0')}'
        : '';

    return ProfileModel(
      name: input.fullName,
      gender: _canonicalGender(input.gender),
      birthDate: BirthProfileFormat.storageDate(input.birthDate),
      birthTime: birthTime,
      birthPlace: input.province ?? '',
      latitude: birth.latitude,
      longitude: birth.longitude,
      timezone: birth.timeZone.id,
    );
  }

  static String _canonicalGender(String? value) {
    return switch (value?.trim()) {
      'ชาย' => 'male',
      'หญิง' => 'female',
      'อื่น ๆ' => 'other',
      _ => '',
    };
  }

  static Future<void> _saveForAuthenticatedUser(
    String userId,
    ProfileModel profile,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != userId) {
      throw StateError('Authenticated user does not match the profile owner');
    }
    await ProfileService().saveProfile(profile);
  }

  static Future<BaziChartModel> _generateBaziOnly(
    String userId,
    ProfileModel profile,
  ) async {
    return BaziApiService.generateBazi(
      uid: userId,
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim().isEmpty
          ? null
          : profile.birthTime.trim(),
      timezone: profile.timezone.isNotEmpty ? profile.timezone : 'Asia/Bangkok',
      gender: profile.gender,
      latitude: profile.latitude,
      longitude: profile.longitude,
      canonicalProfile: profile.toMap(),
    );
  }

  static Future<bool> _generateWesternOnly(
    String userId,
    ProfileModel profile,
  ) async {
    final snapshot = await AstrologyGenerationCoordinator().ensureGenerated(
      userId,
      retrySystemId: 'western',
      forceSystemId: 'western',
    );
    return snapshot.system('western').isReady;
  }
}
