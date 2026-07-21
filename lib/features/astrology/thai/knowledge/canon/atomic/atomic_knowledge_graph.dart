/// Canon Atomic Knowledge V2 — knowledge graph.
///
/// Canon is now a **graph**: entities are nodes, relationships are first-class
/// edges. The graph is built deterministically from atomic units and supports
/// validation and queries (neighbours, edges by relation, relations between two
/// entities). Pure Dart; no Flutter/engine/runtime imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';

class AtomicNode {
  const AtomicNode({required this.id, required this.kind, required this.value});

  /// Stable node id: `kind:value` (e.g. `planet:jupiter`).
  final String id;
  final AtomicEntityKind kind;
  final String value;

  static String makeId(AtomicEntityKind kind, String value) =>
      '${kind.name}:${value.trim()}';
}

class AtomicEdge {
  const AtomicEdge({
    required this.fromId,
    required this.toId,
    required this.relation,
    required this.unitId,
    this.condition,
    this.strength = AtomicStrength.none,
  });

  final String fromId;
  final String toId;
  final AtomicRelation relation;
  final String unitId;
  final String? condition;
  final AtomicStrength strength;

  String get signature => '$fromId|${relation.wire}|$toId|${condition ?? ''}';
}

class AtomicGraphIssue {
  const AtomicGraphIssue(this.code, this.message, {this.ref});
  final String code;
  final String message;
  final String? ref;

  @override
  String toString() => '$code${ref == null ? '' : ' ($ref)'}: $message';
}

/// An immutable, deterministic graph view over atomic units.
class AtomicKnowledgeGraph {
  AtomicKnowledgeGraph._(this._nodes, this._edges);

  final Map<String, AtomicNode> _nodes;
  final List<AtomicEdge> _edges;

  List<AtomicNode> get nodes {
    final list = _nodes.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  List<AtomicEdge> get edges {
    final list = [..._edges];
    list.sort((a, b) => a.signature.compareTo(b.signature));
    return list;
  }

  int get nodeCount => _nodes.length;
  int get edgeCount => _edges.length;

  AtomicNode? node(String id) => _nodes[id];

  /// Build a graph from atomic units. Endpoints are created from the units, so
  /// every edge always has both endpoints present.
  static AtomicKnowledgeGraph build(Iterable<AtomicKnowledgeUnit> units) {
    final nodes = <String, AtomicNode>{};
    final edges = <AtomicEdge>[];
    for (final u in units) {
      final fromId = AtomicNode.makeId(u.subjectKind, u.subject);
      final toId = AtomicNode.makeId(u.objectKind, u.object);
      nodes.putIfAbsent(
          fromId, () => AtomicNode(id: fromId, kind: u.subjectKind, value: u.subject));
      nodes.putIfAbsent(
          toId, () => AtomicNode(id: toId, kind: u.objectKind, value: u.object));
      edges.add(AtomicEdge(
        fromId: fromId,
        toId: toId,
        relation: u.relation,
        unitId: u.id,
        condition: u.condition,
        strength: u.strength,
      ));
    }
    return AtomicKnowledgeGraph._(nodes, edges);
  }

  /// Outgoing edges from a node.
  List<AtomicEdge> edgesFrom(String nodeId) =>
      edges.where((e) => e.fromId == nodeId).toList();

  /// Distinct neighbour node ids reachable from [nodeId].
  List<String> neighbours(String nodeId) {
    final out = edges.where((e) => e.fromId == nodeId).map((e) => e.toId).toSet().toList();
    out.sort();
    return out;
  }

  /// Edges carrying a given relation.
  List<AtomicEdge> edgesWithRelation(AtomicRelation r) =>
      edges.where((e) => e.relation == r).toList();

  /// All relations asserted between two entity nodes (directed from → to).
  List<AtomicRelation> relationsBetween(String fromId, String toId) {
    final out = edges
        .where((e) => e.fromId == fromId && e.toId == toId)
        .map((e) => e.relation)
        .toSet()
        .toList();
    out.sort((a, b) => a.wire.compareTo(b.wire));
    return out;
  }

  /// Validate graph integrity. Endpoints always exist by construction; this
  /// flags duplicate edges and direct contradictions (supports + opposes between
  /// the same ordered pair).
  List<AtomicGraphIssue> validate() {
    final issues = <AtomicGraphIssue>[];
    final seen = <String>{};
    for (final e in edges) {
      if (!_nodes.containsKey(e.fromId)) {
        issues.add(AtomicGraphIssue('dangling_from',
            'Edge from missing node "${e.fromId}".', ref: e.unitId));
      }
      if (!_nodes.containsKey(e.toId)) {
        issues.add(AtomicGraphIssue('dangling_to',
            'Edge to missing node "${e.toId}".', ref: e.unitId));
      }
      if (!seen.add(e.signature)) {
        issues.add(AtomicGraphIssue('duplicate_edge',
            'Duplicate edge ${e.signature}.', ref: e.unitId));
      }
    }
    // Direct contradictions.
    final supports = <String>{};
    final opposes = <String>{};
    for (final e in edges) {
      final pair = '${e.fromId}->${e.toId}';
      if (e.relation == AtomicRelation.supports) supports.add(pair);
      if (e.relation == AtomicRelation.opposes) opposes.add(pair);
    }
    for (final pair in supports.intersection(opposes)) {
      issues.add(AtomicGraphIssue('contradiction',
          'Both supports and opposes asserted for $pair.'));
    }
    return issues;
  }

  bool get isValid => validate().isEmpty;
}
