import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v4_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_view_model.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_footer_reflection_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_future_possibility_section.dart';

void main() {
  testWidgets('FusionFooterReflectionSection builds with real ViewModel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FusionFooterReflectionSection(
            data: FusionFooterReflectionViewModel(
              title: 'closing-title',
              body: 'closing-body',
            ),
          ),
        ),
      ),
    );

    expect(find.text('closing-title'), findsOneWidget);
    expect(find.text('closing-body'), findsOneWidget);
  });

  testWidgets('FusionFuturePossibilitySection builds with real ViewModel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FusionFuturePossibilitySection(
              data: FusionFuturePossibilityViewModel(
                title: FusionResultV4Copy.futurePossibilityTitle,
                opportunityLabel: FusionResultV4Copy.opportunityLabel,
                opportunity: 'opportunity-body',
                challengeLabel: FusionResultV4Copy.challengeLabel,
                challenge: 'challenge-body',
                futureQuestionLabel: FusionResultV4Copy.futureQuestionLabel,
                futureReflection: 'question-body',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text(FusionResultV4Copy.futurePossibilityTitle), findsOneWidget);
    expect(find.text('opportunity-body'), findsOneWidget);
    expect(find.text('challenge-body'), findsOneWidget);
    expect(find.text('question-body'), findsOneWidget);
  });
}
