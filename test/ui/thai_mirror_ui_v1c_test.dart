import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_evidence_explorer_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_hero_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_profile_context_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_section_card_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_evidence_explorer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_lens_badge.dart';

ThaiMirrorViewState _viewState({
  ThaiMirrorEvidenceExplorerState? evidenceExplorer,
  ThaiMirrorProfileContextState? profileContext,
  List<String> disclaimers = const [],
}) {
  return ThaiMirrorViewState(
    hero: const ThaiMirrorHeroState(
      titleTh: ThaiMirrorHeroState.defaultTitleTh,
      titleEn: ThaiMirrorHeroState.defaultTitleEn,
      reflectionSummary: ThaiMirrorHeroState.fallbackReflectionSummary,
      topThemeNames: [],
    ),
    topThemes: const [],
    sections: const [
      ThaiMirrorSectionCardState(
        id: ThaiMirrorSectionId.coreSelf,
        titleTh: 'แก่นตัวตน',
        titleEn: 'Core Self',
        summary: 'สรุปแก่นตัวตน',
        themeChips: [],
        evidenceCount: 1,
        isExpandedDefault: true,
      ),
    ],
    evidenceExplorer: evidenceExplorer ?? _sampleEvidenceExplorer(),
    profileContext: profileContext ?? ThaiMirrorProfileContextState.empty,
    disclaimers: disclaimers,
    narrativeStatus: ThaiMirrorNarrativeStatus.complete,
  );
}

ThaiMirrorEvidenceExplorerState _sampleEvidenceExplorer() {
  return ThaiMirrorEvidenceExplorerState(
    totalEvidenceCount: 4,
    lensCounts: const {
      ThaiMirrorLensSource.lagna: 1,
      ThaiMirrorLensSource.lagnaLord: 1,
      ThaiMirrorLensSource.myanmarSeven: 1,
      ThaiMirrorLensSource.mahabhutaPosition: 1,
    },
    rows: const [
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.lagna,
        lensLabelTh: 'ลัคนา',
        contentKey: 'lagna_capricorn',
        contentTitle: 'Lagna Capricorn',
        supportedThemeIds: ['disciplined', 'builder', 'stable', 'analytical'],
        sectionIdLabel: 'แก่นตัวตน',
      ),
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.lagnaLord,
        lensLabelTh: 'เจ้าเรือนลัคนา',
        contentKey: 'lagna_lord_saturn',
        contentTitle: 'Lagna Lord Saturn',
        supportedThemeIds: ['disciplined', 'builder'],
        sectionIdLabel: 'แก่นตัวตน',
      ),
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.myanmarSeven,
        lensLabelTh: 'เลข 7 ตัว (พม่า)',
        contentKey: 'myanmar_7_3',
        contentTitle: 'Myanmar 7 #3',
        supportedThemeIds: ['builder'],
        sectionIdLabel: 'งานและความทะเยอทะยาน',
      ),
      ThaiMirrorEvidenceRowState(
        lensSource: ThaiMirrorLensSource.mahabhutaPosition,
        lensLabelTh: 'มหาภูติ (ตำแหน่ง)',
        contentKey: 'mahabhuta_earth',
        contentTitle: 'Mahabhuta Earth',
        supportedThemeIds: ['stable', 'loyal', 'resilient'],
        sectionIdLabel: 'โลกอารมณ์',
      ),
    ],
  );
}

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

Widget _wrap(ThaiMirrorViewState viewState) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C6BC0)),
      useMaterial3: true,
    ),
    home: ThaiMirrorResultPage(viewState: viewState),
  );
}

Future<void> _expandExplorer(WidgetTester tester) async {
  final finder = find.text(ThaiMirrorEvidenceExplorer.titleTh);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('ThaiMirrorResultPage V1c', () {
    testWidgets('renders evidence explorer header', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      expect(find.text(ThaiMirrorEvidenceExplorer.titleTh), findsOneWidget);
      expect(find.text(ThaiMirrorEvidenceExplorer.subtitleTh), findsOneWidget);
      expect(find.byType(ThaiMirrorEvidenceExplorer), findsOneWidget);
    });

    testWidgets('evidence explorer collapsed by default', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      expect(find.text('lagna_capricorn'), findsNothing);
      expect(find.text('สรุปตามเลนส์'), findsNothing);
    });

    testWidgets('expands evidence explorer', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.text('lagna_capricorn'), findsOneWidget);
      expect(find.text('สรุปตามเลนส์'), findsOneWidget);
    });

    testWidgets('shows lens summary counts', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.textContaining('ลัคนา (1)'), findsOneWidget);
      expect(find.textContaining('เจ้าเรือน (1)'), findsOneWidget);
      expect(find.textContaining('เลข 7 ตัว (1)'), findsOneWidget);
      expect(find.textContaining('มหาภูติ (1)'), findsOneWidget);
    });

    testWidgets('renders lagna badge', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.text('ลัคนา'), findsWidgets);
      expect(find.byType(ThaiMirrorLensBadge), findsWidgets);
    });

    testWidgets('renders lagna lord badge', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.text('เจ้าเรือนลัคนา'), findsOneWidget);
    });

    testWidgets('renders myanmar badge', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.text('เลข 7 ตัว'), findsWidgets);
    });

    testWidgets('renders mahabhuta badge', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      await _expandExplorer(tester);

      expect(find.text('มหาภูติ'), findsWidgets);
    });

    testWidgets('sorts evidence rows by contribution then key', (tester) async {
      await tester.pumpWidget(
        _wrap(_viewState(evidenceExplorer: _sortingEvidenceExplorer())),
      );

      await _expandExplorer(tester);

      final keys = tester
          .widgetList<Text>(find.textContaining('_key'))
          .map((widget) => widget.data)
          .toList();

      expect(keys, ['aaa_key', 'mmm_key', 'zzz_key']);
    });

    testWidgets('shows empty evidence state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _viewState(
            evidenceExplorer: ThaiMirrorEvidenceExplorerState.empty,
          ),
        ),
      );

      await _expandExplorer(tester);

      expect(
        find.text(ThaiMirrorEvidenceExplorer.emptyMessage),
        findsOneWidget,
      );
    });

    testWidgets('renders profile context', (tester) async {
      await tester.pumpWidget(_wrap(_viewState()));

      expect(find.text('บริบทข้อมูลเกิด'), findsOneWidget);
      expect(find.text('✓ มีเวลาเกิด'), findsOneWidget);
      expect(find.textContaining('มาตรฐานการคำนวณ: v1.1'), findsOneWidget);
    });

    testWidgets('renders profile warnings', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _viewState(
            profileContext: const ThaiMirrorProfileContextState(
              hasBirthTime: false,
              warningMessages: [
                'ไม่มีเวลาเกิด — ลัคนาอาจไม่แสดง',
              ],
              calculationStandardVersion: 'v1.1',
            ),
          ),
        ),
      );

      expect(find.text('⚠ ไม่พบเวลาเกิด'), findsOneWidget);
      expect(
        find.textContaining('ไม่มีเวลาเกิด — ลัคนาอาจไม่แสดง'),
        findsOneWidget,
      );
    });

    testWidgets('renders disclaimers', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _viewState(
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
        _wrap(
          _viewState(
            disclaimers: const ['ข้อจำกัดความรับผิดชอบ'],
          ),
        ),
      );

      expect(find.text(ThaiMirrorHeroState.defaultTitleTh), findsOneWidget);
      expect(find.text('แก่นตัวตน'), findsOneWidget);
      expect(find.text(ThaiMirrorEvidenceExplorer.titleTh), findsOneWidget);
      expect(find.text('บริบทข้อมูลเกิด'), findsOneWidget);
      expect(find.text('ข้อจำกัดความรับผิดชอบ'), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
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
