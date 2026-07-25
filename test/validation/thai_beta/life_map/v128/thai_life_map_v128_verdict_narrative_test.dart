import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// V1.2.8 — Past / Current / Future verdict narrative contract.
void main() {
  group('Life Map V1.2.8 verdict narrative', () {
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

    void expectNoPolicyViolation(String text, {required String label}) {
      expect(text.trim(), isNotEmpty, reason: label);
      expect(
        LifeMapVerdictCopy.violatesPrimaryBody(text),
        isFalse,
        reason: '$label contains banned hedge/coaching/catastrophe: $text',
      );
      expect(text.contains('{{'), isFalse, reason: label);
      expect(text.contains('null'), isFalse, reason: label);
      expect(text.contains('TODO'), isFalse, reason: label);
      expect(text.trim().endsWith('หรือไม่'), isFalse, reason: label);
      expect(text.contains('?'), isFalse, reason: label);
    }

    test('Past uses event → impact structure without hedges', () {
      final state = buildAt(weekday: DateTime.friday, age: 42);
      final past = state.periods.where((p) => p.isPast).toList();
      expect(past, isNotEmpty);
      for (final p in past) {
        expectNoPolicyViolation(p.summary, label: 'past ${p.planetLine}');
        expect(p.advice, isEmpty);
        expect(p.harder, isEmpty);
        expect(p.whatChanges, isEmpty);
        final blob = p.summary;
        expect(
          blob.contains('ช่วง') || blob.contains('แรงหลัก'),
          isTrue,
          reason: 'past event framing',
        );
        expect(
          blob.contains('ผลที่ตามมา') ||
              blob.contains('ฝังแบบแผน') ||
              blob.contains('เปลี่ยน') ||
              blob.contains('ถูกกำหนด') ||
              blob.contains('ถูกบังคับ') ||
              blob.contains('กลายเป็น') ||
              blob.contains('แรงหลัก'),
          isTrue,
          reason: 'past impact framing',
        );
      }
    });

    test('Current uses reality → pressure → life impact structure', () {
      final state = buildAt(weekday: DateTime.monday, age: 35);
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expectNoPolicyViolation(current.summary, label: 'current summary');
      expectNoPolicyViolation(current.whatChanges, label: 'current highlight');
      expectNoPolicyViolation(current.harder, label: 'current pressure');
      expectNoPolicyViolation(current.advice, label: 'current impact');
      expect(
        current.summary.contains('ขณะนี้') ||
            current.summary.contains('จังหวะ'),
        isTrue,
      );
      expect(
        current.harder.contains('แรงกดดัน') ||
            current.harder.contains('ความขัดแย้ง'),
        isTrue,
      );
      expect(
        current.advice.contains('ผลต่อชีวิต') ||
            current.advice.contains('ถูกบังคับให้ชัด') ||
            current.advice.contains('เปลี่ยน'),
        isTrue,
      );
    });

    test('Future uses direction → domain → outcome structure', () {
      final state = buildAt(weekday: DateTime.wednesday, age: 28);
      final future = state.periods.where((p) => !p.isPast && !p.isCurrent);
      expect(future, isNotEmpty);
      for (final p in future) {
        expectNoPolicyViolation(p.summary, label: 'future ${p.planetLine}');
        expectNoPolicyViolation(p.whatChanges, label: 'future highlight');
        expectNoPolicyViolation(p.advice, label: 'future outcome');
        expect(
          p.summary.contains('เมื่อถึง') || p.summary.contains('จังหวะ'),
          isTrue,
        );
        expect(
          p.advice.contains('ผลที่ตามมา') || p.advice.contains('สภาพใหม่'),
          isTrue,
        );
        expect(p.whatChanges.contains('ให้ให้'), isFalse);
      }
    });

    test('Past / Current / Future differ for same profile', () {
      final state = buildAt(weekday: DateTime.saturday, age: 48, seed: 9);
      final past = state.periods.where((p) => p.isPast).first;
      final current = state.periods.singleWhere((p) => p.isCurrent);
      final future = state.periods
          .where((p) => !p.isPast && !p.isCurrent)
          .first;
      expect(past.summary, isNot(equals(current.summary)));
      expect(current.summary, isNot(equals(future.summary)));
      expect(past.summary, isNot(equals(future.summary)));
    });

    test('output is deterministic for same seed', () {
      final a = buildAt(weekday: DateTime.thursday, age: 40, seed: 21);
      final b = buildAt(weekday: DateTime.thursday, age: 40, seed: 21);
      expect(
        a.periods.map((p) => p.summary).toList(),
        b.periods.map((p) => p.summary).toList(),
      );
      expect(
        a.periods
            .map((p) => '${p.whatChanges}|${p.harder}|${p.advice}')
            .toList(),
        b.periods
            .map((p) => '${p.whatChanges}|${p.harder}|${p.advice}')
            .toList(),
      );
    });

    test('eight weekdays produce verdict copy without policy violations', () {
      const weekdays = [
        DateTime.sunday,
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ];
      // Wednesday night uses same weekday index; engine receives DateTime weekday.
      for (final weekday in weekdays) {
        for (final age in const [12, 25, 45, 70]) {
          final state = buildAt(
            weekday: weekday,
            age: age,
            seed: weekday + age,
          );
          expect(state.periods.length, 8);
          for (final p in state.periods) {
            expectNoPolicyViolation(
              p.summary,
              label: 'wd=$weekday age=$age ${p.planetLine}',
            );
            if (!p.isPast) {
              expectNoPolicyViolation(
                p.whatChanges,
                label: 'highlight wd=$weekday age=$age',
              );
              expectNoPolicyViolation(
                p.harder,
                label: 'pressure wd=$weekday age=$age',
              );
              expectNoPolicyViolation(
                p.advice,
                label: 'impact wd=$weekday age=$age',
              );
            }
          }
        }
      }
    });
  });
}
