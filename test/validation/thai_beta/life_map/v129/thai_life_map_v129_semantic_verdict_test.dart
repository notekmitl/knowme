import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// V1.2.9 — semantic life-situation verdicts (product acceptance).
void main() {
  group('Life Map V1.2.9 semantic verdict', () {
    ThaiMirrorLifeTimelineState buildAt({
      required int weekday,
      required int age,
      int seed = 17,
    }) {
      final timeline = LifePeriodEngine.build(
        birthWeekday: weekday,
        currentAge: age,
      );
      return TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: seed,
      )!;
    }

    void expectProductCopy(
      String text, {
      required String label,
      bool isAction = false,
    }) {
      expect(text.trim(), isNotEmpty, reason: label);
      expect(
        LifeMapVerdictCopy.violatesPrimaryBody(text),
        isFalse,
        reason: '$label policy: $text',
      );
      final concreteImperative = isAction && text.startsWith('คุณต้อง');
      expect(
        LifeMapVerdictCopy.looksLikeAbstractOnly(text) && !concreteImperative,
        isFalse,
        reason: '$label abstract-only: $text',
      );
      expect(text.contains('{{'), isFalse);
      expect(text.contains('null'), isFalse);
      expect(text.trim().endsWith('หรือไม่'), isFalse);
      expect(text.contains('?'), isFalse);
    }

    test('Production failure phrases are gone from presenter path', () {
      final state = buildAt(weekday: DateTime.sunday, age: 25);
      final blob = state.periods.map((p) => p.summary).join('\n');
      expect(blob.contains('แกนของชีวิต'), isFalse);
      expect(blob.contains('บรรยากาศหลัก'), isFalse);
      expect(blob.contains('มากกว่าเรื่องอื่นในช่วงใกล้เคียง'), isFalse);
      expect(blob.contains('มีน้ำหนักต่างจากจังหวะ'), isFalse);
      expect(blob.contains('ภายใต้อิทธิพล'), isFalse);
      expect(blob.contains('แรงหลัก'), isFalse);
    });

    test('Past/Current/Future expose situation+domain+consequence semantics', () {
      final state = buildAt(weekday: DateTime.friday, age: 42);
      // Rebuild via composer is covered by presenter strings; assert product shape.
      final past = state.periods.where((p) => p.isPast).first;
      final current = state.periods.singleWhere((p) => p.isCurrent);
      final future = state.periods
          .where((p) => !p.isPast && !p.isCurrent)
          .first;

      expectProductCopy(past.summary, label: 'past');
      expectProductCopy(current.summary, label: 'current summary');
      expectProductCopy(current.harder, label: 'current pressure');
      expectProductCopy(
        current.advice,
        label: 'current consequence',
        isAction: true,
      );
      expectProductCopy(future.summary, label: 'future summary');
      expectProductCopy(
        future.advice,
        label: 'future consequence',
        isAction: true,
      );

      expect(past.summary, isNot(equals(current.summary)));
      expect(current.summary, isNot(equals(future.summary)));
      expect(current.summary, isNot(equals(current.harder)));
      expect(current.harder, isNot(equals(current.advice)));
    });

    test('different planets yield different situation claims', () {
      final a = buildAt(weekday: DateTime.monday, age: 40, seed: 3);
      final b = buildAt(weekday: DateTime.saturday, age: 40, seed: 3);
      final aPast = a.periods
          .where((p) => p.isPast)
          .map((p) => p.summary)
          .join('|');
      final bPast = b.periods
          .where((p) => p.isPast)
          .map((p) => p.summary)
          .join('|');
      expect(aPast, isNot(equals(bPast)));
    });

    test('deterministic for same seed', () {
      final a = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      final b = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      expect(
        a.periods.map((p) => '${p.summary}|${p.harder}|${p.advice}').toList(),
        b.periods.map((p) => '${p.summary}|${p.harder}|${p.advice}').toList(),
      );
    });

    test('eight weekdays × ages keep product copy', () {
      for (final weekday in [
        DateTime.sunday,
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ]) {
        for (final age in [12, 25, 45, 70]) {
          final state = buildAt(
            weekday: weekday,
            age: age,
            seed: weekday + age,
          );
          for (final p in state.periods) {
            expectProductCopy(
              p.summary,
              label: 'wd=$weekday age=$age ${p.planetLine}',
            );
            if (!p.isPast) {
              expectProductCopy(p.harder, label: 'pressure');
              expectProductCopy(
                p.advice,
                label: 'consequence',
                isAction: true,
              );
            }
          }
        }
      }
    });
  });
}
