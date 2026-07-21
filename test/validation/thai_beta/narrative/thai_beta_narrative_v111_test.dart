import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_block_integrity.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_block_selector.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_block.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_blocks.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_confidence.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_domain.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  group('Block Integrity V1.1.1', () {
    test('curated catalog passes integrity validation', () {
      final report = ThaiBetaCuratedBlockIntegrity.validate();
      expect(
        report.violations,
        isEmpty,
        reason: report.violations.join('\n'),
      );
    });

    test('every section has required fields for its type', () {
      for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
        switch (block.section) {
          case CuratedNarrativeSection.hero:
            expect(block.heroSentences.length, greaterThanOrEqualTo(3),
                reason: block.id);
          case CuratedNarrativeSection.strength:
            expect(block.observableBehavior, isNotNull, reason: block.id);
            expect(block.strengthText, isNotNull, reason: block.id);
          case CuratedNarrativeSection.domain:
            expect(block.domain, isNotNull, reason: block.id);
            expect(block.domainOverview, isNotNull, reason: block.id);
          case CuratedNarrativeSection.dashboard:
            expect(block.domain, isNotNull, reason: block.id);
            expect(block.dashboardCurrent, isNotNull, reason: block.id);
          case CuratedNarrativeSection.advice:
            expect(block.adviceText, isNotNull, reason: block.id);
        }
      }
    });

    test('requiresBirthTime implies not safeWithoutBirthTime', () {
      for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
        if (block.requiresBirthTime) {
          expect(block.safeWithoutBirthTime, isFalse, reason: block.id);
        }
      }
    });
  });

  group('Confidence Consistency V1.1.1', () {
    test('forBirthTime maps true→1.0 and false→0.5', () {
      expect(ThaiBetaNarrativeConfidence.forBirthTime(true), 1.0);
      expect(ThaiBetaNarrativeConfidence.forBirthTime(false), 0.5);
    });

    test('unsafe blocks require withBirthTime effective minimum', () {
      for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
        if (block.requiresBirthTime || !block.safeWithoutBirthTime) {
          final effective = ThaiBetaNarrativeConfidence.effectiveMinimum(
            declaredMinimum: block.minimumConfidence,
            requiresBirthTime: block.requiresBirthTime,
            safeWithoutBirthTime: block.safeWithoutBirthTime,
          );
          expect(
            effective,
            greaterThanOrEqualTo(ThaiBetaNarrativeConfidence.withBirthTime),
            reason: block.id,
          );
        }
      }
    });

    test('no-time query never selects unsafe block', () {
      for (final section in CuratedNarrativeSection.values) {
        for (final domain in ThaiBetaLifeDomain.values) {
          final selection = ThaiBetaCuratedBlockSelector.select(
            CuratedBlockQuery(
              section: section,
              primaryThemeId: 'nonexistent_theme_xyz',
              domain: section == CuratedNarrativeSection.hero ||
                      section == CuratedNarrativeSection.strength
                  ? null
                  : domain,
              hasBirthTime: false,
              confidence: ThaiBetaNarrativeConfidence.withoutBirthTime,
              seed: section.index * 10 + domain.index,
            ),
          );
          expect(selection.block.requiresBirthTime, isFalse,
              reason: '${section.name}/${domain.name}');
          expect(selection.block.safeWithoutBirthTime, isTrue,
              reason: '${section.name}/${domain.name} → ${selection.block.id}');
          final effective = ThaiBetaNarrativeConfidence.effectiveMinimum(
            declaredMinimum: selection.block.minimumConfidence,
            requiresBirthTime: selection.block.requiresBirthTime,
            safeWithoutBirthTime: selection.block.safeWithoutBirthTime,
          );
          expect(
            ThaiBetaNarrativeConfidence.withoutBirthTime,
            greaterThanOrEqualTo(effective),
            reason: selection.block.id,
          );
        }
      }
    });

    test('low confidence rejects high-minimum unsafe block', () {
      final unsafe = ThaiBetaCuratedNarrativeBlocks.all.firstWhere(
        (b) =>
            !b.safeWithoutBirthTime &&
            b.section == CuratedNarrativeSection.hero,
      );
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.hero,
          primaryThemeId: unsafe.primaryTraitIds.isNotEmpty
              ? unsafe.primaryTraitIds.first
              : 'nonexistent',
          secondaryThemeId: unsafe.secondaryTraitIds.isNotEmpty
              ? unsafe.secondaryTraitIds.first
              : null,
          hasBirthTime: false,
          confidence: ThaiBetaNarrativeConfidence.withoutBirthTime,
          seed: 1,
        ),
      );
      expect(selection.block.id, isNot(unsafe.id));
      expect(selection.block.safeWithoutBirthTime, isTrue);
    });

    test('composed no-time report traces effective confidence ≤ 0.5', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      );
      final withBlocks = result.trace.entries.where((e) => e.blockId != null);
      expect(withBlocks, isNotEmpty);
      for (final entry in withBlocks) {
        expect(entry.minimumConfidence, isNotNull);
        expect(
          entry.minimumConfidence!,
          lessThanOrEqualTo(ThaiBetaNarrativeConfidence.withoutBirthTime),
          reason: '${entry.sectionId}/${entry.blockId}',
        );
        expect(entry.requiresBirthTime, isFalse);
      }
    });

    test('composed with-time report can use full-confidence blocks', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final withBlocks = result.trace.entries.where((e) => e.blockId != null);
      expect(
        withBlocks.any(
          (e) =>
              e.minimumConfidence != null &&
              e.minimumConfidence! >=
                  ThaiBetaNarrativeConfidence.withBirthTime,
        ),
        isTrue,
      );
    });

    test('domainAdviceFallback respects hasBirthTime confidence', () {
      final noTime = ThaiBetaDomainSemanticTags.domainAdviceFallback(
        ThaiBetaLifeDomain.health,
        'curious',
        hasBirthTime: false,
      );
      expect(noTime.trim(), isNotEmpty);

      final withTime = ThaiBetaDomainSemanticTags.domainAdviceFallback(
        ThaiBetaLifeDomain.health,
        'curious',
        hasBirthTime: true,
      );
      expect(withTime.trim(), isNotEmpty);
    });
  });
}
