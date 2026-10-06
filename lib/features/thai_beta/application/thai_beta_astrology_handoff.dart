import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/services/bazi_api_service.dart';
import 'package:knowme/services/astrology_api_service.dart';

typedef ThaiBetaBaziGenerator =
    Future<BaziChartModel> Function(String userId, ProfileModel profile);
typedef ThaiBetaWesternGenerator =
    Future<AstrologyChartModel> Function(String userId, ProfileModel profile);
typedef ThaiBetaBaziCalculator =
    Future<BaziChartModel> Function(ProfileModel profile);
typedef ThaiBetaWesternCalculator =
    Future<AstrologyChartModel> Function(ProfileModel profile);

class ThaiBetaPreparedAstrology {
  const ThaiBetaPreparedAstrology._({this.baziChart, this.westernChart});

  factory ThaiBetaPreparedAstrology.bazi(BaziChartModel chart) =>
      ThaiBetaPreparedAstrology._(baziChart: chart);

  factory ThaiBetaPreparedAstrology.western(AstrologyChartModel chart) =>
      ThaiBetaPreparedAstrology._(westernChart: chart);

  final BaziChartModel? baziChart;
  final AstrologyChartModel? westernChart;
}

/// Converts the anonymous Thai-beta form into the canonical signed-in profile
/// used by the Chinese and Western engines, then generates only the selected
/// system.
///
/// Unknown time stays empty in the stored profile. The noon value used inside
/// birth normalization for Thai day resolution is never persisted or sent to
/// BaZi.
class ThaiBetaAstrologyHandoff {
  ThaiBetaAstrologyHandoff({
    ThaiBetaBaziGenerator? generateBazi,
    ThaiBetaWesternGenerator? generateWestern,
    ThaiBetaBaziCalculator? calculateBazi,
    ThaiBetaWesternCalculator? calculateWestern,
  }) : _generateBazi = generateBazi ?? _generateBaziOnly,
       _generateWestern = generateWestern ?? _generateWesternOnly,
       _calculateBazi = calculateBazi ?? _calculateBaziOnly,
       _calculateWestern = calculateWestern ?? _calculateWesternOnly;

  final ThaiBetaBaziGenerator _generateBazi;
  final ThaiBetaWesternGenerator _generateWestern;
  final ThaiBetaBaziCalculator _calculateBazi;
  final ThaiBetaWesternCalculator _calculateWestern;

  /// Overall reading calculates from birth data without a Firebase account or
  /// a profile/chart write. Only the existing single-system path persists.
  Future<ThaiBetaPreparedAstrology> prepareAnonymous({
    required ThaiBetaInput input,
    required String systemId,
  }) async {
    if (systemId != 'bazi' && systemId != 'western') {
      throw ArgumentError.value(systemId, 'systemId', 'Unsupported system');
    }
    if (systemId == 'western' &&
        (!input.hasBirthTime || (input.provinceKey?.trim().isEmpty ?? true))) {
      throw StateError(
        'Western astrology requires a known birth time and province',
      );
    }
    final profile = profileFromInput(input);
    return systemId == 'bazi'
        ? ThaiBetaPreparedAstrology.bazi(await _calculateBazi(profile))
        : ThaiBetaPreparedAstrology.western(await _calculateWestern(profile));
  }

  Future<ThaiBetaPreparedAstrology> prepare({
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
      return ThaiBetaPreparedAstrology.bazi(await _generateBazi(uid, profile));
    }

    // Western V2 uses the same authenticated atomic path as BaZi: profile,
    // chart, Fusion snapshot, and invalidation commit together on the server.
    return ThaiBetaPreparedAstrology.western(
      await _generateWestern(uid, profile),
    );
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

  static Future<BaziChartModel> _calculateBaziOnly(ProfileModel profile) {
    return BaziApiService.calculateBazi(
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim().isEmpty
          ? null
          : profile.birthTime.trim(),
      timezone: profile.timezone,
      gender: profile.gender,
      latitude: profile.latitude,
      longitude: profile.longitude,
    );
  }

  static Future<AstrologyChartModel> _calculateWesternOnly(
    ProfileModel profile,
  ) {
    return AstrologyApiService.calculateChart(
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim(),
      timezone: profile.timezone,
      latitude: profile.latitude,
      longitude: profile.longitude,
    );
  }

  static Future<AstrologyChartModel> _generateWesternOnly(
    String userId,
    ProfileModel profile,
  ) async {
    return AstrologyApiService.generateChart(
      uid: userId,
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim(),
      timezone: profile.timezone.isNotEmpty ? profile.timezone : 'Asia/Bangkok',
      latitude: profile.latitude,
      longitude: profile.longitude,
      canonicalProfile: profile.toMap(),
    );
  }
}
