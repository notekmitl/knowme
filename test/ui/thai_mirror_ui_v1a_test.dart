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

ThaiMirrorViewState _sampleViewState({
  List<ThaiMirrorThemeCardState> topThemes = const [
    ThaiMirrorThemeCardState(
      rank: 1,
      themeId: 'disciplined',
      themeName: 'Disciplined',
      description: 'Tends to rely on structure, consistency, and self-control.',
      confidenceLabel: 'ความชัดเจนสูง',
      evidenceCount: 2,
    ),
    ThaiMirrorThemeCardState(
      rank: 2,
      themeId: 'builder',
      themeName: 'Builder',
      description: 'Tends to create durable outcomes through steady effort.',
      confidenceLabel: 'ปานกลาง',
      evidenceCount: 1,
    ),
  ],
  List<ThaiMirrorSectionCardState> sections = const [],
  String reflectionSummary = 'หลายครั้งคุณอาจมองตัวเองผ่านธีม Disciplined และ Builder',
}) {
  final defaultSections = sections.isEmpty
      ? [
          ThaiMirrorSectionCardState(
            id: ThaiMirrorSectionId.coreSelf,
            titleTh: 'แก่นตัวตน',
            titleEn: 'Core Self',
            summary:
                'หลายครั้งคุณอาจมองตัวเองผ่านความรับผิดชอบและความสามารถในการสร้างความมั่นคง',
            themeChips: const ['Disciplined', 'Builder'],
            evidenceCount: 2,
            isExpandedDefault: true,
          ),
          ThaiMirrorSectionCardState(
            id: ThaiMirrorSectionId.thinkingStyle,
            titleTh: 'รูปแบบการคิด',
            titleEn: 'Thinking Style',
            summary: 'หลายครั้งรูปแบบการคิดของคุณอาจเชื่อมกับธีม Analytical',
            themeChips: const ['Analytical'],
            evidenceCount: 1,
            isExpandedDefault: true,
          ),
          ThaiMirrorSectionCardState(
            id: ThaiMirrorSectionId.emotionalWorld,
            titleTh: 'โลกอารมณ์',
            titleEn: 'Emotional World',
            summary: 'หลายครั้งโลกอารมณ์ของคุณอาจสัมผัสได้ผ่านธีม Stable',
            themeChips: const ['Stable'],
            evidenceCount: 1,
            isExpandedDefault: true,
          ),
        ]
      : sections;

  return ThaiMirrorViewState(
    hero: ThaiMirrorHeroState(
      titleTh: ThaiMirrorHeroState.defaultTitleTh,
      titleEn: ThaiMirrorHeroState.defaultTitleEn,
      reflectionSummary: reflectionSummary,
      topThemeNames: topThemes.map((theme) => theme.themeName).toList(),
    ),
    topThemes: topThemes,
    sections: defaultSections,
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

void main() {
  group('ThaiMirrorResultPage V1a', () {
    testWidgets('renders page scaffold', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renders hero section content', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.text(ThaiMirrorHeroState.defaultTitleTh), findsOneWidget);
      expect(find.text('Your Thai Mirror'), findsOneWidget);
      expect(find.textContaining('หลายครั้งคุณอาจมองตัวเอง'), findsWidgets);
      expect(find.text('Disciplined'), findsWidgets);
    });

    testWidgets('renders top themes section', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.text('ธีมเด่น'), findsOneWidget);
      expect(find.text('Builder'), findsWidgets);
      expect(find.text('ความชัดเจนสูง'), findsOneWidget);
      expect(find.text('2 แหล่งอ้างอิง'), findsWidgets);
      expect(find.textContaining('score'), findsNothing);
    });

    testWidgets('renders core self section', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.text('แก่นตัวตน'), findsOneWidget);
      expect(
        find.textContaining('ความรับผิดชอบและความสามารถในการสร้างความมั่นคง'),
        findsOneWidget,
      );
    });

    testWidgets('renders thinking style section', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.text('รูปแบบการคิด'), findsOneWidget);
      expect(find.textContaining('Analytical'), findsWidgets);
    });

    testWidgets('renders emotional world section', (tester) async {
      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.text('โลกอารมณ์'), findsOneWidget);
      expect(find.textContaining('Stable'), findsWidgets);
    });

    testWidgets('handles empty top themes', (tester) async {
      await tester.pumpWidget(
        _wrap(_sampleViewState(topThemes: const [])),
      );

      expect(find.text('ยังไม่มีธีมเด่นในขณะนี้'), findsOneWidget);
      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
    });

    testWidgets('handles empty sections list without crash', (tester) async {
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

      expect(find.text('แก่นตัวตน'), findsOneWidget);
      expect(
        find.text(ThaiMirrorSectionCard.emptySummaryMessage),
        findsWidgets,
      );
    });

    testWidgets('wraps long summary text', (tester) async {
      final longSummary = List.filled(12, 'ประโยคที่ยาวมากเพื่อทดสอบการขึ้นบรรทัดใหม่').join(' ');

      await tester.pumpWidget(
        _wrap(
          _sampleViewState(
            reflectionSummary: longSummary,
            sections: [
              ThaiMirrorSectionCardState(
                id: ThaiMirrorSectionId.coreSelf,
                titleTh: 'แก่นตัวตน',
                titleEn: 'Core Self',
                summary: longSummary,
                themeChips: const [],
                evidenceCount: 0,
                isExpandedDefault: true,
              ),
            ],
          ),
        ),
      );

      expect(find.textContaining('ประโยคที่ยาวมาก'), findsWidgets);
    });

    testWidgets('layout is scrollable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(_sampleViewState()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('โลกอารมณ์'), findsOneWidget);
    });
  });
}
