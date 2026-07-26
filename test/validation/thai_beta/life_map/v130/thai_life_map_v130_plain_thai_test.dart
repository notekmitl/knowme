import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// V1.3.0 — Product Language Gate on UI-visible Life Map text.
void main() {
  group('Life Map V1.3.0 plain Thai', () {
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

    String cardText(ThaiMirrorLifePeriodState p) {
      return [
        p.summary,
        p.whatChanges,
        p.harder,
        p.advice,
      ].where((s) => s.trim().isNotEmpty).join('\n');
    }

    void expectLanguageGate(String text, {required String label}) {
      expect(text.trim(), isNotEmpty, reason: label);
      expect(
        LifeMapVerdictCopy.violatesPrimaryBody(text),
        isFalse,
        reason: '$label policy: $text',
      );
      expect(
        LifeMapVerdictCopy.looksLikeAbstractOnly(text),
        isFalse,
        reason: '$label abstract: $text',
      );
      expect(
        LifeMapPlainThaiRenderer.hasDomainDumpTail(text),
        isFalse,
        reason: '$label domain dump: $text',
      );
      expect(
        LifeMapPlainThaiRenderer.hasHardJargon(text),
        isFalse,
        reason: '$label jargon: $text',
      );
      expect(text.contains('ผลกระทบหลักอยู่ที่'), isFalse, reason: label);
      expect(text.contains('{{'), isFalse);
      expect(text.contains('null'), isFalse);
      expect(text.trim().endsWith('หรือไม่'), isFalse);
      expect(text.contains('?'), isFalse);
    }

    test('Production V1.2.9 failure phrases are gone', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final blob = state.periods.map(cardText).join('\n');
      expect(blob.contains('ช่วงนั้นบทบาทในบ้านถูกจัดใหม่'), isFalse);
      expect(blob.contains('ผลกระทบหลักอยู่ที่'), isFalse);
      expect(blob.contains('ขอบเขตงาน'), isFalse);
      expect(blob.contains('ขยายบทบาท'), isFalse);
      expect(blob.contains('ควบคู่กับด้าน'), isFalse);
      expect(blob.contains('เป้าหมายเปลี่ยนไปสู่'), isFalse);
      expect(blob.contains('โครงสร้างชีวิต'), isFalse);
      expect(blob.contains('ความมั่นคงทางใจผูกกับ'), isFalse);
    });

    test('each card has at most one ช่วงนั้น and no repeated time opens', () {
      for (final weekday in [
        DateTime.sunday,
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ]) {
        final state = buildAt(weekday: weekday, age: 39, seed: weekday + 3);
        for (final p in state.periods) {
          final text = cardText(p);
          expectLanguageGate(text, label: p.planetLine);
          expect(
            LifeMapPlainThaiRenderer.countMarker(text, 'ช่วงนั้น'),
            lessThanOrEqualTo(1),
            reason: p.planetLine,
          );
          final paras = text
              .split(RegExp(r'\n+'))
              .where((s) => s.trim().isNotEmpty)
              .toList();
          if (paras.length >= 2) {
            final starts = paras.map((s) {
              if (s.startsWith('ช่วงนั้น')) return 'ช่วงนั้น';
              if (s.startsWith('ตอนนี้')) return 'ตอนนี้';
              if (s.startsWith('ต่อไป')) return 'ต่อไป';
              if (s.startsWith('ขณะนี้')) return 'ขณะนี้';
              return '';
            }).where((s) => s.isNotEmpty);
            expect(
              starts.length,
              lessThanOrEqualTo(1),
              reason: 'repeated time opens: $text',
            );
          }
        }
      }
    });

    test('Past/Current/Future use distinct tense language', () {
      final state = buildAt(weekday: DateTime.friday, age: 42);
      final past = state.periods.where((p) => p.isPast).first;
      final current = state.periods.singleWhere((p) => p.isCurrent);
      final future = state.periods
          .where((p) => !p.isPast && !p.isCurrent)
          .first;

      expect(past.summary, isNot(equals(current.summary)));
      expect(current.summary, isNot(equals(future.summary)));
      expect(
        current.summary.contains('ตอนนี้') || current.summary.contains('ต้อง'),
        isTrue,
      );
      expect(
        future.summary.contains('ต่อไป') ||
            future.summary.contains('โอกาส') ||
            future.summary.contains('จะ'),
        isTrue,
      );
      expect(current.summary, isNot(equals(current.harder)));
      expect(current.harder, isNot(equals(current.advice)));
      expect(current.whatChanges, isEmpty);
    });

    test('full 8-period UI text is plain and deterministic', () {
      final a = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      final b = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      expect(
        a.periods.map(cardText).toList(),
        b.periods.map(cardText).toList(),
      );
      expect(a.periods, hasLength(8));
      for (final p in a.periods) {
        expectLanguageGate(cardText(p), label: p.planetLine);
        for (final sentence in cardText(p).split(RegExp(r'[\n。]'))) {
          if (sentence.trim().isEmpty) continue;
          expect(
            LifeMapPlainThaiRenderer.approxClauseCount(sentence),
            lessThanOrEqualTo(4),
            reason: sentence,
          );
        }
      }
    });

    test('different weekdays yield different plain claims', () {
      final a = buildAt(weekday: DateTime.monday, age: 40, seed: 3);
      final b = buildAt(weekday: DateTime.saturday, age: 40, seed: 3);
      expect(
        a.periods.map((p) => p.summary).join('|'),
        isNot(equals(b.periods.map((p) => p.summary).join('|'))),
      );
    });
  });
}
