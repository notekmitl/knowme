import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../../domain/mbti_cognitive_models.dart';

enum _TimelineNodeState { completed, current, locked }

/// Visual 16 → 40 → 80 cognitive checkpoint timeline (presentation only).
class MbtiCognitiveProgressTimeline extends StatelessWidget {
  const MbtiCognitiveProgressTimeline({
    super.key,
    required this.scoredQuestionCount,
  });

  final int scoredQuestionCount;

  static _TimelineNodeState _stateFor(int checkpoint, int scored) {
    final done = scored >= checkpoint;
    if (done) return _TimelineNodeState.completed;

    final nextTarget = scored < mbtiCognitiveMiniCheckpoint
        ? mbtiCognitiveMiniCheckpoint
        : scored < mbtiCognitiveStandardCheckpoint
            ? mbtiCognitiveStandardCheckpoint
            : scored < mbtiCognitiveAccurateCheckpoint
                ? mbtiCognitiveAccurateCheckpoint
                : 0;

    if (nextTarget == checkpoint) return _TimelineNodeState.current;
    return _TimelineNodeState.locked;
  }

  Color _tierColor(int checkpoint) {
    if (checkpoint == mbtiCognitiveMiniCheckpoint) {
      return Colors.teal.shade600;
    }
    if (checkpoint == mbtiCognitiveStandardCheckpoint) {
      return Colors.indigo.shade600;
    }
    return Colors.deepPurple.shade700;
  }

  String _tierSubtitleKey(int checkpoint) {
    if (checkpoint == mbtiCognitiveMiniCheckpoint) {
      return 'mbti_cog_timeline_tier_mini';
    }
    if (checkpoint == mbtiCognitiveStandardCheckpoint) {
      return 'mbti_cog_timeline_tier_standard';
    }
    return 'mbti_cog_timeline_tier_accurate';
  }

  @override
  Widget build(BuildContext context) {
    final scored = scoredQuestionCount.clamp(0, mbtiCognitiveAccurateCheckpoint);
    final nodes = [
      mbtiCognitiveMiniCheckpoint,
      mbtiCognitiveStandardCheckpoint,
      mbtiCognitiveAccurateCheckpoint,
    ];

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.t('mbti_cog_progress_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              AppText.t('mbti_cog_progress_hint'),
              style: TextStyle(
                fontSize: 12,
                height: 1.25,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < nodes.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _Connector(
                          filled: scored >= nodes[i],
                          color: _tierColor(nodes[i - 1]),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _TimelineNode(
                      checkpoint: nodes[i],
                      state: _stateFor(nodes[i], scored),
                      tierColor: _tierColor(nodes[i]),
                      subtitleKey: _tierSubtitleKey(nodes[i]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: filled ? color : Colors.grey.shade300,
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.checkpoint,
    required this.state,
    required this.tierColor,
    required this.subtitleKey,
  });

  final int checkpoint;
  final _TimelineNodeState state;
  final Color tierColor;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.grey.shade500;
    final activeColor =
        state == _TimelineNodeState.locked ? muted : tierColor;

    Widget circleChild;
    switch (state) {
      case _TimelineNodeState.completed:
        circleChild = const Icon(Icons.check, size: 18, color: Colors.white);
      case _TimelineNodeState.current:
        circleChild = const SizedBox.shrink();
      case _TimelineNodeState.locked:
        circleChild = Icon(Icons.lock_outline, size: 16, color: muted);
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state == _TimelineNodeState.completed
                ? tierColor
                : state == _TimelineNodeState.current
                    ? tierColor
                    : Colors.grey.shade200,
            border: state == _TimelineNodeState.current
                ? Border.all(color: tierColor, width: 3)
                : state == _TimelineNodeState.locked
                    ? Border.all(color: Colors.grey.shade400, width: 2)
                    : null,
          ),
          child: circleChild,
        ),
        const SizedBox(height: 8),
        Text(
          '$checkpoint',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: activeColor,
          ),
        ),
        Text(
          AppText.t(subtitleKey),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
