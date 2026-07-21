import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_completion_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_progress_bar.dart';

void main() {
  testWidgets('Landing screen sets expectations and shows the start CTA',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ThaiBetaLandingPage()),
    );
    await tester.pump();

    // CTA lives in the bottom bar (always visible); the info tiles scroll.
    expect(find.text('เริ่มการวิเคราะห์'), findsOneWidget);
    expect(find.text('จุดประสงค์'), findsOneWidget);
    expect(find.text('ใช้เวลาโดยประมาณ'), findsOneWidget);
  });

  testWidgets('Completion screen shows thanks + reference id + restart',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ThaiBetaCompletionPage(researchId: 'TH-00000042'),
      ),
    );
    await tester.pump();

    expect(find.text('ขอบคุณที่ร่วมงานวิจัย!'), findsOneWidget);
    expect(find.text('TH-00000042'), findsOneWidget);
    expect(find.text('เริ่มการวิเคราะห์ใหม่'), findsOneWidget);
  });

  testWidgets('Progress bar renders all four step labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThaiBetaProgressBar(current: ThaiBetaStep.read),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('กรอกข้อมูล'), findsOneWidget);
    expect(find.text('ตรวจสอบข้อมูล'), findsOneWidget);
    expect(find.text('อ่านผล'), findsOneWidget);
    expect(find.text('ส่งความคิดเห็น'), findsOneWidget);
  });
}
