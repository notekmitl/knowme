/// P2 — one domain's place in the fused priority ordering.
///
/// [rank] is 1-based (1 = most important), [score] is the priority score
/// (absolute net strength, boosted when providers agree), and [agreed] flags
/// whether the boost applied.
class FusionPriority {
  const FusionPriority({
    required this.domain,
    required this.rank,
    required this.score,
    required this.agreed,
  });

  final String domain;
  final int rank;
  final int score;
  final bool agreed;
}
