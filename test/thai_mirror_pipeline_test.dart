import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

void main() {
  group('ThaiMirrorPipeline', () {
    test('full pipeline produces success result', () {
      final result = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.viewState, isA<ThaiMirrorViewState>());
      expect(result.profile, isA<ThaiAstrologyProfile>());
      expect(result.mirrorResult, isA<ThaiMirrorResult>());
      expect(result.generatedAt, isNotNull);
      expect(result.errorMessage, isNull);
    });

    test('missing birth time still renders pipeline output', () {
      final result = ThaiMirrorPipeline.generate(
        _bangkokBirth(
          year: 1990,
          month: 6,
          day: 15,
          hasBirthTime: false,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.profile!.hasBirthTime, isFalse);
      expect(result.profile!.warnings, isNotEmpty);
      expect(result.viewState!.profileContext.hasBirthTime, isFalse);
      expect(result.viewState!.profileContext.hasWarnings, isTrue);
      expect(result.mirrorResult!.narrativeStatus,
          ThaiMirrorNarrativeStatus.complete);
      expect(result.mirrorResult!.topThemes, isNotEmpty);
      expect(result.viewState!.evidenceExplorer.totalEvidenceCount,
          greaterThan(0));
      expect(result.profile!.myanmarKeys, isNotEmpty);
      expect(result.profile!.mahabhutaPositionKeys, isNotEmpty);
    });

    test('partial profile without lagna still succeeds', () {
      final result = ThaiMirrorPipeline.generate(
        _bangkokBirth(
          year: 1985,
          month: 1,
          day: 10,
          hasBirthTime: false,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.profile!.lagnaKey, isNull);
      expect(result.profile!.lagnaLordKey, isNull);
      expect(result.mirrorResult!.sections, hasLength(8));
      expect(result.viewState!.sections, hasLength(8));
    });

    test('view state is generated from mirror result', () {
      final result = ThaiMirrorPipeline.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      expect(result.isSuccess, isTrue);
      expect(result.viewState!.hero.titleTh, isNotEmpty);
      expect(result.viewState!.sections, hasLength(8));
      expect(result.viewState!.evidenceExplorer.totalEvidenceCount,
          greaterThan(0));
      expect(result.viewState!.narrativeStatus,
          ThaiMirrorNarrativeStatus.complete);
    });

    test('mirror result is generated with narrative', () {
      final result = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );

      expect(result.isSuccess, isTrue);
      expect(result.mirrorResult!.contractVersion, 'v1');
      expect(result.mirrorResult!.topThemes.length, lessThanOrEqualTo(3));
      expect(result.mirrorResult!.hasNarrative, isTrue);
      expect(
        result.mirrorResult!.sections.any((section) => section.hasSummary),
        isTrue,
      );
    });

    test('pipeline result includes generatedAt timestamp', () {
      final before = DateTime.now().toUtc();
      final result = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final after = DateTime.now().toUtc();

      expect(result.isSuccess, isTrue);
      expect(
        result.generatedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        result.generatedAt!.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('generate does not throw for valid birth data', () {
      expect(
        () => ThaiMirrorPipeline.generate(ThaiMirrorPipeline.sampleQaBirthData()),
        returnsNormally,
      );

      final result = ThaiMirrorPipeline.generate(
        _bangkokBirth(year: 2000, month: 12, day: 31, hour: 23, minute: 59),
      );
      expect(result, isA<ThaiMirrorPipelineResult>());
    });

    test('failure result exposes error message without throwing', () {
      const failure = ThaiMirrorPipelineResult.failure(
        errorMessage: 'Thai Mirror pipeline failed: simulated',
      );

      expect(failure.isFailure, isTrue);
      expect(failure.isSuccess, isFalse);
      expect(failure.viewState, isNull);
      expect(failure.errorMessage, contains('simulated'));
    });

    test('deterministic theme output for same birth data', () {
      final birthData = _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2);

      final first = ThaiMirrorPipeline.generate(birthData);
      final second = ThaiMirrorPipeline.generate(birthData);

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);

      final firstThemeIds =
          first.mirrorResult!.topThemes.map((theme) => theme.themeId).toList();
      final secondThemeIds =
          second.mirrorResult!.topThemes.map((theme) => theme.themeId).toList();

      expect(firstThemeIds, secondThemeIds);
      expect(
        first.mirrorResult!.sections.length,
        second.mirrorResult!.sections.length,
      );
      expect(
        first.viewState!.topThemes.map((theme) => theme.themeId).toList(),
        second.viewState!.topThemes.map((theme) => theme.themeId).toList(),
      );
    });

    test('empty top themes state is handled when no themes resolve', () {
      final result = ThaiMirrorPipeline.generate(
        ThaiBirthData(
          localDateTime: DateTime(1900, 1, 1),
          timeZoneOffset: _bangkokOffset,
          latitude: 0,
          longitude: 0,
          hasBirthTime: false,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.viewState!.topThemes, isA<List>());
      expect(result.mirrorResult!.topThemes.length, lessThanOrEqualTo(3));
    });
  });
}
