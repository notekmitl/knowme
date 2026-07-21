import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/conversation/conversation_catalog.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_flow.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_question.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_session.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_suggestion.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_topic.dart';
import 'package:knowme/features/product_validation/product_validation.dart';
import 'package:knowme/features/runtime/fusion/fusion_result.dart';
import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';

import '../mirror_copy.dart';
import '../mirror_experience_input.dart';
import '../mirror_view_models.dart';
import 'mirror_question_card.dart';
import 'mirror_theme.dart';

/// P3 — the conversation, which **starts from cards, not an empty chat**.
///
/// It drives the V16 guided-conversation flow through the Fusion Runtime: the
/// user opens a topic card, taps a predefined question, the runtime answers, and
/// the flow offers the next cards. No typing, no AI, no astrology terminology —
/// answers are framed as life, with the confidence behind the read.
class MirrorConversationEntry extends StatefulWidget {
  const MirrorConversationEntry({
    super.key,
    required this.input,
    required this.runtime,
  });

  final MirrorExperienceInput input;
  final FusionRuntime runtime;

  @override
  State<MirrorConversationEntry> createState() =>
      _MirrorConversationEntryState();
}

class _MirrorConversationEntryState extends State<MirrorConversationEntry> {
  late ConversationSession _session;

  @override
  void initState() {
    super.initState();
    _session = ConversationSession.start(
      birthDate: widget.input.birthDate,
      asOf: widget.input.asOf,
    );
  }

  void _openTopic(ConversationTopic topic) {
    ProductValidation.tracker.conversationTopicOpened(topic.name);
    setState(() {
      _session = ConversationFlow.openTopic(_session, topic);
    });
  }

  void _ask(String questionId) {
    ProductValidation.tracker.conversationQuestionAsked(questionId);
    setState(() {
      _session =
          ConversationFlow.ask(_session, questionId, runtime: widget.runtime);
    });
    // The fusion answer resolves synchronously and is now in state.
    ProductValidation.tracker.conversationAnswerViewed(questionId);
  }

  void _askFromSuggestion(String questionId) {
    ProductValidation.tracker.conversationSuggestionTapped(questionId);
    _ask(questionId);
  }

  void _backToTopics() {
    setState(() {
      _session = ConversationSession.start(
        birthDate: widget.input.birthDate,
        asOf: widget.input.asOf,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _session.state;
    final children = <Widget>[];

    if (state.topic == null) {
      children.add(_sectionTitle(MirrorCopy.askMoreTitle));
      children.add(_sectionBody(MirrorCopy.askMoreBody));
      children.add(const SizedBox(height: 12));
      for (final topic in ConversationTopic.values) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MirrorQuestionCard(
            title: _topicTitle(topic),
            icon: _topicIcon(topic),
            onTap: () => _openTopic(topic),
          ),
        ));
      }
    } else {
      children.add(_topicHeader(state.topic!));
      children.add(const SizedBox(height: 8));

      if (state.lastAnswer != null) {
        children.add(_answerCard(
          state.lastQuestion!,
          state.lastAnswer!.fusion,
        ));
        children.add(const SizedBox(height: 16));
        if (state.suggestions.isNotEmpty) {
          children.add(_sectionTitle('You might also ask'));
          children.add(const SizedBox(height: 8));
          for (final s in state.suggestions) {
            children.add(Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MirrorQuestionCard(
                title: s.label,
                subtitle: _suggestionReason(s.reason),
                icon: Icons.subdirectory_arrow_right_rounded,
                onTap: () => _askFromSuggestion(s.questionId),
              ),
            ));
          }
        }
      } else {
        children.add(const SizedBox(height: 4));
        for (final q in ConversationCatalog.forTopic(state.topic!)) {
          children.add(Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MirrorQuestionCard(
              title: q.label,
              icon: Icons.help_outline_rounded,
              onTap: () => _ask(q.id),
            ),
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // --- Pieces --------------------------------------------------------------

  Widget _sectionTitle(String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      );

  Widget _sectionBody(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      );

  Widget _topicHeader(ConversationTopic topic) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: _backToTopics,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to topics',
        ),
        const SizedBox(width: 4),
        Icon(_topicIcon(topic), color: scheme.primary),
        const SizedBox(width: 8),
        Text(_topicTitle(topic),
            style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _answerCard(ConversationQuestion question, FusionResult fusion) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final view = _summarize(fusion);
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.label, style: text.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            )),
            const SizedBox(height: 10),
            Text(view.headline, style: text.titleMedium?.copyWith(
              color: MirrorTheme.toneColor(view.tone),
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 8),
            Text(view.body, style: text.bodyLarge),
            const SizedBox(height: 12),
            MirrorClarityPill(label: view.clarityLabel),
          ],
        ),
      ),
    );
  }

  _AnswerView _summarize(FusionResult fusion) {
    final netByDomain = <String, int>{
      for (final e in fusion.mergedEvidence) e.domain: e.netMagnitude,
    };
    String? domain;
    if (fusion.priorities.isNotEmpty) {
      domain = fusion.priorities.first.domain;
    } else if (netByDomain.isNotEmpty) {
      domain = netByDomain.keys.first;
    }
    final net = domain == null ? 0 : (netByDomain[domain] ?? 0);
    final tone = net > 0
        ? MirrorTone.strong
        : net < 0
            ? MirrorTone.tender
            : MirrorTone.steady;
    final title = domain == null ? 'This' : MirrorCopy.areaTitle(domain);
    final headline = tone == MirrorTone.strong
        ? '$title looks supportive'
        : tone == MirrorTone.tender
            ? '$title asks for care'
            : '$title looks steady';
    return _AnswerView(
      tone: tone,
      headline: headline,
      body: MirrorCopy.toneSummary(tone),
      clarityLabel: MirrorCopy.clarityLabel(fusion.confidence.band),
    );
  }

  String _suggestionReason(ConversationSuggestionReason reason) {
    switch (reason) {
      case ConversationSuggestionReason.followUp:
        return 'A natural next step';
      case ConversationSuggestionReason.deepen:
        return 'Go a little deeper';
    }
  }

  String _topicTitle(ConversationTopic topic) {
    switch (topic) {
      case ConversationTopic.currentLife:
        return 'Life right now';
      case ConversationTopic.career:
        return 'Work & Direction';
      case ConversationTopic.money:
        return 'Money & Security';
      case ConversationTopic.relationship:
        return 'Relationships';
      case ConversationTopic.family:
        return 'Family';
      case ConversationTopic.health:
        return 'Health & Energy';
      case ConversationTopic.growth:
        return 'Personal Growth';
      case ConversationTopic.future:
        return 'The road ahead';
    }
  }

  IconData _topicIcon(ConversationTopic topic) {
    switch (topic) {
      case ConversationTopic.currentLife:
        return Icons.wb_sunny_rounded;
      case ConversationTopic.career:
        return Icons.work_outline_rounded;
      case ConversationTopic.money:
        return Icons.savings_rounded;
      case ConversationTopic.relationship:
        return Icons.favorite_border_rounded;
      case ConversationTopic.family:
        return Icons.home_rounded;
      case ConversationTopic.health:
        return Icons.spa_rounded;
      case ConversationTopic.growth:
        return Icons.eco_rounded;
      case ConversationTopic.future:
        return Icons.explore_rounded;
    }
  }
}

class _AnswerView {
  const _AnswerView({
    required this.tone,
    required this.headline,
    required this.body,
    required this.clarityLabel,
  });

  final MirrorTone tone;
  final String headline;
  final String body;
  final String clarityLabel;
}
