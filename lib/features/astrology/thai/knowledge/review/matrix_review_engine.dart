import 'package:knowme/features/astrology/thai/knowledge/consensus/knowledge_consensus_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/sources/knowledge_source_engine.dart';

/// Thai Astrology — **Matrix Review** (V9).
///
/// Reviews the frozen relationship matrix against real evidence (the V8
/// consensus over V7 sources, plus user research from V3/V4) and produces a
/// **proposal**. It changes **no code**: it neither reads nor writes the engine
/// `PlanetRelationshipMatrix`. The "current matrix" value is taken from the V2
/// knowledge mirror (`PlanetRelationshipKnowledge`), which reflects the frozen
/// matrix for display only.

/// What the proposal recommends for one relationship.
enum MatrixRecommendation {
  /// Evidence agrees with the matrix, or there is not enough evidence.
  keep,

  /// Evidence disagrees but is not strong enough to act on alone.
  review,

  /// Evidence strongly and clearly disagrees with the matrix.
  replace,
}

/// One reviewed relationship.
class MatrixReviewRow {
  const MatrixReviewRow({
    required this.from,
    required this.to,
    required this.currentMatrix,
    required this.consensus,
    required this.supportingSourceIds,
    required this.conflictingSourceIds,
    required this.userResearchIds,
    required this.recommendation,
    required this.rationale,
  });

  final String from;
  final String to;

  /// Current matrix value (`friend` | `neutral` | `enemy`), from the V2 mirror.
  final String currentMatrix;
  final ConsensusEntry consensus;
  final List<String> supportingSourceIds;
  final List<String> conflictingSourceIds;
  final List<String> userResearchIds;
  final MatrixRecommendation recommendation;
  final String rationale;

  String get pairKey => '$from->$to';
}

/// Qualitative estimate of what acting on the proposal would touch.
class EngineImpactEstimate {
  const EngineImpactEstimate({
    required this.keep,
    required this.review,
    required this.replace,
  });

  final int keep;
  final int review;
  final int replace;

  /// Subsystems that consume planet-relationship values. Only `replace` rows
  /// would actually change behaviour; `review` rows need a human decision first.
  static const List<String> affectedSubsystems = [
    'timeline',
    'prediction',
    'decision',
    'compatibility',
    'conversation',
  ];

  bool get hasProposedChanges => replace > 0;

  List<String> toReportLines() => [
        'Engine impact estimate',
        '  Keep    : $keep',
        '  Review  : $review',
        '  Replace : $replace',
        if (hasProposedChanges)
          '  → $replace relationship(s) would change engine output, affecting: '
              '${affectedSubsystems.join(', ')}.'
        else
          '  → No relationship changes proposed; engine output unaffected.',
      ];
}

/// The full review proposal.
class MatrixReviewReport {
  const MatrixReviewReport({required this.rows, required this.impact});

  final List<MatrixReviewRow> rows;
  final EngineImpactEstimate impact;

  Iterable<MatrixReviewRow> _of(MatrixRecommendation r) =>
      rows.where((x) => x.recommendation == r);

  int get keep => _of(MatrixRecommendation.keep).length;
  int get review => _of(MatrixRecommendation.review).length;
  int get replace => _of(MatrixRecommendation.replace).length;

  List<String> toReportLines() => [
        'Thai Astrology — Matrix Review (proposal, no code change)',
        'Relationships reviewed : ${rows.length}',
        'Keep / Review / Replace: $keep / $review / $replace',
        ...impact.toReportLines(),
      ];
}

/// Builds a [MatrixReviewReport]. Pure: takes already-loaded inputs.
abstract final class MatrixReviewEngine {
  static MatrixReviewReport review({
    required PlanetRelationshipKnowledge knowledge,
    required KnowledgeConsensusEngine consensus,
    required KnowledgeSourceEngine sources,
    List<KnowledgeResearchRecord> research = const [],
  }) {
    // Current matrix mirror: directed pair -> relation name.
    final currentByPair = <String, String>{
      for (final r in knowledge.records)
        '${r.from.name}->${r.to.name}': r.relation.name,
    };

    // User-research record ids per directed pair.
    final researchByPair = <String, List<String>>{};
    for (final rr in research) {
      for (final rel in rr.relationship) {
        (researchByPair[rel.pairKey] ??= <String>[]).add(rr.id);
      }
    }

    final rows = <MatrixReviewRow>[];
    var keep = 0;
    var review = 0;
    var replace = 0;

    currentByPair.forEach((pairKey, current) {
      final parts = pairKey.split('->');
      final from = parts.first;
      final to = parts.last;
      final entry = consensus.entryFor(from, to);

      final supporting = <String>[];
      final conflicting = <String>[];
      for (final s in sources.sources) {
        for (final a in s.assertions) {
          if (a.pairKey != pairKey) continue;
          if (!kSourceRelations.contains(a.relation)) continue;
          if (a.relation == current) {
            supporting.add(s.id);
          } else {
            conflicting.add(s.id);
          }
        }
      }

      final recommendation = _recommend(current: current, entry: entry);
      switch (recommendation) {
        case MatrixRecommendation.keep:
          keep++;
        case MatrixRecommendation.review:
          review++;
        case MatrixRecommendation.replace:
          replace++;
      }

      rows.add(MatrixReviewRow(
        from: from,
        to: to,
        currentMatrix: current,
        consensus: entry,
        supportingSourceIds: supporting.toSet().toList()..sort(),
        conflictingSourceIds: conflicting.toSet().toList()..sort(),
        userResearchIds: researchByPair[pairKey] ?? const [],
        recommendation: recommendation,
        rationale: _rationale(current: current, entry: entry, rec: recommendation),
      ));
    });

    rows.sort((a, b) => a.pairKey.compareTo(b.pairKey));
    return MatrixReviewReport(
      rows: rows,
      impact: EngineImpactEstimate(keep: keep, review: review, replace: replace),
    );
  }

  static MatrixRecommendation _recommend({
    required String current,
    required ConsensusEntry entry,
  }) {
    // Not enough evidence to act on.
    if (entry.classification == ConsensusClass.uncovered ||
        entry.confidence == ConsensusConfidence.none ||
        entry.confidence == ConsensusConfidence.low) {
      return MatrixRecommendation.keep;
    }
    // Evidence agrees with the matrix.
    if (entry.consensusRelation == current) {
      return MatrixRecommendation.keep;
    }
    // Evidence disagrees: replace only when strong AND clear.
    final strongAndClear = entry.confidence == ConsensusConfidence.high &&
        (entry.classification == ConsensusClass.consensus ||
            entry.classification == ConsensusClass.majority);
    return strongAndClear
        ? MatrixRecommendation.replace
        : MatrixRecommendation.review;
  }

  static String _rationale({
    required String current,
    required ConsensusEntry entry,
    required MatrixRecommendation rec,
  }) {
    if (entry.classification == ConsensusClass.uncovered) {
      return 'No sources assert this relationship; keep the current matrix '
          'value ("$current").';
    }
    final cons = entry.consensusRelation ?? 'split';
    final votes = 'friend ${entry.friend} / enemy ${entry.enemy} / '
        'neutral ${entry.neutral} across ${entry.sourceCount} source(s)';
    switch (rec) {
      case MatrixRecommendation.keep:
        if (entry.consensusRelation == current) {
          return 'Consensus ("$cons", ${entry.confidence.name}) agrees with the '
              'matrix; $votes.';
        }
        return 'Evidence is too weak to act on (${entry.confidence.name} '
            'confidence); keep "$current". $votes.';
      case MatrixRecommendation.review:
        return 'Consensus ("$cons") differs from the matrix ("$current") but is '
            '${entry.classification.name}/${entry.confidence.name}; needs human '
            'review. $votes.';
      case MatrixRecommendation.replace:
        return 'Strong, clear consensus ("$cons", ${entry.confidence.name}) '
            'disagrees with the matrix ("$current"); propose replacing. $votes.';
    }
  }
}
