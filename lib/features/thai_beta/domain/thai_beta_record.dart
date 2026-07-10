import 'thai_beta_engine_versions.dart';
import 'thai_beta_feedback.dart';
import 'thai_beta_input.dart';
import 'thai_beta_normalized_snapshot.dart';

/// One persisted Thai Beta submission (Firestore `thai_beta_feedback/{id}`).
///
/// Bundles Raw Input → Normalized Birth → Thai Report Snapshot → Engine Versions
/// → Feedback → CreatedAt. A few fields are promoted to the top level
/// ([rating], [thaiAstrologicalDate], [thaiFoundationVersion]) so the admin tool
/// can search/filter without reaching into nested maps.
class ThaiBetaRecord {
  const ThaiBetaRecord({
    required this.input,
    required this.normalizedBirth,
    required this.reportSnapshot,
    required this.reportHash,
    required this.engineVersions,
    required this.feedback,
    this.id,
    this.researchId,
    this.startedAt,
    this.submittedAt,
    this.durationSeconds,
    this.createdAt,
  });

  final String? id;

  /// Human-facing sequential reference, e.g. `TH-00000001`. Assigned by the
  /// store at save time; null on a not-yet-persisted record.
  final String? researchId;

  final ThaiBetaInput input;
  final ThaiBetaNormalizedSnapshot normalizedBirth;
  final Map<String, dynamic> reportSnapshot;

  /// SHA-256 fingerprint of [reportSnapshot] (see [ThaiBetaReportHash]).
  final String reportHash;

  final ThaiBetaEngineVersions engineVersions;
  final ThaiBetaFeedback feedback;

  /// When the research session began (form opened).
  final DateTime? startedAt;

  /// When the feedback was submitted.
  final DateTime? submittedAt;

  /// Whole-session duration ([submittedAt] − [startedAt]).
  final int? durationSeconds;

  final DateTime? createdAt;

  int get rating => feedback.overallRating;
  String get thaiAstrologicalDate => normalizedBirth.thaiAstrologicalDate;
  String get thaiFoundationVersion => engineVersions.thaiFoundationVersion;

  /// Serialized for write. `researchId`, `startedAt`, `submittedAt`,
  /// `durationSeconds` and `createdAt` are stamped by the store at save time,
  /// so they are intentionally omitted here.
  Map<String, dynamic> toMap() {
    return {
      'input': input.toMap(),
      'normalizedBirth': normalizedBirth.toMap(),
      'reportSnapshot': reportSnapshot,
      'reportHash': reportHash,
      'engineVersions': engineVersions.toMap(),
      'feedback': feedback.toMap(),
      // Promoted, denormalized fields for admin search/filter:
      'rating': rating,
      'thaiAstrologicalDate': thaiAstrologicalDate,
      'thaiFoundationVersion': thaiFoundationVersion,
    };
  }

  factory ThaiBetaRecord.fromMap(
    Map<String, dynamic> map, {
    String? id,
    DateTime? startedAt,
    DateTime? submittedAt,
    DateTime? createdAt,
  }) {
    return ThaiBetaRecord(
      id: id,
      researchId: map['researchId']?.toString(),
      input: ThaiBetaInput.fromMap(
        Map<String, dynamic>.from(map['input'] as Map? ?? const {}),
      ),
      normalizedBirth: ThaiBetaNormalizedSnapshot.fromMap(
        Map<String, dynamic>.from(map['normalizedBirth'] as Map? ?? const {}),
      ),
      reportSnapshot:
          Map<String, dynamic>.from(map['reportSnapshot'] as Map? ?? const {}),
      reportHash: (map['reportHash'] ?? '').toString(),
      engineVersions: ThaiBetaEngineVersions.fromMap(
        Map<String, dynamic>.from(map['engineVersions'] as Map? ?? const {}),
      ),
      feedback: ThaiBetaFeedback.fromMap(
        Map<String, dynamic>.from(map['feedback'] as Map? ?? const {}),
      ),
      startedAt: startedAt,
      submittedAt: submittedAt,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      createdAt: createdAt,
    );
  }
}
