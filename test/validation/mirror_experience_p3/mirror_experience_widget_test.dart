import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/mirror_experience/mirror_copy.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_input.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_runtime.dart';
import 'package:knowme/features/mirror_experience/ui/mirror_home.dart';
import 'package:knowme/features/mirror_experience/ui/mirror_journey.dart';

/// P3 — widget smoke tests: the experience renders and walks the full flow
/// (Current Life → Prediction → Decision → Ask More → Conversation → Reflection)
/// driven only by the Fusion Runtime.
void main() {
  final input = MirrorExperienceInput(
    birthDate: DateTime(1989, 4, 15),
    asOf: DateTime(2026, 6, 28),
  );

  Widget host(Widget child) => MaterialApp(home: child);

  testWidgets('MirrorHome shows the entry surface and CTA', (tester) async {
    await tester.pumpWidget(host(
      MirrorHome(input: input, runtime: MirrorExperienceRuntime.fusion),
    ));

    expect(find.text(MirrorCopy.homeTitle), findsOneWidget);
    expect(find.text(MirrorCopy.homeCta), findsOneWidget);
  });

  testWidgets('MirrorJourney walks every stage', (tester) async {
    await tester.pumpWidget(host(
      MirrorJourney(input: input, runtime: MirrorExperienceRuntime.fusion),
    ));
    await tester.pumpAndSettle();

    // Stage 1 — Current Life.
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text(MirrorCopy.currentLifeHeadline), findsOneWidget);

    // Stage 2 — Prediction.
    await tester.tap(find.text(MirrorCopy.continueCta));
    await tester.pumpAndSettle();
    expect(find.text(MirrorCopy.predictionHeadline), findsOneWidget);

    // Stage 3 — Decision.
    await tester.tap(find.text(MirrorCopy.continueCta));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 5'), findsOneWidget);

    // Stage 4 — Ask More / Conversation (starts from cards).
    await tester.tap(find.text(MirrorCopy.continueCta));
    await tester.pumpAndSettle();
    expect(find.text(MirrorCopy.askMoreTitle), findsOneWidget);

    // Open a topic, then ask a predefined question -> a fused answer renders.
    await tester.tap(find.text('Life right now'));
    await tester.pumpAndSettle();
    final question = find.text('Where does my life stand right now?');
    expect(question, findsOneWidget);
    await tester.ensureVisible(question);
    await tester.tap(question);
    await tester.pumpAndSettle();
    expect(find.textContaining('Read is'), findsWidgets);

    // Stage 5 — Reflection.
    await tester.tap(find.text(MirrorCopy.continueCta));
    await tester.pumpAndSettle();
    expect(find.text(MirrorCopy.reflectionHeadline), findsOneWidget);
    expect(find.text(MirrorCopy.startOverCta), findsOneWidget);
  });
}
