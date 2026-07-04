import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/reference/canon_reference_table_cell.dart';

import 'thai_canon_production_loader.dart';

/// Deterministic in-memory index over frozen Canon production data.
class ThaiCanonEvidenceIndex {
  ThaiCanonEvidenceIndex._({
    required this.units,
    required this.referenceCells,
    required this.sourceBookId,
    this.sourceTitle,
  }) : _bySubject = _indexBy(units, (u) => u.subject),
       _byObject = _indexBy(units, (u) => u.object),
       _byRelation = _indexByRelation(units),
       _byDomain = _indexBy(units, (u) => u.domain.name),
       _byPage = _indexByPage(units),
       _byContextType = _indexByContextType(units),
       _byContextValue = _indexByContextValue(units),
       _byTableId = _indexCellsBy(referenceCells, (c) => c.tableId);

  factory ThaiCanonEvidenceIndex.fromLoadResult(
    ThaiCanonProductionLoadResult load,
  ) {
    return ThaiCanonEvidenceIndex._(
      units: load.units,
      referenceCells: load.referenceCells,
      sourceBookId: load.sourceBookId,
      sourceTitle: load.sourceTitle,
    );
  }

  final List<AtomicKnowledgeUnit> units;
  final List<CanonReferenceTableCell> referenceCells;
  final String sourceBookId;
  final String? sourceTitle;

  final Map<String, List<AtomicKnowledgeUnit>> _bySubject;
  final Map<String, List<AtomicKnowledgeUnit>> _byObject;
  final Map<AtomicRelation, List<AtomicKnowledgeUnit>> _byRelation;
  final Map<String, List<AtomicKnowledgeUnit>> _byDomain;
  final Map<String, List<AtomicKnowledgeUnit>> _byPage;
  final Map<AtomicContextType, List<AtomicKnowledgeUnit>> _byContextType;
  final Map<String, List<AtomicKnowledgeUnit>> _byContextValue;
  final Map<String, List<CanonReferenceTableCell>> _byTableId;

  int get atomicCount => units.length;
  int get referenceCellCount => referenceCells.length;

  List<AtomicKnowledgeUnit> bySubject(String subject) =>
      _sorted(_bySubject[subject.trim()] ?? const []);

  List<AtomicKnowledgeUnit> byObject(String object) =>
      _sorted(_byObject[object.trim()] ?? const []);

  List<AtomicKnowledgeUnit> byRelation(AtomicRelation relation) =>
      _sorted(_byRelation[relation] ?? const []);

  List<AtomicKnowledgeUnit> byDomain(KnowledgeDomain domain) =>
      _sorted(_byDomain[domain.name] ?? const []);

  List<AtomicKnowledgeUnit> bySourcePage(String page) =>
      _sorted(_byPage[page.trim()] ?? const []);

  List<AtomicKnowledgeUnit> byContextType(AtomicContextType type) =>
      _sorted(_byContextType[type] ?? const []);

  List<AtomicKnowledgeUnit> byContextValue(String value) =>
      _sorted(_byContextValue[value.trim()] ?? const []);

  List<AtomicKnowledgeUnit> byPlanet(String canonPlanetId) {
    final id = canonPlanetId.trim();
    final matches = <AtomicKnowledgeUnit>[
      ...?(_bySubject[id]),
      ...?(_byObject[id]),
    ];
    final seen = <String>{};
    final unique = <AtomicKnowledgeUnit>[];
    for (final unit in matches) {
      if (seen.add(unit.id)) unique.add(unit);
    }
    return _sorted(unique);
  }

  List<AtomicKnowledgeUnit> byMahabhutPosition(String canonPositionId) =>
      byObject(canonPositionId.trim());

  List<AtomicKnowledgeUnit> byTaksaRole(String canonRoleId) =>
      byObject(canonRoleId.trim());

  List<AtomicKnowledgeUnit> byLifePeriodContext(String contextValue) =>
      byContextValue(contextValue.trim());

  /// Remedy-domain units — internal query surface only.
  List<AtomicKnowledgeUnit> byRemedyDomain() => byDomain(KnowledgeDomain.remedies);

  AtomicKnowledgeUnit? unitById(String id) {
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  List<CanonReferenceTableCell> referenceCellsForTable(String tableId) =>
      List<CanonReferenceTableCell>.unmodifiable(
        _byTableId[tableId.trim()] ?? const [],
      );

  List<CanonReferenceTableCell> referenceCellsForPage(String page) {
    final pageTrim = page.trim();
    final matches = referenceCells
        .where((c) => c.evidence.page?.trim() == pageTrim)
        .toList(growable: false);
    matches.sort((a, b) => a.id.compareTo(b.id));
    return matches;
  }

  static Map<String, List<AtomicKnowledgeUnit>> _indexBy(
    Iterable<AtomicKnowledgeUnit> units,
    String Function(AtomicKnowledgeUnit) keyFn,
  ) {
    final map = <String, List<AtomicKnowledgeUnit>>{};
    for (final unit in units) {
      map.putIfAbsent(keyFn(unit), () => []).add(unit);
    }
    return map;
  }

  static Map<AtomicRelation, List<AtomicKnowledgeUnit>> _indexByRelation(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    final map = <AtomicRelation, List<AtomicKnowledgeUnit>>{};
    for (final unit in units) {
      map.putIfAbsent(unit.relation, () => []).add(unit);
    }
    return map;
  }

  static Map<String, List<AtomicKnowledgeUnit>> _indexByPage(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    final map = <String, List<AtomicKnowledgeUnit>>{};
    for (final unit in units) {
      final page = unit.evidence.page?.trim();
      if (page == null || page.isEmpty) continue;
      map.putIfAbsent(page, () => []).add(unit);
    }
    return map;
  }

  static Map<AtomicContextType, List<AtomicKnowledgeUnit>> _indexByContextType(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    final map = <AtomicContextType, List<AtomicKnowledgeUnit>>{};
    for (final unit in units) {
      final ctx = unit.context;
      if (ctx == null) continue;
      map.putIfAbsent(ctx.type, () => []).add(unit);
    }
    return map;
  }

  static Map<String, List<AtomicKnowledgeUnit>> _indexByContextValue(
    Iterable<AtomicKnowledgeUnit> units,
  ) {
    final map = <String, List<AtomicKnowledgeUnit>>{};
    for (final unit in units) {
      final ctx = unit.context;
      if (ctx == null) continue;
      map.putIfAbsent(ctx.value.trim(), () => []).add(unit);
    }
    return map;
  }

  static Map<String, List<CanonReferenceTableCell>> _indexCellsBy(
    Iterable<CanonReferenceTableCell> cells,
    String Function(CanonReferenceTableCell) keyFn,
  ) {
    final map = <String, List<CanonReferenceTableCell>>{};
    for (final cell in cells) {
      map.putIfAbsent(keyFn(cell), () => []).add(cell);
    }
    return map;
  }

  static List<AtomicKnowledgeUnit> _sorted(List<AtomicKnowledgeUnit> units) {
    final copy = List<AtomicKnowledgeUnit>.from(units);
    copy.sort((a, b) => a.id.compareTo(b.id));
    return List<AtomicKnowledgeUnit>.unmodifiable(copy);
  }
}
