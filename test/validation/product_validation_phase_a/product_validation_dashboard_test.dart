import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/product_validation/product_validation_recorder.dart';
import 'package:knowme/features/product_validation/ui/product_validation_dashboard.dart';

/// Phase A — the internal dashboard renders the funnel + insights from a recorder.
void main() {
  testWidgets('dashboard shows empty state with no sessions', (tester) async {
    final recorder = ProductValidationRecorder();
    await tester.pumpWidget(MaterialApp(
      home: ProductValidationDashboard(recorder: recorder),
    ));

    expect(find.text('Product Validation · Internal'), findsOneWidget);
    expect(find.textContaining('No sessions recorded'), findsOneWidget);
  });

  testWidgets('dashboard renders funnel + insights after a session',
      (tester) async {
    final recorder = ProductValidationRecorder();
    recorder.sessionStarted();
    recorder.homeViewed();
    recorder.journeyStarted();
    recorder.insightViewed();
    recorder.predictionViewed();
    recorder.decisionViewed();
    recorder.askMoreViewed();
    recorder.conversationQuestionAsked('career_change');
    recorder.conversationAnswerViewed('career_change');
    recorder.reflectionViewed();

    await tester.pumpWidget(MaterialApp(
      home: ProductValidationDashboard(recorder: recorder),
    ));

    expect(find.text('Engagement funnel'), findsOneWidget);
    expect(find.text('Current Life (WOW)'), findsOneWidget);
    expect(find.textContaining('WOW reach rate'), findsWidgets);
  });
}
