/// Canon Knowledge Extraction Workspace V4 — workspace validator.
///
/// Deterministic, read-only validation of a session's atomic units against the
/// atomic rules, the Canonical Ontology and the knowledge graph. Catches every
/// failure class the workspace must block before import. Pure Dart; depends only
/// on the atomic + ontology knowledge layers (never on any engine/runtime).
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_extraction_rules.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_graph.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_extraction_session.dart';

enum WorkspaceSeverity { error, warning }

class WorkspaceIssue {
  const WorkspaceIssue(this.severity, this.code, this.message, {this.ref});

  final WorkspaceSeverity severity;
  final String code;
  final String message;
  final String? ref;

  bool get isError => severity == WorkspaceSeverity.error;

  String get signature => '${severity.name}|$code|${ref ?? ''}|$message';

  @override
  String toString() =>
      '[${severity.name}] $code${ref == null ? '' : ' ($ref)'}: $message';
}

class WorkspaceValidationReport {
  const WorkspaceValidationReport(this.issues);

  final List<WorkspaceIssue> issues;

  bool get isValid => issues.where((i) => i.isError).isEmpty;
  List<WorkspaceIssue> get errors => issues.where((i) => i.isError).toList();
  List<WorkspaceIssue> get warnings =>
      issues.where((i) => i.severity == WorkspaceSeverity.warning).toList();

  bool hasCode(String code) => issues.any((i) => i.code == code);

  Set<String> get codes => issues.map((i) => i.code).toSet();
}

abstract final class WorkspaceValidator {
  /// Relations that directly contradict each other within the graph.
  static const Map<AtomicRelation, AtomicRelation> _opposite = {
    AtomicRelation.supports: AtomicRelation.opposes,
    AtomicRelation.opposes: AtomicRelation.supports,
  };

  /// Validate [session] against [ontology] and an existing [baseline].
  /// Deterministic: identical inputs always produce identical issue lists.
  static WorkspaceValidationReport validate(
    KnowledgeExtractionSession session,
    CanonicalOntology ontology, {
    Iterable<AtomicKnowledgeUnit> baseline = const [],
  }) {
    final issues = <WorkspaceIssue>[];
    void err(String code, String msg, {String? ref}) =>
        issues.add(WorkspaceIssue(WorkspaceSeverity.error, code, msg, ref: ref));
    void warn(String code, String msg, {String? ref}) => issues
        .add(WorkspaceIssue(WorkspaceSeverity.warning, code, msg, ref: ref));

    final units = session.sortedUnits;

    // 1. Atomicity (one fact / one meaning / one rule) + duplicate ids.
    for (final issue in AtomicExtractionRules.validateAll(units)) {
      err('atomicity_${issue.code}', issue.message, ref: issue.unitId);
    }

    // 2-4. Per-unit ontology / relationship / evidence checks.
    for (final u in units) {
      if (!_resolves(ontology, u.subject)) {
        err('ontology_unresolved_subject',
            'Subject "${u.subject}" is not in the ontology.', ref: u.id);
      }
      if (!_resolves(ontology, u.object)) {
        err('ontology_unresolved_object',
            'Object "${u.object}" is not in the ontology.', ref: u.id);
      }
      if (!ontology.isRegisteredRelationship(u.relation.wire)) {
        err('relationship_not_registered',
            'Relationship "${u.relation.wire}" is not registered.', ref: u.id);
      }
      if (!u.evidence.hasReference) {
        err('missing_evidence_reference',
            'No book reference (page/chapter/section).', ref: u.id);
      }
    }

    // 5. Duplicate knowledge — same fact under different ids.
    final byFact = <String, List<String>>{};
    for (final u in units) {
      byFact.putIfAbsent(_factKey(u), () => []).add(u.id);
    }
    final dupKeys = byFact.entries.where((e) => e.value.length > 1).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in dupKeys) {
      final ids = [...entry.value]..sort();
      err('duplicate_knowledge',
          'Fact "${entry.key}" asserted by ${ids.length} units: ${ids.join(', ')}.',
          ref: entry.key);
    }

    // 6. Graph conflicts (contradictions / duplicate edges) within the session,
    // and against the baseline.
    final graph = AtomicKnowledgeGraph.build(units);
    for (final gi in graph.validate()) {
      err('graph_${gi.code}', gi.message, ref: gi.ref);
    }
    for (final c in _baselineConflicts(units, baseline)) {
      err('graph_baseline_conflict', c);
    }

    // 7. Coverage impact (informational, deterministic).
    if (units.isEmpty) {
      warn('coverage_no_impact', 'Session has no units; coverage will not change.');
    }

    issues.sort((a, b) => a.signature.compareTo(b.signature));
    return WorkspaceValidationReport(issues);
  }

  static bool _resolves(CanonicalOntology ontology, String token) =>
      ontology.entity(token) != null || ontology.canResolve(token);

  static String _factKey(AtomicKnowledgeUnit u) =>
      '${u.subjectKind.name}:${u.subject}|${u.relation.wire}|'
      '${u.objectKind.name}:${u.object}|${u.condition ?? ''}';

  static List<String> _baselineConflicts(
    List<AtomicKnowledgeUnit> units,
    Iterable<AtomicKnowledgeUnit> baseline,
  ) {
    // Map ordered entity pair -> relations asserted, for baseline.
    final baseRel = <String, Set<AtomicRelation>>{};
    for (final b in baseline) {
      baseRel
          .putIfAbsent(_pairKey(b), () => <AtomicRelation>{})
          .add(b.relation);
    }
    final out = <String>{};
    for (final u in units) {
      final opp = _opposite[u.relation];
      if (opp == null) continue;
      if (baseRel[_pairKey(u)]?.contains(opp) ?? false) {
        out.add(
            'Session asserts "${u.relation.wire}" but Canon already asserts "${opp.wire}" for ${_pairKey(u)}.');
      }
    }
    final list = out.toList()..sort();
    return list;
  }

  static String _pairKey(AtomicKnowledgeUnit u) =>
      '${u.subjectKind.name}:${u.subject}->${u.objectKind.name}:${u.object}';
}
