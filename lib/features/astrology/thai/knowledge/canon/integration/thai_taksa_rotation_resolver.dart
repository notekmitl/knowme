import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';

import 'thai_canon_evidence_repository.dart';
import 'thai_taksa_role_assignment.dart';
import 'thai_taksa_role_runtime_key.dart';
import 'thai_taksa_rotation_metadata.dart';

/// Result of resolving weekday Taksa rotation from frozen Canon evidence.
class ThaiTaksaRotationResolveResult {
  const ThaiTaksaRotationResolveResult({
    required this.metadata,
  });

  final ThaiTaksaRotationMetadata metadata;
}

/// Deterministic Taksa rotation resolver — Canon evidence only, no inference.
abstract final class ThaiTaksaRotationResolver {
  static ThaiTaksaRotationResolveResult resolve({
    required ThaiBirthData? birthData,
    required ThaiCanonEvidenceRepository repository,
  }) {
    final weekday = birthData?.thaiWeekdayNumber;
    if (weekday == null) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata.empty(
          blocker: TaksaRotationBlocker.missingBirthWeekday,
        ),
      );
    }

    final blocker = _blockerForWeekday(weekday);
    if (blocker != null) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata(
          birthWeekdayNumber: weekday,
          assignments: const [],
          blocker: blocker,
        ),
      );
    }

    final contextValue = ThaiTaksaBirthWeekday.canonContextValueForWeekday(weekday);
    if (contextValue == null) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata(
          birthWeekdayNumber: weekday,
          assignments: const [],
          blocker: TaksaRotationBlocker.notInSource,
        ),
      );
    }

    final rotationUnits = _rotationUnitsForContext(
      repository.index.units,
      contextValue,
    );
    if (rotationUnits.isEmpty) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata(
          birthWeekdayNumber: weekday,
          assignments: const [],
          blocker: TaksaRotationBlocker.notInSource,
        ),
      );
    }

    final assignments = <ThaiTaksaRoleAssignment>[];
    for (final unit in rotationUnits) {
      if (!unit.subject.startsWith('planet.') ||
          !ThaiTaksaRoleRuntimeKey.isAllowed(unit.object)) {
        continue;
      }
      assignments.add(
        ThaiTaksaRoleAssignment(
          birthWeekdayNumber: weekday,
          planetCanonId: unit.subject,
          taksaRoleCanonId: unit.object,
          sourcePage: unit.evidence.page ?? '',
          sourceUnitId: unit.id,
          source: _sourceForUnit(unit),
        ),
      );
    }
    assignments.sort((a, b) => a.planetCanonId.compareTo(b.planetCanonId));

    return ThaiTaksaRotationResolveResult(
      metadata: ThaiTaksaRotationMetadata(
        birthWeekdayNumber: weekday,
        assignments: assignments,
      ),
    );
  }

  static String? _blockerForWeekday(int weekday) {
    if (ThaiTaksaBirthWeekday.partialSourceReviewWeekdayNumbers
        .contains(weekday)) {
      return TaksaRotationBlocker.partialSourceReviewRequired;
    }
    if (ThaiTaksaBirthWeekday.notInSourceWeekdayNumbers.contains(weekday)) {
      return TaksaRotationBlocker.notInSource;
    }
    if (!ThaiTaksaBirthWeekday.supportedWeekdayNumbers.contains(weekday)) {
      return TaksaRotationBlocker.unsupportedWeekday;
    }
    return null;
  }

  static String _sourceForUnit(AtomicKnowledgeUnit unit) {
    if (unit.id.startsWith('taksa.p38.monday.')) {
      return 'source_forensics_patch';
    }
    return 'canon_structural';
  }

  static List<AtomicKnowledgeUnit> _rotationUnitsForContext(
    Iterable<AtomicKnowledgeUnit> units,
    String contextValue,
  ) {
    final matches = units
        .where(
          (u) =>
              u.relation == AtomicRelation.locatedIn &&
              u.subject.startsWith('planet.') &&
              u.object.startsWith('taksaRole.') &&
              _matchesWeekdayRotationContext(u, contextValue),
        )
        .toList(growable: false);
    matches.sort((a, b) => a.id.compareTo(b.id));
    return matches;
  }

  static bool _matchesWeekdayRotationContext(
    AtomicKnowledgeUnit unit,
    String contextValue,
  ) {
    final ctx = unit.context;
    if (ctx == null || ctx.value != contextValue) return false;
    return ctx.type == AtomicContextType.other ||
        ctx.type == AtomicContextType.taksaChart;
  }
}
