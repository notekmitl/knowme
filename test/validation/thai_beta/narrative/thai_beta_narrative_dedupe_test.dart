import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_dedupe.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_formatting.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  String sectionText(Iterable<String> paragraphs) =>
      paragraphs.map(ThaiBetaNarrativeFormatting.normalizedKey).join('|');

  group('Dedupe', () {
    test('no duplicated normalized sentence in one section', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;

      for (final card in view.strengths.cards) {
        if (card.expandedBody == null) continue;
        final keys = card.expandedBody!
            .split(RegExp(r'\n\n+'))
            .map(ThaiBetaNarrativeFormatting.normalizedKey)
            .where((k) => k.length > 8)
            .toList();
        expect(keys.toSet().length, keys.length);
      }
    });

    test('no adjacent semantic duplicate in hero', () {
      final summary = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view.hero.summary;
      final parts = summary.split(RegExp(r'\n\n+'));
      for (var i = 1; i < parts.length; i++) {
        expect(
          ThaiBetaNarrativeFormatting.normalizedKey(parts[i - 1]),
          isNot(equals(ThaiBetaNarrativeFormatting.normalizedKey(parts[i]))),
        );
      }
    });

    test('no repeated behavior example across dashboard domains', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureC(),
      ).view;
      final actions = view.lifeDashboard
          .map((i) => ThaiBetaNarrativeFormatting.normalizedKey(i.suggestedAction))
          .where((k) => k.length > 10)
          .toList();
      expect(actions.toSet().length, actions.length);
    });

    test('no อย่างเช่น เมื่อต้องใช้ repeated template', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      final all = StringBuffer()
        ..write(view.hero.summary)
        ..write(view.strengths.cards.map((c) => c.expandedBody ?? '').join());
      expect(all.toString().contains('อย่างเช่น เมื่อต้องใช้'), isFalse);
    });

    test('repeated fixed disclaimer is allowed only where intended', () {
      const allowed = 'นี่ไม่ใช่คำฟันธง';
      final deduped = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: 'disclaimer',
        paragraphs: [allowed, 'unique line', allowed],
        globalUsed: {},
      );
      expect(deduped.where((p) => p.contains(allowed)).length, 2);
    });

    test('dedupeParagraphs removes exact duplicates in section', () {
      final out = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: 'test',
        paragraphs: ['คุณมุ่งมั่น', 'คุณมุ่งมั่น', 'อีกประโยค'],
        globalUsed: {},
      );
      expect(out.length, 2);
      expect(sectionText(out), isNot(contains('คุณมุ่งมั่น|คุณมุ่งมั่น')));
    });

    test('resolveUnique never reintroduces duplicate primary text', () {
      final used = <String>{};
      const duplicate = 'คุณมุ่งมั่นและไม่หยุด';
      expect(
        ThaiBetaNarrativeDedupe.resolveUnique(text: duplicate, used: used),
        duplicate,
      );
      expect(
        ThaiBetaNarrativeDedupe.resolveUnique(
          text: duplicate,
          used: used,
          fallbacks: ['เมื่อตั้งใจแล้ว คุณมักเดินหน้าต่อ'],
        ),
        'เมื่อตั้งใจแล้ว คุณมักเดินหน้าต่อ',
      );
      expect(
        ThaiBetaNarrativeDedupe.resolveUnique(text: duplicate, used: used),
        '',
      );
    });

    test('fixed template keys are tracked across sections', () {
      const template =
          'และนั่นคือสิ่งที่ทำให้คนรอบตัวรู้สึกว่ามีคุณอยู่แล้วอุ่นใจ';
      final used = <String>{};
      ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: 'a',
        paragraphs: ['$template ในบริบทแรก'],
        globalUsed: used,
      );
      final second = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: 'b',
        paragraphs: ['$template ในบริบทที่สอง'],
        globalUsed: used,
      );
      expect(second, isEmpty);
    });

    test('narrative section fields drop duplicates after section dedupe', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;

      for (final section in view.narrativeSections) {
        final keys = [
          section.overview,
          section.whyItAppears,
          section.advice,
          section.example,
        ]
            .where((text) => text.trim().isNotEmpty)
            .map(ThaiBetaNarrativeFormatting.normalizedKey)
            .where((key) => key.length > 8)
            .toList();
        expect(keys.toSet().length, keys.length,
            reason: '${section.label} has duplicate normalized fields');
      }
    });
  });
}
