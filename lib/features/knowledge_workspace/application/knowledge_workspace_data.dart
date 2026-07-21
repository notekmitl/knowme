import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/evidence/evidence_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';

/// Read-only aggregation backing the Knowledge Workspace (V5).
///
/// It joins the knowledge layers (V2 planet-relationship records, V3 research,
/// V4 evidence) into browseable view-models. **Knowledge layer only** — it has
/// no dependency on the runtime, prediction, or the engine/matrix directly: the
/// "current matrix" value is read from the V2 knowledge record's `relation`
/// (which mirrors the frozen matrix), never from the engine.
class KnowledgeWorkspaceData {
  KnowledgeWorkspaceData({
    required this.relationships,
    required this.research,
    required this.evidence,
    required this.knowledgeCoverage,
  });

  /// One view per directed relationship (the 56 V2 records).
  final List<RelationshipView> relationships;
  final List<KnowledgeResearchRecord> research;
  final List<EvidenceRecord> evidence;
  final PlanetRelationshipCoverageReport knowledgeCoverage;

  // ---------------------------------------------------------------------------
  // construction
  // ---------------------------------------------------------------------------

  /// Build from the bundled knowledge assets.
  static Future<KnowledgeWorkspaceData> loadFromAssets({
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    final knowledge =
        await PlanetRelationshipKnowledgeImporter.loadFromAsset(bundle: b);
    final evidenceEngine =
        await KnowledgeEvidenceEngine.loadFromAssets(bundle: b);
    return build(
      knowledge: knowledge.knowledge,
      evidenceEngine: evidenceEngine,
    );
  }

  /// Build from already-loaded engines (used by tests).
  static KnowledgeWorkspaceData build({
    required PlanetRelationshipKnowledge knowledge,
    required KnowledgeEvidenceEngine evidenceEngine,
  }) {
    final researchEngine = KnowledgeResearchEngine(evidenceEngine.research);
    final conflictsByPair = {
      for (final c in researchEngine.findConflicts()) c.pairKey: c,
    };

    final views = <RelationshipView>[];
    for (final record in knowledge.records) {
      final from = record.from.name;
      final to = record.to.name;
      final researchRecords = researchEngine.findSupportingEvidence(from, to);
      final evidence = <EvidenceRecord>[];
      final seen = <String>{};
      for (final r in researchRecords) {
        for (final id in r.evidenceIds) {
          final ev = evidenceEngine.findEvidence(id);
          if (ev != null && seen.add(ev.id)) evidence.add(ev);
        }
      }
      views.add(
        RelationshipView(
          from: from,
          to: to,
          currentMatrix: record.relation.name,
          knowledgeStatus: record.status,
          research: researchRecords,
          evidence: evidence,
          conflict: conflictsByPair['$from->$to'],
        ),
      );
    }

    return KnowledgeWorkspaceData(
      relationships: views,
      research: evidenceEngine.research,
      evidence: evidenceEngine.evidence,
      knowledgeCoverage: knowledge.coverage(),
    );
  }

  // ---------------------------------------------------------------------------
  // filtering
  // ---------------------------------------------------------------------------

  List<RelationshipView> filterRelationships(KnowledgeWorkspaceFilter f) {
    return relationships.where((v) {
      if (f.planet != null && v.from != f.planet && v.to != f.planet) {
        return false;
      }
      if (f.relation != null && v.currentMatrix != f.relation) return false;
      if (f.status != null && v.knowledgeStatus.name != f.status) return false;
      if (f.school != null && !_relationshipMatchesSchool(v, f.school!)) {
        return false;
      }
      if (f.author != null && !_relationshipMatchesEvidence(v, (e) => e.author == f.author)) {
        return false;
      }
      if (f.book != null && !_relationshipMatchesEvidence(v, (e) => e.sourceLabel == f.book)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  List<EvidenceRecord> filterEvidence(KnowledgeWorkspaceFilter f) {
    return evidence.where((e) {
      if (f.school != null && e.school != f.school) return false;
      if (f.author != null && e.author != f.author) return false;
      if (f.book != null && e.sourceLabel != f.book) return false;
      return true;
    }).toList(growable: false);
  }

  bool _relationshipMatchesSchool(RelationshipView v, String school) =>
      v.evidence.any((e) => e.school == school);

  bool _relationshipMatchesEvidence(
    RelationshipView v,
    bool Function(EvidenceRecord) test,
  ) =>
      v.evidence.any(test);

  /// Distinct filter option values for the UI.
  List<String> get schools =>
      _distinct(evidence.map((e) => e.school));
  List<String> get authors =>
      _distinct(evidence.map((e) => e.author));
  List<String> get books =>
      _distinct(evidence.map((e) => e.sourceLabel));
  List<String> get planets =>
      _distinct(relationships.expand((v) => [v.from, v.to]));

  static List<String> _distinct(Iterable<String> values) {
    final set = values.where((v) => v.trim().isNotEmpty).toSet().toList()
      ..sort();
    return set;
  }
}

/// One relationship as shown in the workspace.
class RelationshipView {
  const RelationshipView({
    required this.from,
    required this.to,
    required this.currentMatrix,
    required this.knowledgeStatus,
    required this.research,
    required this.evidence,
    this.conflict,
  });

  final String from;
  final String to;

  /// `friend` | `neutral` | `enemy` (from the V2 knowledge record / matrix).
  final String currentMatrix;
  final PlanetRelationshipStatus knowledgeStatus;
  final List<KnowledgeResearchRecord> research;
  final List<EvidenceRecord> evidence;
  final ResearchConflict? conflict;

  String get pairKey => '$from->$to';
  bool get hasConflict => conflict != null;
  bool get hasEvidence => evidence.isNotEmpty;
}

/// Read-only filter for the workspace. Null = no constraint.
class KnowledgeWorkspaceFilter {
  const KnowledgeWorkspaceFilter({
    this.school,
    this.author,
    this.book,
    this.relation,
    this.status,
    this.planet,
  });

  final String? school;
  final String? author;
  final String? book;
  final String? relation;
  final String? status;
  final String? planet;

  KnowledgeWorkspaceFilter copyWith({
    String? Function()? school,
    String? Function()? author,
    String? Function()? book,
    String? Function()? relation,
    String? Function()? status,
    String? Function()? planet,
  }) {
    return KnowledgeWorkspaceFilter(
      school: school != null ? school() : this.school,
      author: author != null ? author() : this.author,
      book: book != null ? book() : this.book,
      relation: relation != null ? relation() : this.relation,
      status: status != null ? status() : this.status,
      planet: planet != null ? planet() : this.planet,
    );
  }

  bool get isEmpty =>
      school == null &&
      author == null &&
      book == null &&
      relation == null &&
      status == null &&
      planet == null;
}
