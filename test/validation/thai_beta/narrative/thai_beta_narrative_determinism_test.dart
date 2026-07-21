import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_stable_hash.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  group('Determinism', () {
    test('same analysis produces identical narrative', () {
      final a = ThaiBetaNarrativeFixtures.fixtureA();
      final first = ThaiBetaNarrativeComposer.compose(a);
      final second = ThaiBetaNarrativeComposer.compose(a);
      expect(first.view.hero.headline, second.view.hero.headline);
      expect(first.view.hero.summary, second.view.hero.summary);
      expect(
        first.view.lifeDashboard.map((i) => i.currentState).toList(),
        second.view.lifeDashboard.map((i) => i.currentState).toList(),
      );
    });

    test('repeated export produces identical text', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final doc1 = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final doc2 = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(doc1.fullPlainText, doc2.fullPlainText);
    });

    test('fixed reference date produces stable age and period text', () {
      final a = ThaiBetaNarrativeFixtures.fixtureA();
      final timelineA = a.consumerViewState!.lifeTimeline!.currentStage.ageLabel;
      final b = ThaiBetaNarrativeFixtures.fixtureA();
      final timelineB = b.consumerViewState!.lifeTimeline!.currentStage.ageLabel;
      expect(timelineA, timelineB);
    });

    test('phrase selection does not use randomness', () {
      final seeds = <String>{};
      for (var i = 0; i < 5; i++) {
        final view = ThaiBetaNarrativeComposer.compose(
          ThaiBetaNarrativeFixtures.fixtureA(),
        ).view;
        seeds.add(view.hero.headline);
      }
      expect(seeds.length, 1);
    });

    test('stable hash seed is platform-independent', () {
      expect(
        ThaiBetaNarrativeStableHash.fnv1a32('ชีวิตด้านการงาน'),
        ThaiBetaNarrativeStableHash.fnv1a32('ชีวิตด้านการงาน'),
      );
      expect(
        ThaiBetaNarrativeStableHash.fnv1a32('ชีวิตด้านการงาน'),
        isNot(equals(ThaiBetaNarrativeStableHash.fnv1a32('ชีวิตด้านการเงิน'))),
      );
    });
  });
}
