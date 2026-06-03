import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/mbti_cognitive_session_state.dart';
import '../domain/mbti_cognitive_models.dart';
import 'mbti_cognitive_result_page.dart';

class MbtiCognitiveTestPage extends StatefulWidget {
  const MbtiCognitiveTestPage({
    super.key,
    this.continueToStandardCheckpoint = false,
    this.continueToAccurateCheckpoint = false,
    this.restoredAnswers,
  });

  final bool continueToStandardCheckpoint;
  final bool continueToAccurateCheckpoint;
  final Map<String, int>? restoredAnswers;

  @override
  State<MbtiCognitiveTestPage> createState() => _MbtiCognitiveTestPageState();
}

class _MbtiCognitiveTestPageState extends State<MbtiCognitiveTestPage> {
  late final MbtiCognitiveSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = MbtiCognitiveSessionState();
    _session.addListener(_onSessionChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _session.initialize();

    if (!mounted) return;

    if (widget.continueToAccurateCheckpoint) {
      await _session.resumeToAccurateCheckpoint(
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
      final displaySummary = _session.resultForDisplay(existing);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MbtiCognitiveResultPage(
            summary: displaySummary,
            canContinueToStandard: _session.canOfferStandardContinue,
            canContinueToAccurate: _session.canOfferAccurateContinue,
            pendingAnswersForContinue: _session.canOfferAnyContinue
                ? Map<String, int>.from(_session.answers)
                : null,
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MbtiCognitiveResultPage(
          summary: summary,
          canContinueToStandard: _session.canOfferStandardContinue,
          canContinueToAccurate: _session.canOfferAccurateContinue,
          pendingAnswersForContinue: _session.canOfferAnyContinue
              ? Map<String, int>.from(_session.answers)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session.status == MbtiCognitiveSessionStatus.error) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_cognitive_title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_session.errorMessage ?? 'Error'),
          ),
        ),
      );
    }

    if (_session.status == MbtiCognitiveSessionStatus.empty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_cognitive_title'))),
        body: Center(child: Text(AppText.t('no_questions'))),
      );
    }

    final question = _session.currentQuestion!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('mbti_cognitive_title')),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppText.t('mbti_cog_question_progress')
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
                      child: Text(AppText.t('mbti_cog_back')),
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
                            ? AppText.t('mbti_cog_see_result')
                            : AppText.t('mbti_cog_next'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(MbtiCognitiveQuestion question) {
    final selected = _session.selectedScoreForCurrent;

    return question.options.map((option) {
      final textMap = Map<String, dynamic>.from(option['text'] ?? {});
      final score = (option['score'] as num?)?.toInt() ?? 0;
      final label = textMap[AppText.lang] ?? textMap['en'] ?? '';
      final isSelected = selected == score;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.indigo.shade700 : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          onPressed: () => _session.selectAnswer(score),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }
}
