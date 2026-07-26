import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_blocks.dart';

/// V1.3.1 — Past depth + natural Current + hero disclaimer removal.
void main() {
  group('Life Map V1.3.1 narrative depth', () {
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

    String cardText(ThaiMirrorLifePeriodState p) => [
      p.summary,
      p.whatChanges,
      p.harder,
      p.advice,
    ].where((s) => s.trim().isNotEmpty).join('\n');

    test('Production V1.3.0 failure phrases are gone', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final blob = state.periods.map(cardText).join('\n');
      expect(blob.contains('แย่งกันอยู่'), isFalse);
      expect(blob.contains('แย่งกัน'), isFalse);
      expect(
        blob.contains('ภาระที่มีกับเวลาพักที่ร่างกายต้องการแย่งกันอยู่'),
        isFalse,
      );
      expect(blob.contains('ผลกระทบหลักอยู่ที่'), isFalse);
    });

    test('Past with evidence is a story not a 3-bullet summary', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      for (final p in state.periods.where((p) => p.isPast)) {
        final text = p.summary;
        expect(LifeMapVerdictCopy.violatesPrimaryBody(text), isFalse);
        expect(LifeMapPlainThaiRenderer.hasAbstractDuel(text), isFalse);
        expect(LifeMapPlainThaiRenderer.hasPastSoftOpener(text), isFalse);
        final words = (text.replaceAll(RegExp(r'\s+'), '').runes.length / 2.5)
            .round();
        expect(words, greaterThanOrEqualTo(40), reason: text);
        // Multiple distinct beats: context/change/pressure/response cues.
        expect(
          text.contains('ก่อนหน้า') ||
              text.contains('เปลี่ยน') ||
              text.contains('ต้อง'),
          isTrue,
          reason: text,
        );
        expect(
          text.contains('ต้อง') ||
              text.contains('คุณ') ||
              text.contains('เริ่ม'),
          isTrue,
        );
        expect('ช่วงนั้น'.allMatches(text).length, equals(0), reason: text);
        expect('ในช่วงนั้น'.allMatches(text).length, equals(0), reason: text);
      }
    });

    test('Current uses natural actor-led pressure language', () {
      for (final weekday in [
        DateTime.sunday,
        DateTime.monday,
        DateTime.friday,
      ]) {
        final state = buildAt(weekday: weekday, age: 35, seed: weekday + 2);
        final current = state.periods.singleWhere((p) => p.isCurrent);
        for (final part in [current.summary, current.harder, current.advice]) {
          expect(LifeMapPlainThaiRenderer.hasAbstractDuel(part), isFalse);
          expect(LifeMapVerdictCopy.violatesPrimaryBody(part), isFalse);
          expect(part.contains('แย่งกัน'), isFalse);
        }
        expect(current.summary, isNot(equals(current.harder)));
        expect(current.harder, isNot(equals(current.advice)));
      }
    });

    test('hero curated blocks no longer include soft disclaimer', () {
      final blob = ThaiBetaCuratedNarrativeBlocks.all
          .expand((b) => b.heroSentences)
          .join('\n');
      expect(blob.contains('ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง'), isFalse);
      expect(blob.contains('ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ'), isFalse);
      // Unrelated hero line still present (not replaced with filler).
      expect(
        blob.contains(
              'เวลาต้องเลือก คุณมักลิสต์ข้อดีข้อเสียในหัวอยู่เงียบ ๆ ก่อนเสมอ',
            ) ||
            blob.contains('คนอื่นมักเห็นว่าคุณ'),
        isTrue,
      );
    });

    test('deterministic and 8 periods still product-safe', () {
      final a = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      final b = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      expect(
        a.periods.map(cardText).toList(),
        b.periods.map(cardText).toList(),
      );
      expect(a.periods, hasLength(8));
      for (final p in a.periods) {
        final text = cardText(p);
        expect(LifeMapPlainThaiRenderer.hasAbstractDuel(text), isFalse);
        expect(LifeMapVerdictCopy.violatesPrimaryBody(text), isFalse);
        expect(
          LifeMapPlainThaiRenderer.countMarker(text, 'ช่วงนั้น'),
          equals(0),
        );
        expect(LifeMapPlainThaiRenderer.hasPastSoftOpener(text), isFalse);
        expect(
          LifeMapPlainThaiRenderer.hasVagueRelationshipForm(text),
          isFalse,
        );
      }
    });
  });
}
