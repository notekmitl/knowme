import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'thai_canon_evidence_repository.dart';
import 'thai_taksa_role_assignment.dart';

/// Feasibility classification for Taksa rotation model.
enum TaksaRotationFeasibilityResult {
  readyToImplementFullRotation,
  readyToImplementPartialRotation,
  readyToImplementTuesdayOnly,
  needsTaksaSourceForensics,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension TaksaRotationFeasibilityResultWire on TaksaRotationFeasibilityResult {
  String get wire => switch (this) {
        TaksaRotationFeasibilityResult.readyToImplementFullRotation =>
          'READY_TO_IMPLEMENT_FULL_ROTATION',
        TaksaRotationFeasibilityResult.readyToImplementPartialRotation =>
          'READY_TO_IMPLEMENT_PARTIAL_ROTATION',
        TaksaRotationFeasibilityResult.readyToImplementTuesdayOnly =>
          'READY_TO_IMPLEMENT_TUESDAY_ONLY',
        TaksaRotationFeasibilityResult.needsTaksaSourceForensics =>
          'NEEDS_TAKSA_SOURCE_FORENSICS',
        TaksaRotationFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        TaksaRotationFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker when Taksa rotation cannot be resolved for a profile weekday.
abstract final class TaksaRotationBlocker {
  static const unsupportedWeekday = 'TAKSA_ROTATION_UNSUPPORTED_WEEKDAY';
  static const sourceBlocked = 'TAKSA_ROTATION_SOURCE_BLOCKED';
  static const missingBirthWeekday = 'TAKSA_ROTATION_MISSING_BIRTH_WEEKDAY';
}

/// Thai birth weekday labels — exact Canon context tokens only.
abstract final class ThaiTaksaBirthWeekday {
  static const labelsByNumber = {
    1: 'อาทิตย์',
    2: 'จันทร์',
    3: 'อังคาร',
    4: 'พุธ',
    5: 'พฤหัส',
    6: 'ศุกร์',
    7: 'เสาร์',
  };

  /// Canon `context.value` for weekday-born rotation (e.g. `คนเกิดวันอังคาร`).
  static String? canonContextValueForWeekday(int weekdayNumber) {
    final label = labelsByNumber[weekdayNumber];
    if (label == null) return null;
    return 'คนเกิดวัน$label';
  }

  /// Weekdays with source-backed rotation assignments in frozen Canon.
  static const supportedWeekdayNumbers = {3};

  /// Weekdays where p38 rotation tables exist but OCR blocked extraction (Phase C).
  static const ocrBlockedWeekdayNumbers = {1, 2};
}

/// Resolved Taksa rotation metadata for one profile.
class ThaiTaksaRotationMetadata {
  const ThaiTaksaRotationMetadata({
    required this.birthWeekdayNumber,
    required this.assignments,
    this.blocker,
  });

  const ThaiTaksaRotationMetadata.empty({this.blocker})
      : birthWeekdayNumber = null,
        assignments = const [];

  final int? birthWeekdayNumber;
  final List<ThaiTaksaRoleAssignment> assignments;
  final String? blocker;

  bool get hasAssignments => assignments.isNotEmpty;
}

/// Read-only feasibility audit over frozen Canon Taksa rotation evidence.
class ThaiTaksaRotationFeasibilityAudit {
  const ThaiTaksaRotationFeasibilityAudit({
    required this.result,
    required this.supportedWeekdayNumbers,
    required this.ocrBlockedWeekdayNumbers,
    required this.unsupportedWeekdayNumbers,
    required this.rotationAssignmentsByWeekday,
    required this.sourcePagesReviewed,
  });

  final TaksaRotationFeasibilityResult result;
  final List<int> supportedWeekdayNumbers;
  final List<int> ocrBlockedWeekdayNumbers;
  final List<int> unsupportedWeekdayNumbers;
  final Map<int, int> rotationAssignmentsByWeekday;
  final List<String> sourcePagesReviewed;

  static ThaiTaksaRotationFeasibilityAudit audit({
    ThaiCanonEvidenceRepository? repository,
  }) {
    final repo = repository;
    final rotationByWeekday = <int, int>{};
    if (repo != null) {
      for (final unit in _weekdayRotationUnits(repo.index.units)) {
        final weekday = _weekdayFromContext(unit.context?.value);
        if (weekday == null) continue;
        rotationByWeekday[weekday] = (rotationByWeekday[weekday] ?? 0) + 1;
      }
    }

    final supported = ThaiTaksaBirthWeekday.supportedWeekdayNumbers
        .where((w) => (rotationByWeekday[w] ?? 0) > 0)
        .toList()
      ..sort();
    final ocrBlocked = ThaiTaksaBirthWeekday.ocrBlockedWeekdayNumbers.toList()
      ..sort();
    final unsupported = <int>[];
    for (var w = 1; w <= 7; w++) {
      if (supported.contains(w) || ocrBlocked.contains(w)) continue;
      unsupported.add(w);
    }

    final result = _classify(
      supportedCount: supported.length,
      ocrBlockedCount: ocrBlocked.length,
      totalWithAssignments: rotationByWeekday.length,
    );

    return ThaiTaksaRotationFeasibilityAudit(
      result: result,
      supportedWeekdayNumbers: supported,
      ocrBlockedWeekdayNumbers: ocrBlocked,
      unsupportedWeekdayNumbers: unsupported,
      rotationAssignmentsByWeekday: rotationByWeekday,
      sourcePagesReviewed: const ['38', '39'],
    );
  }

  static TaksaRotationFeasibilityResult _classify({
    required int supportedCount,
    required int ocrBlockedCount,
    required int totalWithAssignments,
  }) {
    if (supportedCount == 7) {
      return TaksaRotationFeasibilityResult.readyToImplementFullRotation;
    }
    if (supportedCount > 1 && supportedCount < 7) {
      return TaksaRotationFeasibilityResult.readyToImplementPartialRotation;
    }
    if (supportedCount == 1 && totalWithAssignments == 1) {
      return TaksaRotationFeasibilityResult.readyToImplementTuesdayOnly;
    }
    if (ocrBlockedCount > 0 && supportedCount == 0) {
      return TaksaRotationFeasibilityResult.needsTaksaSourceForensics;
    }
    if (supportedCount == 0 && ocrBlockedCount == 0) {
      return TaksaRotationFeasibilityResult.blockedBySourceGap;
    }
    if (supportedCount == 1) {
      return TaksaRotationFeasibilityResult.readyToImplementTuesdayOnly;
    }
    return TaksaRotationFeasibilityResult.blockedByModelingGap;
  }

  static Iterable<AtomicKnowledgeUnit> _weekdayRotationUnits(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    return units.where(
      (u) =>
          u.relation == AtomicRelation.locatedIn &&
          u.subject.startsWith('planet.') &&
          u.object.startsWith('taksaRole.') &&
          u.context?.type == AtomicContextType.other &&
          (u.context?.value ?? '').startsWith('คนเกิดวัน'),
    );
  }

  static int? _weekdayFromContext(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final entry in ThaiTaksaBirthWeekday.labelsByNumber.entries) {
      if (value == 'คนเกิดวัน${entry.value}') return entry.key;
    }
    return null;
  }
}
