import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/mirror_experience/mirror_copy.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_input.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_runtime.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_service.dart';
import 'package:knowme/features/mirror_experience/ui/daily_mirror_section.dart';
import 'package:knowme/features/mirror_experience/ui/mirror_conversation_entry.dart';
import 'package:knowme/features/product_validation/product_validation.dart';
import 'package:knowme/features/product_validation/product_validation_events.dart';

/// Phase C — the Daily Mirror composes the existing fusion reads into today's
/// life guidance. These pin determinism, the "explain life, not astrology" copy,
/// and the four Daily Mirror telemetry signals.
void main() {
  final inputs = <MirrorExperienceInput>[
    MirrorExperienceInput(
      birthDate: DateTime(1989, 4, 15),
      asOf: DateTime(2026, 6, 28),
    ),
    MirrorExperienceInput(
      birthDate: DateTime(1995, 9, 26),
      asOf: DateTime(2026, 6, 28),
    ),
  ];

  final service = MirrorExperienceService(MirrorExperienceRuntime.fusion);

  const forbidden = <String>[
    'planet', 'saturn', 'mars', 'venus', 'mercury', 'jupiter', 'moon', 'sun',
    'rahu', 'ketu', 'astrology', 'horoscope', 'zodiac', 'natal', 'lagna',
    'runtime', 'fusion', 'thai', 'prediction', 'decision', 'timeline',
  ];

  void assertClean(String text) {
    final lower = text.toLowerCase();
    for (final word in forbidden) {
      expect(lower.contains(word), isFalse,
          reason: 'Daily copy must not mention "$word": "$text"');
    }
  }

  test('daily read has three labelled messages, an action and clarity', () {
    for (final input in inputs) {
      final daily = service.daily(input);

      expect(daily.opportunity.label, MirrorCopy.opportunityLabel);
      expect(daily.caution.label, MirrorCopy.cautionLabel);
      expect(daily.focus.label, MirrorCopy.focusLabel);
      expect(daily.action.label, MirrorCopy.actionLabel);
      expect(daily.action.body, isNotEmpty);
      expect(daily.clarity.value, inInclusiveRange(0, 100));
      expect(daily.evidenceAreas.length, lessThanOrEqualTo(4));
      expect(daily.dateLabel, contains('June'));
    }
  });

  test('daily copy explains life, never engines or concepts', () {
    for (final input in inputs) {
      final daily = service.daily(input);
      assertClean(daily.greeting);
      for (final m in [daily.opportunity, daily.caution, daily.focus]) {
        assertClean(m.label);
        assertClean(m.title);
        assertClean(m.body);
      }
      assertClean(daily.action.label);
      assertClean(daily.action.body);
    }
  });

  test('daily read is deterministic for the same input', () {
    final a = service.daily(inputs.first);
    final b = service.daily(inputs.first);
    expect(a.opportunity.body, b.opportunity.body);
    expect(a.caution.body, b.caution.body);
    expect(a.focus.body, b.focus.body);
    expect(a.action.body, b.action.body);
    expect(a.clarity.value, b.clarity.value);
    expect(a.evidenceAreas.map((e) => e.key),
        b.evidenceAreas.map((e) => e.key));
  });

  testWidgets('action click and conversation start are tracked', (tester) async {
    ProductValidation.recorder.reset();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DailyMirrorSection(
            input: inputs.first,
            runtime: MirrorExperienceRuntime.fusion,
          ),
        ),
      ),
    ));
    await tester.pump();

    // Suggested action.
    final actionCta = find.text(MirrorCopy.dailyActionDoneCta);
    await tester.ensureVisible(actionCta);
    await tester.pump();
    await tester.tap(actionCta);
    await tester.pump();
    expect(find.text(MirrorCopy.dailyActionDoneAck), findsOneWidget);

    // Conversation entry.
    final entry = find.text(MirrorCopy.dailyConversationTitle);
    await tester.ensureVisible(entry);
    await tester.pump();
    await tester.tap(entry);
    await tester.pump();
    expect(find.byType(MirrorConversationEntry), findsOneWidget);

    final events =
        ProductValidation.recorder.currentEvents.map((e) => e.type).toList();
    expect(events, contains(ProductEventType.dailyMirrorOpened));
    expect(events, contains(ProductEventType.dailyActionClicked));
    expect(events, contains(ProductEventType.dailyConversationStarted));
  });
}
