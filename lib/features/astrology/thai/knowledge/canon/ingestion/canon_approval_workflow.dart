/// Mahabhut Ingestion Toolchain V1 — Canon Approval Workflow.
///
/// Enforces the state machine `candidate → validated → reviewed → canonApproved`
/// with guards, and promotes approved candidates into a Canon Database patch
/// (entities ready to merge into `canon_database.knowme.json`). Pure Dart.
library;

import 'dart:convert';

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate_validator.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_extraction_engine.dart';

class CanonTransitionResult {
  const CanonTransitionResult(this.ok, this.message);
  final bool ok;
  final String message;
}

/// A set of Canon Database entities produced by promotion, serialisable into the
/// database JSON shape (books/chapters/sections/topics/units/evidence/
/// crossReferences/sourceReferences).
class CanonDatabasePatch {
  CanonDatabasePatch({
    this.chapters = const [],
    this.sections = const [],
    this.units = const [],
    this.evidence = const [],
    this.crossReferences = const [],
  });

  final List<CanonChapter> chapters;
  final List<CanonSection> sections;
  final List<CanonKnowledgeUnit> units;
  final List<CanonEvidence> evidence;
  final List<CanonCrossReference> crossReferences;

  Map<String, dynamic> toJson() => {
        'chapters': chapters
            .map((c) => {
                  'id': c.id,
                  'bookId': c.bookId,
                  if (c.number != null) 'number': c.number,
                  'title': c.title,
                })
            .toList(),
        'sections': sections
            .map((s) => {
                  'id': s.id,
                  'chapterId': s.chapterId,
                  'bookId': s.bookId,
                  'title': s.title,
                  if (s.topic != null) 'topic': s.topic,
                  if (s.pageStart != null) 'pageStart': s.pageStart,
                  if (s.pageEnd != null) 'pageEnd': s.pageEnd,
                })
            .toList(),
        'units': units.map(_unitJson).toList(),
        'evidence': evidence
            .map((e) => {
                  'id': e.id,
                  if (e.unitId != null) 'unitId': e.unitId,
                  if (e.page != null) 'page': e.page,
                  if (e.quote != null) 'quote': e.quote,
                })
            .toList(),
        'crossReferences': crossReferences
            .map((x) => {
                  'id': x.id,
                  'fromId': x.fromId,
                  'toId': x.toId,
                  'type': x.type.name,
                  if (x.note != null) 'note': x.note,
                })
            .toList(),
      };

  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(toJson());

  static Map<String, dynamic> _unitJson(CanonKnowledgeUnit u) => {
        'id': u.id,
        'type': u.type.name,
        'topic': u.topic,
        'subject': u.subject,
        if (u.title != null) 'title': u.title,
        'statement': u.statement,
        if (u.value != null) 'value': u.value,
        'confidence': u.confidence.name,
        'validationStatus': u.validationStatus.name,
        'location': {
          'bookId': u.location.bookId,
          if (u.location.chapterId != null) 'chapterId': u.location.chapterId,
          if (u.location.sectionId != null) 'sectionId': u.location.sectionId,
          if (u.location.topicId != null) 'topicId': u.location.topicId,
          if (u.location.page != null) 'page': u.location.page,
        },
        'evidenceIds': u.evidenceIds,
        'crossReferenceIds': u.crossReferenceIds,
        'conditions': u.conditions,
        'exceptions': u.exceptions,
      };
}

abstract final class CanonApprovalWorkflow {
  /// Move a candidate to `validated` — only from `candidate` and only if it has
  /// no validation errors.
  static CanonTransitionResult validate(
    CanonCandidateStore store,
    String id, {
    Set<String> knownIds = const {},
  }) {
    final c = store.byId(id);
    if (c == null) return const CanonTransitionResult(false, 'Unknown candidate.');
    if (c.status != CanonCandidateStatus.candidate) {
      return CanonTransitionResult(
          false, 'Can only validate from "candidate" (is ${c.status.name}).');
    }
    final report =
        CanonCandidateValidator.validate(store, knownIds: knownIds);
    if (!report.isCandidateClean(id)) {
      return CanonTransitionResult(false,
          'Validation failed: ${report.forCandidate(id).where((i) => i.isError).map((i) => i.code).join(', ')}.');
    }
    c.status = CanonCandidateStatus.validated;
    return const CanonTransitionResult(true, 'Validated.');
  }

  /// Move `validated → reviewed` (the human review gate).
  static CanonTransitionResult review(CanonCandidateStore store, String id) {
    final c = store.byId(id);
    if (c == null) return const CanonTransitionResult(false, 'Unknown candidate.');
    if (c.status != CanonCandidateStatus.validated) {
      return CanonTransitionResult(
          false, 'Can only review from "validated" (is ${c.status.name}).');
    }
    c.status = CanonCandidateStatus.reviewed;
    return const CanonTransitionResult(true, 'Reviewed.');
  }

  /// Move `reviewed → canonApproved`.
  static CanonTransitionResult approve(CanonCandidateStore store, String id) {
    final c = store.byId(id);
    if (c == null) return const CanonTransitionResult(false, 'Unknown candidate.');
    if (c.status != CanonCandidateStatus.reviewed) {
      return CanonTransitionResult(
          false, 'Can only approve from "reviewed" (is ${c.status.name}).');
    }
    c.status = CanonCandidateStatus.canonApproved;
    return const CanonTransitionResult(true, 'Canon approved.');
  }

  /// Promote all `canonApproved` candidates into a Canon Database patch. Builds
  /// one [CanonKnowledgeUnit] + [CanonEvidence] per candidate, plus
  /// [CanonChapter]/[CanonSection] from [extraction], and emits example units +
  /// `exampleOf` cross-references for any candidate `examples`.
  static CanonDatabasePatch promote(
    CanonCandidateStore store, {
    CanonExtractionResult? extraction,
  }) {
    final units = <CanonKnowledgeUnit>[];
    final evidence = <CanonEvidence>[];
    final crossRefs = <CanonCrossReference>[];

    for (final c in store.withStatus(CanonCandidateStatus.canonApproved)) {
      final evId = '${c.id}-e';
      evidence.add(CanonEvidence(
        id: evId,
        unitId: c.id,
        page: c.page,
        quote: c.evidenceQuote,
      ));
      final xrefIds = <String>[];
      var xi = 0;
      for (final x in c.crossRefs) {
        xi++;
        final xid = '${c.id}-x${xi.toString().padLeft(2, '0')}';
        crossRefs.add(CanonCrossReference(
          id: xid,
          fromId: c.id,
          toId: x.toId,
          type: x.type,
          note: x.note,
        ));
        xrefIds.add(xid);
      }
      // Example sub-units, linked back to the parent via exampleOf.
      var ei = 0;
      for (final ex in c.examples) {
        ei++;
        final exId = '${c.id}-ex${ei.toString().padLeft(2, '0')}';
        units.add(CanonKnowledgeUnit(
          id: exId,
          type: CanonUnitType.example,
          topic: c.topic,
          subject: c.subject,
          statement: ex,
          location: CanonLocation(
            bookId: c.bookId,
            chapterId: c.chapterId,
            sectionId: c.sectionId,
            topicId: c.topicId,
            page: c.page,
          ),
          validationStatus: CanonValidationStatus.canonApproved,
          confidence: c.confidence,
        ));
        final xid = '$exId-of';
        crossRefs.add(CanonCrossReference(
          id: xid,
          fromId: exId,
          toId: c.id,
          type: CanonCrossReferenceType.exampleOf,
        ));
      }

      units.add(CanonKnowledgeUnit(
        id: c.id,
        type: c.type ?? CanonUnitType.concept,
        topic: c.topic,
        subject: c.subject,
        statement: c.statement,
        title: c.title,
        value: c.value,
        location: CanonLocation(
          bookId: c.bookId,
          chapterId: c.chapterId,
          sectionId: c.sectionId,
          topicId: c.topicId,
          page: c.page,
        ),
        confidence: c.confidence,
        validationStatus: CanonValidationStatus.canonApproved,
        evidenceIds: [evId],
        crossReferenceIds: xrefIds,
        conditions: c.conditions,
        exceptions: c.exceptions,
        notes: c.extractionNotes.isEmpty ? null : c.extractionNotes.join(' | '),
      ));
    }

    return CanonDatabasePatch(
      chapters: extraction?.chapters ?? const [],
      sections: extraction?.sections ?? const [],
      units: units,
      evidence: evidence,
      crossReferences: crossRefs,
    );
  }
}
