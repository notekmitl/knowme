import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_profiles.dart';

/// Deterministic birth fixtures for Canon evidence alignment QA.
///
/// No random data, no current-date dependency, no Firestore/network.
class ThaiCanonEvidenceAlignmentFixture {
  const ThaiCanonEvidenceAlignmentFixture({
    required this.id,
    required this.label,
    required this.birthData,
    this.weekdayNote,
  });

  final String id;
  final String label;
  final ThaiBirthData birthData;

  /// Human-readable weekday / harness note when applicable.
  final String? weekdayNote;

  String get birthSummary {
    final dt = birthData.localDateTime;
    final time = birthData.hasBirthTime
        ? '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}'
        : 'no birth time';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} $time ICT · '
        '${birthData.latitude},${birthData.longitude}';
  }
}

/// Canonical fixture set for alignment audits.
abstract final class ThaiCanonEvidenceAlignmentFixtures {
  static ThaiCanonEvidenceAlignmentFixture get qaSample =>
      ThaiCanonEvidenceAlignmentFixture(
        id: 'qa_sample',
        label: 'Existing QA sample birth (Bangkok 1972-04-04)',
        birthData: ThaiMirrorPipeline.sampleQaBirthData(),
        weekdayNote: 'Tuesday (civil) · harness baseline',
      );

  static List<ThaiCanonEvidenceAlignmentFixture> get all {
    return [
      qaSample,
      ...ThaiQaHarnessProfiles.all.map(_fromHarness),
    ];
  }

  static ThaiCanonEvidenceAlignmentFixture byId(String id) {
    return all.firstWhere(
      (f) => f.id == id,
      orElse: () => qaSample,
    );
  }

  static ThaiCanonEvidenceAlignmentFixture _fromHarness(
    ThaiQaHarnessProfile profile,
  ) {
    return ThaiCanonEvidenceAlignmentFixture(
      id: 'harness_${profile.id.toLowerCase()}',
      label: profile.label,
      birthData: profile.birthData,
      weekdayNote: profile.label.split('·').first.trim(),
    );
  }
}
