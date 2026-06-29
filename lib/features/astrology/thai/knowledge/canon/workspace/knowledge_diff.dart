/// Canon Knowledge Extraction Workspace V4 — knowledge diff.
///
/// Before importing, the workspace shows how a session changes Canon. Each unit
/// is classified NEW / UPDATED / UNCHANGED / CONFLICT / DEPRECATED against the
/// existing baseline. This is the review surface — Canon is never overwritten
/// blindly. Deterministic; pure Dart over the atomic layer.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';

enum DiffKind { added, updated, unchanged, conflict, deprecated }

class DiffEntry {
  const DiffEntry(this.kind, this.unitId, this.detail);

  final DiffKind kind;
  final String unitId;
  final String detail;

  String get signature => '${kind.name}|$unitId|$detail';

  @override
  String toString() => '${kind.name.toUpperCase()} $unitId: $detail';
}

class KnowledgeDiff {
  const KnowledgeDiff(this.entries);

  /// Entries sorted deterministically by (kind, unitId).
  final List<DiffEntry> entries;

  int count(DiffKind kind) => entries.where((e) => e.kind == kind).length;

  List<DiffEntry> of(DiffKind kind) =>
      entries.where((e) => e.kind == kind).toList();

  bool get hasConflict => entries.any((e) => e.kind == DiffKind.conflict);

  String get summary =>
      'NEW ${count(DiffKind.added)}  UPDATED ${count(DiffKind.updated)}  '
      'UNCHANGED ${count(DiffKind.unchanged)}  '
      'CONFLICT ${count(DiffKind.conflict)}  '
      'DEPRECATED ${count(DiffKind.deprecated)}';

  /// Compute a diff of [incoming] (the session) against [baseline] (the canon).
  /// Identity is the unit id. A changed *fact* (subject/relation/object/
  /// condition) under a stable id is a CONFLICT; a changed *qualifier*
  /// (strength/confidence/evidence/notes) is an UPDATE.
  static KnowledgeDiff compute({
    required Iterable<AtomicKnowledgeUnit> baseline,
    required Iterable<AtomicKnowledgeUnit> incoming,
  }) {
    final base = {for (final u in baseline) u.id: u};
    final next = {for (final u in incoming) u.id: u};
    final entries = <DiffEntry>[];

    for (final entry in next.entries) {
      final b = base[entry.key];
      final u = entry.value;
      if (b == null) {
        entries.add(DiffEntry(DiffKind.added, u.id, u.label));
      } else if (_factKey(b) != _factKey(u)) {
        entries.add(DiffEntry(DiffKind.conflict, u.id,
            'fact changed: "${b.label}" → "${u.label}"'));
      } else if (_qualifierKey(b) != _qualifierKey(u)) {
        entries.add(DiffEntry(DiffKind.updated, u.id,
            'qualifiers changed (${_qualifierKey(b)} → ${_qualifierKey(u)})'));
      } else {
        entries.add(DiffEntry(DiffKind.unchanged, u.id, u.label));
      }
    }

    for (final entry in base.entries) {
      if (!next.containsKey(entry.key)) {
        entries.add(
            DiffEntry(DiffKind.deprecated, entry.key, entry.value.label));
      }
    }

    entries.sort((a, b) => a.signature.compareTo(b.signature));
    return KnowledgeDiff(entries);
  }

  static String _factKey(AtomicKnowledgeUnit u) =>
      '${u.subjectKind.name}:${u.subject}|${u.relation.wire}|'
      '${u.objectKind.name}:${u.object}|${u.condition ?? ''}';

  static String _qualifierKey(AtomicKnowledgeUnit u) =>
      '${u.strength.name}|${u.confidence.name}|${u.effect ?? ''}|'
      '${u.evidence.bookId}/${u.evidence.chapter ?? ''}/'
      '${u.evidence.section ?? ''}/${u.evidence.page ?? ''}|${u.notes ?? ''}';
}
