import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

ThaiPresentedTheme _theme({
  required String themeId,
  required ThemeCategory category,
  double score = 0.8,
}) {
  final definition = ThemeRegistry.getById(themeId)!;
  return ThaiPresentedTheme(
    themeId: themeId,
    themeName: definition.name,
    category: category.displayName,
    description: definition.description,
    score: score,
    confidence: ThaiThemeConfidenceLevel.high,
    evidence: const [],
  );
}

List<String> _allVisibleStrings(consumer) {
  return [
    consumer.hero.headline,
    consumer.hero.summary,
    ...consumer.hero.tags,
    consumer.strengths.title,
    ...consumer.strengths.cards.expand((c) => [c.title, c.body]),
    consumer.cautions.title,
    ...consumer.cautions.cards.expand((c) => [c.title, c.body]),
    consumer.advice.title,
    consumer.advice.body,
    ...consumer.lifeDashboard.expand(
      (item) => [
        item.label,
        item.currentState,
        item.whyItAppears,
        item.suggestedAction,
      ],
    ),
    consumer.sourceTransparency.dataUsed,
    consumer.sourceTransparency.calculation,
    consumer.sourceTransparency.meaning,
    consumer.secretTip,
    ...consumer.disclaimers,
    ThaiMirrorConsumerCopy.footerDisclaimer,
  ];
}

void main() {
  group('ThaiMirrorConsumerPresenter', () {
    test('maps mirror result to person-first consumer copy', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _theme(themeId: 'disciplined', category: ThemeCategory.coreSelf),
            _theme(themeId: 'analytical', category: ThemeCategory.thinkingStyle),
            _theme(themeId: 'builder', category: ThemeCategory.workAndAmbition),
            _theme(themeId: 'reliability', category: ThemeCategory.strengths),
            _theme(
              themeId: 'overthinking',
              category: ThemeCategory.growthAreas,
            ),
            _theme(
              themeId: 'develop_patience',
              category: ThemeCategory.growthPath,
            ),
          ],
        ),
      );

      final consumer = ThaiMirrorConsumerPresenter.present(result);

      expect(consumer.hero.headline, isNotEmpty);
      expect(consumer.strengths.cards.length, greaterThanOrEqualTo(1));
      expect(consumer.hero.summary, isNot(contains('หลายครั้ง')));
      expect(consumer.disclaimers, ThaiMirrorConsumerCopy.consumerDisclaimers);
      expect(consumer.strengths.title, ThaiMirrorConsumerCopy.strengthsSectionTitle);
      expect(consumer.cautions.title, ThaiMirrorConsumerCopy.cautionsSectionTitle);
      expect(consumer.cautions.cards.length, 3);
      expect(consumer.lifeDashboard, hasLength(5));

      for (final text in _allVisibleStrings(consumer)) {
        expect(
          ThaiMirrorConsumerCopy.containsBannedCopy(text),
          isFalse,
          reason: 'Banned copy in: $text',
        );
      }
    });

    test('empty mirror result maps without exception', () {
      final result = ThaiMirrorAssembler.assemble(
        const ThaiMirrorInput(
          profile: ThaiAstrologyProfile(),
          presentedThemes: [],
        ),
      );

      final consumer = ThaiMirrorConsumerPresenter.present(result);

      expect(consumer.hero.headline, isNotEmpty);
      expect(consumer.strengths.cards, isEmpty);
      expect(consumer.cautions.cards, isEmpty);
      expect(consumer.lifeDashboard, hasLength(5));

      for (final text in _allVisibleStrings(consumer)) {
        expect(
          RegExp(r'[A-Za-z]{3,}').hasMatch(text),
          isFalse,
          reason: 'English in: $text',
        );
      }
    });

    test('profiles without strengths section derive theme-based cards', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _theme(themeId: 'reflective', category: ThemeCategory.thinkingStyle),
            _theme(themeId: 'visionary', category: ThemeCategory.coreSelf),
            _theme(themeId: 'big_picture', category: ThemeCategory.thinkingStyle),
            _theme(themeId: 'curious', category: ThemeCategory.coreSelf),
            _theme(themeId: 'avoidance', category: ThemeCategory.growthAreas),
            _theme(
              themeId: 'open_to_collaboration',
              category: ThemeCategory.growthPath,
            ),
          ],
        ),
      );

      final consumer = ThaiMirrorConsumerPresenter.present(result);

      expect(consumer.strengths.cards, hasLength(3));
      expect(
        consumer.strengths.cards.map((c) => c.title).toSet().length,
        3,
        reason: 'Strength titles should be unique',
      );
      expect(
        consumer.strengths.cards.any((c) => c.title == 'ไม่ยอมแพ้ง่าย ๆ'),
        isFalse,
        reason: 'Should not use generic fallback strengths',
      );
    });
  });

  group('ThaiMirrorConsumerCopy', () {
    test('buildHeadline uses natural Thai not internal labels', () {
      final headline = ThaiMirrorConsumerCopy.buildHeadline([
        'analytical',
        'expressive',
        'loyal',
      ]);

      expect(headline, isNotEmpty);
      expect(headline, isNot(contains('Analytical')));
      expect(headline, isNot(contains('Reflective')));
    });
  });

  group('ThaiMirrorConsumerPage golden', () {
    testWidgets('consumer result page screenshot', (tester) async {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _theme(themeId: 'disciplined', category: ThemeCategory.coreSelf),
            _theme(themeId: 'analytical', category: ThemeCategory.thinkingStyle),
            _theme(themeId: 'loyal', category: ThemeCategory.relationships),
            _theme(themeId: 'builder', category: ThemeCategory.workAndAmbition),
            _theme(themeId: 'reliability', category: ThemeCategory.strengths),
            _theme(
              themeId: 'overthinking',
              category: ThemeCategory.growthAreas,
            ),
            _theme(
              themeId: 'develop_patience',
              category: ThemeCategory.growthPath,
            ),
          ],
        ),
      );

      final consumer = ThaiMirrorConsumerPresenter.present(result);

      await tester.binding.setSurfaceSize(const Size(390, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
            useMaterial3: true,
          ),
          home: ThaiMirrorResultPage(consumerState: consumer),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ThaiMirrorResultPage),
        matchesGoldenFile('goldens/thai_mirror_consumer_page.png'),
      );
    });
  });
}
