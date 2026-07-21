/// Mahabhut Content Engineering V1 — Review Assistant.
///
/// A *helper only* for human reviewers. It surfaces highlights over candidates
/// (un-converted paragraphs, missing citation/page, duplicates, rules without a
/// cross-reference, missing metadata) and a pre-approval checklist. It composes
/// the existing Validation Engine and QA Tools — it does **not** add a parallel
/// checking system and it never creates or alters knowledge. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate_validator.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_qa_tools.dart';

enum CanonHighlightKind {
  unconverted,
  missingMetadata,
  missingCitation,
  missingPage,
  duplicate,
  ruleWithoutCrossRef,
  brokenCrossRef,
}

enum CanonHighlightSeverity { info, warning, error }

class CanonReviewAnnotation {
  const CanonReviewAnnotation({
    required this.candidateId,
    required this.kind,
    required this.severity,
    required this.message,
  });

  final String candidateId;
  final CanonHighlightKind kind;
  final CanonHighlightSeverity severity;
  final String message;
}

class CanonReviewResult {
  CanonReviewResult(this.annotations);

  final List<CanonReviewAnnotation> annotations;

  List<CanonReviewAnnotation> forCandidate(String id) =>
      annotations.where((a) => a.candidateId == id).toList();

  bool hasBlocking(String id) =>
      forCandidate(id).any((a) => a.severity == CanonHighlightSeverity.error);

  Map<CanonHighlightKind, int> get countsByKind {
    final m = <CanonHighlightKind, int>{};
    for (final a in annotations) {
      m[a.kind] = (m[a.kind] ?? 0) + 1;
    }
    return m;
  }
}

abstract final class CanonReviewAssistant {
  /// Build review highlights. Composes [CanonCandidateValidator] (the source of
  /// truth for errors) and [CanonQaTools] (orphan rules), then adds two
  /// reviewer-facing hints not covered there: *un-converted* paragraphs and
  /// *missing metadata* (warnings, never errors).
  static CanonReviewResult review(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) {
    final out = <CanonReviewAnnotation>[];

    // 1) Reuse the validation engine for the authoritative checks.
    final report =
        CanonCandidateValidator.validate(store, knownIds: knownIds);
    for (final i in report.issues) {
      final kind = _kindForCode(i.code);
      if (kind == null) continue;
      out.add(CanonReviewAnnotation(
        candidateId: i.candidateId,
        kind: kind,
        severity: i.isError
            ? CanonHighlightSeverity.error
            : CanonHighlightSeverity.warning,
        message: i.message,
      ));
    }

    // 2) Reuse QA tools for orphan rules (rule without any cross-reference).
    for (final f in CanonQaTools.orphanRule(store).findings) {
      out.add(CanonReviewAnnotation(
        candidateId: f.candidateId,
        kind: CanonHighlightKind.ruleWithoutCrossRef,
        severity: CanonHighlightSeverity.warning,
        message: f.detail,
      ));
    }

    // 3) Reviewer-only hints.
    for (final c in store.candidates) {
      if (c.type == null) {
        out.add(CanonReviewAnnotation(
          candidateId: c.id,
          kind: CanonHighlightKind.unconverted,
          severity: CanonHighlightSeverity.warning,
          message: 'Paragraph not yet converted to a Knowledge Unit '
              '(assign a type).',
        ));
      } else if (c.topic.trim().isEmpty ||
          c.subject.trim().isEmpty ||
          (c.title == null || c.title!.trim().isEmpty)) {
        out.add(CanonReviewAnnotation(
          candidateId: c.id,
          kind: CanonHighlightKind.missingMetadata,
          severity: CanonHighlightSeverity.warning,
          message: 'Metadata incomplete (topic/subject/title).',
        ));
      }
    }

    return CanonReviewResult(out);
  }

  static CanonHighlightKind? _kindForCode(String code) {
    switch (code) {
      case 'missing_citation':
        return CanonHighlightKind.missingCitation;
      case 'missing_page':
        return CanonHighlightKind.missingPage;
      case 'duplicate':
        return CanonHighlightKind.duplicate;
      case 'broken_reference':
      case 'invalid_cross_reference':
        return CanonHighlightKind.brokenCrossRef;
      case 'required_fields':
        return CanonHighlightKind.missingMetadata;
      default:
        return null; // empty_rule / empty_concept covered by required/QA
    }
  }
}

/// One row of the pre-approval review checklist.
class CanonChecklistItem {
  const CanonChecklistItem({
    required this.id,
    required this.label,
    required this.auto,
    this.check,
  });

  final String id;
  final String label;

  /// Whether the toolchain can verify this item automatically. Human-only items
  /// (verbatim fidelity, no added interpretation) have [auto] = false.
  final bool auto;

  /// Returns true/false for auto items, or null for manual items.
  final bool? Function(CanonCandidateUnit unit)? check;
}

enum CanonChecklistState { pass, fail, manual }

/// The canonical review checklist that gates `reviewed → canonApproved`.
abstract final class CanonReviewChecklist {
  static final List<CanonChecklistItem> standard = [
    const CanonChecklistItem(
      id: 'verbatim',
      label: 'Faithful to the source, recorded as structured knowledge '
          '(not copied paragraph text)',
      auto: false,
    ),
    CanonChecklistItem(
      id: 'citation',
      label: 'Book reference present (page / chapter / section)',
      auto: true,
      check: (u) => u.hasCitation,
    ),
    CanonChecklistItem(
      id: 'page',
      label: 'Page reference present and correct',
      auto: true,
      check: (u) => u.hasPage,
    ),
    const CanonChecklistItem(
      id: 'no_interpretation',
      label: 'No added interpretation beyond the book',
      auto: false,
    ),
    CanonChecklistItem(
      id: 'metadata',
      label: 'Metadata complete (type, topic, subject)',
      auto: true,
      check: (u) =>
          u.type != null && u.topic.trim().isNotEmpty && u.subject.trim().isNotEmpty,
    ),
    CanonChecklistItem(
      id: 'cross_refs',
      label: 'Cross references complete (rules link to related units)',
      auto: true,
      check: (u) => u.type != CanonUnitType.rule || u.crossRefs.isNotEmpty,
    ),
  ];

  /// Evaluate the auto-checkable items for [unit]; manual items return `manual`.
  static Map<String, CanonChecklistState> evaluate(CanonCandidateUnit unit) {
    final out = <String, CanonChecklistState>{};
    for (final item in standard) {
      if (!item.auto || item.check == null) {
        out[item.id] = CanonChecklistState.manual;
      } else {
        out[item.id] =
            item.check!(unit) == true ? CanonChecklistState.pass : CanonChecklistState.fail;
      }
    }
    return out;
  }

  /// True when no auto-checkable item is failing (manual items still need a
  /// human, but nothing automatic blocks approval).
  static bool autoClean(CanonCandidateUnit unit) =>
      evaluate(unit).values.every((s) => s != CanonChecklistState.fail);
}
