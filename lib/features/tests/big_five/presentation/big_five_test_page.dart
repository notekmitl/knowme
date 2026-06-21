import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/questions/likert_options.dart';
import 'package:knowme/domain/models/test_question.dart';
import 'package:knowme/features/funnel_telemetry/funnel_telemetry.dart';

import '../application/big_five_session_state.dart';
import '../domain/big_five_models.dart';
import 'big_five_progressive_flow.dart';

/// Progressive Big Five test flow (10 → 44 → 80).
class BigFiveTestPage extends StatefulWidget {
  const BigFiveTestPage({
    super.key,
    this.continueToStandardCheckpoint = false,
    this.continueToDeepCheckpoint = false,
    this.restoredAnswers,
  });

  /// Resume at Q11 after quick result (10 → 44).
  final bool continueToStandardCheckpoint;

  /// Resume at Q45 after standard result (44 → 80).
  final bool continueToDeepCheckpoint;

  /// In-memory answers when continuing without Firestore (guest).
  final Map<String, int>? restoredAnswers;

  @override
  State<BigFiveTestPage> createState() => _BigFiveTestPageState();
}

class _BigFiveTestPageState extends State<BigFiveTestPage> {
  late final BigFiveSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = BigFiveSessionState();
    _session.addListener(_onSessionChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _session.initialize();

    if (!mounted) return;

    if (widget.continueToDeepCheckpoint) {
      await _session.resumeToDeepCheckpoint(
        restoredAnswers: widget.restoredAnswers,
      );
      return;
    }

    if (widget.continueToStandardCheckpoint) {
      await _session.resumeToStandardCheckpoint(
        restoredAnswers: widget.restoredAnswers,
      );
      return;
    }

    final existing = _session.existingCompletedResult;
    if (existing != null) {
      BigFiveProgressiveFlow.replaceWithResult(
        context,
        summary: existing,
        session: _session,
      );
    }
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    super.dispose();
  }

  Future<void> _finishTest() async {
    final summary = await _session.finish();
    if (!mounted) return;

    if (summary == null) {
      final message = _session.errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    await FunnelTelemetry.track(FunnelTelemetryEvent.bigFiveComplete);

    BigFiveProgressiveFlow.replaceWithResult(
      context,
      summary: summary,
      session: _session,
    );
  }

  List<Map<String, dynamic>> _optionsFor(TestQuestion question) {
    if (question.options.isNotEmpty) {
      return question.options
          .map((option) => Map<String, dynamic>.from(option))
          .toList();
    }
    return likert5;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session.status == BigFiveSessionStatus.error) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('big_five_test_title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_session.errorMessage ?? 'Error'),
          ),
        ),
      );
    }

    if (_session.status == BigFiveSessionStatus.empty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('big_five_test_title'))),
        body: Center(child: Text(AppText.t('big_five_test_empty'))),
      );
    }

    final question = _session.currentQuestion!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _session.persistBeforeLeave();
        if (!mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppText.t('big_five_test_title')),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppText.t('big_five_test_question_progress')
                      .replaceAll('{current}', '${_session.index + 1}')
                      .replaceAll('{total}', '${_session.total}'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: _session.progressValue),
                const SizedBox(height: 40),
                Text(
                  question.text[AppText.lang] ?? question.text['en'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildOptions(question),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _session.canGoBack ? _session.goBack : null,
                        child: Text(AppText.t('big_five_test_back')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _session.isLastQuestion
                            ? (_session.canFinishTest ? _finishTest : null)
                            : (_session.canGoNext &&
                                    _session.currentQuestionAnswered
                                ? _session.goNext
                                : null),
                        child: Text(
                          _session.isLastQuestion
                              ? AppText.t('big_five_test_see_result')
                              : AppText.t('big_five_test_next'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(TestQuestion question) {
    final lang = AppText.lang;
    final selected = _session.selectedScoreForCurrent;

    return _optionsFor(question).map((option) {
      final textMap = Map<String, dynamic>.from(option['text'] ?? {});
      final score = (option['score'] as num?)?.toInt() ?? 0;
      final label = textMap[lang] ?? textMap['en'] ?? '';
      final isSelected = selected == score;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          onPressed: () => _session.selectAnswer(score),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }
}
