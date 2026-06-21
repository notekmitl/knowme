import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/tests/big_five/application/big_five_result_content.dart';
import 'package:knowme/features/tests/big_five/application/big_five_scorer.dart';
import 'package:knowme/features/tests/big_five/data/modules/big_five_progressive_questions.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/presentation/big_five_result_page.dart';

void main() {
  setUp(() {
    AppText.lang = 'th';
  });

  BigFiveResultSummary _summaryFor(int questionCount) {
    final questions = BigFiveProgressiveQuestions.forTargetTotal(questionCount);
    final answers = {for (final q in questions) q.id: 4};
    return const BigFiveScorer().score(
      questions: questions,
      answers: answers,
    );
  }

  group('BigFiveResultContent', () {
    test('builds five trait cards without scores in copy', () {
      final content = BigFiveResultContent.build(_summaryFor(10));

      expect(content.traitCards.length, 5);
      expect(content.heroParagraphs, isNotEmpty);
      expect(content.disclosure, contains('10'));
      for (final card in content.traitCards) {
        expect(card.productName, isNotEmpty);
        expect(card.bandLabel, isNotEmpty);
        expect(card.reflection, isNotEmpty);
        expect(card.reflection, isNot(contains('percentile')));
      }
    });

    test('uses neuroticism product name without clinical label', () {
      final content = BigFiveResultContent.build(_summaryFor(10));
      final stressCard = content.traitCards
          .firstWhere((card) => card.traitId == 'neuroticism');

      expect(stressCard.productName, AppText.t('big_five_trait_neuroticism_name'));
      expect(stressCard.productName.toLowerCase(), isNot(contains('neuroticism')));
    });
  });

  group('BigFiveResultPage', () {
    testWidgets('renders hero, traits, timeline, and disclosure', (
      tester,
    ) async {
      final summary = _summaryFor(44);

      await tester.pumpWidget(
        MaterialApp(
          home: BigFiveResultPage(summary: summary),
        ),
      );

      expect(find.text(AppText.t('big_five_result_title')), findsOneWidget);
      expect(find.text(AppText.t('big_five_result_traits_title')), findsOneWidget);
      expect(find.text(AppText.t('big_five_depth_title')), findsOneWidget);
      expect(find.textContaining('44'), findsWidgets);
      expect(find.textContaining('High'), findsNothing);
      expect(find.textContaining('Low'), findsNothing);
    });

    testWidgets('shows deep pattern section at 80 questions', (tester) async {
      final summary = _summaryFor(80);

      await tester.pumpWidget(
        MaterialApp(
          home: BigFiveResultPage(summary: summary),
        ),
      );

      expect(
        find.text(AppText.t('big_five_pattern_title_deep')),
        findsOneWidget,
      );
      expect(summary.depthTier, BigFiveDepthTier.deep);
    });
  });
}
