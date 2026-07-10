import 'package:flutter/material.dart';

import 'package:knowme/features/mirror_experience/ui/mirror_cards_common.dart';
import 'package:knowme/features/mirror_experience/ui/mirror_theme.dart';

import '../application/mirror_habit_snapshot.dart';
import '../domain/mirror_day_record.dart';
import 'mirror_habit_copy.dart';

/// Phase D — the habit loop made visible: streak, last week, Yesterday-vs-Today,
/// a one-tap reflection, weekly/monthly reflections, the life trend, and a
/// gentle "return tomorrow" nudge. Reuses the Mirror card shell + theme.
class MirrorHabitSection extends StatelessWidget {
  const MirrorHabitSection({
    super.key,
    required this.snapshot,
    required this.records,
    required this.today,
    required this.todayRecord,
    required this.onReflect,
  });

  final MirrorHabitSnapshot snapshot;
  final List<MirrorDayRecord> records;
  final DateTime today;
  final MirrorDayRecord todayRecord;
  final void Function(String choice) onReflect;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return MirrorCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _streakHeader(context),
          const SizedBox(height: 16),
          _historyStrip(context),
          const SizedBox(height: 8),
          Text(
            MirrorHabitCopy.yesterday(snapshot.comparison),
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Divider(height: 28),
          _reflect(context),
          const Divider(height: 28),
          _periodRow(context),
          const SizedBox(height: 16),
          _trend(context),
          const SizedBox(height: 16),
          _returnNudge(context),
        ],
      ),
    );
  }

  Widget _streakHeader(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final active = snapshot.streak.activeToday;
    final color = active ? MirrorTheme.tender : scheme.onSurfaceVariant;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_fire_department_rounded, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your streak', style: text.titleMedium),
              const SizedBox(height: 2),
              Text(
                MirrorHabitCopy.streakLine(snapshot.streak),
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _historyStrip(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final byKey = <String, MirrorDayRecord>{
      for (final r in records) r.dateKey: r,
    };
    final dots = <Widget>[];
    for (var i = 6; i >= 0; i--) {
      final day = MirrorDate.dayOf(today).subtract(Duration(days: i));
      final r = byKey[MirrorDate.key(day)];
      final opened = r?.opened ?? false;
      final reflected = r?.reflected ?? false;
      final color = !opened
          ? scheme.surfaceContainerHighest
          : reflected
              ? MirrorTheme.strong
              : scheme.primary;
      dots.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Tooltip(
            message: MirrorDate.key(day),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ));
    }
    return Row(children: dots);
  }

  Widget _reflect(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (todayRecord.reflected) {
      final choice = todayRecord.reflectionChoice;
      return Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: MirrorTheme.strong),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              choice == null
                  ? MirrorHabitCopy.reflectedThanks
                  : '${MirrorHabitCopy.reflectChoiceLabel(choice)} · '
                      '${MirrorHabitCopy.reflectedThanks}',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MirrorHabitCopy.reflectTitle, style: text.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _reflectChip(context, 'opportunity',
                MirrorHabitCopy.reflectOpportunity),
            _reflectChip(context, 'caution', MirrorHabitCopy.reflectCaution),
            _reflectChip(context, 'focus', MirrorHabitCopy.reflectFocus),
          ],
        ),
      ],
    );
  }

  Widget _reflectChip(BuildContext context, String choice, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => onReflect(choice),
    );
  }

  Widget _periodRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _periodTile(
            context,
            MirrorHabitCopy.weeklyTitle,
            MirrorHabitCopy.period(snapshot.weekly),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _periodTile(
            context,
            MirrorHabitCopy.monthlyTitle,
            MirrorHabitCopy.period(snapshot.monthly),
          ),
        ),
      ],
    );
  }

  Widget _periodTile(BuildContext context, String title, String body) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: text.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: text.bodyMedium),
        ],
      ),
    );
  }

  Widget _trend(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.show_chart_rounded, size: 20, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MirrorHabitCopy.trendTitle, style: text.titleMedium),
              const SizedBox(height: 2),
              Text(
                MirrorHabitCopy.trend(snapshot.trend),
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _returnNudge(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_twilight_rounded, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              MirrorHabitCopy.returnTomorrow(snapshot.streak),
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
