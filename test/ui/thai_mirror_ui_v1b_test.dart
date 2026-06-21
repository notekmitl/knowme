import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_evidence_explorer_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_hero_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_profile_context_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_section_card_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_theme_card_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_section_card.dart';

const _allSections = [
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.coreSelf,
    titleTh: 'แก่นตัวตน',
    titleEn: 'Core Self',
    summary: 'หลายครั้งคุณอาจมองตัวเองผ่านความรับผิดชอบและความสามารถในการสร้างความมั่นคง',
    themeChips: ['Disciplined', 'Builder'],
    evidenceCount: 2,
    isExpandedDefault: true,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.thinkingStyle,
    titleTh: 'รูปแบบการคิด',
    titleEn: 'Thinking Style',
    summary: 'หลายครั้งรูปแบบการคิดของคุณอาจเชื่อมกับธีม Analytical',
    themeChips: ['Analytical'],
    evidenceCount: 1,
    isExpandedDefault: true,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.emotionalWorld,
    titleTh: 'โลกอารมณ์',
    titleEn: 'Emotional World',
    summary: 'หลายครั้งโลกอารมณ์ของคุณอาจสัมผัสได้ผ่านธีม Stable',
    themeChips: ['Stable'],
    evidenceCount: 1,
    isExpandedDefault: true,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.relationships,
    titleTh: 'ความสัมพันธ์',
    titleEn: 'Relationships',
    summary: 'หลายครั้งความสัมพันธ์ของคุณอาจสะท้อนผ่านธีม Loyal',
    themeChips: ['Loyal', 'Warm'],
    evidenceCount: 2,
    isExpandedDefault: false,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.workAndAmbition,
    titleTh: 'งานและความทะเยอทะยาน',
    titleEn: 'Work & Ambition',
    summary: 'หลายครั้งแรงจูงใจในงานของคุณอาจเชื่อมกับธีม Builder',
    themeChips: ['Builder'],
    evidenceCount: 1,
    isExpandedDefault: false,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.strengths,
    titleTh: 'จุดแข็ง',
    titleEn: 'Strengths',
    summary: 'หลายครั้งจุดแข็งของคุณอาจปรากฏผ่านความสม่ำเสมอและความอดทน',
    themeChips: ['Disciplined', 'Resilient'],
    evidenceCount: 3,
    isExpandedDefault: false,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.growthAreas,
    titleTh: 'พื้นที่เติบโต',
    titleEn: 'Growth Areas',
    summary: 'หลายครั้งพื้นที่เติบโตของคุณอาจเกี่ยวข้องกับการเปิดรับมุมมองใหม่',
    themeChips: ['Flexible'],
    evidenceCount: 1,
    isExpandedDefault: false,
  ),
  ThaiMirrorSectionCardState(
    id: ThaiMirrorSectionId.growthPath,
    titleTh: 'เส้นทางเติบโต',
    titleEn: 'Growth Path',
    summary: 'หลายครั้งเส้นทางเติบโตของคุณอาจเริ่มจากการสังเกตรูปแบบที่ทำซ้ำ',
    themeChips: ['Reflective'],
    evidenceCount: 1,
    isExpandedDefault: false,
  ),
];

ThaiMirrorViewState _fullViewState({
  List<ThaiMirrorSectionCardState> sections = _allSections,
  String? relationshipsSummary,
}) {
  final resolvedSections = relationshipsSummary == null
      ? sections
      : sections
          .map(
            (section) => section.id == ThaiMirrorSectionId.relationships
                ? ThaiMirrorSectionCardState(
                    id: section.id,
                    titleTh: section.titleTh,
                    titleEn: section.titleEn,
                    summary: relationshipsSummary,
                    themeChips: section.themeChips,
                    evidenceCount: section.evidenceCount,
                    isExpandedDefault: section.isExpandedDefault,
                  )
                : section,
          )
          .toList();

  return ThaiMirrorViewState(
    hero: const ThaiMirrorHeroState(
      titleTh: ThaiMirrorHeroState.defaultTitleTh,
      titleEn: ThaiMirrorHeroState.defaultTitleEn,
      reflectionSummary: 'หลายครั้งคุณอาจมองตัวเองผ่านธีม Disciplined และ Builder',
      topThemeNames: ['Disciplined', 'Builder'],
    ),
    topThemes: const [
      ThaiMirrorThemeCardState(
        rank: 1,
        themeId: 'disciplined',
        themeName: 'Disciplined',
        description: 'Tends to rely on structure, consistency, and self-control.',
        confidenceLabel: 'ความชัดเจนสูง',
        evidenceCount: 2,
      ),
    ],
    sections: resolvedSections,
    evidenceExplorer: ThaiMirrorEvidenceExplorerState.empty,
    profileContext: ThaiMirrorProfileContextState.empty,
    disclaimers: const [],
    narrativeStatus: ThaiMirrorNarrativeStatus.complete,
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

Future<void> _expandSection(WidgetTester tester, String titleTh) async {
  final finder = find.text(titleTh);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('ThaiMirrorResultPage V1b', () {
    testWidgets('renders relationships section', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.text('ความสัมพันธ์'), findsOneWidget);
      await _expandSection(tester, 'ความสัมพันธ์');
      expect(
        find.textContaining('หลายครั้งความสัมพันธ์ของคุณอาจสะท้อนผ่านธีม Loyal'),
        findsOneWidget,
      );
      expect(find.text('Loyal'), findsOneWidget);
      expect(find.text('2 แหล่งอ้างอิง'), findsWidgets);
    });

    testWidgets('renders work and ambition section', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.text('งานและความทะเยอทะยาน'), findsOneWidget);
      await _expandSection(tester, 'งานและความทะเยอทะยาน');
      expect(
        find.textContaining('หลายครั้งแรงจูงใจในงานของคุณอาจเชื่อมกับธีม Builder'),
        findsOneWidget,
      );
    });

    testWidgets('renders strengths section', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.text('จุดแข็ง'), findsOneWidget);
      await _expandSection(tester, 'จุดแข็ง');
      expect(
        find.textContaining('หลายครั้งจุดแข็งของคุณอาจปรากฏผ่านความสม่ำเสมอ'),
        findsOneWidget,
      );
      expect(find.text('Resilient'), findsOneWidget);
    });

    testWidgets('renders growth areas section', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.text('พื้นที่เติบโต'), findsOneWidget);
      await _expandSection(tester, 'พื้นที่เติบโต');
      expect(
        find.textContaining('หลายครั้งพื้นที่เติบโตของคุณอาจเกี่ยวข้อง'),
        findsOneWidget,
      );
      expect(find.text('Flexible'), findsOneWidget);
    });

    testWidgets('renders growth path section', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.text('เส้นทางเติบโต'), findsOneWidget);
      expect(find.text('→'), findsOneWidget);
      await _expandSection(tester, 'เส้นทางเติบโต');
      expect(
        find.textContaining('หลายครั้งเส้นทางเติบโตของคุณอาจเริ่มจากการสังเกต'),
        findsOneWidget,
      );
    });

    testWidgets('collapsed defaults for later sections', (tester) async {
      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(
        find.textContaining('หลายครั้งความสัมพันธ์ของคุณอาจสะท้อนผ่านธีม Loyal'),
        findsNothing,
      );
      expect(
        find.textContaining('หลายครั้งคุณอาจมองตัวเองผ่านความรับผิดชอบ'),
        findsOneWidget,
      );
      expect(find.text('ThaiMirrorSectionCard'), findsNothing);
      expect(find.byType(ThaiMirrorSectionCard), findsNWidgets(8));
    });

    testWidgets('empty state rendering keeps all sections visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ThaiMirrorViewState(
            hero: const ThaiMirrorHeroState(
              titleTh: ThaiMirrorHeroState.defaultTitleTh,
              titleEn: ThaiMirrorHeroState.defaultTitleEn,
              reflectionSummary: ThaiMirrorHeroState.fallbackReflectionSummary,
              topThemeNames: [],
            ),
            topThemes: const [],
            sections: const [],
            evidenceExplorer: ThaiMirrorEvidenceExplorerState.empty,
            profileContext: ThaiMirrorProfileContextState.empty,
            disclaimers: const [],
            narrativeStatus: ThaiMirrorNarrativeStatus.structuralOnly,
          ),
        ),
      );

      for (final id in ThaiMirrorResultPage.sectionIds) {
        expect(find.text(id.titleTh), findsOneWidget);
      }

      await _expandSection(tester, 'ความสัมพันธ์');
      expect(
        find.text(ThaiMirrorSectionCard.emptySummaryMessage),
        findsWidgets,
      );
    });

    testWidgets('wraps long summaries in added sections', (tester) async {
      final longSummary =
          List.filled(10, 'ประโยคยาวสำหรับทดสอบการขึ้นบรรทัดใหม่ในส่วนความสัมพันธ์')
              .join(' ');

      await tester.pumpWidget(
        _wrap(_fullViewState(relationshipsSummary: longSummary)),
      );

      await _expandSection(tester, 'ความสัมพันธ์');
      expect(find.textContaining('ประโยคยาวสำหรับทดสอบ'), findsOneWidget);
    });

    testWidgets('scroll entire page through all sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(_fullViewState()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('เส้นทางเติบโต'), findsOneWidget);
      expect(find.text('พื้นที่เติบโต'), findsOneWidget);
    });

    testWidgets('consumes ThaiMirrorViewState only', (tester) async {
      final viewState = _fullViewState();

      await tester.pumpWidget(_wrap(viewState));

      final page = tester.widget<ThaiMirrorResultPage>(
        find.byType(ThaiMirrorResultPage),
      );
      expect(page.viewState, same(viewState));
      expect(page.viewState.sections.length, 8);
      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
      expect(find.textContaining('score'), findsNothing);
    });
  });
}
