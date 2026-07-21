import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// Outcome of resolving all nodes for one subject.
enum CanonResolutionOutcome {
  /// Canon (Tier 1) speaks; its statement is authoritative.
  canonical,

  /// Canon nodes disagree with each other (canon vs canon) — needs a human;
  /// the layer never silently picks a winner among canon.
  canonInternalConflict,

  /// No canon node; only supporting sources (Tier 2–4) — provisional.
  supportingOnly,

  /// No nodes at all.
  empty,
}

/// The resolved knowledge for one subject after applying the Source Priority.
///
/// **Canon always wins:** when any Tier-1 canonical node exists, it is the
/// authority. Supporting nodes (Tier 2–4) are kept to *add detail, examples and
/// explanation* ([supporting]); supporting nodes whose [value] contradicts Canon
/// are recorded in [overruledByCanon] for transparency but never applied.
class CanonResolution {
  const CanonResolution({
    required this.topic,
    required this.subject,
    required this.outcome,
    required this.canon,
    required this.supporting,
    required this.overruledByCanon,
    required this.value,
    required this.rationale,
  });

  final String topic;
  final String subject;
  final CanonResolutionOutcome outcome;

  /// The authoritative canon nodes (empty unless [outcome] is canonical/
  /// canonInternalConflict).
  final List<CanonicalKnowledgeNode> canon;

  /// Supporting nodes that elaborate the resolved knowledge (do not contradict).
  final List<CanonicalKnowledgeNode> supporting;

  /// Supporting nodes whose [value] contradicts Canon — overruled, kept only for
  /// transparency.
  final List<CanonicalKnowledgeNode> overruledByCanon;

  /// The resolved normalized assertion when one exists (rule-type subjects).
  final String? value;

  final String rationale;

  String get subjectKey => '$topic::$subject';
  bool get isCanonical => outcome == CanonResolutionOutcome.canonical;
  bool get needsHumanReview =>
      outcome == CanonResolutionOutcome.canonInternalConflict;
}

/// Applies the Source Priority ladder to nodes. Pure and deterministic.
abstract final class CanonConflictResolver {
  /// Resolve a single subject's nodes.
  static CanonResolution resolveSubject(
    List<CanonicalKnowledgeNode> nodes,
  ) {
    if (nodes.isEmpty) {
      return const CanonResolution(
        topic: '',
        subject: '',
        outcome: CanonResolutionOutcome.empty,
        canon: [],
        supporting: [],
        overruledByCanon: [],
        value: null,
        rationale: 'No nodes.',
      );
    }
    final topic = nodes.first.topic;
    final subject = nodes.first.subject;

    final canon = nodes.where((n) => n.tier.isCanon).toList();
    final supporting = nodes
        .where((n) => n.tier.isSupporting)
        .toList()
      ..sort(_byTierThenConfidence);

    if (canon.isNotEmpty) {
      // Canon vs canon: if canon nodes carry differing values, that's an
      // internal conflict we never auto-resolve.
      final canonValues = canon
          .map((n) => n.value)
          .where((v) => v != null && v.trim().isNotEmpty)
          .toSet();
      if (canonValues.length > 1) {
        return CanonResolution(
          topic: topic,
          subject: subject,
          outcome: CanonResolutionOutcome.canonInternalConflict,
          canon: canon,
          supporting: supporting,
          overruledByCanon: const [],
          value: null,
          rationale:
              'Canon nodes disagree (${canonValues.join(' vs ')}); human review '
              'required. Supporting sources cannot break a canon-vs-canon tie.',
        );
      }

      final canonValue = canonValues.isEmpty ? null : canonValues.single;
      final overruled = <CanonicalKnowledgeNode>[];
      final elaborating = <CanonicalKnowledgeNode>[];
      for (final s in supporting) {
        if (canonValue != null &&
            s.value != null &&
            s.value!.trim().isNotEmpty &&
            s.value != canonValue) {
          overruled.add(s);
        } else {
          elaborating.add(s);
        }
      }

      return CanonResolution(
        topic: topic,
        subject: subject,
        outcome: CanonResolutionOutcome.canonical,
        canon: canon,
        supporting: elaborating,
        overruledByCanon: overruled,
        value: canonValue,
        rationale: overruled.isEmpty
            ? 'Canon is authoritative; ${elaborating.length} supporting '
                'source(s) add detail.'
            : 'Canon is authoritative; ${overruled.length} contradicting '
                'supporting source(s) overruled (kept for transparency).',
      );
    }

    // No canon: supporting-only (provisional).
    final values = supporting
        .map((n) => n.value)
        .where((v) => v != null && v.trim().isNotEmpty)
        .toSet();
    final topValue = _highestAuthorityValue(supporting);
    return CanonResolution(
      topic: topic,
      subject: subject,
      outcome: CanonResolutionOutcome.supportingOnly,
      canon: const [],
      supporting: supporting,
      overruledByCanon: const [],
      value: topValue,
      rationale: values.length > 1
          ? 'No canon node; supporting sources disagree '
              '(${values.join(' vs ')}). Provisional — Canon needed.'
          : 'No canon node; supporting only. Provisional until Canon covers it.',
    );
  }

  /// Resolve every subject across [nodes]. Keyed by `topic::subject`, sorted.
  static Map<String, CanonResolution> resolveAll(
    Iterable<CanonicalKnowledgeNode> nodes,
  ) {
    final bySubject = <String, List<CanonicalKnowledgeNode>>{};
    for (final n in nodes) {
      (bySubject[n.subjectKey] ??= []).add(n);
    }
    final out = <String, CanonResolution>{};
    final keys = bySubject.keys.toList()..sort();
    for (final key in keys) {
      out[key] = resolveSubject(bySubject[key]!);
    }
    return out;
  }

  // --- helpers ---------------------------------------------------------------

  static int _byTierThenConfidence(
    CanonicalKnowledgeNode a,
    CanonicalKnowledgeNode b,
  ) {
    final byTier = a.tier.priority.compareTo(b.tier.priority);
    if (byTier != 0) return byTier;
    return b.confidence.index.compareTo(a.confidence.index);
  }

  static String? _highestAuthorityValue(List<CanonicalKnowledgeNode> sorted) {
    for (final n in sorted) {
      if (n.value != null && n.value!.trim().isNotEmpty) return n.value;
    }
    return null;
  }
}
