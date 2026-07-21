/// One source-backed planet → Taksa role assignment (internal metadata only).
class ThaiTaksaRoleAssignment {
  const ThaiTaksaRoleAssignment({
    required this.birthWeekdayNumber,
    required this.planetCanonId,
    required this.taksaRoleCanonId,
    required this.sourcePage,
    required this.sourceUnitId,
    required this.source,
    this.confidence = 'deterministic',
  });

  /// Thai weekday อาทิตย์=1 … เสาร์=7.
  final int birthWeekdayNumber;
  final String planetCanonId;
  final String taksaRoleCanonId;
  final String sourcePage;
  final String sourceUnitId;

  /// `canon_structural` or `source_forensics_patch`.
  final String source;
  final String confidence;
}
