import 'package:flutter/material.dart';

import 'package:knowme/features/mirror_habit/application/mirror_habit_snapshot.dart';
import 'package:knowme/features/mirror_habit/application/mirror_habit_store.dart';
import 'package:knowme/features/mirror_habit/domain/mirror_day_record.dart';
import 'package:knowme/features/mirror_habit/mirror_habit.dart';
import 'package:knowme/features/mirror_habit/ui/mirror_habit_section.dart';
import 'package:knowme/features/product_validation/product_validation.dart';
import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';

import '../mirror_copy.dart';
import '../mirror_experience_input.dart';
import '../mirror_experience_service.dart';
import '../mirror_view_models.dart';
import 'mirror_cards_common.dart';
import 'mirror_conversation_entry.dart';
import 'mirror_home.dart';
import 'mirror_question_card.dart';
import 'mirror_theme.dart';

/// Phase C — the Daily Mirror, the emotional entry of Home.
///
/// Home is now "Today": three life-guidance messages (opportunity, caution,
/// focus), one suggested step, and one conversation entry. Prediction, Decision
/// and Timeline never appear as concepts — the user experiences life guidance,
/// not engine outputs. The numbers stay behind an expandable "what this is based
/// on". The full guided [MirrorHome] journey is reachable but secondary.
///
/// It reuses the existing P3 widgets and consumes the **`FusionRuntime` only**
/// via [MirrorExperienceService]; no new runtime, provider or AI.
class DailyMirrorSection extends StatefulWidget {
  const DailyMirrorSection({
    super.key,
    required this.input,
    required this.runtime,
    this.habitStore,
  });

  final MirrorExperienceInput input;
  final FusionRuntime runtime;

  /// Phase D — where the daily habit records live (defaults to [MirrorHabit.store]).
  final MirrorHabitStore? habitStore;

  @override
  State<DailyMirrorSection> createState() => _DailyMirrorSectionState();
}

class _DailyMirrorSectionState extends State<DailyMirrorSection> {
  late final MirrorExperienceService _service;
  late final MirrorDaily _daily;
  late final MirrorHabitStore _store;
  late final DateTime _today;
  bool _actionDone = false;
  bool _askOpen = false;

  // Phase D — habit loop state.
  List<MirrorDayRecord> _records = const [];
  MirrorDayRecord? _todayRecord;
  MirrorHabitSnapshot? _habit;

  @override
  void initState() {
    super.initState();
    _service = MirrorExperienceService(widget.runtime);
    _daily = _service.daily(widget.input);
    _store = widget.habitStore ?? MirrorHabit.store;
    _today = MirrorDate.dayOf(widget.input.asOf ?? DateTime.now());
    // Telemetry: opening Home opens the Daily Mirror and shows today's read.
    // The internal funnel stages are still satisfied (the read surfaces the
    // current-life, forward and decision content, just relabelled as life).
    final t = ProductValidation.tracker;
    t.sessionStarted();
    t.homeViewed();
    t.dailyMirrorOpened();
    t.insightViewed();
    t.predictionViewed();
    t.decisionViewed();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    final stored = await _store.recent();
    final todayKey = MirrorDate.key(_today);
    MirrorDayRecord? existing;
    for (final r in stored) {
      if (r.dateKey == todayKey) existing = r;
    }
    final todayRecord =
        (existing ?? MirrorDayRecord.fromDaily(_daily, _today))
            .copyWith(opened: true);
    await _store.upsert(todayRecord);

    final merged = <MirrorDayRecord>[
      for (final r in stored)
        if (r.dateKey != todayKey) r,
      todayRecord,
    ];
    if (!mounted) return;
    setState(() {
      _records = merged;
      _todayRecord = todayRecord;
      _habit = MirrorHabitSnapshot.from(merged, _today);
    });
  }

  void _updateToday(MirrorDayRecord updated) {
    _store.upsert(updated);
    final todayKey = updated.dateKey;
    final merged = <MirrorDayRecord>[
      for (final r in _records)
        if (r.dateKey != todayKey) r,
      updated,
    ];
    setState(() {
      _records = merged;
      _todayRecord = updated;
      _habit = MirrorHabitSnapshot.from(merged, _today);
    });
  }

  void _onAction() {
    if (_actionDone) return;
    ProductValidation.tracker.dailyActionClicked();
    setState(() => _actionDone = true);
    final today = _todayRecord;
    if (today != null && !today.actionTaken) {
      _updateToday(today.copyWith(actionTaken: true));
    }
  }

  void _onReflect(String choice) {
    final today = _todayRecord;
    if (today == null || today.reflected) return;
    ProductValidation.tracker.dailyReflectionSaved();
    _updateToday(today.copyWith(reflected: true, reflectionChoice: choice));
  }

  void _openConversation() {
    if (_askOpen) return;
    final t = ProductValidation.tracker;
    t.dailyConversationStarted();
    t.askMoreViewed();
    setState(() => _askOpen = true);
  }

  void _openJourney() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MirrorHome(input: widget.input, runtime: widget.runtime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MirrorCardShell(child: _todayBody(context)),
        const SizedBox(height: 16),
        if (_askOpen)
          MirrorConversationEntry(
            input: widget.input,
            runtime: widget.runtime,
          )
        else
          MirrorQuestionCard(
            title: MirrorCopy.dailyConversationTitle,
            subtitle: MirrorCopy.dailyConversationBody,
            icon: Icons.chat_bubble_outline_rounded,
            onTap: _openConversation,
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _openJourney,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text(MirrorCopy.dailyJourneyCta),
          ),
        ),
        if (_habit != null && _todayRecord != null) ...[
          const SizedBox(height: 16),
          MirrorHabitSection(
            snapshot: _habit!,
            records: _records,
            today: _today,
            todayRecord: _todayRecord!,
            onReflect: _onReflect,
          ),
        ],
      ],
    );
  }

  Widget _todayBody(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(MirrorCopy.dailyTitle, style: text.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    _daily.dateLabel,
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            MirrorClarityPill(label: _daily.clarity.label),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _daily.greeting,
          style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _message(context, _daily.opportunity),
        const Divider(height: 28),
        _message(context, _daily.caution),
        const Divider(height: 28),
        _message(context, _daily.focus),
        const SizedBox(height: 20),
        _actionTile(context),
        const SizedBox(height: 8),
        MirrorWhyTile(
          areas: _daily.evidenceAreas,
          clarity: _daily.clarity,
          cardId: 'dailyMirror',
        ),
      ],
    );
  }

  Widget _message(BuildContext context, MirrorDailyMessage m) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final color = MirrorTheme.toneColor(m.tone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m.label.toUpperCase(),
          style: text.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(MirrorTheme.toneIcon(m.tone), size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                m.title,
                style: text.titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(m.body, style: text.bodyLarge),
      ],
    );
  }

  Widget _actionTile(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                MirrorCopy.actionLabel.toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_daily.action.body, style: text.bodyLarge),
          const SizedBox(height: 12),
          if (_actionDone)
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 18, color: MirrorTheme.strong),
                const SizedBox(width: 6),
                Text(
                  MirrorCopy.dailyActionDoneAck,
                  style: text.bodyMedium?.copyWith(color: MirrorTheme.strong),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: _onAction,
                child: const Text(MirrorCopy.dailyActionDoneCta),
              ),
            ),
        ],
      ),
    );
  }
}
