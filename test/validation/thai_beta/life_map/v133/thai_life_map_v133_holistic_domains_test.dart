import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_current_domain_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// V1.3.3 — Holistic overview + Past life-story variety + Current life domains.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bannedSemanticHeadings = [
    'วิถีทาง',
    'เรื่องสำคัญของช่วงนี้',
    'สรุปช่วงนี้',
    'สิ่งที่ทำให้ลำบาก',
    'ผลต่อชีวิตในช่วงนี้',
    'ความเปลี่ยนแปลงจากช่วงก่อน',
  ];

  const allowedDomains = [
    LifeMapCurrentDomainComposer.titleWork,
    LifeMapCurrentDomainComposer.titleMoney,
    LifeMapCurrentDomainComposer.titleHealth,
    LifeMapCurrentDomainComposer.titleFortune,
  ];

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

  String openerKey(String text) {
    final t = text.trim();
    if (t.isEmpty) return '';
    final first = t.split(RegExp(r'\s+|\n')).first;
    return first.length <= 12 ? first : first.substring(0, 12);
  }

  String skeleton(String text) {
    // Collapse nouns loosely: keep verbs/particles pattern for template detect.
    return text
        .replaceAll(RegExp(r'[๐-๙0-9]+'), '#')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  group('V1.3.3 opening holistic hero', () {
    test('not personality-only — has natal + life/current dimensions', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      expect(view.hero.identityBadge, 'ดวงไทยของคุณ');
      expect(view.signatureInsight.isEmpty, isTrue);
      final blob = '${view.hero.headline}\n${view.hero.summary}';
      expect(blob, isNot(contains('แก่นที่พอเห็นได้จากข้อมูลที่มี')));
      expect(blob, isNot(contains('ข้อมูลวันเกิดครบถ้วน')));
      expect(blob, isNot(contains('ใช้สังเกตตัวเอง ไม่ใช่คำฟันธง')));

      // Life / current dimension markers (not trait-only).
      final hasLifeDim =
          blob.contains('เส้นทางชีวิต') ||
          blob.contains('จังหวะ') ||
          blob.contains('ช่วง') ||
          blob.contains('ดาวเสวยอายุ') ||
          blob.contains('ตอนนี้อยู่ใน');
      expect(hasLifeDim, isTrue, reason: blob);

      // Headline must not be a pure "คุณเป็นคน..." personality line alone.
      expect(view.hero.headline.startsWith('คุณเป็นคน'), isFalse);
      expect(view.hero.headline.contains('พื้นฐานจากดวงไทยคู่กับ'), isFalse);

      final paras = view.hero.summary
          .split('\n\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();
      expect(paras.length, greaterThanOrEqualTo(2));
      expect(paras.length, lessThanOrEqualTo(4));
    });

    test('incomplete birth time keeps limitation on subtitle', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view;
      expect(view.hero.identitySubtitle, contains('ไม่มีเวลาเกิด'));
      expect(view.signatureInsight.isEmpty, isTrue);
    });

    testWidgets('UI: single hero, no core card, no complete banner', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: ThaiBetaNarrativeFixtures.fixtureA(),
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thai_consumer_hero')), findsOneWidget);
      expect(
        find.byKey(const Key('thai_consumer_signature_insight')),
        findsNothing,
      );
      expect(find.text('ข้อมูลวันเกิดครบถ้วน'), findsNothing);
    });
  });

  group('V1.3.3 Past life-story variety', () {
    test('eight past periods without soft opener or shared skeleton', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final past = state.periods.where((p) => p.isPast).toList();
      expect(past.length, 3); // age 39 — first three periods are past

      // Full 8-period board across ages that cover all eight as past/current/future.
      final full = buildAt(weekday: DateTime.sunday, age: 100);
      expect(full.periods.length, 8);

      final openers = <String>[];
      final skeletons = <String>[];
      for (final p in full.periods.where((p) => p.isPast)) {
        final text = p.summary;
        expect(text, isNotEmpty);
        expect(text, isNot(contains('ในช่วงนั้น')));
        expect(RegExp(r'(^|\n)ช่วงนั้น').hasMatch(text), isFalse);
        expect(
          LifeMapPlainThaiRenderer.hasVagueRelationshipForm(text),
          isFalse,
        );
        openers.add(openerKey(text));
        skeletons.add(skeleton(text.split('\n\n').first));
      }

      // Not all past cards share the same opening token.
      expect(openers.toSet().length, greaterThan(1), reason: '$openers');

      // First-paragraph skeletons should not be identical across all past cards.
      expect(skeletons.toSet().length, greaterThan(1), reason: '$skeletons');
    });

    test('production-equivalent weekday=7 age=39 past still evidence-only', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39, seed: 17);
      for (final p in state.periods.where((p) => p.isPast)) {
        expect(p.summary, isNot(contains('แต่งงาน')));
        expect(p.summary, isNot(contains('เลิกรา')));
        expect(p.summary, isNot(contains('ในช่วงนั้น')));
      }
    });
  });

  group('V1.3.3 Current life domains', () {
    test('Current uses exactly 4 forecast domains', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expect(current.lifeDomains, isNotEmpty);
      expect(current.lifeDomains.length, 4);
      expect(
        current.lifeDomains.map((d) => d.title).toList(),
        LifeMapCurrentDomainComposer.allowedTitles,
      );

      for (final d in current.lifeDomains) {
        expect(allowedDomains, contains(d.title));
        expect(d.body.trim(), isNotEmpty);
        expect(d.body, isNot(contains('ข้อมูลไม่เพียงพอ')));
        expect(
          LifeMapPlainThaiRenderer.hasVagueRelationshipForm(d.body),
          isFalse,
        );
        // Health safety
        if (d.title == LifeMapCurrentDomainComposer.titleHealth) {
          for (final banned in ['โรค', 'มะเร็ง', 'วินิจฉัย', 'เบาหวาน']) {
            expect(d.body, isNot(contains(banned)));
          }
        }
      }

      // No duplicate bodies across domains.
      final bodies = current.lifeDomains.map((d) => d.body.trim()).toList();
      expect(bodies.toSet().length, bodies.length);

      final titles = current.lifeDomains.map((d) => d.title).toList();
      expect(titles.toSet().length, titles.length);

      for (final h in bannedSemanticHeadings) {
        expect(titles, isNot(contains(h)));
      }
      for (final h in LifeMapCurrentDomainComposer.legacyTitles) {
        expect(titles, isNot(contains(h)));
      }
    });

    test('Future keeps slot layout — no life domain headings forced', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final future = state.periods.where((p) => !p.isPast && !p.isCurrent);
      for (final p in future) {
        expect(p.lifeDomains, isEmpty);
        expect(p.summary, isNotEmpty);
      }
    });

    testWidgets('Current UI shows domain titles when expanded', (tester) async {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expect(current.lifeDomains, isNotEmpty);

      await tester.binding.setSurfaceSize(const Size(390, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiMirrorLifeTimelineSection(
                state: state,
                lifeMapMode: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure current details are visible (scroll + expand if needed).
      final workTitle = find.text(LifeMapCurrentDomainComposer.titleWork);
      if (workTitle.evaluate().isEmpty) {
        final expand = find.text(
          ThaiMirrorLifeTimelineSection.expandDetailsLabel,
        );
        for (var i = 0; i < expand.evaluate().length; i++) {
          await tester.ensureVisible(expand.at(i));
          await tester.tap(expand.at(i), warnIfMissed: false);
          await tester.pumpAndSettle();
          if (find
              .text(LifeMapCurrentDomainComposer.titleWork)
              .evaluate()
              .isNotEmpty) {
            break;
          }
        }
      }
      expect(find.text(LifeMapCurrentDomainComposer.titleWork), findsWidgets);
      for (final d in current.lifeDomains) {
        expect(find.text(d.title), findsWidgets);
      }
      // Current must not surface legacy semantic titles as domain headings.
      for (final h in bannedSemanticHeadings) {
        expect(current.lifeDomains.map((d) => d.title), isNot(contains(h)));
      }
    });
  });

  group('V1.3.3 regression gates', () {
    test('Past/Current/Future classification intact', () {
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      expect(state.periods.where((p) => p.isPast).length, greaterThan(0));
      expect(state.periods.where((p) => p.isCurrent).length, 1);
      expect(
        state.periods.where((p) => !p.isPast && !p.isCurrent).length,
        greaterThan(0),
      );
    });

    test('V1.3.2 language gates still hold', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      expect(view.signatureInsight.isEmpty, isTrue);
      expect(view.birthDataConfidence.title, isEmpty);
      final state = buildAt(weekday: DateTime.sunday, age: 39);
      for (final p in state.periods) {
        final blob = [
          p.summary,
          p.harder,
          p.advice,
          ...p.lifeDomains.map((d) => d.body),
        ].join('\n');
        expect(blob, isNot(contains('ในช่วงนั้น')));
        expect(blob, isNot(contains('รูปแบบความรัก')));
        expect(blob, isNot(contains('ตั้งขอบเขตใหม่')));
      }
    });
  });
}
