/// Validation rules for Canon Reference Table cells (D-078 Phase G).
///
/// Ensures provenance, deterministic keys, and no calculation hooks.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_extraction_rules.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/reference/canon_reference_table_cell.dart';

class CanonReferenceTableIssue {
  const CanonReferenceTableIssue(this.cellId, this.code, this.message);

  final String cellId;
  final String code;
  final String message;

  @override
  String toString() => '$code ($cellId): $message';
}

abstract final class CanonReferenceTableRules {
  static List<CanonReferenceTableIssue> validateCell(
      CanonReferenceTableCell cell) {
    final issues = <CanonReferenceTableIssue>[];
    void bad(String code, String msg) =>
        issues.add(CanonReferenceTableIssue(cell.id, code, msg));

    if (cell.tableId.trim().isEmpty) bad('empty_table_id', 'Table id is empty.');
    if (cell.tableTitle.trim().isEmpty) {
      bad('empty_table_title', 'Table title is empty.');
    }
    if (cell.rowKey.trim().isEmpty) bad('empty_row_key', 'Row key is empty.');
    if (cell.columnKey.trim().isEmpty) {
      bad('empty_column_key', 'Column key is empty.');
    }
    if (cell.cellValue.trim().isEmpty) {
      bad('empty_cell_value', 'Cell value is empty.');
    }
    if (!cell.evidence.hasReference) {
      bad('missing_reference', 'No book reference (page).');
    }
    for (final token in [cell.tableTitle, cell.columnKey, cell.cellValue]) {
      if (!AtomicExtractionRules.isAtomicToken(token)) {
        bad('non_atomic_token', 'Token is not atomic: $token');
      }
    }
    if (cell.rowKey.contains('\n')) {
      bad('non_atomic_row_key', 'Row key must be a single line.');
    }
    return issues;
  }

  static List<CanonReferenceTableIssue> validateAll(
      Iterable<CanonReferenceTableCell> cells) {
    final issues = <CanonReferenceTableIssue>[];
    final seenIds = <String>{};
    final seenKeys = <String>{};
    for (final cell in cells) {
      if (!seenIds.add(cell.id)) {
        issues.add(CanonReferenceTableIssue(
            cell.id, 'duplicate_id', 'Duplicate cell id.'));
      }
      final composite =
          '${cell.tableId}|${cell.rowKey}|${cell.columnKey}|${cell.cellValue}';
      if (!seenKeys.add(composite)) {
        issues.add(CanonReferenceTableIssue(
            cell.id, 'duplicate_cell', 'Duplicate table cell.'));
      }
      issues.addAll(validateCell(cell));
    }
    return issues;
  }

  static bool isValid(CanonReferenceTableCell cell) =>
      validateCell(cell).isEmpty;
}
