import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_input_page.dart';

const _unknownTimeHelp =
    'หากไม่ทราบเวลาเกิด รายงานจะเว้นหัวข้อที่ต้องใช้เวลาเกิด เช่น ลัคนาและเรือน เพื่อไม่สรุปเกินข้อมูลที่มี';
const _legacyInaccurateHelp =
    'ผลวิเคราะห์บางส่วนอาจคลาดเคลื่อน แต่ยังสามารถวิเคราะห์พื้นฐานได้';

void main() {
  Future<void> pumpInput(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(home: ThaiBetaInputPage()),
      );

  testWidgets('initial known-time state does not show unknown-time help', (
    tester,
  ) async {
    await pumpInput(tester);

    expect(find.text(_unknownTimeHelp), findsNothing);
    expect(find.text(_legacyInaccurateHelp), findsNothing);
    expect(find.text('เวลาเกิด (24 ชั่วโมง)'), findsOneWidget);
  });

  testWidgets('unknown-time help is fail-closed and toggles without duplication', (
    tester,
  ) async {
    await pumpInput(tester);

    await tester.tap(find.text('ฉันไม่ทราบเวลาเกิด'));
    await tester.pumpAndSettle();

    expect(find.text(_unknownTimeHelp), findsOneWidget);
    expect(find.text(_legacyInaccurateHelp), findsNothing);
    expect(find.text('เวลาเกิด (24 ชั่วโมง)'), findsNothing);

    await tester.tap(find.text('ฉันไม่ทราบเวลาเกิด'));
    await tester.pumpAndSettle();

    expect(find.text(_unknownTimeHelp), findsNothing);
    expect(find.text(_legacyInaccurateHelp), findsNothing);
    expect(find.text('เวลาเกิด (24 ชั่วโมง)'), findsOneWidget);
  });
}
