import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_block_selector.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_block.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_blocks.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_domain.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_forbidden.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_formatting.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  group('Curated block selection V1.1', () {
    test('exact trait pair + domain selected before fallback', () {
      final exact = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.hero,
          primaryThemeId: 'resilient',
          secondaryThemeId: 'analytical',
          hasBirthTime: true,
          seed: 1,
        ),
      );
      expect(exact.matchLevel, lessThan(5));
      expect(exact.block.id, 'hero_resilient_analytical_v1');

      final fallback = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.dashboard,
          primaryThemeId: 'nonexistent_theme',
          domain: ThaiBetaLifeDomain.money,
          hasBirthTime: true,
          seed: 1,
        ),
      );
      expect(fallback.matchLevel, greaterThanOrEqualTo(3));
      expect(fallback.block.domain, ThaiBetaLifeDomain.money);
    });

    test('unsupported pair uses safe curated fallback', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.dashboard,
          primaryThemeId: 'nonexistent_theme',
          domain: ThaiBetaLifeDomain.money,
          hasBirthTime: true,
          seed: 2,
        ),
      );
      expect(selection.matchLevel, greaterThanOrEqualTo(3));
      expect(selection.block.domain, ThaiBetaLifeDomain.money);
    });

    test('same input selects same block', () {
      const query = CuratedBlockQuery(
        section: CuratedNarrativeSection.strength,
        primaryThemeId: 'resilient',
        hasBirthTime: true,
        seed: 42,
      );
      final a = ThaiBetaCuratedBlockSelector.select(query);
      final b = ThaiBetaCuratedBlockSelector.select(query);
      expect(a.block.id, b.block.id);
    });

    test('block requiring birth time rejected when time missing', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.hero,
          primaryThemeId: 'disciplined',
          hasBirthTime: false,
          seed: 3,
        ),
      );
      expect(selection.block.requiresBirthTime, isFalse);
      expect(selection.block.safeWithoutBirthTime, isTrue);
      expect(selection.block.id, 'hero_no_time_cautious_v1');
    });

    test('inner-drive hero blocks default unsafe without birth time', () {
      for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
        if (block.section != CuratedNarrativeSection.hero) continue;
        if (block.id == 'hero_no_time_cautious_v1') continue;
        final hasInnerDrive = block.heroSentences.any(
          (s) => s.contains('เบื้องหลัง') || s.contains('ในที่ประชุม'),
        );
        if (hasInnerDrive) {
          expect(block.safeWithoutBirthTime, isFalse, reason: block.id);
        }
      }
    });

    test('unsupported hero query uses hero-section fallback', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.hero,
          primaryThemeId: 'nonexistent_theme',
          hasBirthTime: true,
          seed: 99,
        ),
      );
      expect(selection.block.section, CuratedNarrativeSection.hero);
      expect(selection.block.heroSentences, isNotEmpty);
    });

    test('unsupported strength query uses strength-section fallback', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.strength,
          primaryThemeId: 'nonexistent_theme',
          hasBirthTime: true,
          seed: 99,
        ),
      );
      expect(selection.block.section, CuratedNarrativeSection.strength);
      expect(selection.block.observableBehavior, isNotNull);
    });

    test('unsupported advice query uses advice-section fallback', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.advice,
          primaryThemeId: 'nonexistent_theme',
          domain: ThaiBetaLifeDomain.love,
          hasBirthTime: true,
          seed: 99,
        ),
      );
      expect(selection.block.section, CuratedNarrativeSection.advice);
      expect(selection.block.adviceText, isNotNull);
    });

    test('unsupported domain query uses domain-section fallback', () {
      final selection = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.domain,
          primaryThemeId: 'nonexistent_theme',
          domain: ThaiBetaLifeDomain.health,
          hasBirthTime: true,
          seed: 99,
        ),
      );
      expect(selection.block.section, CuratedNarrativeSection.domain);
      expect(selection.block.domainOverview, isNotNull);
    });
  });

  group('Thai grammar V1.1', () {
    String allText(ThaiBetaAnalysis Function() loadFixture) {
      final view = ThaiBetaNarrativeComposer.compose(loadFixture()).view;
      final buf = StringBuffer()
        ..write(view.hero.summary)
        ..write(view.advice.body);
      for (final card in view.strengths.cards) {
        buf.write(card.body);
        buf.write(card.expandedBody ?? '');
      }
      for (final item in view.lifeDashboard) {
        buf.write(item.suggestedAction);
        buf.write(item.whyItAppears);
      }
      return buf.toString();
    }

    test('no forbidden runtime patterns in composed output', () {
      for (final fixture in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureB,
        ThaiBetaNarrativeFixtures.fixtureC,
      ]) {
        final text = allText(fixture);
        expect(
          ThaiBetaNarrativeForbidden.findForbidden(text),
          isEmpty,
          reason: 'fixture output must not contain forbidden patterns',
        );
      }
    });

    test('advice begins with valid curated action phrase', () {
      for (final fixture in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureB,
      ]) {
        final view = ThaiBetaNarrativeComposer.compose(fixture()).view;
        for (final item in view.lifeDashboard) {
          if (item.suggestedAction.trim().isEmpty) continue;
          expect(
            ThaiBetaNarrativeForbidden.isValidAdvicePhrase(item.suggestedAction),
            isTrue,
            reason: item.suggestedAction,
          );
        }
        if (view.advice.body.trim().isNotEmpty) {
          expect(
            ThaiBetaNarrativeForbidden.isValidAdvicePhrase(view.advice.body),
            isTrue,
          );
        }
      }
    });
  });

  group('Strength dedupe V1.1', () {
    test('strength expanded has three distinct parts when present', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      for (final card in view.strengths.cards) {
        if (card.expandedBody == null) continue;
        final parts = card.expandedBody!.split(RegExp(r'\n\n+'));
        expect(parts.length, greaterThanOrEqualTo(1));
        final keys = parts
            .map(ThaiBetaNarrativeFormatting.normalizedKey)
            .where((k) => k.length > 8)
            .toList();
        expect(keys.toSet().length, keys.length);
      }
    });

    test('strength cards do not repeat expanded body across section', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view;
      final expandedKeys = <String>{};
      for (final card in view.strengths.cards) {
        if (card.expandedBody == null) continue;
        final key = ThaiBetaNarrativeFormatting.normalizedKey(card.expandedBody!);
        expect(expandedKeys.contains(key), isFalse, reason: card.title);
        expandedKeys.add(key);
      }
    });

    test('title does not duplicate first expanded sentence', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      for (final card in view.strengths.cards) {
        if (card.expandedBody == null) continue;
        final first = card.expandedBody!.split(RegExp(r'\n\n+')).first;
        expect(
          ThaiBetaNarrativeFormatting.normalizedKey(card.title),
          isNot(equals(ThaiBetaNarrativeFormatting.normalizedKey(first))),
        );
      }
    });
  });

  group('Hero V1.1', () {
    test('hero headline does not duplicate first summary sentence', () {
      for (final fixture in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureB,
      ]) {
        final hero = ThaiBetaNarrativeComposer.compose(fixture()).view.hero;
        final firstSummary = hero.summary.split(RegExp(r'\n\n+')).first.trim();
        expect(
          ThaiBetaNarrativeFormatting.normalizedKey(hero.headline),
          isNot(equals(ThaiBetaNarrativeFormatting.normalizedKey(firstSummary))),
        );
      }
    });

    test('hero has 3-5 sentences', () {
      final summary = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view.hero.summary;
      final parts = summary.split(RegExp(r'\n\n+')).where((p) => p.trim().isNotEmpty);
      expect(parts.length, inInclusiveRange(3, 6));
    });

    test('hero uses at most 3 trait tags', () {
      final hero = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view.hero;
      expect(hero.tags.length, lessThanOrEqualTo(3));
    });

    test('no-time hero uses cautious language', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      );
      final hero = result.view.hero;
      expect(
        result.trace.entries.firstWhere((e) => e.sectionId == 'hero').blockId,
        'hero_no_time_cautious_v1',
      );
      expect(hero.headline, contains('ภาพรวมจากวันเกิด'));
      expect(hero.summary, contains('ไม่มีเวลาเกิด'));
      expect(
        ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(hero.summary),
        isEmpty,
      );
    });

    test('hero tension requires distinct supported traits', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureC(),
      );
      final heroTrace = result.trace.entries.where((e) => e.sectionId == 'hero');
      expect(heroTrace, isNotEmpty);
      expect(heroTrace.first.blockId, isNotNull);
    });
  });

  group('Domain correctness V1.1', () {
    test('all domains convert signals to domain behavior', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      for (final domain in ThaiBetaLifeDomain.values) {
        final item = view.lifeDashboard.firstWhere(
          (i) => i.label == domain.labelTh ||
              (domain == ThaiBetaLifeDomain.luck && i.label == 'โชคและโอกาส'),
        );
        expect(
          ThaiBetaDomainSemanticTags.isTextDomainCompatible(
            '${item.currentState} ${item.whyItAppears}',
            domain,
          ),
          isTrue,
          reason: domain.labelTh,
        );
      }
    });
  });

  group('No-birth-time safety V1.1', () {
    test('report and export share no-time policy', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureB();
      final screen = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(screen.hero.summary, contains('ไม่มีเวลาเกิด'));
      expect(export.fullPlainText, contains('ไม่มีเวลาเกิด'));
      expect(
        ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(
          export.fullPlainText,
        ),
        isEmpty,
      );
    });
  });

  group('Traceability V1.1', () {
    test('curated blocks trace block id and signals', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final withBlock = result.trace.entries.where((e) => e.blockId != null);
      expect(withBlock, isNotEmpty);
      for (final entry in withBlock) {
        expect(entry.primaryTrait, isNotEmpty);
        expect(entry.sourceSignalIds, isNotEmpty);
      }
    });

    test('every curated section includes block trace metadata', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final entries = result.trace.entries;

      expect(
        entries.any((e) => e.sectionId == 'hero' && e.blockId != null),
        isTrue,
      );
      expect(
        entries.any((e) => e.sectionId.startsWith('strength_') && e.blockId != null),
        isTrue,
      );
      expect(
        entries.any((e) => e.sectionId == 'advice' && e.blockId != null),
        isTrue,
      );
      expect(
        entries.where((e) => e.sectionId.startsWith('dashboard_') && e.blockId != null).length,
        greaterThanOrEqualTo(5),
      );
      expect(
        entries.where((e) => e.sectionId.startsWith('narrative_') && e.blockId != null).length,
        greaterThanOrEqualTo(5),
      );

      for (final entry in entries.where((e) => e.blockId != null)) {
        expect(entry.minimumConfidence, isNotNull);
        expect(entry.requiresBirthTime, isNotNull);
      }
    });

    test('public output has no internal block ids', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
        expect(doc.fullPlainText.contains(block.id), isFalse);
      }
    });
  });

  group('Determinism V1.1', () {
    test('stable tie-break by block id', () {
      const query = CuratedBlockQuery(
        section: CuratedNarrativeSection.advice,
        primaryThemeId: 'curious',
        domain: ThaiBetaLifeDomain.work,
        hasBirthTime: true,
        seed: 0,
      );
      final ids = List.generate(
        3,
        (_) => ThaiBetaCuratedBlockSelector.select(query).block.id,
      );
      expect(ids.toSet().length, 1);
    });
  });
}
