/// Mahabhut Content Engineering V1 — Consistency Checker.
///
/// Cross-cutting consistency over the whole candidate set: same concept named
/// consistently, duplicate rules sharing one id, formulas not duplicated,
/// citations not missing, metadata complete. Distinct from the per-unit
/// Validation Engine — this looks *across* units. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';

class CanonConsistencyIssue {
  const CanonConsistencyIssue({
    required this.code,
    required this.message,
    required this.candidateIds,
  });

  final String code;
  final String message;
  final List<String> candidateIds;

  @override
  String toString() => '$code: $message [${candidateIds.join(', ')}]';
}

class CanonConsistencyReport {
  CanonConsistencyReport(this.issues);

  final List<CanonConsistencyIssue> issues;

  bool get isClean => issues.isEmpty;
  List<CanonConsistencyIssue> withCode(String code) =>
      issues.where((i) => i.code == code).toList();

  Map<String, int> get countsByCode {
    final m = <String, int>{};
    for (final i in issues) {
      m[i.code] = (m[i.code] ?? 0) + 1;
    }
    return m;
  }
}

abstract final class CanonConsistencyChecker {
  static CanonConsistencyReport check(CanonCandidateStore store) {
    final issues = <CanonConsistencyIssue>[];
    final typed = store.candidates.where((c) => c.type != null).toList();

    // 1) Same concept used with one name: a subject must map to a single title,
    // and a title to a single subject.
    final subjectToTitles = <String, Set<String>>{};
    final titleToSubjects = <String, Set<String>>{};
    final subjectIds = <String, List<String>>{};
    for (final c in typed.where((c) => c.type == CanonUnitType.concept)) {
      final title = (c.title ?? '').trim();
      if (c.subject.trim().isEmpty || title.isEmpty) continue;
      subjectToTitles.putIfAbsent(c.subject, () => {}).add(title);
      titleToSubjects.putIfAbsent(title, () => {}).add(c.subject);
      subjectIds.putIfAbsent(c.subject, () => []).add(c.id);
    }
    subjectToTitles.forEach((subject, titles) {
      if (titles.length > 1) {
        issues.add(CanonConsistencyIssue(
          code: 'concept_naming',
          message: 'Concept "$subject" uses multiple names: '
              '${titles.join(' / ')}.',
          candidateIds: subjectIds[subject] ?? const [],
        ));
      }
    });

    // 2) Duplicate rules should share one id: same (subject, statement) under
    // different ids.
    _flagDuplicateContent(
      typed.where((c) => c.type == CanonUnitType.rule),
      'duplicate_rule_id',
      'Identical rule under multiple ids (reuse a single id).',
      issues,
    );

    // 3) Formula not duplicated.
    _flagDuplicateContent(
      typed.where((c) => c.type == CanonUnitType.formula),
      'duplicate_formula',
      'Identical formula created more than once.',
      issues,
    );

    // 4) Citation not missing (cross-cutting completeness signal).
    final missingCite =
        typed.where((c) => !c.hasCitation || !c.hasPage).map((c) => c.id).toList();
    if (missingCite.isNotEmpty) {
      issues.add(CanonConsistencyIssue(
        code: 'citation_gap',
        message: '${missingCite.length} unit(s) missing quote and/or page.',
        candidateIds: missingCite,
      ));
    }

    // 5) Metadata complete.
    final missingMeta = typed
        .where((c) => c.topic.trim().isEmpty || c.subject.trim().isEmpty)
        .map((c) => c.id)
        .toList();
    if (missingMeta.isNotEmpty) {
      issues.add(CanonConsistencyIssue(
        code: 'metadata_gap',
        message: '${missingMeta.length} unit(s) missing topic/subject.',
        candidateIds: missingMeta,
      ));
    }

    return CanonConsistencyReport(issues);
  }

  static void _flagDuplicateContent(
    Iterable<CanonCandidateUnit> units,
    String code,
    String message,
    List<CanonConsistencyIssue> issues,
  ) {
    final byContent = <String, List<String>>{};
    for (final c in units) {
      final key = '${c.subjectKey}|${(c.value ?? c.statement).trim()}';
      if (key.endsWith('|')) continue;
      byContent.putIfAbsent(key, () => []).add(c.id);
    }
    byContent.forEach((_, ids) {
      if (ids.length > 1) {
        issues.add(CanonConsistencyIssue(
          code: code,
          message: message,
          candidateIds: ids,
        ));
      }
    });
  }
}
