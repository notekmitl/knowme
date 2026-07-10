import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/mirror_experience/mirror_experience_input.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_runtime.dart';
import 'package:knowme/features/mirror_experience/mirror_view_models.dart';
import 'package:knowme/features/mirror_experience/ui/daily_mirror_section.dart';
import 'package:knowme/features/mirror_habit/application/mirror_habit_store.dart';
import 'package:knowme/features/mirror_habit/domain/mirror_day_record.dart';
import 'package:knowme/features/mirror_habit/ui/mirror_habit_copy.dart';
import 'package:knowme/features/mirror_habit/ui/mirror_habit_section.dart';
import 'package:knowme/features/product_validation/product_validation.dart';
import 'package:knowme/features/product_validation/product_validation_events.dart';
import 'package:knowme/features/product_validation/ui/product_validation_dashboard.dart';

void main() {
  final asOf = DateTime(2026, 6, 28);
  final input = MirrorExperienceInput(
    birthDate: DateTime(1990, 5, 20),
    asOf: asOf,
  );

  testWidgets('Daily Mirror shows the habit loop and records a reflection',
      (tester) async {
    ProductValidation.recorder.reset();
    final store = InMemoryMirrorHabitStore();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DailyMirrorSection(
            input: input,
            runtime: MirrorExperienceRuntime.fusion,
            habitStore: store,
          ),
        ),
      ),
    ));
    // Let the async habit load complete.
    await tester.pump();
    await tester.pump();

    expect(find.byType(MirrorHabitSection), findsOneWidget);

    // Today is opened and persisted.
    final stored = await store.recent();
    expect(stored.where((r) => r.opened && r.dateKey == '2026-06-28').length, 1);

    // Reflect on "the opening".
    final chip = find.text(MirrorHabitCopy.reflectOpportunity);
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await tester.pump();

    expect(find.textContaining(MirrorHabitCopy.reflectedThanks), findsOneWidget);
    final after = await store.recent();
    final todayRec =
        after.firstWhere((r) => r.dateKey == '2026-06-28');
    expect(todayRec.reflected, isTrue);
    expect(todayRec.reflectionChoice, 'opportunity');

    final events =
        ProductValidation.recorder.currentEvents.map((e) => e.type).toList();
    expect(events, contains(ProductEventType.dailyMirrorOpened));
    expect(events, contains(ProductEventType.dailyReflectionSaved));
  });

  testWidgets('internal dashboard shows habit metrics from the store',
      (tester) async {
    ProductValidation.recorder.reset();
    final seed = <MirrorDayRecord>[
      for (var i = 0; i <= 9; i++)
        MirrorDayRecord(
          date: asOf.subtract(Duration(days: i)),
          opened: true,
          reflected: i.isEven,
          focusTone: MirrorTone.steady,
          clarity: 60,
        ),
    ];
    final store = InMemoryMirrorHabitStore(seed);

    await tester.pumpWidget(MaterialApp(
      home: ProductValidationDashboard(habitStore: store),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Daily habit'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Reflection rate'), findsOneWidget);
  });
}
