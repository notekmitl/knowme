import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_profile_enrichment.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _birth({
  required DateTime local,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: local,
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

void main() {
  group('ThaiMirrorProfileEnrichment', () {
    test('injects myanmar and mahabhuta when foundation profile is empty', () {
      final birth = _birth(
        local: DateTime(1990, 6, 15),
        hasBirthTime: false,
      );
      final base = ThaiFoundationEngine.generate(birth);
      expect(base.myanmarKeys, isEmpty);
      expect(base.mahabhutaPositionKeys, isEmpty);

      final enriched = ThaiMirrorProfileEnrichment.enrich(
        profile: base,
        birthData: birth,
      );

      expect(enriched.myanmarKeys, isNotEmpty);
      expect(enriched.mahabhutaPositionKeys.length,
          ThaiMirrorProfileEnrichment.interimMahabhutaKeyCount);
      expect(enriched.myanmarKeys.length,
          ThaiMirrorProfileEnrichment.interimMyanmarKeyCount);
      expect(enriched.dominantMyanmarKey, isNotNull);
      expect(
        enriched.warnings.any((w) => w.code == 'MIRROR_DATE_ONLY_LENS_FALLBACK'),
        isTrue,
      );
    });

    test('does not override profile that already has lens keys', () {
      final profile = ThaiAstrologyProfile(
        lagnaKey: 'lagna_leo',
        lagnaLordKey: 'lagna_lord_sun',
        mahabhutaPositionKeys: const [ThaiContentKeys.mahabhutaRachiya],
        myanmarKeys: const [ThaiContentKeys.myanmarSeven1],
        dominantMyanmarKey: ThaiContentKeys.myanmarSeven1,
        hasBirthTime: true,
        calculationStandardVersion: 'v1',
        computedAt: DateTime.utc(2026, 1, 1),
      );

      final enriched = ThaiMirrorProfileEnrichment.enrich(
        profile: profile,
        birthData: _birth(local: DateTime(1990, 1, 1)),
      );

      expect(enriched.myanmarKeys, profile.myanmarKeys);
      expect(enriched.mahabhutaPositionKeys, profile.mahabhutaPositionKeys);
      expect(
        enriched.warnings.any((w) => w.code.contains('MIRROR_')),
        isFalse,
      );
    });

    test('weekday maps to expected dominant myanmar key', () {
      final sunday = _birth(local: DateTime(2024, 6, 9), hasBirthTime: false);
      final enriched = ThaiMirrorProfileEnrichment.enrich(
        profile: ThaiFoundationEngine.generate(sunday),
        birthData: sunday,
      );

      expect(enriched.dominantMyanmarKey, ThaiContentKeys.myanmarSeven1);
    });
  });
}
