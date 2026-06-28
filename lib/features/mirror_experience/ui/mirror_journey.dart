import 'package:flutter/material.dart';

import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';

import '../mirror_copy.dart';
import '../mirror_experience_input.dart';
import '../mirror_experience_service.dart';
import '../mirror_view_models.dart';
import 'mirror_conversation_entry.dart';
import 'mirror_decision_card.dart';
import 'mirror_insight_card.dart';
import 'mirror_prediction_card.dart';
import 'mirror_reflection.dart';

/// The ordered stages of the journey.
enum _Stage { currentLife, prediction, decision, conversation, reflection }

/// P3 — the guided journey that ties the experience together:
/// Current Life → Prediction → Decision → Ask More → Conversation → Reflection.
///
/// It owns one [MirrorExperienceService] over the Fusion Runtime and walks the
/// user one calm step at a time. View models are computed lazily and cached.
class MirrorJourney extends StatefulWidget {
  const MirrorJourney({
    super.key,
    required this.input,
    required this.runtime,
  });

  final MirrorExperienceInput input;
  final FusionRuntime runtime;

  @override
  State<MirrorJourney> createState() => _MirrorJourneyState();
}

class _MirrorJourneyState extends State<MirrorJourney> {
  late final MirrorExperienceService _service;
  int _index = 0;

  MirrorInsight? _insight;
  MirrorPrediction? _prediction;
  MirrorDecision? _decision;
  MirrorReflectionData? _reflection;

  static const List<_Stage> _stages = _Stage.values;

  @override
  void initState() {
    super.initState();
    _service = MirrorExperienceService(widget.runtime);
  }

  _Stage get _stage => _stages[_index];

  void _next() {
    if (_index < _stages.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _restart() {
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MirrorCopy.homeTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _stages.length,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stageLabel(),
                const SizedBox(height: 12),
                _stageBody(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _stage == _Stage.reflection
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: _next,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(MirrorCopy.continueCta),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _stageLabel() {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      'Step ${_index + 1} of ${_stages.length}',
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: scheme.onSurfaceVariant),
    );
  }

  Widget _stageBody() {
    switch (_stage) {
      case _Stage.currentLife:
        _insight ??= _service.currentLife(widget.input);
        return MirrorInsightCard(insight: _insight!);
      case _Stage.prediction:
        _prediction ??= _service.prediction(widget.input);
        return MirrorPredictionCard(prediction: _prediction!);
      case _Stage.decision:
        _decision ??= _service.decision(widget.input);
        return MirrorDecisionCard(decision: _decision!);
      case _Stage.conversation:
        return MirrorConversationEntry(
          input: widget.input,
          runtime: widget.runtime,
        );
      case _Stage.reflection:
        _reflection ??= _service.reflection(widget.input);
        return MirrorReflection(data: _reflection!, onStartOver: _restart);
    }
  }
}
