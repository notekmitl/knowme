import 'package:flutter/material.dart';

import '../../application/thai_life_map_beta_feedback_store.dart';
import '../../domain/thai_life_map_beta_feedback.dart';

/// Non-blocking Life Map validation invite for invited-beta users only.
///
/// Shown after the report body; never as an interrupting modal.
class ThaiLifeMapBetaFeedbackPanel extends StatefulWidget {
  const ThaiLifeMapBetaFeedbackPanel({
    super.key,
    required this.userId,
    required this.lifeMapRef,
    required this.viewportClass,
    required this.buildVersion,
    this.sourcePath = 'thai_beta_report',
    this.isQaTest = false,
    this.store,
    this.periodLabels = const [],
  });

  final String userId;
  final String lifeMapRef;
  final String viewportClass;
  final String buildVersion;
  final String sourcePath;
  final bool isQaTest;
  final ThaiLifeMapBetaFeedbackStore? store;
  final List<String> periodLabels;

  @override
  State<ThaiLifeMapBetaFeedbackPanel> createState() =>
      _ThaiLifeMapBetaFeedbackPanelState();
}

class _ThaiLifeMapBetaFeedbackPanelState
    extends State<ThaiLifeMapBetaFeedbackPanel> {
  late final ThaiLifeMapBetaFeedbackStore _store =
      widget.store ?? ThaiLifeMapBetaFeedbackStore();

  int _lifeFit = 0;
  int _clarity = 0;
  int _trust = 0;
  int _usefulness = 0;
  final _comment = TextEditingController();
  final Set<ThaiLifeMapUxIssue> _ux = {};
  int? _selectedPeriod;
  ThaiLifeMapPeriodFeedbackCategory? _periodCategory;
  final _periodComment = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _expanded = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final existing = await _store.loadOwn().timeout(
        const Duration(milliseconds: 800),
      );
      if (!mounted) return;
      if (existing != null && existing.scores.isComplete) {
        setState(() {
          _lifeFit = existing.scores.lifeFit;
          _clarity = existing.scores.clarity;
          _trust = existing.scores.trust;
          _usefulness = existing.scores.usefulness;
          _ux.addAll(existing.uxIssues);
          if (existing.optionalComment != null) {
            _comment.text = existing.optionalComment!;
          }
          _loaded = true;
        });
      } else {
        setState(() => _loaded = true);
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    _periodComment.dispose();
    super.dispose();
  }

  Future<void> _submitOverall() async {
    final scores = ThaiLifeMapBetaScores(
      lifeFit: _lifeFit,
      clarity: _clarity,
      trust: _trust,
      usefulness: _usefulness,
    );
    final err = ThaiLifeMapBetaFeedback.validate(
      scores: scores,
      lifeMapRef: widget.lifeMapRef,
      viewportClass: widget.viewportClass,
      buildVersion: widget.buildVersion,
      optionalComment: _comment.text.trim().isEmpty
          ? null
          : _comment.text.trim(),
      uxIssues: _ux.toList(),
    );
    if (err != null) {
      setState(() => _message = err);
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await _store.upsertOverall(
      ThaiLifeMapBetaFeedback(
        userId: widget.userId,
        scores: scores,
        lifeMapRef: widget.lifeMapRef,
        viewportClass: widget.viewportClass,
        buildVersion: widget.buildVersion,
        feedbackSchemaVersion: ThaiLifeMapBetaFeedback.schemaVersion,
        sourcePath: widget.sourcePath,
        isQaTest: widget.isQaTest,
        optionalComment: _comment.text.trim().isEmpty
            ? null
            : _comment.text.trim(),
        uxIssues: _ux.toList(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.success
          ? 'บันทึกคะแนนแล้ว ขอบคุณสำหรับ Feedback'
          : (result.error ?? 'บันทึกไม่สำเร็จ');
    });
  }

  Future<void> _submitPeriod() async {
    if (_selectedPeriod == null || _periodCategory == null) {
      setState(() => _message = 'เลือกช่วงชีวิตและประเภท Feedback');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await _store.upsertPeriodFeedback(
      feedback: ThaiLifeMapPeriodFeedback(
        periodIndex: _selectedPeriod!,
        category: _periodCategory!,
        optionalComment: _periodComment.text.trim().isEmpty
            ? null
            : _periodComment.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.success
          ? 'บันทึก Feedback ช่วงชีวิตแล้ว'
          : (result.error ?? 'บันทึกไม่สำเร็จ');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Card(
      key: const Key('thai_life_map_beta_feedback_panel'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        title: Text(
          'ช่วยประเมินแผนที่ชีวิต (Invited Beta)',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: const Text(
          'Feedback นี้ใช้ปรับปรุงระบบเท่านั้น ไม่เก็บวันเกิด/เวลาเกิด/จังหวัด',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScoreRow(
                  label: 'ความตรงกับชีวิต',
                  value: _lifeFit,
                  onChanged: (v) => setState(() => _lifeFit = v),
                ),
                _ScoreRow(
                  label: 'ความเข้าใจง่าย',
                  value: _clarity,
                  onChanged: (v) => setState(() => _clarity = v),
                ),
                _ScoreRow(
                  label: 'ความน่าเชื่อถือ',
                  value: _trust,
                  onChanged: (v) => setState(() => _trust = v),
                ),
                _ScoreRow(
                  label: 'ประโยชน์ที่ได้รับ',
                  value: _usefulness,
                  onChanged: (v) => setState(() => _usefulness = v),
                ),
                const SizedBox(height: 8),
                Text('ปัญหา UX (ถ้ามี)', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final issue in ThaiLifeMapUxIssue.values)
                      FilterChip(
                        label: Text(issue.labelTh),
                        selected: _ux.contains(issue),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _ux.add(issue);
                          } else {
                            _ux.remove(issue);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _comment,
                  maxLength: ThaiLifeMapBetaFeedback.maxCommentLength,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ความคิดเห็นเพิ่มเติม (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('thai_life_map_beta_feedback_submit_scores'),
                  onPressed: _busy ? null : _submitOverall,
                  child: Text(_busy ? 'กำลังบันทึก…' : 'ส่งคะแนนภาพรวม'),
                ),
                const Divider(height: 32),
                Text(
                  'Feedback ต่อช่วงชีวิต',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: const Key('thai_life_map_beta_feedback_period'),
                  // ignore: deprecated_member_use
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'ช่วงชีวิต',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var i = 0; i < 8; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          widget.periodLabels.length > i
                              ? widget.periodLabels[i]
                              : 'ช่วงที่ ${i + 1}',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedPeriod = v),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in ThaiLifeMapPeriodFeedbackCategory.values)
                      ChoiceChip(
                        label: Text(c.labelTh),
                        selected: _periodCategory == c,
                        onSelected: (_) => setState(() => _periodCategory = c),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _periodComment,
                  maxLength: ThaiLifeMapBetaFeedback.maxCommentLength,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุช่วงนี้ (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('thai_life_map_beta_feedback_submit_period'),
                  onPressed: _busy ? null : _submitPeriod,
                  child: const Text('ส่ง Feedback ช่วงชีวิต'),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    key: const Key('thai_life_map_beta_feedback_message'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          for (var i = 1; i <= 5; i++)
            IconButton(
              key: Key('score_${label}_$i'),
              tooltip: '$i',
              onPressed: () => onChanged(i),
              icon: Icon(
                i <= value ? Icons.star : Icons.star_border,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
