import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_profiles.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_report.dart';

const _noBirthTimeIds = {'QA-05', 'QA-06', 'QA-15', 'QA-16'};

class _ProfileQuality {
  const _ProfileQuality({
    required this.profileId,
    required this.themeQuality,
    required this.narrativeQuality,
    required this.sectionQuality,
    required this.evidenceQuality,
    required this.readability,
  });

  final String profileId;
  final double themeQuality;
  final double narrativeQuality;
  final double sectionQuality;
  final double evidenceQuality;
  final double readability;

  double get overall =>
      (themeQuality +
          narrativeQuality +
          sectionQuality +
          evidenceQuality +
          readability) /
      5;
}

_ProfileQuality _scoreProfile(String profileId) {
  final profile = ThaiMirrorQaProfiles.byId(profileId);
  final result = ThaiMirrorPipeline.generate(profile.birthData);
  expect(result.isSuccess, isTrue, reason: profileId);

  final mirror = result.mirrorResult!;
  final viewState = result.viewState!;

  final topThemes = mirror.topThemes.length;
  final evidenceCount = viewState.evidenceExplorer.totalEvidenceCount;
  final lensTypes = viewState.evidenceExplorer.rows
      .map((row) => row.lensSource)
      .toSet();
  final nonLagnaEvidence = viewState.evidenceExplorer.rows
      .where(
        (row) =>
            row.lensSource == ThaiMirrorLensSource.myanmarSeven ||
            row.lensSource == ThaiMirrorLensSource.mahabhutaPosition,
      )
      .length;

  final summaries =
      mirror.sections.map((section) => section.summary ?? '').toList();
  final uniqueSummaries = summaries.toSet().length;
  final englishLeakage = summaries.where(_hasEnglishSentence).length;
  final typographyIssues =
      summaries.where((s) => RegExp(r'ธีม[A-Za-z]').hasMatch(s)).length;
  final lagnaCopyRepeats = summaries
      .where((s) => s.contains('ลัคนา') && s.contains('มักสะท้อน'))
      .length;

  final sectionsWithThemes = mirror.sections
      .where((section) => section.supportingThemes.isNotEmpty)
      .length;
  final sectionsWithEvidence =
      mirror.sections.where((section) => section.evidence.isNotEmpty).length;

  final themeQuality = _clampScore(
    (topThemes >= 3 ? 8.0 : topThemes * 2.5) +
        (nonLagnaEvidence > 0 ? 1.5 : 0),
  );

  final narrativeQuality = _clampScore(
    10 -
        englishLeakage * 2.5 -
        typographyIssues * 2 -
        (summaries.length - uniqueSummaries) * 1.5 -
        lagnaCopyRepeats * 1.2,
  );

  final sectionQuality = _clampScore(
    sectionsWithThemes * 1.1 + sectionsWithEvidence * 0.15,
  );

  final evidenceQuality = _clampScore(
    evidenceCount >= 20
        ? 9.0
        : evidenceCount >= 10
            ? 7.5
            : evidenceCount >= 6
                ? 6.0
                : evidenceCount > 0
                    ? 4.5
                    : 1.0,
  );

  final readability = _clampScore(
    summaries.where((s) => s.length >= 40).length * 1.1 +
        (lensTypes.length >= 3 ? 2.0 : lensTypes.length.toDouble()),
  );

  return _ProfileQuality(
    profileId: profileId,
    themeQuality: themeQuality,
    narrativeQuality: narrativeQuality,
    sectionQuality: sectionQuality,
    evidenceQuality: evidenceQuality,
    readability: readability,
  );
}

double _clampScore(double value) => value.clamp(1.0, 10.0);

bool _hasEnglishSentence(String text) {
  final latinWords = RegExp(r'\b[A-Za-z]{4,}\b').allMatches(text);
  for (final match in latinWords) {
    final word = match.group(0)!;
    if (_allowedLatinTokens.contains(word)) continue;
    if (word == 'Tends' || word == 'despite' || word == 'obstacles') {
      return true;
    }
    final thai = RegExp(r'[\u0E00-\u0E7F]').allMatches(text).length;
    final latin = RegExp(r'[A-Za-z]').allMatches(text).length;
    if (latin > thai) return true;
  }
  return false;
}

const _allowedLatinTokens = {
  'Ambitious',
  'Leadership',
  'Creative',
  'Analytical',
  'Strategic',
  'Reflective',
  'Empathetic',
  'Independent',
  'Practical',
  'Idealistic',
  'Resilient',
  'Curious',
  'Disciplined',
  'Adaptable',
  'Expressive',
  'Supportive',
  'Visionary',
  'Grounded',
  'Intuitive',
  'Driven',
};

void main() {
  group('Thai Mirror Quality Sprint V1', () {
    late List<_ProfileQuality> scores;

    setUpAll(() {
      scores = ThaiMirrorQaProfiles.all
          .map((profile) => _scoreProfile(profile.id))
          .toList();
    });

    test('all 22 QA profiles run successfully', () {
      expect(scores, hasLength(22));
    });

    test('no birth time profiles produce themes and evidence', () {
      for (final id in _noBirthTimeIds) {
        final report = ThaiMirrorQaReport.generate(ThaiMirrorQaProfiles.byId(id));
        expect(report.pipelineSucceeded, isTrue, reason: id);
        expect(report.topThemes, isNotEmpty, reason: id);
        expect(report.evidenceCount, greaterThan(0), reason: id);
        expect(report.status, isNot(ThaiMirrorQaStatus.fail), reason: id);
      }
    });

    test('overall quality target >= 7.5', () {
      final overall =
          scores.map((score) => score.overall).reduce((a, b) => a + b) /
              scores.length;
      expect(overall, greaterThanOrEqualTo(7.5));
    });

    test('no birth time average >= 5.0', () {
      final noBirth = scores
          .where((score) => _noBirthTimeIds.contains(score.profileId))
          .map((score) => score.overall)
          .reduce((a, b) => a + b);
      expect(noBirth / _noBirthTimeIds.length, greaterThanOrEqualTo(5.0));
    });

    test('section differentiation >= 7.0', () {
      final avgSection = scores
              .map((score) => score.sectionQuality)
              .reduce((a, b) => a + b) /
          scores.length;
      expect(avgSection, greaterThanOrEqualTo(7.0));
    });

    test('narrative quality >= 7.0', () {
      final avgNarrative = scores
              .map((score) => score.narrativeQuality)
              .reduce((a, b) => a + b) /
          scores.length;
      expect(avgNarrative, greaterThanOrEqualTo(7.0));
    });

    test('theme typography uses space after ธีม', () {
      for (final profile in ThaiMirrorQaProfiles.all) {
        final result = ThaiMirrorPipeline.generate(profile.birthData);
        final summaries = result.mirrorResult!.sections
            .map((section) => section.summary ?? '')
            .join(' ');
        expect(RegExp(r'ธีม[A-Za-z]').hasMatch(summaries), isFalse,
            reason: profile.id);
      }
    });

    test('strengths section avoids English leakage sentences', () {
      for (final profile in ThaiMirrorQaProfiles.all) {
        final result = ThaiMirrorPipeline.generate(profile.birthData);
        final strengths = result.mirrorResult!.sections
            .firstWhere((s) => s.id == ThaiMirrorSectionId.strengths)
            .summary!;
        expect(strengths.contains('despite obstacles'), isFalse,
            reason: profile.id);
        expect(strengths.contains('keep going'), isFalse, reason: profile.id);
        expect(strengths.toLowerCase().contains('tends to'), isFalse,
            reason: profile.id);
      }
    });
  });
}
