import 'dart:convert';

import 'package:knowme/features/astrology/thai/knowledge/evidence/evidence_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';

/// Thai Astrology — **Knowledge Acquisition** layer (V6).
///
/// Lets researchers populate the Knowledge Platform **gradually, JSON only** —
/// no manual Dart editing. A batch (evidence + research records) is validated,
/// previewed (dry-run), applied in-session, and can be rolled back. Every import
/// produces an [AcquisitionImportReport] (imported / updated / skipped /
/// conflicts / errors).
///
/// Boundary: this **never touches the `PlanetRelationshipMatrix`** or the engine.
/// It only merges the research + evidence corpora (V3/V4). The "current matrix"
/// is read elsewhere for display only.

/// The recognised, allowed relation values (matches the research schema).
const Set<String> kAcquisitionRelations = {'friend', 'neutral', 'enemy'};

/// What happened to one record in a batch.
enum AcquisitionOutcome { imported, updated, skipped, error }

/// Per-record result inside an import report.
class AcquisitionRecordOutcome {
  const AcquisitionRecordOutcome({
    required this.kind,
    required this.id,
    required this.outcome,
    this.detail,
    this.conflict = false,
  });

  /// `evidence` | `research`.
  final String kind;
  final String id;
  final AcquisitionOutcome outcome;

  /// For errors: the reason (e.g. `validation_failed`, `broken_link`).
  final String? detail;

  /// True when an imported/updated research record participates in a
  /// relationship conflict in the merged corpus.
  final bool conflict;
}

/// An immutable snapshot of the acquired corpora.
class AcquisitionState {
  AcquisitionState({
    required Iterable<EvidenceRecord> evidence,
    required Iterable<KnowledgeResearchRecord> research,
  })  : evidence = List.unmodifiable(evidence),
        research = List.unmodifiable(research);

  final List<EvidenceRecord> evidence;
  final List<KnowledgeResearchRecord> research;

  static AcquisitionState empty() =>
      AcquisitionState(evidence: const [], research: const []);

  /// Canonical JSON the admin can copy back into the repo asset files. Evidence
  /// and research are emitted as two separate, ready-to-paste documents.
  Map<String, String> toAssetJson() {
    final evidenceDoc = {
      'schemaVersion': '1.0',
      'domain': 'knowledge_evidence',
      'records': [
        for (final e in (evidence.toList()..sort((a, b) => a.id.compareTo(b.id))))
          KnowledgeAcquisitionEngine.evidenceToMap(e),
      ],
    };
    final researchDoc = {
      'schemaVersion': '1.0',
      'domain': 'knowledge_research',
      'records': [
        for (final r
            in (research.toList()..sort((a, b) => a.id.compareTo(b.id))))
          KnowledgeAcquisitionEngine.researchToMap(r),
      ],
    };
    const encoder = JsonEncoder.withIndent('  ');
    return {
      'evidence.knowme.json': encoder.convert(evidenceDoc),
      'research.knowme.json': encoder.convert(researchDoc),
    };
  }
}

/// A relationship conflict surfaced by an import (research records disagree on
/// the relation asserted for a directed pair).
class AcquisitionConflict {
  const AcquisitionConflict({
    required this.pairKey,
    required this.relations,
    required this.recordIds,
  });

  final String pairKey;
  final Set<String> relations;
  final List<String> recordIds;
}

/// Result of validating / previewing / applying a batch.
class AcquisitionImportReport {
  AcquisitionImportReport({
    required this.batchId,
    required List<AcquisitionRecordOutcome> outcomes,
    required List<AcquisitionConflict> conflicts,
    required List<String> fatalErrors,
    required this.resultState,
  })  : outcomes = List.unmodifiable(outcomes),
        conflicts = List.unmodifiable(conflicts),
        fatalErrors = List.unmodifiable(fatalErrors);

  final String? batchId;
  final List<AcquisitionRecordOutcome> outcomes;
  final List<AcquisitionConflict> conflicts;

  /// Batch-level errors that prevented any import (e.g. malformed JSON).
  final List<String> fatalErrors;

  /// The corpus state that *would* result if this batch is applied (errored
  /// records excluded). Equal to the input state when [hasFatalError].
  final AcquisitionState resultState;

  Iterable<AcquisitionRecordOutcome> _of(AcquisitionOutcome o) =>
      outcomes.where((x) => x.outcome == o);

  int get imported => _of(AcquisitionOutcome.imported).length;
  int get updated => _of(AcquisitionOutcome.updated).length;
  int get skipped => _of(AcquisitionOutcome.skipped).length;
  int get errors => _of(AcquisitionOutcome.error).length;
  int get conflictCount => conflicts.length;

  bool get hasFatalError => fatalErrors.isNotEmpty;

  /// True when nothing would change (no imports/updates and no fatal error).
  bool get isNoOp => imported == 0 && updated == 0 && !hasFatalError;

  List<String> toReportLines() => [
        'Knowledge Acquisition — Import Report'
            '${batchId != null ? ' [$batchId]' : ''}',
        'Imported : $imported',
        'Updated  : $updated',
        'Skipped  : $skipped',
        'Conflicts: $conflictCount',
        'Errors   : ${errors + fatalErrors.length}',
        if (hasFatalError) ...fatalErrors.map((e) => '  ! $e'),
      ];
}

/// Pure, deterministic merge + validation for acquisition batches.
abstract final class KnowledgeAcquisitionEngine {
  /// Dry-run: validate a batch against [base] and produce the report + the
  /// resulting state. Does not mutate anything.
  static AcquisitionImportReport preview(AcquisitionState base, String batchJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(batchJson);
    } on FormatException catch (e) {
      return _fatal(base, 'invalid_json: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      return _fatal(base, 'invalid_shape: expected a JSON object');
    }
    final batchId = decoded['batchId'] is String
        ? decoded['batchId'] as String
        : null;

    final outcomes = <AcquisitionRecordOutcome>[];

    // --- evidence ---
    final evidenceById = {for (final e in base.evidence) e.id: e};
    final mergedEvidence = Map<String, EvidenceRecord>.from(evidenceById);
    final batchEvidenceIds = <String>{};
    final rawEvidence = decoded['evidence'];
    if (rawEvidence is List) {
      for (final raw in rawEvidence) {
        if (raw is! Map<String, dynamic>) {
          outcomes.add(const AcquisitionRecordOutcome(
              kind: 'evidence',
              id: '?',
              outcome: AcquisitionOutcome.error,
              detail: 'invalid_shape'));
          continue;
        }
        final id = raw['id'];
        final parsed = KnowledgeEvidenceEngine.evidenceRecordFromMap(raw);
        if (parsed == null) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'evidence',
              id: id is String ? id : '?',
              outcome: AcquisitionOutcome.error,
              detail: 'validation_failed'));
          continue;
        }
        if (!batchEvidenceIds.add(parsed.id)) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'evidence',
              id: parsed.id,
              outcome: AcquisitionOutcome.error,
              detail: 'duplicate_in_batch'));
          continue;
        }
        outcomes.add(AcquisitionRecordOutcome(
          kind: 'evidence',
          id: parsed.id,
          outcome: _classify(
            existing: evidenceById[parsed.id],
            incoming: parsed,
            toMap: evidenceToMap,
          ),
        ));
        mergedEvidence[parsed.id] = parsed;
      }
    }

    // --- research ---
    final researchById = {for (final r in base.research) r.id: r};
    final mergedResearch = Map<String, KnowledgeResearchRecord>.from(researchById);
    final batchResearchIds = <String>{};
    final touchedPairs = <String>{};
    final rawResearch = decoded['research'];
    if (rawResearch is List) {
      for (final raw in rawResearch) {
        if (raw is! Map<String, dynamic>) {
          outcomes.add(const AcquisitionRecordOutcome(
              kind: 'research',
              id: '?',
              outcome: AcquisitionOutcome.error,
              detail: 'invalid_shape'));
          continue;
        }
        final id = raw['id'];
        final parsed = KnowledgeResearchEngine.recordFromMap(raw);
        if (parsed == null) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'research',
              id: id is String ? id : '?',
              outcome: AcquisitionOutcome.error,
              detail: 'validation_failed'));
          continue;
        }
        if (!batchResearchIds.add(parsed.id)) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'research',
              id: parsed.id,
              outcome: AcquisitionOutcome.error,
              detail: 'duplicate_in_batch'));
          continue;
        }
        final badRelation = parsed.relationship
            .map((r) => r.relation)
            .firstWhere((rel) => !kAcquisitionRelations.contains(rel),
                orElse: () => '');
        if (badRelation.isNotEmpty) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'research',
              id: parsed.id,
              outcome: AcquisitionOutcome.error,
              detail: 'invalid_relation: $badRelation'));
          continue;
        }
        final missing = parsed.evidenceIds
            .where((eid) =>
                !mergedEvidence.containsKey(eid) &&
                !batchEvidenceIds.contains(eid))
            .toList();
        if (missing.isNotEmpty) {
          outcomes.add(AcquisitionRecordOutcome(
              kind: 'research',
              id: parsed.id,
              outcome: AcquisitionOutcome.error,
              detail: 'broken_link: ${missing.join(', ')}'));
          continue;
        }
        mergedResearch[parsed.id] = parsed;
        for (final rel in parsed.relationship) {
          touchedPairs.add(rel.pairKey);
        }
        outcomes.add(AcquisitionRecordOutcome(
          kind: 'research',
          id: parsed.id,
          outcome: _classify(
            existing: researchById[parsed.id],
            incoming: parsed,
            toMap: researchToMap,
          ),
        ));
      }
    }

    // --- conflicts (only for pairs touched by this batch) ---
    final allConflicts = KnowledgeResearchEngine(mergedResearch.values)
        .findConflicts()
        .where((c) => touchedPairs.contains(c.pairKey))
        .toList();
    final conflicts = [
      for (final c in allConflicts)
        AcquisitionConflict(
            pairKey: c.pairKey, relations: c.relations, recordIds: c.recordIds),
    ];
    final conflictRecordIds = {for (final c in conflicts) ...c.recordIds};

    // Re-stamp research outcomes that participate in a conflict.
    final finalOutcomes = [
      for (final o in outcomes)
        (o.kind == 'research' &&
                (o.outcome == AcquisitionOutcome.imported ||
                    o.outcome == AcquisitionOutcome.updated) &&
                conflictRecordIds.contains(o.id))
            ? AcquisitionRecordOutcome(
                kind: o.kind, id: o.id, outcome: o.outcome, conflict: true)
            : o,
    ];

    final result = AcquisitionState(
      evidence: mergedEvidence.values,
      research: mergedResearch.values,
    );

    return AcquisitionImportReport(
      batchId: batchId,
      outcomes: finalOutcomes,
      conflicts: conflicts,
      fatalErrors: const [],
      resultState: result,
    );
  }

  static AcquisitionImportReport _fatal(AcquisitionState base, String message) =>
      AcquisitionImportReport(
        batchId: null,
        outcomes: const [],
        conflicts: const [],
        fatalErrors: [message],
        resultState: base,
      );

  static AcquisitionOutcome _classify<T>({
    required T? existing,
    required T incoming,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    if (existing == null) return AcquisitionOutcome.imported;
    final a = jsonEncode(toMap(existing));
    final b = jsonEncode(toMap(incoming));
    return a == b ? AcquisitionOutcome.skipped : AcquisitionOutcome.updated;
  }

  // ---------------------------------------------------------------------------
  // canonical serialization (for diffing + export)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> evidenceToMap(EvidenceRecord e) => {
        'id': e.id,
        'sourceType': e.sourceType,
        'school': e.school,
        'author': e.author,
        'book': e.book,
        'edition': e.edition,
        'publisher': e.publisher,
        'year': e.year,
        'page': e.page,
        'language': e.language,
        'quote': e.quote,
        'summary': e.summary,
        'url': e.url,
        'license': e.license,
        'reviewStatus': e.reviewStatus.name,
        'reviewer': e.reviewer,
        'createdAt': e.createdAt?.toIso8601String(),
        'updatedAt': e.updatedAt?.toIso8601String(),
        'notes': e.notes,
      };

  static Map<String, dynamic> researchToMap(KnowledgeResearchRecord r) => {
        'id': r.id,
        'topic': r.topic,
        'entity': r.entity,
        'interpretation': r.interpretation,
        'relationship': [
          for (final rel in r.relationship)
            {'from': rel.from, 'to': rel.to, 'relation': rel.relation},
        ],
        'evidenceIds': r.evidenceIds,
        'confidence': r.confidence.name,
        'reviewedBy': r.reviewedBy,
        'status': r.status.name,
        'notes': r.notes,
      };
}

/// Stateful, in-session acquisition workbench: holds the working corpus, an undo
/// stack for rollback, and the history of applied import reports.
class KnowledgeAcquisitionSession {
  KnowledgeAcquisitionSession({required AcquisitionState initial})
      : _current = initial;

  AcquisitionState _current;
  final List<AcquisitionState> _undo = [];
  final List<AcquisitionImportReport> _history = [];

  AcquisitionState get state => _current;
  List<AcquisitionImportReport> get history => List.unmodifiable(_history);
  bool get canRollback => _undo.isNotEmpty;

  /// Dry-run validation/preview against the current state.
  AcquisitionImportReport preview(String batchJson) =>
      KnowledgeAcquisitionEngine.preview(_current, batchJson);

  /// Apply a batch: advances the working state (valid records merged, errored
  /// records skipped) and records the report. A fatal-error batch changes
  /// nothing. Returns the report.
  AcquisitionImportReport apply(String batchJson) {
    final report = preview(batchJson);
    if (report.hasFatalError || report.isNoOp) return report;
    _undo.add(_current);
    _current = report.resultState;
    _history.add(report);
    return report;
  }

  /// Undo the most recent applied import. Returns the report that was undone.
  AcquisitionImportReport? rollback() {
    if (_undo.isEmpty) return null;
    _current = _undo.removeLast();
    return _history.isEmpty ? null : _history.removeLast();
  }
}
