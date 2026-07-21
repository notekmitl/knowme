/// Mahabhut Ingestion Toolchain V1 — Diff Engine.
///
/// Compares two candidate stores (e.g. before/after an OCR correction) and
/// reports which knowledge units, rules and citations changed. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';

/// A field-level change on one candidate.
class CanonFieldChange {
  const CanonFieldChange(this.field, this.before, this.after);
  final String field;
  final String? before;
  final String? after;

  @override
  String toString() => '$field: "${before ?? ''}" → "${after ?? ''}"';
}

/// Per-unit change record.
class CanonUnitDiff {
  const CanonUnitDiff(this.id, this.changes);
  final String id;
  final List<CanonFieldChange> changes;

  bool get statementChanged => changes.any((c) => c.field == 'statement');
  bool get ruleChanged =>
      changes.any((c) => c.field == 'value' || c.field == 'type');
  bool get citationChanged =>
      changes.any((c) => c.field == 'evidenceQuote' || c.field == 'page');
}

class CanonDiffReport {
  const CanonDiffReport({
    required this.added,
    required this.removed,
    required this.changed,
  });

  final List<String> added;
  final List<String> removed;
  final List<CanonUnitDiff> changed;

  int get changedUnits => changed.length;
  int get rulesChanged => changed.where((d) => d.ruleChanged).length;
  int get citationsChanged => changed.where((d) => d.citationChanged).length;

  bool get isEmpty =>
      added.isEmpty && removed.isEmpty && changed.isEmpty;

  String get summary =>
      '+${added.length} / -${removed.length} / ~$changedUnits changed '
      '($rulesChanged rule(s), $citationsChanged citation(s)).';
}

abstract final class CanonDiffEngine {
  /// Diff [oldStore] → [newStore], matched by candidate id.
  static CanonDiffReport diff(
    CanonCandidateStore oldStore,
    CanonCandidateStore newStore,
  ) {
    final oldById = {for (final c in oldStore.candidates) c.id: c};
    final newById = {for (final c in newStore.candidates) c.id: c};

    final added = newById.keys.where((id) => !oldById.containsKey(id)).toList()
      ..sort();
    final removed = oldById.keys.where((id) => !newById.containsKey(id)).toList()
      ..sort();

    final changed = <CanonUnitDiff>[];
    for (final id in newById.keys.where(oldById.containsKey)) {
      final changes = _changes(oldById[id]!, newById[id]!);
      if (changes.isNotEmpty) changed.add(CanonUnitDiff(id, changes));
    }
    changed.sort((a, b) => a.id.compareTo(b.id));

    return CanonDiffReport(added: added, removed: removed, changed: changed);
  }

  static List<CanonFieldChange> _changes(
    CanonCandidateUnit a,
    CanonCandidateUnit b,
  ) {
    final out = <CanonFieldChange>[];
    void cmp(String field, String? x, String? y) {
      if ((x ?? '') != (y ?? '')) out.add(CanonFieldChange(field, x, y));
    }

    cmp('statement', a.statement, b.statement);
    cmp('type', a.type?.name, b.type?.name);
    cmp('topic', a.topic, b.topic);
    cmp('subject', a.subject, b.subject);
    cmp('value', a.value, b.value);
    cmp('page', a.page, b.page);
    cmp('evidenceQuote', a.evidenceQuote, b.evidenceQuote);
    cmp('status', a.status.name, b.status.name);
    cmp('conditions', a.conditions.join(' | '), b.conditions.join(' | '));
    cmp('exceptions', a.exceptions.join(' | '), b.exceptions.join(' | '));
    cmp(
      'crossRefs',
      a.crossRefs.map((x) => '${x.type.name}->${x.toId}').join(', '),
      b.crossRefs.map((x) => '${x.type.name}->${x.toId}').join(', '),
    );
    return out;
  }
}
