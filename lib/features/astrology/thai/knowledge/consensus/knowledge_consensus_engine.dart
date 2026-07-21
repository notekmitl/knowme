import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart'
    show kKnowledgeResearchPlanets;
import 'package:knowme/features/astrology/thai/knowledge/sources/knowledge_source_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/sources/source_record.dart';

/// Thai Astrology — **Consensus Engine** (V8).
///
/// Measures agreement *between sources* (V7) for every directed relationship by
/// counting friend / enemy / neutral votes. It classifies the outcome and
/// estimates a confidence from the number of sources.
///
/// Boundary: pure knowledge layer. It reads source assertions only and **does
/// NOT read or modify the `PlanetRelationshipMatrix`** or the engine.

/// How sources agree on a relationship.
enum ConsensusClass {
  /// No source asserts this pair.
  uncovered,

  /// Every source agrees (a single relation asserted).
  consensus,

  /// A unique winner with a strict majority (> 50%).
  majority,

  /// Tie for the top relation — no unique winner.
  split,

  /// A unique winner but only a plurality (≤ 50%) — strong disagreement.
  disputed,
}

/// Confidence in the consensus, driven by the number of sources.
enum ConsensusConfidence { none, low, medium, high }

/// Per-relationship consensus result.
class ConsensusEntry {
  const ConsensusEntry({
    required this.from,
    required this.to,
    required this.friend,
    required this.enemy,
    required this.neutral,
    required this.sourceCount,
    required this.classification,
    required this.confidence,
    required this.consensusRelation,
  });

  final String from;
  final String to;
  final int friend;
  final int enemy;
  final int neutral;

  /// Distinct sources that asserted this pair.
  final int sourceCount;
  final ConsensusClass classification;
  final ConsensusConfidence confidence;

  /// The winning relation, or null when uncovered / split.
  final String? consensusRelation;

  String get pairKey => '$from->$to';
  int get totalVotes => friend + enemy + neutral;

  int votesFor(String relation) => switch (relation) {
        'friend' => friend,
        'enemy' => enemy,
        'neutral' => neutral,
        _ => 0,
      };
}

/// Consensus engine over the V7 source corpus.
class KnowledgeConsensusEngine {
  KnowledgeConsensusEngine(this._sources);

  factory KnowledgeConsensusEngine.fromSourceEngine(
    KnowledgeSourceEngine engine,
  ) =>
      KnowledgeConsensusEngine(engine.sources);

  final List<SourceRecord> _sources;

  /// Consensus for one directed pair.
  ConsensusEntry entryFor(String from, String to) {
    var friend = 0;
    var enemy = 0;
    var neutral = 0;
    final contributingSources = <String>{};
    for (final s in _sources) {
      var counted = false;
      for (final a in s.assertions) {
        if (a.from != from || a.to != to) continue;
        if (!kSourceRelations.contains(a.relation)) continue;
        switch (a.relation) {
          case 'friend':
            friend++;
          case 'enemy':
            enemy++;
          case 'neutral':
            neutral++;
        }
        counted = true;
      }
      if (counted) contributingSources.add(s.id);
    }
    return _classify(
      from: from,
      to: to,
      friend: friend,
      enemy: enemy,
      neutral: neutral,
      sourceCount: contributingSources.length,
    );
  }

  /// Consensus for every directed pair in the 56-pair universe.
  List<ConsensusEntry> entries() {
    final out = <ConsensusEntry>[];
    for (final from in kKnowledgeResearchPlanets) {
      for (final to in kKnowledgeResearchPlanets) {
        if (from == to) continue;
        out.add(entryFor(from, to));
      }
    }
    return out;
  }

  ConsensusReport report() => ConsensusReport.of(entries());

  // ---------------------------------------------------------------------------
  // classification
  // ---------------------------------------------------------------------------

  static ConsensusEntry _classify({
    required String from,
    required String to,
    required int friend,
    required int enemy,
    required int neutral,
    required int sourceCount,
  }) {
    final total = friend + enemy + neutral;
    if (total == 0) {
      return ConsensusEntry(
        from: from,
        to: to,
        friend: 0,
        enemy: 0,
        neutral: 0,
        sourceCount: 0,
        classification: ConsensusClass.uncovered,
        confidence: ConsensusConfidence.none,
        consensusRelation: null,
      );
    }

    final tally = {'friend': friend, 'enemy': enemy, 'neutral': neutral};
    final present = tally.entries.where((e) => e.value > 0).toList();
    final maxVotes = present.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final winners = present.where((e) => e.value == maxVotes).toList();

    ConsensusClass classification;
    String? consensusRelation;
    if (present.length == 1) {
      classification = ConsensusClass.consensus;
      consensusRelation = present.single.key;
    } else if (winners.length > 1) {
      classification = ConsensusClass.split;
      consensusRelation = null;
    } else {
      consensusRelation = winners.single.key;
      classification = maxVotes * 2 > total
          ? ConsensusClass.majority
          : ConsensusClass.disputed;
    }

    return ConsensusEntry(
      from: from,
      to: to,
      friend: friend,
      enemy: enemy,
      neutral: neutral,
      sourceCount: sourceCount,
      classification: classification,
      confidence: _confidence(sourceCount, classification),
      consensusRelation: consensusRelation,
    );
  }

  /// Confidence is driven by the number of sources, then downgraded one level
  /// when sources are split / disputed.
  static ConsensusConfidence _confidence(int sources, ConsensusClass c) {
    ConsensusConfidence base;
    if (sources <= 0) {
      base = ConsensusConfidence.none;
    } else if (sources <= 2) {
      base = ConsensusConfidence.low;
    } else if (sources <= 7) {
      base = ConsensusConfidence.medium;
    } else {
      base = ConsensusConfidence.high;
    }
    if (c == ConsensusClass.split || c == ConsensusClass.disputed) {
      base = switch (base) {
        ConsensusConfidence.high => ConsensusConfidence.medium,
        ConsensusConfidence.medium => ConsensusConfidence.low,
        ConsensusConfidence.low => ConsensusConfidence.low,
        ConsensusConfidence.none => ConsensusConfidence.none,
      };
    }
    return base;
  }
}

/// Consensus Report — per-pair entries + a summary of the classification split.
class ConsensusReport {
  const ConsensusReport({
    required this.entries,
    required this.uncovered,
    required this.consensus,
    required this.majority,
    required this.split,
    required this.disputed,
  });

  factory ConsensusReport.of(List<ConsensusEntry> entries) {
    var uncovered = 0;
    var consensus = 0;
    var majority = 0;
    var split = 0;
    var disputed = 0;
    for (final e in entries) {
      switch (e.classification) {
        case ConsensusClass.uncovered:
          uncovered++;
        case ConsensusClass.consensus:
          consensus++;
        case ConsensusClass.majority:
          majority++;
        case ConsensusClass.split:
          split++;
        case ConsensusClass.disputed:
          disputed++;
      }
    }
    return ConsensusReport(
      entries: List.unmodifiable(entries),
      uncovered: uncovered,
      consensus: consensus,
      majority: majority,
      split: split,
      disputed: disputed,
    );
  }

  final List<ConsensusEntry> entries;
  final int uncovered;
  final int consensus;
  final int majority;
  final int split;
  final int disputed;

  int get total => entries.length;

  /// Pairs with at least one source.
  int get covered => total - uncovered;

  List<String> toReportLines() => [
        'Thai Astrology — Consensus Report',
        'Relationships          : $total',
        'Covered                : $covered',
        'Consensus (unanimous)  : $consensus',
        'Majority               : $majority',
        'Split                  : $split',
        'Disputed               : $disputed',
        'Uncovered              : $uncovered',
      ];
}
