import '../../foundation/models/thai_astrology_profile.dart';
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
  /// Readable birth-date lookup cells in `producedReferenceTableCells` (D-078).
  static const referenceTableCellCount = 28;

  /// pp.23–27 rows excluded by OCR per Phase G close report.
  static const ocrBlockedBirthDateRowCount = 62;

  static const birthDateLookupTableId = 'lookupTable.birthDateChart';
  static const birthDateLookupTableTitle = 'คำนวณสำเร็จรูป';
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
    const hasEngineFormula = false;
    const hasCanonFormula = false;
    const hasPartialLookup = true;
    const p19MappingOnly = true;
    const p19Adjustment = true;
    const row4AsRemainder = false;
    const rejectsRow4Reduced = true;
    const rejectsChartNumbers = true;

    final result = _classify(
      hasEngineFormula: hasEngineFormula,
      hasCanonFormula: hasCanonFormula,
      hasPartialLookup: hasPartialLookup,
      referenceCells:
          ThaiRemainderCalculationModelSourceFacts.referenceTableCellCount,
      ocrBlocked:
          ThaiRemainderCalculationModelSourceFacts.ocrBlockedBirthDateRowCount,
    );

    return ThaiRemainderCalculationModelFeasibilityAudit(
      result: result,
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

  static RemainderCalculationModelFeasibilityResult _classify({
    required bool hasEngineFormula,
    required bool hasCanonFormula,
    required bool hasPartialLookup,
    required int referenceCells,
    required int ocrBlocked,
  }) {
    if (hasEngineFormula || hasCanonFormula) {
      return RemainderCalculationModelFeasibilityResult
          .readyToImplementRemainderCalculation;
    }
    if (hasPartialLookup &&
        referenceCells > 0 &&
        ocrBlocked == 0) {
      return RemainderCalculationModelFeasibilityResult
          .readyToUseReferenceTableRemainder;
    }
    if (hasPartialLookup && referenceCells > 0 && ocrBlocked > referenceCells) {
      return RemainderCalculationModelFeasibilityResult.needsSourceForensics;
    }
    if (!hasPartialLookup && !hasCanonFormula && !hasEngineFormula) {
      return RemainderCalculationModelFeasibilityResult.blockedBySourceGap;
    }
    return RemainderCalculationModelFeasibilityResult.needsSourceForensics;
  }
}

/// Source-backed remainder calculator — returns null until audit is READY.
abstract final class ThaiMahabhutRemainderCalculator {
  static ThaiRemainderMetadata? calculate({ThaiAstrologyProfile? profile}) {
    final audit = ThaiRemainderCalculationModelFeasibility.audit();
    if (audit.result !=
            RemainderCalculationModelFeasibilityResult
                .readyToImplementRemainderCalculation &&
        audit.result !=
            RemainderCalculationModelFeasibilityResult
                .readyToUseReferenceTableRemainder) {
      return null;
    }
    if (profile == null) return null;
    return null;
  }
}
