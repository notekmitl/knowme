/// Canon Atomic Knowledge V2 — extraction rules.
///
/// Enforces the **Atomic Knowledge Rule**: one fact / one meaning / one rule.
/// The extraction pipeline must *reject* paragraphs, summaries, rewritten
/// narrative, interpretation and prediction, and only admit structured atomic
/// facts (entity / relationship / condition / effect / exception / confidence /
/// evidence).
///
/// Deterministic, pure Dart. No Flutter/engine/runtime imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';

enum CanonInputVerdict { atomic, narrative }

class CanonInputDecision {
  const CanonInputDecision(this.verdict, [this.reason]);

  final CanonInputVerdict verdict;
  final String? reason;

  bool get isAtomic => verdict == CanonInputVerdict.atomic;
}

class AtomicIssue {
  const AtomicIssue(this.unitId, this.code, this.message);
  final String unitId;
  final String code;
  final String message;

  @override
  String toString() => '$code ($unitId): $message';
}

abstract final class AtomicExtractionRules {
  /// Maximum words an atomic *token* (subject/object/condition/effect) may have
  /// before it is treated as prose rather than a structured value.
  static const int maxTokenWords = 6;

  /// Narrative marker words — their presence signals prose/interpretation/
  /// prediction rather than an atomic fact. Deterministic and intentionally
  /// conservative (English + a few Thai connectives).
  static const List<String> narrativeMarkers = [
    'usually',
    'often',
    'brings',
    'success',
    'because',
    'therefore',
    'tends',
    'might',
    'may',
    'will likely',
    'suggests',
    'indicates that',
    'มักจะ',
    'ส่งผลให้',
    'เพราะ',
    'ดังนั้น',
  ];

  /// Classify a raw text fragment. A fragment is *narrative* when it reads like a
  /// sentence/paragraph: multiple sentences, too many words, or a narrative
  /// marker word. Atomic tokens are short, single-idea values.
  static CanonInputDecision classify(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const CanonInputDecision(
          CanonInputVerdict.narrative, 'empty input');
    }
    final lower = text.toLowerCase();

    // Multiple sentences → narrative.
    final sentenceTerminators = RegExp(r'[.!?。]').allMatches(text).length;
    if (sentenceTerminators >= 1 && _wordCount(text) > maxTokenWords) {
      return const CanonInputDecision(
          CanonInputVerdict.narrative, 'reads like a sentence/paragraph');
    }

    // Too long → prose, not an atomic token.
    if (_wordCount(text) > maxTokenWords) {
      return CanonInputDecision(CanonInputVerdict.narrative,
          'too many words (> $maxTokenWords) — summarise into atomic units');
    }

    // Narrative marker words.
    for (final m in narrativeMarkers) {
      if (lower.contains(m)) {
        return CanonInputDecision(
            CanonInputVerdict.narrative, 'narrative marker: "$m"');
      }
    }

    // Conjunction joining multiple ideas → not atomic.
    if (RegExp(r'\b(and|or)\b').hasMatch(lower) || text.contains(' และ ')) {
      return const CanonInputDecision(
          CanonInputVerdict.narrative, 'joins multiple ideas (split them)');
    }

    return const CanonInputDecision(CanonInputVerdict.atomic);
  }

  /// True when [token] is an acceptable atomic value.
  static bool isAtomicToken(String? token) =>
      token != null && classify(token).isAtomic;

  /// Validate a single atomic unit. Returns the issues that make it non-atomic
  /// or untraceable; an empty list means the unit is a valid atomic fact.
  static List<AtomicIssue> validateUnit(AtomicKnowledgeUnit u) {
    final issues = <AtomicIssue>[];
    void bad(String code, String msg) => issues.add(AtomicIssue(u.id, code, msg));

    if (u.subject.trim().isEmpty) bad('empty_subject', 'Subject is empty.');
    if (u.object.trim().isEmpty) bad('empty_object', 'Object is empty.');

    final subjectDecision = classify(u.subject);
    if (!subjectDecision.isAtomic) {
      bad('non_atomic_subject',
          'Subject is not atomic: ${subjectDecision.reason}.');
    }
    final objectDecision = classify(u.object);
    if (!objectDecision.isAtomic) {
      bad('non_atomic_object',
          'Object is not atomic: ${objectDecision.reason}.');
    }
    if (u.condition != null && !isAtomicToken(u.condition)) {
      bad('non_atomic_condition', 'Condition is not an atomic token.');
    }
    if (u.effect != null && !isAtomicToken(u.effect)) {
      bad('non_atomic_effect', 'Effect is not an atomic token.');
    }

    // Traceability by reference (D-057).
    if (!u.evidence.hasReference) {
      bad('missing_reference', 'No book reference (page/chapter/section).');
    }
    return issues;
  }

  /// Validate a whole set of atomic units (per-unit atomicity + duplicate id).
  static List<AtomicIssue> validateAll(Iterable<AtomicKnowledgeUnit> units) {
    final issues = <AtomicIssue>[];
    final seenIds = <String>{};
    for (final u in units) {
      if (!seenIds.add(u.id)) {
        issues.add(AtomicIssue(u.id, 'duplicate_id', 'Duplicate unit id.'));
      }
      issues.addAll(validateUnit(u));
    }
    return issues;
  }

  static bool isAtomic(AtomicKnowledgeUnit u) => validateUnit(u).isEmpty;

  static int _wordCount(String s) =>
      s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
