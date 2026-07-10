import 'package:flutter/material.dart';

import '../../application/thai_beta_analysis.dart';
import '../../application/thai_beta_store.dart';
import '../../domain/thai_beta_feedback.dart';
import '../../domain/thai_beta_perceived_method.dart';
import '../../domain/thai_beta_record.dart';
import '../widgets/thai_beta_progress_bar.dart';
import 'thai_beta_completion_page.dart';

/// Feedback step: structured feedback + consent → Firestore. (The technical
/// "ข้อมูลที่ใช้คำนวณ" panel lives on the summary screen before the report.)
class ThaiBetaFeedbackPage extends StatefulWidget {
  const ThaiBetaFeedbackPage({
    super.key,
    required this.analysis,
    this.store,
  });

  final ThaiBetaAnalysis analysis;

  /// Injectable for tests; defaults to a real [ThaiBetaStore] at runtime.
  final ThaiBetaStore? store;

  @override
  State<ThaiBetaFeedbackPage> createState() => _ThaiBetaFeedbackPageState();
}

class _ThaiBetaFeedbackPageState extends State<ThaiBetaFeedbackPage> {
  int _rating = 0;
  final _mostAccurate = TextEditingController();
  final _leastAccurate = TextEditingController();
  final _wantMore = TextEditingController();
  final _recommend = TextEditingController();
  final _otherMethod = TextEditingController();
  ThaiBetaPerceivedMethod? _perceivedMethod;
  bool _consent = false;
  bool _submitting = false;

  late final ThaiBetaStore _store = widget.store ?? ThaiBetaStore();

  @override
  void dispose() {
    _mostAccurate.dispose();
    _leastAccurate.dispose();
    _wantMore.dispose();
    _recommend.dispose();
    _otherMethod.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _rating > 0 && _perceivedMethod != null && _consent && !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final feedback = ThaiBetaFeedback(
      overallRating: _rating,
      mostAccurate: _mostAccurate.text.trim(),
      leastAccurate: _leastAccurate.text.trim(),
      wantMoreAnalysis: _wantMore.text.trim(),
      recommendReason: _recommend.text.trim(),
      perceivedMethod: _perceivedMethod!,
      perceivedMethodOther:
          _perceivedMethod == ThaiBetaPerceivedMethod.other
              ? _otherMethod.text.trim()
              : null,
      consentGiven: _consent,
    );

    final record = ThaiBetaRecord(
      input: widget.analysis.input,
      normalizedBirth: widget.analysis.normalizedSnapshot!,
      reportSnapshot: widget.analysis.reportSnapshot ?? const {},
      reportHash: widget.analysis.reportHash ?? '',
      engineVersions: widget.analysis.engineVersions!,
      feedback: feedback,
      startedAt: widget.analysis.startedAt,
    );

    final result = await _store.save(record);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.success) {
      // Never silently ignore a failed save — show the error and allow retry.
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('บันทึกไม่สำเร็จ'),
          content: Text(
            result.error ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            ThaiBetaCompletionPage(researchId: result.researchId ?? '-'),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ความคิดเห็นของคุณ'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ThaiBetaProgressBar(current: ThaiBetaStep.feedback),
            Expanded(
              child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Text('ความแม่นยำโดยรวม',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _StarRating(
                  rating: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 24),
                _LongTextField(
                  controller: _mostAccurate,
                  label: 'ส่วนไหนที่รู้สึกว่าตรงกับคุณที่สุด?',
                ),
                const SizedBox(height: 16),
                _LongTextField(
                  controller: _leastAccurate,
                  label: 'ส่วนไหนที่ไม่ค่อยตรงกับคุณ?',
                ),
                const SizedBox(height: 16),
                _LongTextField(
                  controller: _wantMore,
                  label: 'อยากให้ระบบวิเคราะห์อะไรเพิ่มเติม?',
                ),
                const SizedBox(height: 16),
                _LongTextField(
                  controller: _recommend,
                  label: 'ทำไมคุณถึงจะแนะนำระบบนี้ให้เพื่อน?',
                ),
                const SizedBox(height: 24),
                Text('คุณคิดว่าระบบใช้อะไรในการวิเคราะห์คุณ?',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                RadioGroup<ThaiBetaPerceivedMethod>(
                  groupValue: _perceivedMethod,
                  onChanged: (v) => setState(() => _perceivedMethod = v),
                  child: Column(
                    children: [
                      for (final method in ThaiBetaPerceivedMethod.values)
                        RadioListTile<ThaiBetaPerceivedMethod>(
                          contentPadding: EdgeInsets.zero,
                          value: method,
                          title: Text(method.labelTh),
                        ),
                    ],
                  ),
                ),
                if (_perceivedMethod == ThaiBetaPerceivedMethod.other)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: TextField(
                      controller: _otherMethod,
                      decoration: const InputDecoration(
                        labelText: 'โปรดระบุ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                  title: const Text(
                    'ฉันยินยอมให้เก็บข้อมูลนี้เพื่อการพัฒนาและวิจัยระบบ',
                  ),
                ),
                const SizedBox(height: 8),
                if (!_consent)
                  Text(
                    'จำเป็นต้องยินยอมก่อนจึงจะส่งความคิดเห็นได้',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.error),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ส่งความคิดเห็น'),
                ),
              ],
            ),
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged(i),
            iconSize: 38,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            icon: Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i <= rating ? const Color(0xFFF9A825) : scheme.outline,
            ),
          ),
      ],
    );
  }
}

class _LongTextField extends StatelessWidget {
  const _LongTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
