import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_domain.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  final domains = ThaiBetaLifeDomain.values;

  group('Semantic correctness', () {
    test('work narrative uses work-compatible signals', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final work = view.lifeDashboard.firstWhere((i) => i.label == 'การงาน');
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          '${work.currentState} ${work.whyItAppears}',
          ThaiBetaLifeDomain.work,
        ),
        isTrue,
      );
    });

    test('finance narrative uses finance-compatible signals', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final money = view.lifeDashboard.firstWhere((i) => i.label == 'การเงิน');
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          '${money.currentState} ${money.whyItAppears}',
          ThaiBetaLifeDomain.money,
        ),
        isTrue,
      );
    });

    test('relationship narrative uses relationship-compatible signals', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final love = view.lifeDashboard.firstWhere((i) => i.label == 'ความรัก');
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          '${love.currentState} ${love.whyItAppears}',
          ThaiBetaLifeDomain.love,
        ),
        isTrue,
      );
    });

    test('health narrative uses health-compatible signals', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final health = view.lifeDashboard.firstWhere((i) => i.label == 'สุขภาพ');
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          '${health.currentState} ${health.whyItAppears}',
          ThaiBetaLifeDomain.health,
        ),
        isTrue,
      );
    });

    test('opportunity narrative uses opportunity-compatible signals', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final luck =
          view.lifeDashboard.firstWhere((i) => i.label == 'โชคและโอกาส');
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          '${luck.currentState} ${luck.whyItAppears}',
          ThaiBetaLifeDomain.luck,
        ),
        isTrue,
      );
    });

    test('known wrong-domain mappings are rejected', () {
      const teachingHealth = 'คุณชอบสอนและอธิบายให้คนอื่นเข้าใจ';
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          teachingHealth,
          ThaiBetaLifeDomain.health,
        ),
        isFalse,
      );
    });

    test('domain label prefix alone does not satisfy compatibility', () {
      const genericTeaching = 'คุณชอบสอนและอธิบายให้คนอื่นเข้าใจ';
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          'ด้านการเงิน — $genericTeaching',
          ThaiBetaLifeDomain.money,
        ),
        isFalse,
      );
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          'ด้านพลังใจ — $genericTeaching',
          ThaiBetaLifeDomain.health,
        ),
        isFalse,
      );
    });

    test('all dashboard domains are semantically tagged', () {
      for (final entry in <MapEntry<String, ThaiBetaAnalysis Function()>>[
        MapEntry('A', ThaiBetaNarrativeFixtures.fixtureA),
        MapEntry('C', ThaiBetaNarrativeFixtures.fixtureC),
      ]) {
        final view = ThaiBetaNarrativeComposer.compose(entry.value()).view;
        for (final domain in domains) {
          final item = view.lifeDashboard.firstWhere(
            (i) => i.label == domain.labelTh ||
                (domain == ThaiBetaLifeDomain.luck &&
                    i.label == 'โชคและโอกาส'),
          );
          expect(
            ThaiBetaDomainSemanticTags.isTextDomainCompatible(
              '${item.currentState} ${item.whyItAppears}',
              domain,
            ),
            isTrue,
            reason: '${domain.labelTh} for fixture ${entry.key}',
          );
        }
      }
    });

    test('dashboard suggested actions stay domain-compatible', () {
      for (final fixture in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureC,
      ]) {
        final view = ThaiBetaNarrativeComposer.compose(fixture()).view;
        for (final domain in domains) {
          final item = view.lifeDashboard.firstWhere(
            (i) => i.label == domain.labelTh ||
                (domain == ThaiBetaLifeDomain.luck &&
                    i.label == 'โชคและโอกาส'),
          );
          expect(
            ThaiBetaDomainSemanticTags.isTextDomainCompatible(
              item.suggestedAction,
              domain,
            ),
            isTrue,
            reason: '${domain.labelTh} action',
          );
        }
      }
    });

    test('incompatible advice fallback never bypasses domain filter', () {
      const teaching = 'คุณชอบสอนและอธิบายให้คนอื่นเข้าใจ';
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          teaching,
          ThaiBetaLifeDomain.health,
        ),
        isFalse,
      );
      final fallback = ThaiBetaDomainSemanticTags.domainAdviceFallback(
        ThaiBetaLifeDomain.health,
        'curious',
      );
      expect(
        ThaiBetaDomainSemanticTags.isTextDomainCompatible(
          fallback,
          ThaiBetaLifeDomain.health,
        ),
        isTrue,
      );
    });
  });
}
