import 'package:knowme/features/mirror_experience/mirror_view_models.dart';

/// Phase D — date-only helpers so the habit loop reasons in whole days.
abstract final class MirrorDate {
  static DateTime dayOf(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String key(DateTime dt) {
    final d = dayOf(dt);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  static DateTime? parseKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Whole days from [a] to [b] (b - a), date-only.
  static int daysBetween(DateTime a, DateTime b) =>
      dayOf(b).difference(dayOf(a)).inDays;
}

MirrorTone _toneFromName(String? name) {
  if (name == null) return MirrorTone.steady;
  for (final t in MirrorTone.values) {
    if (t.name == name) return t;
  }
  return MirrorTone.steady;
}

/// Phase D — one day in the Daily Mirror habit loop.
///
/// A compact, **non-astrology** snapshot of the day's read plus the loop flags
/// (opened → action → reflected). It carries only tones, area keys and clarity —
/// never planet/engine/system data — so history, streaks and trends can be
/// computed deterministically and persisted per user.
class MirrorDayRecord {
  const MirrorDayRecord({
    required this.date,
    this.opened = false,
    this.actionTaken = false,
    this.reflected = false,
    this.reflectionChoice,
    this.opportunityTone = MirrorTone.steady,
    this.cautionTone = MirrorTone.steady,
    this.focusTone = MirrorTone.steady,
    this.focusKey,
    this.clarity = 0,
  });

  /// Date-only (local midnight) the record belongs to.
  final DateTime date;

  final bool opened;
  final bool actionTaken;
  final bool reflected;

  /// Which message felt most true: 'opportunity' | 'caution' | 'focus' | null.
  /// A fixed, deterministic choice — never free text, never AI.
  final String? reflectionChoice;

  final MirrorTone opportunityTone;
  final MirrorTone cautionTone;
  final MirrorTone focusTone;
  final String? focusKey;
  final int clarity;

  String get dateKey => MirrorDate.key(date);

  MirrorDayRecord copyWith({
    bool? opened,
    bool? actionTaken,
    bool? reflected,
    String? reflectionChoice,
  }) =>
      MirrorDayRecord(
        date: date,
        opened: opened ?? this.opened,
        actionTaken: actionTaken ?? this.actionTaken,
        reflected: reflected ?? this.reflected,
        reflectionChoice: reflectionChoice ?? this.reflectionChoice,
        opportunityTone: opportunityTone,
        cautionTone: cautionTone,
        focusTone: focusTone,
        focusKey: focusKey,
        clarity: clarity,
      );

  Map<String, Object?> toMap() => {
        'date': dateKey,
        'opened': opened,
        'actionTaken': actionTaken,
        'reflected': reflected,
        'reflectionChoice': reflectionChoice,
        'opportunityTone': opportunityTone.name,
        'cautionTone': cautionTone.name,
        'focusTone': focusTone.name,
        'focusKey': focusKey,
        'clarity': clarity,
      };

  factory MirrorDayRecord.fromMap(Map<String, Object?> map) {
    final dateRaw = map['date'];
    final date = dateRaw is String
        ? (MirrorDate.parseKey(dateRaw) ?? DateTime.now())
        : DateTime.now();
    return MirrorDayRecord(
      date: MirrorDate.dayOf(date),
      opened: map['opened'] == true,
      actionTaken: map['actionTaken'] == true,
      reflected: map['reflected'] == true,
      reflectionChoice: map['reflectionChoice'] as String?,
      opportunityTone: _toneFromName(map['opportunityTone'] as String?),
      cautionTone: _toneFromName(map['cautionTone'] as String?),
      focusTone: _toneFromName(map['focusTone'] as String?),
      focusKey: map['focusKey'] as String?,
      clarity: (map['clarity'] as num?)?.toInt() ?? 0,
    );
  }

  /// Seeds a record from today's Daily Mirror read.
  factory MirrorDayRecord.fromDaily(MirrorDaily daily, DateTime date) =>
      MirrorDayRecord(
        date: MirrorDate.dayOf(date),
        opened: true,
        opportunityTone: daily.opportunity.tone,
        cautionTone: daily.caution.tone,
        focusTone: daily.focus.tone,
        focusKey: daily.focus.area?.key,
        clarity: daily.clarity.value,
      );
}
