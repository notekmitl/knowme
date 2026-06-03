import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../mbti_cognitive_result_content.dart';

/// Cognitive preference ranking — order over magnitude (no % bars).
class MbtiCognitivePreferenceRanking extends StatelessWidget {
  const MbtiCognitivePreferenceRanking({
    super.key,
    required this.orderedFunctions,
  });

  final List<String> orderedFunctions;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final top = orderedFunctions.take(4).toList();
    final rest = orderedFunctions.length > 4
        ? orderedFunctions.sublist(4)
        : <String>[];

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppText.t('mbti_cog_ranking_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              AppText.t('mbti_cog_ranking_hint'),
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ...top.asMap().entries.map(
              (entry) => _TopRankCard(
                rank: entry.key + 1,
                function: entry.value,
                accent: accent,
                isLast: entry.key == top.length - 1 && rest.isEmpty,
              ),
            ),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 6),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              Text(
                AppText.t('mbti_cog_ranking_rest_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              ...rest.asMap().entries.map(
                (entry) => _CompactRankRow(
                  rank: entry.key + 5,
                  function: entry.value,
                  isLast: entry.key == rest.length - 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopRankCard extends StatelessWidget {
  const _TopRankCard({
    required this.rank,
    required this.function,
    required this.accent,
    required this.isLast,
  });

  final int rank;
  final String function;
  final Color accent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final label = MbtiCognitiveResultContent.functionLabel(function);
    final desc = MbtiCognitiveResultContent.functionDescription(function);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RankBadge(rank: rank, accent: accent, prominent: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$function — $label',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accent.withValues(alpha: 0.95),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _RankAccent(rank: rank, accent: accent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed-width rank accent (not tied to score %).
class _RankAccent extends StatelessWidget {
  const _RankAccent({required this.rank, required this.accent});

  final int rank;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final widthFactor = switch (rank) {
      1 => 1.0,
      2 => 0.78,
      3 => 0.58,
      _ => 0.42,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: constraints.maxWidth * widthFactor,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: accent.withValues(alpha: 0.35 + (0.12 * (5 - rank))),
            ),
          ),
        );
      },
    );
  }
}

class _CompactRankRow extends StatelessWidget {
  const _CompactRankRow({
    required this.rank,
    required this.function,
    required this.isLast,
  });

  final int rank;
  final String function;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Row(
        children: [
          _RankBadge(rank: rank, accent: Colors.grey.shade500, prominent: false),
          const SizedBox(width: 8),
          Text(
            function,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              MbtiCognitiveResultContent.functionLabel(function),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.accent,
    required this.prominent,
  });

  final int rank;
  final Color accent;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final size = prominent ? 28.0 : 22.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: prominent ? accent.withValues(alpha: 0.15) : Colors.grey.shade200,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: prominent ? 13 : 11,
          fontWeight: FontWeight.w800,
          color: prominent ? accent : Colors.grey.shade600,
        ),
      ),
    );
  }
}
