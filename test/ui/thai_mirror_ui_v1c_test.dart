import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_evidence_explorer_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_evidence_explorer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_source_transparency_section.dart';

import 'thai_mirror_consumer_fixtures.dart';

ThaiMirrorEvidenceExplorerState _sortingEvidenceExplorer() {
  return ThaiMirrorEvidenceExplorerState(
    totalEvidenceCount: 3,
    lensCounts: const {
      ThaiMirrorLensSource.lagna: 2,
      ThaiMirrorLensSource.myanmarSeven: 1,
    },
    rows: const [
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.lagna,
        lensLabelTh: 'ลัคนา',
        contentKey: 'zzz_key',
        contentTitle: null,
        supportedThemeIds: ['a', 'b'],
        sectionIdLabel: 'แก่นตัวตน',
      ),
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.lagna,
        lensLabelTh: 'ลัคนา',
        contentKey: 'aaa_key',
        contentTitle: null,
        supportedThemeIds: ['a', 'b', 'c', 'd'],
        sectionIdLabel: 'แก่นตัวตน',
      ),
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.myanmarSeven,
        lensLabelTh: 'เลข 7 ตัว',
        contentKey: 'mmm_key',
        contentTitle: null,
        supportedThemeIds: ['a', 'b', 'c', 'd'],
        sectionIdLabel: 'งานและความทะเยอทะยาน',
      ),
    ],
  );
}

void main() {
  group('ThaiMirrorResultPage V1c', () {
    testWidgets('renders collapsible analysis principles section', (
      tester,
    ) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(
        find.text(ThaiMirrorSourceTransparencySection.titleTh),
        findsOneWidget,
      );
      // Collapsed by default — detail columns are hidden until expanded.
      expect(find.text('ข้อมูลที่ใช้'), findsNothing);

      final header = find.text(ThaiMirrorSourceTransparencySection.titleTh);
      await tester.ensureVisible(header);
      await tester.pumpAndSettle();
      await tester.tap(header);
      await tester.pumpAndSettle();

      expect(find.text('ข้อมูลที่ใช้'), findsOneWidget);
      expect(find.text('หลักการคำนวณ'), findsOneWidget);
      expect(find.text('ความหมายของผลลัพธ์'), findsOneWidget);
    });

    testWidgets('does not render technical evidence explorer on result page', (
      tester,
    ) async {
      await tester.pumpWidget(wrapConsumerResultPage(sampleConsumerViewState()));

      expect(find.byType(ThaiMirrorEvidenceExplorer), findsNothing);
      expect(find.text('บริบทข้อมูลเกิด'), findsNothing);
      expect(find.text('lagna_capricorn'), findsNothing);
      expect(find.text('สรุปตามเลนส์'), findsNothing);
    });

    testWidgets('renders disclaimers', (tester) async {
      await tester.pumpWidget(
        wrapConsumerResultPage(
          sampleConsumerViewState(
            disclaimers: const [
              'เครื่องมือนี้สะท้อนรูปแบบ ไม่ใช่การทำนาย',
              'ผลลัพธ์ขึ้นกับคุณภาพข้อมูลเกิด',
            ],
          ),
        ),
      );

      expect(
        find.text('เครื่องมือนี้สะท้อนรูปแบบ ไม่ใช่การทำนาย'),
        findsOneWidget,
      );
      expect(
        find.text('ผลลัพธ์ขึ้นกับคุณภาพข้อมูลเกิด'),
        findsOneWidget,
      );
    });

    testWidgets('renders full page with transparency blocks', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapConsumerResultPage(
          sampleConsumerViewState(
            disclaimers: const ['ข้อจำกัดความรับผิดชอบ'],
          ),
        ),
      );

      expect(find.textContaining('คุณรับผิดชอบ'), findsOneWidget);
      expect(find.text(ThaiMirrorConsumerCopy.strengthsSectionTitle), findsOneWidget);
      expect(find.text(ThaiMirrorSourceTransparencySection.titleTh), findsOneWidget);
      expect(find.text('ข้อจำกัดความรับผิดชอบ'), findsOneWidget);

      await tester.drag(
        find.descendant(
          of: find.byType(ThaiMirrorResultPage),
          matching: find.byType(SingleChildScrollView).first,
        ),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();

      expect(find.text('ข้อจำกัดความรับผิดชอบ'), findsOneWidget);
    });
  });

  group('ThaiMirrorEvidenceExplorer sorting', () {
    test('sortedRows orders by contribution desc then key asc', () {
      final sorted = ThaiMirrorEvidenceExplorer.sortedRows(
        _sortingEvidenceExplorer().rows,
      );

      expect(
        sorted.map((row) => row.contentKey).toList(),
        ['aaa_key', 'mmm_key', 'zzz_key'],
      );
    });
  });
}
