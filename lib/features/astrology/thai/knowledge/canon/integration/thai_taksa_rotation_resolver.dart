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

    if (ThaiTaksaBirthWeekday.ocrBlockedWeekdayNumbers.contains(weekday)) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata(
          birthWeekdayNumber: weekday,
          assignments: const [],
          blocker: TaksaRotationBlocker.sourceBlocked,
        ),
      );
    }

    final contextValue = ThaiTaksaBirthWeekday.canonContextValueForWeekday(weekday);
    if (contextValue == null) {
      return ThaiTaksaRotationResolveResult(
        metadata: ThaiTaksaRotationMetadata(
          birthWeekdayNumber: weekday,
          assignments: const [],
          blocker: TaksaRotationBlocker.unsupportedWeekday,
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
          blocker: TaksaRotationBlocker.unsupportedWeekday,
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
          source: 'canon_structural',
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
              u.context?.type == AtomicContextType.other &&
              u.context?.value == contextValue,
        )
        .toList(growable: false);
    matches.sort((a, b) => a.id.compareTo(b.id));
    return matches;
  }
}
