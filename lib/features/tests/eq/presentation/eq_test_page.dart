import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/domain/models/test_question.dart';
import 'package:knowme/features/funnel_telemetry/funnel_telemetry.dart';

import '../application/eq_test_session_state.dart';
import '../domain/eq_models.dart';
import '../domain/eq_test_type.dart';
import 'eq_result_page.dart';

/// EQ Awareness test flow (one-shot, 20 questions).
class EqTestPage extends StatefulWidget {
  const EqTestPage({
    super.key,
    this.testType = EqTestType.awareness,
    this.startFreshAfterRetake = false,
  });

  final EqTestType testType;
  final bool startFreshAfterRetake;

  @override
  State<EqTestPage> createState() => _EqTestPageState();
}

class _EqTestPageState extends State<EqTestPage> {
  late final EqTestSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = EqTestSessionState(
      testType: widget.testType,
      startFreshAfterRetake: widget.startFreshAfterRetake,
    );
    _session.addListener(_onSessionChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _session.initialize();

    if (!mounted) return;

    final existing = _session.existingCompletedResult;
    if (existing != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => EqResultPage(
            summary: existing,
            session: _session,
            testType: widget.testType,
          ),
        ),
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

    await FunnelTelemetry.track(FunnelTelemetryEvent.eqComplete);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EqResultPage(
          summary: summary,
          session: _session,
          testType: widget.testType,
        ),
      ),
    );
  }

  String _titleKey() => '${widget.testType.testId}_title';

  @override
  Widget build(BuildContext context) {
    if (_session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session.status == EqTestSessionStatus.error) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t(_titleKey()))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_session.errorMessage ?? 'Error'),
          ),
        ),
      );
    }

    if (_session.status == EqTestSessionStatus.empty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t(_titleKey()))),
        body: Center(child: Text(AppText.t('eq_test_empty'))),
      );
    }

    final question = _session.currentQuestion!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _session.persistBeforeLeave();
        if (!mounted) return;
        Navigator.of(context).pop(
          EqTestProgressHint(
            testType: widget.testType,
            answered: _session.answeredCount,
            total: _session.total,
          ),
        );
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(AppText.t(_titleKey())),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppText.t('eq_test_question_progress')
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
                      onPressed: _session.canGoBack ? _session.goBack : null,
                      child: Text(AppText.t('eq_test_back')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _session.isLastQuestion
                          ? (_session.canFinishTest ? _finishTest : null)
                          : (_session.canGoNext && _session.currentQuestionAnswered
                                ? _session.goNext
                                : null),
                      child: Text(
                        _session.isLastQuestion
                            ? AppText.t('eq_test_see_result')
                            : AppText.t('eq_test_next'),
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

    return question.options.map((option) {
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
          onPressed: () => _session.answer(score),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }
}
