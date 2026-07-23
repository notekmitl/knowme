import 'package:flutter/material.dart';

import '../../application/thai_life_map_beta_feedback_store.dart';
import '../../application/thai_life_map_beta_feedback_summary.dart';
import '../../domain/thai_life_map_beta_feedback.dart';

/// Admin/QA summary for Life Map invited-beta feedback.
class ThaiLifeMapBetaFeedbackSummaryCard extends StatefulWidget {
  const ThaiLifeMapBetaFeedbackSummaryCard({super.key, this.store});

  final ThaiLifeMapBetaFeedbackStore? store;

  @override
  State<ThaiLifeMapBetaFeedbackSummaryCard> createState() =>
      _ThaiLifeMapBetaFeedbackSummaryCardState();
}

class _ThaiLifeMapBetaFeedbackSummaryCardState
    extends State<ThaiLifeMapBetaFeedbackSummaryCard> {
  late final ThaiLifeMapBetaFeedbackStore _store =
      widget.store ?? ThaiLifeMapBetaFeedbackStore();
  late Future<_Loaded> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Loaded> _load() async {
    final overall = await _store.listAllForAdmin();
    final periods = <ThaiLifeMapPeriodFeedback>[];
    for (final f in overall) {
      periods.addAll(await _store.listPeriodFeedbackForAdmin(f.userId));
    }
    final summary = ThaiLifeMapBetaFeedbackSummary.from(
      overall: overall,
      periods: periods,
    );
    final phase = ThaiLifeMapValidationStatus.evaluate(summary);
    return _Loaded(summary: summary, phase: phase);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<_Loaded>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snap.data;
        if (data == null) {
          return const SizedBox.shrink();
        }
        final s = data.summary;
        return Card(
          key: const Key('thai_life_map_beta_feedback_summary_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Life Map Invited Beta Validation',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'สถานะ: ${ThaiLifeMapValidationStatus.labelTh(data.phase)}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _m('ผู้ใช้จริงที่ส่งคะแนน', '${s.realUserCount}'),
                    _m('Submission ทั้งหมด', '${s.submissionCount}'),
                    _m('QA/test (ไม่นับจริง)', '${s.qaSubmissionCount}'),
                    _m('ตรงกับชีวิต (เฉลี่ย)', s.avgLifeFit.toStringAsFixed(2)),
                    _m('เข้าใจง่าย (เฉลี่ย)', s.avgClarity.toStringAsFixed(2)),
                    _m('น่าเชื่อถือ (เฉลี่ย)', s.avgTrust.toStringAsFixed(2)),
                    _m('ประโยชน์ (เฉลี่ย)', s.avgUsefulness.toStringAsFixed(2)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Feedback ต่อช่วงชีวิต',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in s.periodCategoryCounts.entries)
                      Chip(label: Text('${e.key.labelTh}: ${e.value}')),
                  ],
                ),
                const SizedBox(height: 8),
                Text('UX issues', style: theme.textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in s.uxIssueCounts.entries)
                      if (e.value > 0)
                        Chip(label: Text('${e.key.labelTh}: ${e.value}')),
                  ],
                ),
                if (s.buildVersions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Builds: ${s.buildVersions.join(', ')}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (s.latestFeedbackAt != null) ...[
                  Text(
                    'ล่าสุด: ${s.latestFeedbackAt!.toIso8601String()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (s.comments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Comments (จำกัด)', style: theme.textTheme.titleSmall),
                  for (final c in s.comments.take(10))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $c'),
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  'หมายเหตุ: คะแนน “ตรงกับชีวิต” เป็น perceived relevance '
                  'ไม่ใช่หลักฐานความถูกต้องของสูตร/Canon',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _m(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Loaded {
  const _Loaded({required this.summary, required this.phase});
  final ThaiLifeMapBetaFeedbackSummary summary;
  final ThaiLifeMapValidationPhase phase;
}
