import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

import 'thai_mirror_consumer_fixtures.dart';

void main() {
  group('ThaiMirrorResultPage V1b', () {
    testWidgets('renders life dashboard areas', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.text(ThaiMirrorConsumerCopy.dashboardSectionTitle), findsOneWidget);
      expect(find.text('การงาน'), findsOneWidget);
      expect(find.text('การเงิน'), findsOneWidget);
      expect(find.text('ความรัก'), findsOneWidget);
      expect(find.text('สุขภาพ'), findsOneWidget);
      expect(find.text('โชคและโอกาส'), findsOneWidget);
    });

    testWidgets('renders life dashboard status labels in Thai', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.text('สดใส'), findsOneWidget);
      expect(find.text('ดี'), findsWidgets);
      expect(find.text('ดีมาก'), findsOneWidget);
      expect(find.text('ปานกลาง'), findsOneWidget);
    });

    testWidgets('does not show accordion section titles', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.text('แก่นตัวตน'), findsNothing);
      expect(find.text('พื้นที่เติบโต'), findsNothing);
      expect(find.text('เส้นทางเติบโต'), findsNothing);
      expect(find.text('ธีมเด่น'), findsNothing);
    });

    testWidgets('shows secret tip', (tester) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.textContaining('เคล็ดลับ:'), findsOneWidget);
    });

    testWidgets('scroll entire page through consumer sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.byType(SingleChildScrollView), findsWidgets);

      await tester.drag(
        find.descendant(
          of: find.byType(ThaiMirrorResultPage),
          matching: find.byType(SingleChildScrollView).first,
        ),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();

      expect(find.text('หลักการวิเคราะห์'), findsOneWidget);
      expect(find.text(ThaiMirrorConsumerCopy.cautionsSectionTitle), findsOneWidget);
    });

    testWidgets('consumes ThaiMirrorConsumerViewState only', (tester) async {
      final consumerState = sampleConsumerViewState();

      await tester.pumpWidget(wrapConsumerResultPage(consumerState));

      final page = tester.widget<ThaiMirrorResultPage>(
        find.byType(ThaiMirrorResultPage),
      );
      expect(page.consumerState, same(consumerState));
      expect(page.consumerState.lifeDashboard, hasLength(5));
      expect(find.textContaining('score'), findsNothing);
    });

    testWidgets('wraps long advice text', (tester) async {
      final longAdvice =
          List.filled(10, 'คำแนะนำยาวสำหรับทดสอบการขึ้นบรรทัดใหม่').join(' ');

      await tester.pumpWidget(
        wrapConsumerResultPage(
          ThaiMirrorConsumerViewState(
            hero: sampleConsumerViewState().hero,
            strengths: sampleConsumerViewState().strengths,
            cautions: sampleConsumerViewState().cautions,
            advice: ThaiMirrorAdviceState(
              title: ThaiMirrorAdviceState.defaultTitle,
              body: longAdvice,
            ),
            lifeDashboard: sampleConsumerViewState().lifeDashboard,
            narrativeSections: sampleConsumerViewState().narrativeSections,
            signatureInsight: sampleConsumerViewState().signatureInsight,
            reflectionSummary: sampleConsumerViewState().reflectionSummary,
            closingMessage: sampleConsumerViewState().closingMessage,
            sourceTransparency: sampleConsumerViewState().sourceTransparency,
            birthDataConfidence: sampleConsumerViewState().birthDataConfidence,
            secretTip: sampleConsumerViewState().secretTip,
            disclaimers: const [],
          ),
        ),
      );

      expect(find.textContaining('คำแนะนำยาวสำหรับทดสอบ'), findsOneWidget);
    });

    testWidgets('life dashboard currentState shows full Thai without ellipsis',
        (tester) async {
      const fullState =
          'แสดงออกชัด: พูดความรู้สึกตรง ๆ ในที่ที่ปลอดภัยจะทำให้ความรักแน่นแฟ้นขึ้น';
      final base = sampleConsumerViewState();
      final dashboard = [
        ThaiMirrorLifeDashboardItemState(
          label: 'ความรัก',
          currentState: fullState,
          whyItAppears: 'เพราะแสดงออกชัดคือสิ่งที่ติดตัวคุณ',
          suggestedAction: 'ลองพูดความรู้สึกในที่ที่ปลอดภัย',
          status: ThaiMirrorLifeStatus.good,
        ),
        ...base.lifeDashboard.skip(1),
      ];

      await tester.pumpWidget(
        wrapConsumerResultPage(
          ThaiMirrorConsumerViewState(
            hero: base.hero,
            strengths: base.strengths,
            cautions: base.cautions,
            advice: base.advice,
            lifeDashboard: dashboard,
            narrativeSections: base.narrativeSections,
            signatureInsight: base.signatureInsight,
            reflectionSummary: base.reflectionSummary,
            closingMessage: base.closingMessage,
            sourceTransparency: base.sourceTransparency,
            birthDataConfidence: base.birthDataConfidence,
            secretTip: base.secretTip,
            disclaimers: base.disclaimers,
          ),
        ),
      );

      expect(find.text(fullState), findsOneWidget);
      expect(find.textContaining('แน่นแฟ้นข…'), findsNothing);
    });
  });
}
