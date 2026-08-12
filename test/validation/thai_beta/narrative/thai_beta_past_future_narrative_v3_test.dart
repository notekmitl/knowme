import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_period_domain_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_future_prediction_section.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final analysis = ThaiBetaNarrativeFixtures.fixtureA();
  final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final timeline = view.lifeTimeline!;
  final prediction = view.futurePrediction!;

  group('Thai Beta Past-to-Future Narrative V3', () {
    test(
      'supported periods have domains and unsupported late ages fail closed',
      () {
        final periods = timeline.periods
            .where((period) => period.isPast || !period.isCurrent)
            .toList(growable: false);
        expect(periods.where((period) => period.isPast), isNotEmpty);
        expect(
          periods.where((period) => !period.isPast && !period.isCurrent),
          isNotEmpty,
        );

        for (final period in periods) {
          final startAge = int.parse(period.ageLabel.split('–').first);
          if (startAge >= 69) {
            expect(period.lifeDomains, isEmpty);
            continue;
          }
          expect(
            period.lifeDomains.map((domain) => domain.title),
            everyElement(isIn(LifePeriodDomainComposer.requiredTitles)),
            reason: '${period.timeBucketLabel} ${period.ageLabel}',
          );
          for (final domain in period.lifeDomains) {
            expect(domain.body.length, greaterThan(75));
            expect(domain.evidenceKeys, isNotEmpty);
            expect(domain.body, isNot(contains('คะแนน')));
            expect(domain.body, isNot(contains('evidence')));
          }
        }

        for (final title in LifePeriodDomainComposer.requiredTitles) {
          final bodies = periods
              .expand((period) => period.lifeDomains)
              .where((domain) => domain.title == title)
              .map((domain) => domain.body)
              .toList();
          expect(bodies, isNotEmpty, reason: title);
          expect(bodies.toSet().length, bodies.length, reason: title);
        }
      },
    );

    test('prediction covers all domains once across distinct horizons', () {
      expect(prediction.windows, isNotEmpty);
      final covered = <String>[];
      for (final window in prediction.windows) {
        expect(window.domains, isNotEmpty);
        covered.addAll(window.domains.map((domain) => domain.title));
        for (final domain in window.domains) {
          expect(domain.body, isNot(contains('จะถูกบังคับ')));
          expect(domain.body, isNot(contains('คนที่ใช่จะเข้ามา')));
          expect(domain.body, isNot(contains('รายได้จะเพิ่ม')));
          expect(domain.body.length, greaterThan(65));
          expect(domain.risk, isNotEmpty);
          expect(domain.decisionImpact, isNotEmpty);
          expect(domain.preparationAction, isNotEmpty);
        }
      }
      expect(covered.toSet(), {'การงาน', 'การเงิน', 'ความรัก', 'สุขภาพ'});
      expect(covered, hasLength(4));
    });

    test('future copy is deterministic for the same analysis', () {
      final second = ThaiBetaNarrativeComposer.narrativeView(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).futurePrediction!;

      expect(_domainDump(prediction), _domainDump(second));
    });
  });

  group('Thai Beta V3 opt-in UI', () {
    testWidgets('past detail and long-range future are open and grouped', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiMirrorLifeTimelineSection(
                state: timeline,
                lifeMapMode: true,
                detailedNarrativeMode: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('อดีตของคุณ'), findsOneWidget);
      expect(find.text('ช่วงปัจจุบัน'), findsOneWidget);
      expect(find.text('แนวโน้มระยะยาว'), findsOneWidget);

      final firstPast = timeline.periods.firstWhere((period) => period.isPast);
      expect(find.text(firstPast.lifeDomains.first.body), findsNothing);
      expect(find.text(firstPast.summary), findsWidgets);

      final future = timeline.periods.where(
        (period) => !period.isPast && !period.isCurrent,
      );
      for (final period in future) {
        if (period.lifeDomains.isNotEmpty) {
          expect(find.text(period.lifeDomains.first.body), findsNothing);
          expect(find.text(period.summary), findsWidgets);
        } else {
          expect(find.text(period.phaseName), findsWidgets);
        }
      }
    });

    testWidgets(
      'future section shows all four domains without opening detail',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThaiMirrorFuturePredictionSection(
                  state: prediction,
                  detailedNarrativeMode: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('คำทำนายแยกตามด้านชีวิต'),
          findsNWidgets(prediction.windows.length - 1),
        );
        for (final window in prediction.windows.skip(1)) {
          for (final domain in window.domains) {
            expect(find.text(domain.title), findsOneWidget);
          }
        }
        expect(find.text(prediction.detailedSectionIntro), findsOneWidget);
        expect(find.text(prediction.detailedClosingAdvice), findsOneWidget);
      },
    );

    testWidgets('standalone default keeps detailed beta copy hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiMirrorLifeTimelineSection(
                state: timeline,
                lifeMapMode: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('อดีตของคุณ'), findsNothing);
      final firstPast = timeline.periods.firstWhere((period) => period.isPast);
      expect(find.text(firstPast.lifeDomains.first.body), findsNothing);
    });
  });
}

String _domainDump(PredictionSectionModel state) {
  return state.windows
      .expand((window) => window.domains)
      .map((domain) => '${domain.title}|${domain.body}|${domain.caution}')
      .join('\n');
}
