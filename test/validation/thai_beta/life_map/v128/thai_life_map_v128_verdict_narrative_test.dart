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
          blob.contains('ต้อง') ||
              blob.contains('งาน') ||
              blob.contains('บ้าน') ||
              blob.contains('เปลี่ยน') ||
              blob.contains('โอกาส') ||
              blob.contains('หน้าที่'),
          isTrue,
          reason: 'past event framing',
        );
        expect(
          blob.contains('ผล') ||
              blob.contains('เปลี่ยน') ||
              blob.contains('ต้อง') ||
              blob.contains('ชีวิต'),
          isTrue,
          reason: 'past impact framing',
        );
        expect(blob.contains('ผลกระทบหลักอยู่ที่'), isFalse);
        expect('ช่วงนั้น'.allMatches(blob).length, lessThanOrEqualTo(1));
      }
    });

    test('Current uses reality → pressure → life impact structure', () {
      final state = buildAt(weekday: DateTime.monday, age: 35);
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expectNoPolicyViolation(current.summary, label: 'current summary');
      if (current.whatChanges.isNotEmpty) {
        expectNoPolicyViolation(
          current.whatChanges,
          label: 'current highlight',
        );
      }
      expectNoPolicyViolation(current.harder, label: 'current pressure');
      expectNoPolicyViolation(current.advice, label: 'current impact');
      expect(
        current.summary.contains('ตอนนี้') ||
            current.summary.contains('ต้อง') ||
            current.summary.contains('งาน') ||
            current.summary.contains('เงิน'),
        isTrue,
      );
      expect(
        current.harder.contains('ต้อง') ||
            current.harder.contains('แย่ง') ||
            current.harder.contains('งาน') ||
            current.harder.contains('เวลา') ||
            current.harder.contains('คุณ') ||
            current.harder.contains('คนรอบตัว') ||
            current.harder.contains('ภาระ') ||
            current.harder.contains('โฟกัส'),
        isTrue,
      );
      expect(
        current.advice.contains('ต้อง') ||
            current.advice.contains('เปลี่ยน') ||
            current.advice.contains('เลือก') ||
            current.advice.contains('ชีวิต') ||
            current.advice.contains('คุณ') ||
            current.advice.contains('อนาคต') ||
            current.advice.contains('ทักษะ'),
        isTrue,
      );
      expect(current.summary, isNot(equals(current.harder)));
      expect(current.harder, isNot(equals(current.advice)));
    });

    test('Future uses direction → domain → outcome structure', () {
      final state = buildAt(weekday: DateTime.wednesday, age: 28);
      final future = state.periods.where((p) => !p.isPast && !p.isCurrent);
      expect(future, isNotEmpty);
      for (final p in future) {
        expectNoPolicyViolation(p.summary, label: 'future ${p.planetLine}');
        if (p.whatChanges.isNotEmpty) {
          expectNoPolicyViolation(p.whatChanges, label: 'future highlight');
        }
        expectNoPolicyViolation(p.advice, label: 'future outcome');
        expect(
          p.summary.contains('ต่อไป') ||
              p.summary.contains('โอกาส') ||
              p.summary.contains('งาน') ||
              p.summary.contains('เปลี่ยน') ||
              p.summary.contains('ต้อง'),
          isTrue,
        );
        expect(
          p.advice.contains('ต้อง') ||
              p.advice.contains('เปลี่ยน') ||
              p.advice.contains('ชีวิต') ||
              p.advice.contains('หน้าที่') ||
              p.advice.contains('เลือก') ||
              p.advice.contains('คุณ') ||
              p.advice.contains('อนาคต') ||
              p.advice.contains('ทักษะ'),
          isTrue,
        );
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
              if (p.whatChanges.isNotEmpty) {
                expectNoPolicyViolation(
                  p.whatChanges,
                  label: 'highlight wd=$weekday age=$age',
                );
              }
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
