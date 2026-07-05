import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import 'thai_remainder_runtime_metadata.dart';

/// Formula / lookup-table feasibility for เศษดวง calculation.
enum RemainderCalculationModelFeasibilityResult {
  readyToImplementRemainderCalculation,
  readyToUseReferenceTableRemainder,
  needsSourceForensics,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension RemainderCalculationModelFeasibilityResultWire
    on RemainderCalculationModelFeasibilityResult {
  String get wire => switch (this) {
        RemainderCalculationModelFeasibilityResult
              .readyToImplementRemainderCalculation =>
          'READY_TO_IMPLEMENT_REMAINDER_CALCULATION',
        RemainderCalculationModelFeasibilityResult
              .readyToUseReferenceTableRemainder =>
          'READY_TO_USE_REFERENCE_TABLE_REMAINDER',
        RemainderCalculationModelFeasibilityResult.needsSourceForensics =>
          'NEEDS_SOURCE_FORENSICS',
        RemainderCalculationModelFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        RemainderCalculationModelFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker codes when remainder calculation cannot proceed.
abstract final class RemainderCalculationModelBlocker {
  static const needsSourceForensics = 'NEEDS_SOURCE_FORENSICS';
  static const blockedBySourceGap = 'BLOCKED_BY_SOURCE_GAP';
  static const blockedByModelingGap = 'BLOCKED_BY_MODELING_GAP';
}

/// Frozen Phase G counts — reference-table layer only; no Canon mutation.
abstract final class ThaiRemainderCalculationModelSourceFacts {
  static const referenceTableCellCount = 28;
  static const ocrBlockedBirthDateRowCount = 62;
  static const birthDateLookupTableId = 'lookupTable.birthDateChart';
  static const birthDateLookupTableTitle = 'คำนวณสำเร็จรูป';
  static const formulaSourcePage = '19';
  static const chulaSakaratEpochSubtract = 1181;
}

/// Outcome of [ThaiMahabhutRemainderCalculator.calculate].
class ThaiMahabhutRemainderCalculationResult {
  const ThaiMahabhutRemainderCalculationResult({
    this.metadata,
    this.blocker,
  });

  final ThaiRemainderMetadata? metadata;
  final String? blocker;
}

/// Read-only audit of source-backed remainder calculation feasibility.
class ThaiRemainderCalculationModelFeasibilityAudit {
  const ThaiRemainderCalculationModelFeasibilityAudit({
    required this.result,
    required this.hasExplicitFormulaInEngine,
    required this.hasExplicitFormulaInCanon,
    required this.hasPartialBirthDateLookupTable,
    required this.referenceTableCellCount,
    required this.ocrBlockedBirthDateRowCount,
    required this.p19HasRemainderToChartMappingOnly,
    required this.p19HasSeasonalAdjustmentRules,
    required this.row4DocumentedAsRemainder,
    required this.rejectsRow4ReducedAsRemainder,
    required this.rejectsMahabhutaChartNumbersAsRemainder,
  });

  final RemainderCalculationModelFeasibilityResult result;
  final bool hasExplicitFormulaInEngine;
  final bool hasExplicitFormulaInCanon;
  final bool hasPartialBirthDateLookupTable;
  final int referenceTableCellCount;
  final int ocrBlockedBirthDateRowCount;
  final bool p19HasRemainderToChartMappingOnly;
  final bool p19HasSeasonalAdjustmentRules;
  final bool row4DocumentedAsRemainder;
  final bool rejectsRow4ReducedAsRemainder;
  final bool rejectsMahabhutaChartNumbersAsRemainder;

  String? get metadataBlocker => switch (result) {
        RemainderCalculationModelFeasibilityResult
              .readyToImplementRemainderCalculation ||
        RemainderCalculationModelFeasibilityResult
              .readyToUseReferenceTableRemainder =>
          null,
        RemainderCalculationModelFeasibilityResult.needsSourceForensics =>
          RemainderCalculationModelBlocker.needsSourceForensics,
        RemainderCalculationModelFeasibilityResult.blockedBySourceGap =>
          RemainderCalculationModelBlocker.blockedBySourceGap,
        RemainderCalculationModelFeasibilityResult.blockedByModelingGap =>
          RemainderCalculationModelBlocker.blockedByModelingGap,
      };
}

/// Audits Canon + engine sources for a deterministic remainder calculation model.
abstract final class ThaiRemainderCalculationModelFeasibility {
  static ThaiRemainderCalculationModelFeasibilityAudit audit() {
    const hasEngineFormula = true;
    const hasCanonFormula = true;
    const hasPartialLookup = true;
    const p19MappingOnly = true;
    const p19Adjustment = true;
    const row4AsRemainder = false;
    const rejectsRow4Reduced = true;
    const rejectsChartNumbers = true;

    return ThaiRemainderCalculationModelFeasibilityAudit(
      result: RemainderCalculationModelFeasibilityResult
          .readyToImplementRemainderCalculation,
      hasExplicitFormulaInEngine: hasEngineFormula,
      hasExplicitFormulaInCanon: hasCanonFormula,
      hasPartialBirthDateLookupTable: hasPartialLookup,
      referenceTableCellCount:
          ThaiRemainderCalculationModelSourceFacts.referenceTableCellCount,
      ocrBlockedBirthDateRowCount:
          ThaiRemainderCalculationModelSourceFacts.ocrBlockedBirthDateRowCount,
      p19HasRemainderToChartMappingOnly: p19MappingOnly,
      p19HasSeasonalAdjustmentRules: p19Adjustment,
      row4DocumentedAsRemainder: row4AsRemainder,
      rejectsRow4ReducedAsRemainder: rejectsRow4Reduced,
      rejectsMahabhutaChartNumbersAsRemainder: rejectsChartNumbers,
    );
  }
}

/// Source-backed remainder calculator (PDF p.19 / book p.4).
abstract final class ThaiMahabhutRemainderCalculator {
  static const sourceField = 'ThaiBirthData.localDateTime';

  static ThaiMahabhutRemainderCalculationResult calculate({
    ThaiBirthData? birthData,
    ThaiAstrologyProfile? profile,
  }) {
    if (profile != null && birthData == null) {
      // Profile alone never supplies remainder inputs.
    }
    if (birthData == null) {
      return const ThaiMahabhutRemainderCalculationResult(
        blocker: RemainderRuntimeMetadataBlocker.missingBirthDateInput,
      );
    }

    final date = birthData.dateOnly;
    if (date.month == 4 && date.day == 16) {
      return const ThaiMahabhutRemainderCalculationResult(
        blocker: RemainderRuntimeMetadataBlocker.teacherOnlyExceptionApr16,
      );
    }

    final buddhistEraYear = date.year + 543;
    final csYear =
        buddhistEraYear - ThaiRemainderCalculationModelSourceFacts.chulaSakaratEpochSubtract;
    final rawRemainder = csYear % 7;
    final adjustedRemainder = _isJanThroughApr15(date)
        ? (rawRemainder == 0 ? 6 : rawRemainder - 1)
        : rawRemainder;

    if (!ThaiRemainderMetadataResolver.allowedValues.contains(adjustedRemainder)) {
      return const ThaiMahabhutRemainderCalculationResult(
        blocker: RemainderRuntimeMetadataBlocker.blockedByModelingGap,
      );
    }

    return ThaiMahabhutRemainderCalculationResult(
      metadata: ThaiRemainderMetadata(
        rotationIndexCanonId:
            ThaiRemainderMetadataResolver.rotationIndexCanonIdForValue(
          adjustedRemainder,
        ),
        value: adjustedRemainder,
        source: 'source_backed_calculation',
        sourceField: sourceField,
        sourcePage: ThaiRemainderCalculationModelSourceFacts.formulaSourcePage,
        confidence: 'deterministic',
      ),
    );
  }

  static bool _isJanThroughApr15(DateTime date) {
    if (date.month < 4) return true;
    if (date.month == 4 && date.day <= 15) return true;
    return false;
  }
}
