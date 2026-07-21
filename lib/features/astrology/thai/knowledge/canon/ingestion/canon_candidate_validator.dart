/// Mahabhut Ingestion Toolchain V1 — Validation Engine.
///
/// Gates candidates before they may become `validated`. Checks: Required
/// Fields, Duplicate, Broken Reference, Missing Citation, Missing Page, Invalid
/// Cross Reference, Empty Rule, Empty Concept. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';

enum CanonValidationSeverity { error, warning }

class CanonValidationIssue {
  const CanonValidationIssue(
    this.severity,
    this.code,
    this.message, {
    required this.candidateId,
  });

  final CanonValidationSeverity severity;
  final String code;
  final String message;
  final String candidateId;

  bool get isError => severity == CanonValidationSeverity.error;

  @override
  String toString() =>
      '[${severity.name}] $code ($candidateId): $message';
}

/// Per-candidate and store-wide validation outcome.
class CanonValidationReport {
  CanonValidationReport(this.issues);

  final List<CanonValidationIssue> issues;

  bool get isClean => issues.every((i) => !i.isError);
  List<CanonValidationIssue> get errors => issues.where((i) => i.isError).toList();

  List<CanonValidationIssue> forCandidate(String id) =>
      issues.where((i) => i.candidateId == id).toList();
  bool isCandidateClean(String id) =>
      forCandidate(id).every((i) => !i.isError);

  Map<String, int> get countsByCode {
    final m = <String, int>{};
    for (final i in issues) {
      m[i.code] = (m[i.code] ?? 0) + 1;
    }
    return m;
  }
}

abstract final class CanonCandidateValidator {
  /// Validate every candidate in [store]. [knownIds] supplies extra ids that
  /// cross-references may legitimately target (e.g. ids already in the Canon
  /// Database) so promoted batches still validate.
  static CanonValidationReport validate(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) {
    final issues = <CanonValidationIssue>[];
    final ids = store.candidates.map((c) => c.id).toSet();
    final resolvable = {...ids, ...knownIds};

    // Duplicate detection by (type, subjectKey, statement).
    final seen = <String, String>{};

    for (final c in store.candidates) {
      void err(String code, String msg) => issues
          .add(CanonValidationIssue(CanonValidationSeverity.error, code, msg,
              candidateId: c.id));
      void warn(String code, String msg) => issues
          .add(CanonValidationIssue(CanonValidationSeverity.warning, code, msg,
              candidateId: c.id));

      // Required fields: a unit cannot be validated without a human-assigned
      // type/topic/subject and a statement.
      if (c.type == null) {
        err('required_fields', 'Missing "type" (assign during review).');
      }
      if (c.topic.trim().isEmpty) {
        err('required_fields', 'Missing "topic".');
      }
      if (c.subject.trim().isEmpty) {
        err('required_fields', 'Missing "subject".');
      }
      if (c.statement.trim().isEmpty) {
        err('required_fields', 'Missing "statement".');
      }

      // Empty rule / empty concept.
      if (c.type == CanonUnitType.rule && c.statement.trim().isEmpty) {
        err('empty_rule', 'Rule has no statement.');
      }
      if (c.type == CanonUnitType.concept && c.statement.trim().isEmpty) {
        err('empty_concept', 'Concept has no statement.');
      }

      // Traceability is by *reference* (page / chapter / section), never by a
      // stored copyrighted quote.
      if (!c.hasCitation) {
        err('missing_citation', 'No book reference (page/chapter/section).');
      }
      if (!c.hasPage) {
        err('missing_page', 'No page reference.');
      }

      // Cross references.
      for (final x in c.crossRefs) {
        if (!resolvable.contains(x.toId)) {
          err('broken_reference',
              'Cross-reference target "${x.toId}" not found.');
        }
        if (x.toId == c.id) {
          warn('invalid_cross_reference', 'Cross-reference points to itself.');
        }
        if (!_endpointTypeOk(x.type, c.type)) {
          warn('invalid_cross_reference',
              'Cross-reference type ${x.type.name} does not match source '
              'unit type ${c.type?.name ?? 'unset'}.');
        }
      }

      // Duplicate.
      if (c.type != null && c.statement.trim().isNotEmpty) {
        final key = '${c.type!.name}|${c.subjectKey}|${c.statement.trim()}';
        final prior = seen[key];
        if (prior != null) {
          err('duplicate',
              'Duplicate of "$prior" (same type/subject/statement).');
        } else {
          seen[key] = c.id;
        }
      }
    }

    return CanonValidationReport(issues);
  }

  /// Type-consistency for the directed cross-reference kinds that imply a source
  /// unit type. Permissive kinds (seeAlso/refines/dependsOn/contradicts/
  /// exampleOf/chapterToChapter) accept any source type.
  static bool _endpointTypeOk(CanonCrossReferenceType type, CanonUnitType? src) {
    switch (type) {
      case CanonCrossReferenceType.ruleToRule:
        return src == CanonUnitType.rule;
      case CanonCrossReferenceType.conceptToConcept:
        return src == CanonUnitType.concept;
      case CanonCrossReferenceType.conceptToFormula:
        return src == CanonUnitType.concept;
      case CanonCrossReferenceType.formulaToInterpretation:
        return src == CanonUnitType.formula;
      case CanonCrossReferenceType.chapterToChapter:
      case CanonCrossReferenceType.seeAlso:
      case CanonCrossReferenceType.refines:
      case CanonCrossReferenceType.dependsOn:
      case CanonCrossReferenceType.exampleOf:
      case CanonCrossReferenceType.contradicts:
        return true;
    }
  }
}
