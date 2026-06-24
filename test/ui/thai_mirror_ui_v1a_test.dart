import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

import 'thai_mirror_consumer_fixtures.dart';

void main() {
  group('ThaiMirrorResultPage V1a', () {
    testWidgets('renders page scaffold', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('renders consumer hero section', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(
        find.textContaining('คุณเป็นคน'),
        findsOneWidget,
      );
      expect(find.textContaining('หลายครั้ง'), findsNothing);
      expect(find.text('มีวินัย'), findsNothing);
      expect(find.text('รับผิดชอบ'), findsOneWidget);
      expect(find.text('Disciplined'), findsNothing);
      expect(find.text('Your Thai Mirror'), findsNothing);
    });

    testWidgets('renders Thai-only personality tags', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.text('รับผิดชอบ'), findsOneWidget);
      expect(find.text('คิดละเอียด'), findsOneWidget);
      expect(find.textContaining('score'), findsNothing);
    });

    testWidgets('renders insight card sections', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.text('จุดเด่นของคุณ'), findsOneWidget);
      expect(find.text('สิ่งที่ควรระวัง'), findsOneWidget);
      expect(find.text('คำแนะนำสำหรับช่วงนี้'), findsOneWidget);
      expect(find.text('ทำจริงจังเมื่อให้คำมั่น'), findsOneWidget);
      expect(find.text('อย่าคิดวนมากเกินไป'), findsOneWidget);
    });

    testWidgets('handles empty tags without crash', (tester) async {
      await tester.pumpWidget(
        wrapConsumerResultPage(
          sampleConsumerViewState(tags: const []),
        ),
      );

      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
      expect(find.text('จุดเด่นของคุณ'), findsOneWidget);
    });

    testWidgets('wraps long summary text', (tester) async {
      final longSummary =
          List.filled(12, 'ประโยคที่ยาวมากเพื่อทดสอบการขึ้นบรรทัดใหม่').join(' ');

      await tester.pumpWidget(
        wrapConsumerResultPage(
          sampleConsumerViewState(summary: longSummary),
        ),
      );

      expect(find.textContaining('ประโยคที่ยาวมาก'), findsOneWidget);
    });

    testWidgets('layout is scrollable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.byType(SingleChildScrollView), findsWidgets);
      await tester.drag(
        find.descendant(
          of: find.byType(ThaiMirrorResultPage),
          matching: find.byType(SingleChildScrollView).first,
        ),
        const Offset(0, -300),
      );
      await tester.pump();

      expect(find.text('ชีวิตของคุณในด้านต่าง ๆ'), findsOneWidget);
    });
  });
}
