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
  static const partialSourceReviewRequired =
      'TAKSA_ROTATION_PARTIAL_SOURCE_REVIEW_REQUIRED';
  static const notInSource = 'TAKSA_ROTATION_NOT_IN_SOURCE';
  static const missingBirthWeekday = 'TAKSA_ROTATION_MISSING_BIRTH_WEEKDAY';

  @Deprecated('Use partialSourceReviewRequired for Sunday')
  static const sourceBlocked = 'TAKSA_ROTATION_SOURCE_BLOCKED';
}

/// Source-not-in-canon weekday cases (documented separately).
abstract final class ThaiTaksaNotInSourceWeekdayCase {
  static const wednesdayDaytime = 'คนเกิดวันพุธกลางวัน';
  static const wednesdayNightRahu = 'คนเกิดวันพุธกลางคืน / ราหู';
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

  /// Weekdays with source-backed rotation assignments in Canon (Patch 002+).
  static const supportedWeekdayNumbers = {2, 3};

  /// Sunday — forensics partial only; not patched.
  static const partialSourceReviewWeekdayNumbers = {1};

  /// Wed–Sat — no rotation tables in source.
  static const notInSourceWeekdayNumbers = {4, 5, 6, 7};
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
    required this.partialSourceReviewWeekdayNumbers,
    required this.notInSourceWeekdayNumbers,
    required this.rotationAssignmentsByWeekday,
    required this.sourcePagesReviewed,
    required this.wednesdayDaytimeStatus,
    required this.wednesdayNightRahuStatus,
  });

  final TaksaRotationFeasibilityResult result;
  final List<int> supportedWeekdayNumbers;
  final List<int> partialSourceReviewWeekdayNumbers;
  final List<int> notInSourceWeekdayNumbers;
  final Map<int, int> rotationAssignmentsByWeekday;
  final List<String> sourcePagesReviewed;
  final String wednesdayDaytimeStatus;
  final String wednesdayNightRahuStatus;

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
    final partialReview =
        ThaiTaksaBirthWeekday.partialSourceReviewWeekdayNumbers.toList()
          ..sort();
    final notInSource =
        ThaiTaksaBirthWeekday.notInSourceWeekdayNumbers.toList()..sort();

    final result = _classify(supportedCount: supported.length);

    return ThaiTaksaRotationFeasibilityAudit(
      result: result,
      supportedWeekdayNumbers: supported,
      partialSourceReviewWeekdayNumbers: partialReview,
      notInSourceWeekdayNumbers: notInSource,
      rotationAssignmentsByWeekday: rotationByWeekday,
      sourcePagesReviewed: const ['38', '39'],
      wednesdayDaytimeStatus: TaksaRotationBlocker.notInSource,
      wednesdayNightRahuStatus: TaksaRotationBlocker.notInSource,
    );
  }

  static TaksaRotationFeasibilityResult _classify({
    required int supportedCount,
  }) {
    if (supportedCount >= 7) {
      return TaksaRotationFeasibilityResult.readyToImplementFullRotation;
    }
    if (supportedCount > 1) {
      return TaksaRotationFeasibilityResult.readyToImplementPartialRotation;
    }
    if (supportedCount == 1) {
      return TaksaRotationFeasibilityResult.readyToImplementTuesdayOnly;
    }
    return TaksaRotationFeasibilityResult.blockedBySourceGap;
  }

  static Iterable<AtomicKnowledgeUnit> _weekdayRotationUnits(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    return units.where(_isWeekdayRotationUnit);
  }

  static bool _isWeekdayRotationUnit(AtomicKnowledgeUnit u) {
    if (u.relation != AtomicRelation.locatedIn) return false;
    if (!u.subject.startsWith('planet.')) return false;
    if (!u.object.startsWith('taksaRole.')) return false;
    final ctx = u.context;
    if (ctx == null) return false;
    if (!(ctx.type == AtomicContextType.other ||
        ctx.type == AtomicContextType.taksaChart)) {
      return false;
    }
    return ctx.value.startsWith('คนเกิดวัน');
  }

  static int? _weekdayFromContext(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final entry in ThaiTaksaBirthWeekday.labelsByNumber.entries) {
      if (value == 'คนเกิดวัน${entry.value}') return entry.key;
    }
    return null;
  }
}
