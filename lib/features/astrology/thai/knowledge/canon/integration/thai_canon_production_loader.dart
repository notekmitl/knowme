import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/reference/canon_reference_table_cell.dart';

/// Asset path for the frozen Mahabhut production dataset.
const String kThaiCanonFoundationV1Asset =
    'knowledge/canon/production/foundation_v1.knowme.json';

/// Result of loading the frozen production Canon JSON.
class ThaiCanonProductionLoadResult {
  const ThaiCanonProductionLoadResult({
    required this.units,
    required this.referenceCells,
    required this.sourceBookId,
    this.sourceTitle,
    this.issues = const [],
  });

  final List<AtomicKnowledgeUnit> units;
  final List<CanonReferenceTableCell> referenceCells;
  final String sourceBookId;
  final String? sourceTitle;
  final List<String> issues;

  int get atomicCount => units.length;
  int get referenceCellCount => referenceCells.length;

  bool get isValid => issues.isEmpty;
}

/// Read-only loader for frozen `foundation_v1.knowme.json`.
abstract final class ThaiCanonProductionLoader {
  static Future<ThaiCanonProductionLoadResult> loadFromAsset() async {
    final json = await rootBundle.loadString(kThaiCanonFoundationV1Asset);
    return loadFromJson(json);
  }

  static ThaiCanonProductionLoadResult loadFromJson(String jsonText) {
    final issues = <String>[];
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      return ThaiCanonProductionLoadResult(
        units: const [],
        referenceCells: const [],
        sourceBookId: '',
        issues: ['root is not a JSON object'],
      );
    }

    final source = decoded['source'];
    final bookId = source is Map<String, dynamic>
        ? (source['bookId'] as String?)?.trim() ?? 'mahabhut'
        : 'mahabhut';
    final title = source is Map<String, dynamic>
        ? (source['title'] as String?)?.trim()
        : null;

    final units = <AtomicKnowledgeUnit>[];
    final rawUnits = decoded['producedUnits'];
    if (rawUnits is List) {
      for (final entry in rawUnits) {
        if (entry is! Map<String, dynamic>) continue;
        if (!entry.containsKey('id')) continue;
        final unit = AtomicKnowledgeUnit.fromJson(entry);
        if (unit == null) {
          issues.add('invalid unit: ${entry['id']}');
          continue;
        }
        if (!unit.evidence.hasReference) {
          issues.add('missing provenance: ${unit.id}');
        }
        units.add(unit);
      }
    } else {
      issues.add('producedUnits missing or not a list');
    }

    final cells = <CanonReferenceTableCell>[];
    final rawCells = decoded['producedReferenceTableCells'];
    if (rawCells is List) {
      for (final entry in rawCells) {
        if (entry is! Map<String, dynamic>) continue;
        if (!entry.containsKey('id')) continue;
        final cell = CanonReferenceTableCell.fromJson(entry);
        if (cell == null) {
          issues.add('invalid reference cell: ${entry['id']}');
          continue;
        }
        if (!cell.evidence.hasReference) {
          issues.add('missing provenance: ${cell.id}');
        }
        cells.add(cell);
      }
    }

    final ids = units.map((u) => u.id).toList();
    final unique = ids.toSet();
    if (unique.length != ids.length) {
      issues.add('duplicate unit ids detected');
    }

    return ThaiCanonProductionLoadResult(
      units: List<AtomicKnowledgeUnit>.unmodifiable(units),
      referenceCells: List<CanonReferenceTableCell>.unmodifiable(cells),
      sourceBookId: bookId,
      sourceTitle: title,
      issues: List<String>.unmodifiable(issues),
    );
  }
}
