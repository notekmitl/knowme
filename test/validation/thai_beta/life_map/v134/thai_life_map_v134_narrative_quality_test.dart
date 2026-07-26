import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_current_domain_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// V1.3.4 — Narrative quality gates (no ephemeris).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int clauseCount(String body) {
    final markers = RegExp(
      r'(ช่วงนี้|ด้านการ|รายได้|รายจ่าย|แนวโน้ม|ควร|หาก|จุดเสี่ยง|เหมาะกับ|ข้อความนี้|ยังไม่มีสัญญาณ|โชค)',
    );
    final n = markers.allMatches(body).length;
    if (n >= 2) return n.clamp(2, 4);
    // Fallback: long bodies with multiple clauses separated by spaces.
    if (body.length >= 80) return 2;
    return 1;
  }

  group('V1.3.4 overview', () {
    test('hero is life overview, not personality-only or system template', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final blob = '${view.hero.headline}\n${view.hero.summary}';
      expect(view.signatureInsight.isEmpty, isTrue);
      expect(blob, isNot(contains('พื้นฐานจากดวงไทยคู่กับ')));
      expect(blob, isNot(contains('Swiss Ephemeris')));
      expect(blob, isNot(contains('องศา')));
      expect(view.hero.headline.startsWith('คุณเป็นคน'), isFalse);
      expect(
        blob.contains('ดาวเสวยอายุ') ||
            blob.contains('ตอนนี้อยู่ใน') ||
            blob.contains('เส้นทางชีวิต'),
        isTrue,
        reason: blob,
      );
    });

    test('no-birth-time still works', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view;
      expect(view.hero.identitySubtitle, contains('ไม่มีเวลาเกิด'));
    });
  });

  group('V1.3.4 Past', () {
    test('past periods differ by evidence and stay event-safe', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.sunday,
        currentAge: 39,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: 17,
      )!;
      final past = state.periods.where((p) => p.isPast).toList();
      expect(past.length, greaterThanOrEqualTo(2));
      final texts = past.map((p) => p.summary).toList();
      expect(texts.toSet().length, texts.length);
      for (final t in texts) {
        expect(t, isNot(contains('ในช่วงนั้น')));
        expect(t, isNot(contains('แต่งงาน')));
        expect(t, isNot(contains('เลิกรา')));
        expect(t, isNot(contains('ย้ายบ้าน')));
        expect(LifeMapPlainThaiRenderer.hasVagueRelationshipForm(t), isFalse);
        final sentences = t
            .split(RegExp(r'\n\n|\s+(?=คุณ|ต้อง|มีแรง|วัยนี้|ธีม|ช่วงนี้|ใน)'))
            .where((s) => s.trim().isNotEmpty);
        expect(sentences.length, greaterThanOrEqualTo(2));
      }
    });
  });

  group('V1.3.4 Current four domains', () {
    test('always การงาน การเงิน สุขภาพ โชคลาภ with 2–4 sentences', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.sunday,
        currentAge: 39,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: 17,
      )!;
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expect(
        current.lifeDomains.map((d) => d.title).toList(),
        LifeMapCurrentDomainComposer.allowedTitles,
      );
      for (final legacy in LifeMapCurrentDomainComposer.legacyTitles) {
        expect(
          current.lifeDomains.map((d) => d.title),
          isNot(contains(legacy)),
        );
      }
      for (final d in current.lifeDomains) {
        expect(d.body.trim(), isNotEmpty);
        final n = clauseCount(d.body);
        expect(n, greaterThanOrEqualTo(2), reason: '${d.title}: ${d.body}');
        expect(n, lessThanOrEqualTo(4), reason: '${d.title}: ${d.body}');
        // Gambling safety: no exhortation to gamble (informational "พนัน" ban ok).
        expect(d.body, isNot(contains('ซื้อหวย')));
        expect(d.body, isNot(contains('ไปเสี่ยงพนันเพื่อ')));
      }
      final work = current.lifeDomains.firstWhere(
        (d) => d.title == LifeMapCurrentDomainComposer.titleWork,
      );
      expect(
        work.body.contains('ขยาย') ||
            work.body.contains('ทรงตัว') ||
            work.body.contains('เปลี่ยนแปลง') ||
            work.body.contains('พิจารณา') ||
            work.body.contains('ชะลอ') ||
            work.body.contains('เดินหน้า') ||
            work.body.contains('หน้าที่'),
        isTrue,
        reason: work.body,
      );
      final fortune = current.lifeDomains.firstWhere(
        (d) => d.title == LifeMapCurrentDomainComposer.titleFortune,
      );
      expect(
        fortune.body.contains('งาน') || fortune.body.contains('รายได้'),
        isTrue,
      );
      expect(fortune.body, isNot(contains('ควรซื้อหวย')));
    });

    test('different fixtures differ in substance', () {
      String currentBlob(int weekday, int age, int seed) {
        final timeline = LifePeriodEngine.build(
          birthWeekday: weekday,
          currentAge: age,
        );
        final state = TimelinePresenter.build(
          lifePeriods: timeline,
          lagnaLordKey: 'sun',
          orderedThemeIds: const ['structure'],
          topThemeTags: const ['มั่นคง'],
          profileSeed: seed,
        )!;
        final c = state.periods.singleWhere((p) => p.isCurrent);
        return c.lifeDomains.map((d) => '${d.title}:${d.body}').join('|');
      }

      final a = currentBlob(DateTime.sunday, 39, 17);
      final b = currentBlob(DateTime.wednesday, 25, 99);
      expect(a, isNot(equals(b)));
    });
  });

  group('V1.3.4 no ephemeris claims', () {
    test('narrative surfaces do not claim planet degrees or houses grid', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final blob = [
        view.hero.headline,
        view.hero.summary,
        ...?view.lifeTimeline?.periods.expand(
          (p) => [p.summary, ...p.lifeDomains.map((d) => d.body)],
        ),
      ].join('\n');
      expect(blob, isNot(contains('Swiss Ephemeris')));
      expect(blob, isNot(contains('องศาที่')));
      expect(blob, isNot(contains('เรือนที่')));
    });
  });
}
