import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_dashboard.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_engine_versions.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_feedback.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_normalized_snapshot.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_perceived_method.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_record.dart';

ThaiBetaNormalizedSnapshot _snapshot() => const ThaiBetaNormalizedSnapshot(
      rawBirthDate: '1990-05-20',
      birthTime: '08:30',
      province: 'กรุงเทพมหานคร',
      sunrise: '05:55',
      sunriseAvailable: true,
      thaiAstrologicalDate: '1990-05-20',
      usedPreviousDay: false,
      timeZoneId: 'Asia/Bangkok',
      utcOffsetHours: 7,
      latitude: 13.7563,
      longitude: 100.5018,
      locationSource: 'resolvedFromProvince',
      reasons: [],
    );

ThaiBetaRecord _record({
  required int rating,
  String mostAccurate = '',
  String leastAccurate = '',
  String wantMore = '',
}) {
  return ThaiBetaRecord(
    input: ThaiBetaInput(
      firstName: 'A',
      lastName: 'B',
      birthDate: DateTime(1990, 5, 20),
    ),
    normalizedBirth: _snapshot(),
    reportSnapshot: const {},
    reportHash: 'hash',
    engineVersions: const ThaiBetaEngineVersions(
      thaiFoundationVersion: 'v1.1',
      birthNormalizationVersion: 'birth-normalization-v1',
      betaSchemaVersion: 'thai-beta-v1',
    ),
    feedback: ThaiBetaFeedback(
      overallRating: rating,
      mostAccurate: mostAccurate,
      leastAccurate: leastAccurate,
      wantMoreAnalysis: wantMore,
      recommendReason: '',
      perceivedMethod: ThaiBetaPerceivedMethod.birthDate,
      consentGiven: true,
    ),
  );
}

void main() {
  group('ThaiBetaAnalysisRunner', () {
    test('produces the existing Thai report for a complete birth input', () {
      final analysis = ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'สมชาย',
          lastName: 'ใจดี',
          birthDate: DateTime(1990, 5, 20),
          birthHour: 8,
          birthMinute: 30,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
      );

      expect(analysis.isSuccess, isTrue);
      expect(analysis.consumerViewState, isNotNull);
      expect(analysis.profile, isNotNull);
      expect(analysis.normalizedSnapshot!.thaiAstrologicalDate, isNotEmpty);
      expect(analysis.normalizedSnapshot!.hasBirthTime, isTrue);
      expect(analysis.reportSnapshot, isNotNull);
      expect(analysis.reportSnapshot!['report'], isA<Map>());
      expect(analysis.reportHash, isNotNull);
      expect(analysis.reportHash!.length, 64); // sha256 hex
      expect(analysis.engineVersions!.betaSchemaVersion,
          ThaiBetaEngineVersions.currentBetaSchemaVersion);
    });

    test('handles unknown birth time and still analyzes', () {
      final analysis = ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'นภา',
          lastName: 'ทองดี',
          birthDate: DateTime(1995, 1, 1),
          birthTimeUnknown: true,
        ),
      );

      expect(analysis.isSuccess, isTrue);
      expect(analysis.normalizedSnapshot!.hasBirthTime, isFalse);
      expect(analysis.profile!.hasBirthTime, isFalse);
    });

    test('record round-trips through map serialization', () {
      final record = _record(rating: 4, mostAccurate: 'การงาน');
      final restored = ThaiBetaRecord.fromMap(record.toMap());
      expect(restored.rating, 4);
      expect(restored.thaiAstrologicalDate, '1990-05-20');
      expect(restored.thaiFoundationVersion, 'v1.1');
      expect(restored.feedback.mostAccurate, 'การงาน');
    });
  });

  group('ThaiBetaDashboard', () {
    test('aggregates totals, average and rating distribution', () {
      final records = [
        _record(rating: 5, mostAccurate: 'การงาน ตรงมาก'),
        _record(rating: 4, mostAccurate: 'การงาน และความรัก'),
        _record(rating: 2, leastAccurate: 'การเงิน ไม่ตรง'),
      ];

      final dashboard = ThaiBetaDashboard.fromRecords(records);

      expect(dashboard.total, 3);
      expect(dashboard.averageRating, closeTo((5 + 4 + 2) / 3, 0.001));
      expect(dashboard.ratingDistribution[5], 1);
      expect(dashboard.ratingDistribution[4], 1);
      expect(dashboard.ratingDistribution[2], 1);
      expect(dashboard.ratingDistribution[1], 0);

      // "การงาน" appears in two accurate fields → should be the top term.
      expect(dashboard.mostAccurateTopics.first.term, 'การงาน');
      expect(dashboard.mostAccurateTopics.first.count, 2);
      expect(dashboard.mostCommonComplaints
          .any((t) => t.term == 'การเงิน'), isTrue);
    });

    test('empty records yield zeroed dashboard', () {
      final dashboard = ThaiBetaDashboard.fromRecords(const []);
      expect(dashboard.total, 0);
      expect(dashboard.averageRating, 0);
      expect(dashboard.mostAccurateTopics, isEmpty);
    });
  });
}
