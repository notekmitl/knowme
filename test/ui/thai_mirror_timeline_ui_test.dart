import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/pages/thai_mirror_consumer_preview_page.dart';

/// V8 — Life Timeline renders inside the consumer report when a birth date is
/// available, and is hidden when it is not.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(420, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
          useMaterial3: true,
        ),
        home: child,
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('timeline section renders with a birth date', (tester) async {
    await pump(
      tester,
      const ThaiMirrorConsumerPreviewPage(profileId: 'A'),
    );

    expect(find.text('เส้นทางชีวิตของคุณ'), findsOneWidget);
    expect(find.text('คุณอยู่ช่วงไหนของชีวิต'), findsOneWidget);
    expect(find.text('ทุกช่วงชีวิตของคุณ'), findsOneWidget);
    // "ตอนนี้" badge marks the current period card.
    expect(find.text('ตอนนี้'), findsWidgets);
  });

  testWidgets('period cards expand and collapse on tap', (tester) async {
    await pump(
      tester,
      const ThaiMirrorConsumerPreviewPage(profileId: 'A'),
    );

    // Current period is expanded by default — score domain labels visible.
    expect(find.text('การงาน'), findsWidgets);

    // Tap a non-current period (first: ช่วงวางรากฐาน) to expand it.
    await tester.tap(find.text('ช่วงวางรากฐาน').first);
    await tester.pump(const Duration(milliseconds: 300));

    // Still shows score bars after switching expansion.
    expect(find.text('การเงิน'), findsWidgets);

    // Tap again to collapse that card.
    await tester.tap(find.text('ช่วงวางรากฐาน').first);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('timeline still renders without a birth time (weekday only)',
      (tester) async {
    // The life-period cycle depends only on the weekday of birth, not the time,
    // so the production pipeline always derives it. The QA Harness reuses that
    // exact pipeline, so the timeline must remain visible even with no birth
    // time (which only changes confidence copy elsewhere in the report).
    await pump(
      tester,
      const ThaiMirrorConsumerPreviewPage(
        profileId: 'A',
        hasBirthTime: false,
      ),
    );

    expect(find.text('เส้นทางชีวิตของคุณ'), findsOneWidget);
  });

  testWidgets('timeline strip shows full Thai phase names without ellipsis',
      (tester) async {
    await pump(
      tester,
      const ThaiMirrorConsumerPreviewPage(profileId: 'H'),
    );

    const longPhase = 'ช่วงพลิกผันและเปลี่ยนผ่าน';
    expect(find.text(longPhase), findsWidgets);
    expect(find.textContaining('เปลี่ยนผ่…'), findsNothing);
  });

  testWidgets('future prediction confidence label shows full Thai copy',
      (tester) async {
    await pump(
      tester,
      const ThaiMirrorConsumerPreviewPage(profileId: 'H'),
    );

    expect(find.text('แนวโน้มชีวิตในระยะข้างหน้า'), findsOneWidget);
    expect(find.textContaining('พอเห็นแนวโน้มได้ค่อนข้างชัด'), findsWidgets);
    expect(find.textContaining('ค่อนข้างช…'), findsNothing);
  });
}
