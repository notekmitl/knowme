import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_database.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';

/// One indexed result: the unit plus its resolved provenance trace.
class CanonIndexHit {
  const CanonIndexHit({required this.unit, required this.trace});

  final CanonKnowledgeUnit unit;
  final CanonTrace? trace;

  /// Provenance one-liner for citing an insight back to the book.
  String get citation => trace?.citation ?? unit.bookId;
}

/// A read-only, query-friendly view over a [CanonDatabase] — the seam the
/// Reasoning Engine consumes. It exposes lookups by topic / subject / type /
/// validation status, **always paired with traceability**, and never imports
/// or mutates the calculation engine. The Reasoning Engine depends on this
/// index; the index never depends on the engine.
class CanonKnowledgeIndex {
  CanonKnowledgeIndex._(this._db, this._byTopic, this._bySubject, this._byType);

  final CanonDatabase _db;
  final Map<String, List<CanonKnowledgeUnit>> _byTopic;
  final Map<String, List<CanonKnowledgeUnit>> _bySubject;
  final Map<CanonUnitType, List<CanonKnowledgeUnit>> _byType;

  CanonDatabase get database => _db;
  List<String> get topics => _byTopic.keys.toList()..sort();

  factory CanonKnowledgeIndex.build(CanonDatabase db) {
    final byTopic = <String, List<CanonKnowledgeUnit>>{};
    final bySubject = <String, List<CanonKnowledgeUnit>>{};
    final byType = <CanonUnitType, List<CanonKnowledgeUnit>>{};
    for (final u in db.units) {
      (byTopic[u.topic] ??= []).add(u);
      (bySubject[u.subjectKey] ??= []).add(u);
      (byType[u.type] ??= []).add(u);
    }
    return CanonKnowledgeIndex._(db, byTopic, bySubject, byType);
  }

  /// Query the index. All filters are optional and AND-combined. By default only
  /// **canon-approved** units are returned (what the Reasoning Engine may cite);
  /// pass [minStatus] to relax. Results come with provenance traces.
  List<CanonIndexHit> query({
    String? topic,
    String? subject,
    CanonUnitType? type,
    CanonValidationStatus minStatus = CanonValidationStatus.canonApproved,
  }) {
    Iterable<CanonKnowledgeUnit> pool;
    if (subject != null && topic != null) {
      pool = _bySubject['$topic::$subject'] ?? const [];
    } else if (topic != null) {
      pool = _byTopic[topic] ?? const [];
    } else if (type != null) {
      pool = _byType[type] ?? const [];
    } else {
      pool = _db.units;
    }
    final hits = pool
        .where((u) => topic == null || u.topic == topic)
        .where((u) => subject == null || u.subject == subject)
        .where((u) => type == null || u.type == type)
        .where((u) => u.validationStatus.atLeast(minStatus))
        .map((u) => CanonIndexHit(unit: u, trace: _db.trace(u.id)))
        .toList();
    hits.sort((a, b) {
      final byStatus =
          b.unit.validationStatus.rank.compareTo(a.unit.validationStatus.rank);
      if (byStatus != 0) return byStatus;
      return b.unit.confidence.index.compareTo(a.unit.confidence.index);
    });
    return hits;
  }

  /// Canon-approved units for a subject — the typical Reasoning Engine call.
  List<CanonIndexHit> approvedFor(String topic, String subject) =>
      query(topic: topic, subject: subject);
}
