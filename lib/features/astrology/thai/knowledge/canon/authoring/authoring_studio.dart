/// Canon Knowledge Authoring Studio V1 — the draft workspace.
///
/// The **official human editing layer** that sits *before* the Workspace. A
/// reviewer converts one book page into draft Atomic Knowledge Units, batch-edits
/// them, previews validation **using the exact same Workspace validator**, then
/// hands a session to the Workspace for import. Nothing here is Canon.
///
/// Pure Dart; depends on the atomic + ontology + workspace layers (read-only).
/// No engine/runtime/UI dependency.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/canon_completeness_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/authoring/draft_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/authoring/ontology_assist.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_extraction_session.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/review_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/workspace_validator.dart';

/// Result of an editing operation (deterministic, never throws on misuse).
class EditResult {
  const EditResult(this.ok, [this.reason]);
  final bool ok;
  final String? reason;
  static const EditResult success = EditResult(true);
}

class AuthoringStudio {
  AuthoringStudio({
    required this.id,
    required this.source,
    List<DraftKnowledgeUnit>? drafts,
    int seq = 0,
  })  : drafts = drafts ?? <DraftKnowledgeUnit>[],
        _seq = seq;

  final String id;
  final ExtractionSource source;
  final List<DraftKnowledgeUnit> drafts;
  int _seq;

  int get seq => _seq;

  String _newId() {
    _seq += 1;
    return '$id-u${_seq.toString().padLeft(3, '0')}';
  }

  int _indexOf(String draftId) => drafts.indexWhere((d) => d.id == draftId);

  /// Default evidence seeded from the page being authored (reference only).
  AtomicEvidenceRef get _pageEvidence => AtomicEvidenceRef(
        bookId: source.bookId,
        chapter: source.chapter,
        page: source.pageStart?.toString(),
      );

  // ---- Authoring ---------------------------------------------------------

  DraftKnowledgeUnit addDraft({
    String subject = '',
    String object = '',
    AtomicEvidenceRef? evidence,
    void Function(DraftKnowledgeUnit draft)? edit,
  }) {
    final d = DraftKnowledgeUnit(
      id: _newId(),
      subject: subject,
      object: object,
      evidence: evidence ?? _pageEvidence,
    );
    edit?.call(d);
    drafts.add(d);
    return d;
  }

  // ---- Batch editing (editing only; output stays atomic) -----------------

  /// Duplicate a draft; the copy is inserted immediately after the original.
  EditResult duplicate(String draftId) {
    final i = _indexOf(draftId);
    if (i < 0) return const EditResult(false, 'draft not found');
    drafts.insert(i + 1, drafts[i].cloneWith(_newId()));
    return EditResult.success;
  }

  /// Split one draft into several atomic drafts — one per object value. The
  /// original is replaced in place by the new drafts (subject/relation kept).
  EditResult split(String draftId, List<String> objects) {
    final i = _indexOf(draftId);
    if (i < 0) return const EditResult(false, 'draft not found');
    if (objects.isEmpty) return const EditResult(false, 'no objects to split into');
    final base = drafts[i];
    final replacements = [
      for (final obj in objects) base.cloneWith(_newId(), object: obj),
    ];
    drafts.removeAt(i);
    drafts.insertAll(i, replacements);
    return EditResult.success;
  }

  /// Merge duplicate drafts (same fact). Keeps the first, drops the rest, and
  /// keeps the strongest confidence / a referenced evidence. Rejected when the
  /// drafts assert different facts — merging must never break atomicity.
  EditResult merge(List<String> ids) {
    if (ids.length < 2) return const EditResult(false, 'need at least two drafts');
    final targets = <DraftKnowledgeUnit>[];
    for (final id in ids) {
      final i = _indexOf(id);
      if (i < 0) return EditResult(false, 'draft not found: $id');
      targets.add(drafts[i]);
    }
    final factKey = targets.first.factKey;
    if (targets.any((d) => d.factKey != factKey)) {
      return const EditResult(
          false, 'drafts assert different facts; cannot merge atomically');
    }
    final keep = targets.first;
    for (final d in targets) {
      if (d.confidence.index > keep.confidence.index) {
        keep.confidence = d.confidence;
      }
      if (!keep.evidence.hasReference && d.evidence.hasReference) {
        keep.evidence = d.evidence;
      }
    }
    for (final d in targets.skip(1)) {
      drafts.removeWhere((x) => x.id == d.id);
    }
    return EditResult.success;
  }

  EditResult delete(String draftId) {
    final i = _indexOf(draftId);
    if (i < 0) return const EditResult(false, 'draft not found');
    drafts.removeAt(i);
    return EditResult.success;
  }

  EditResult reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= drafts.length) {
      return const EditResult(false, 'oldIndex out of range');
    }
    if (newIndex < 0 || newIndex >= drafts.length) {
      return const EditResult(false, 'newIndex out of range');
    }
    final d = drafts.removeAt(oldIndex);
    drafts.insert(newIndex, d);
    return EditResult.success;
  }

  // ---- Ontology assistance ----------------------------------------------

  List<DraftAssist> assist(CanonicalOntology ontology) =>
      OntologyAssist.forDrafts(ontology, drafts);

  bool allResolved(CanonicalOntology ontology) =>
      OntologyAssist.allResolved(ontology, drafts);

  // ---- Bridge to the Workspace (no duplicated logic) ---------------------

  List<AtomicKnowledgeUnit> toAtomicUnits() =>
      [for (final d in drafts) d.toAtomic()];

  /// The session handed to the Workspace. Always starts in Draft.
  KnowledgeExtractionSession toSession() => KnowledgeExtractionSession(
        id: id,
        source: source,
        units: toAtomicUnits(),
      );

  /// Validation preview — the **exact** Workspace validator, not a copy.
  WorkspaceValidationReport validate(
    CanonicalOntology ontology, {
    Iterable<AtomicKnowledgeUnit> baseline = const [],
  }) =>
      WorkspaceValidator.validate(toSession(), ontology, baseline: baseline);

  /// Full preview (validation + diff + coverage impact) via the Workspace's
  /// own `ReviewReport`.
  ReviewReport preview(
    CanonicalOntology ontology, {
    Iterable<AtomicKnowledgeUnit> baseline = const [],
    CanonCompletenessSpec spec = CanonCompletenessSpec.structural,
  }) =>
      ReviewReport.build(toSession(), ontology, baseline: baseline, spec: spec);

  // ---- Export / import ---------------------------------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'seq': _seq,
        'source': source.toJson(),
        'drafts': [for (final d in drafts) d.toJson()],
      };

  /// Reproduces the identical editing state (ids, order, seq, all fields).
  static AuthoringStudio fromJson(Map<String, dynamic> m) {
    final source = m['source'] is Map<String, dynamic>
        ? ExtractionSource.fromJson(m['source'] as Map<String, dynamic>)
        : null;
    final drafts = <DraftKnowledgeUnit>[
      for (final d in (m['drafts'] as List? ?? const []))
        if (d is Map<String, dynamic>) DraftKnowledgeUnit.fromJson(d),
    ];
    return AuthoringStudio(
      id: (m['id'] as String?)?.trim() ?? 'studio',
      source: source ?? const ExtractionSource(bookId: ''),
      drafts: drafts,
      seq: (m['seq'] as int?) ?? 0,
    );
  }
}
