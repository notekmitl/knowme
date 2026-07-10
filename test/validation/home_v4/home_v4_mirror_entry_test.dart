import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/presentation/home_hero_section.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/mirror_experience/mirror_copy.dart';
import 'package:knowme/features/mirror_experience/ui/daily_mirror_section.dart';
import 'package:knowme/features/mirror_experience/ui/mirror_conversation_entry.dart';
import 'package:knowme/features/product_validation/product_validation.dart';
import 'package:knowme/features/product_validation/product_validation_events.dart';

void main() {
  HomeScreenV3Callbacks noopCallbacks() => HomeScreenV3Callbacks(
        onViewAstrologyResult: () {},
        onViewFullInsight: () {},
        onEditProfile: () {},
        onPsychologyTest: (_) {},
        onUnlockDeepProfile: () {},
        onContinueDiscovering: () {},
        onOpenAstrologyCenter: () {},
      );

  Widget wrap({DateTime? birthDate}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HomeScreenV3(
            data: HomeScreenV3Data.empty(),
            callbacks: noopCallbacks(),
            mirrorBirthDate: birthDate,
          ),
        ),
      ),
    );
  }

  testWidgets('without a birth date Home keeps the legacy hero', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byType(HomeHeroSection), findsOneWidget);
    expect(find.byType(DailyMirrorSection), findsNothing);
  });

  testWidgets('with a birth date the Daily Mirror is the emotional entry',
      (tester) async {
    ProductValidation.recorder.reset();
    await tester.pumpWidget(wrap(birthDate: DateTime(1990, 5, 20)));
    await tester.pump();

    expect(find.byType(DailyMirrorSection), findsOneWidget);
    expect(find.byType(HomeHeroSection), findsNothing);
    expect(find.text(MirrorCopy.dailyTitle), findsOneWidget);

    // Telemetry: entering Home opens a session and the Daily Mirror.
    final events = ProductValidation.recorder.currentEvents
        .map((e) => e.type)
        .toList();
    expect(events, contains(ProductEventType.sessionStarted));
    expect(events, contains(ProductEventType.dailyMirrorOpened));
    expect(events, contains(ProductEventType.insightViewed));
  });

  testWidgets('the conversation entry opens an inline conversation',
      (tester) async {
    ProductValidation.recorder.reset();
    await tester.pumpWidget(wrap(birthDate: DateTime(1990, 5, 20)));
    await tester.pump();

    expect(find.byType(MirrorConversationEntry), findsNothing);

    final entry = find.text(MirrorCopy.dailyConversationTitle);
    await tester.ensureVisible(entry);
    await tester.pump();
    await tester.tap(entry);
    await tester.pump();

    expect(find.byType(MirrorConversationEntry), findsOneWidget);
    final events = ProductValidation.recorder.currentEvents
        .map((e) => e.type)
        .toList();
    expect(events, contains(ProductEventType.dailyConversationStarted));
    expect(events, contains(ProductEventType.askMoreViewed));
  });
}
