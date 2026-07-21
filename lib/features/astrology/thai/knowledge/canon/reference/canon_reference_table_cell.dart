/// Canon Reference Table — one source-provenanced table cell.
///
/// Preserves row/column structure from lookup tables without performing
/// calculation or interpretation. Added by D-078 Phase G.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';

class CanonReferenceTableCell {
  const CanonReferenceTableCell({
    required this.id,
    required this.tableId,
    required this.tableTitle,
    required this.rowKey,
    required this.columnKey,
    required this.cellValue,
    required this.evidence,
  });

  final String id;
  final String tableId;
  final String tableTitle;
  final String rowKey;
  final String columnKey;
  final String cellValue;
  final AtomicEvidenceRef evidence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tableId': tableId,
        'tableTitle': tableTitle,
        'rowKey': rowKey,
        'columnKey': columnKey,
        'cellValue': cellValue,
        'evidence': evidence.toJson(),
      };

  static CanonReferenceTableCell? fromJson(Map<String, dynamic> m) {
    final id = (m['id'] as String?)?.trim();
    final tableId = (m['tableId'] as String?)?.trim();
    final tableTitle = (m['tableTitle'] as String?)?.trim();
    final rowKey = (m['rowKey'] as String?)?.trim();
    final columnKey = (m['columnKey'] as String?)?.trim();
    final cellValue = (m['cellValue'] as String?)?.trim();
    final evidenceMap = m['evidence'];
    final evidence = evidenceMap is Map<String, dynamic>
        ? AtomicEvidenceRef.fromJson(evidenceMap)
        : null;
    if (id == null ||
        id.isEmpty ||
        tableId == null ||
        tableId.isEmpty ||
        tableTitle == null ||
        tableTitle.isEmpty ||
        rowKey == null ||
        rowKey.isEmpty ||
        columnKey == null ||
        columnKey.isEmpty ||
        cellValue == null ||
        cellValue.isEmpty ||
        evidence == null) {
      return null;
    }
    return CanonReferenceTableCell(
      id: id,
      tableId: tableId,
      tableTitle: tableTitle,
      rowKey: rowKey,
      columnKey: columnKey,
      cellValue: cellValue,
      evidence: evidence,
    );
  }
}
