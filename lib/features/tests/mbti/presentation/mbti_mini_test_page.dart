import 'package:flutter/material.dart';
import 'package:knowme/features/funnel_telemetry/funnel_telemetry.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../application/mbti_session_state.dart';
import 'mbti_narrative_preview_page.dart';
import 'mbti_result_page.dart';

/// MBTI mini test flow (first 16 of [mbtiProgressiveQuestions]).
///
/// TODO(progressive): after Q16, optional checkpoint result then continue to Q40/Q80.
class MbtiMiniTestPage extends StatefulWidget {
  const MbtiMiniTestPage({
    super.key,
    this.continueToStandardCheckpoint = false,
    this.continueToAccurateCheckpoint = false,
    this.restoredAnswers,
  });

  /// Resume at Q17 after mini result (16 → 40).
  final bool continueToStandardCheckpoint;

  /// Resume at Q41 after standard result (40 → 80).
  final bool continueToAccurateCheckpoint;

  /// In-memory answers when continuing without Firestore (guest).
  final Map<String, int>? restoredAnswers;

  @override
  State<MbtiMiniTestPage> createState() => _MbtiMiniTestPageState();
}

class _MbtiMiniTestPageState extends State<MbtiMiniTestPage> {
  late final MbtiMiniSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = MbtiMiniSessionState();
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

    await FunnelTelemetry.track(FunnelTelemetryEvent.mbtiStart);

    final existing = _session.existingCompletedResult;
    if (existing != null) {
      final displaySummary = _session.resultForDisplay(existing);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MbtiResultPage(
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

    await FunnelTelemetry.track(FunnelTelemetryEvent.mbtiComplete);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MbtiNarrativePreviewPage(
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
    final lang = AppText.lang;

    if (_session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session.status == MbtiMiniSessionStatus.error) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_mini_title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_session.errorMessage ?? 'Error'),
          ),
        ),
      );
    }

    if (_session.status == MbtiMiniSessionStatus.empty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_mini_title'))),
        body: Center(
          child: Text(
            lang == 'th'
                ? 'ยังไม่มีคำถามในแบบทดสอบนี้'
                : 'No questions available',
          ),
        ),
      );
    }

    final question = _session.currentQuestion!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('mbti_mini_title')),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lang == 'th'
                    ? 'คำถาม ${_session.index + 1} / ${_session.total}'
                    : 'Question ${_session.index + 1} / ${_session.total}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _session.progressValue),
              const SizedBox(height: 40),
              Text(
                question.text[lang] ?? question.text['en'] ?? '',
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
                      child: Text(lang == 'th' ? 'ย้อนกลับ' : 'Back'),
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
                            ? (lang == 'th' ? 'ดูผล' : 'See result')
                            : (lang == 'th' ? 'ถัดไป' : 'Next'),
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
            backgroundColor: isSelected ? Colors.deepPurple.shade700 : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          onPressed: () => _session.selectAnswer(score),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }
}
