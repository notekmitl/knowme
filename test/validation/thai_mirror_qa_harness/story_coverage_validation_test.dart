import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_profiles.dart';

/// Story Coverage Validation — fails CI when the consumer report regresses.
///
/// For every QA Harness profile (A…H) rendered through the **production**
/// pipeline, this asserts:
///   * every required report section renders,
///   * no empty cards (each section has real text),
///   * no placeholder copy (TODO / lorem / null / template markers),
///   * no duplicated section headings,
///   * no English leakage (Thai consumer report stays Thai),
///   * no layout overflow.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final asOf = DateTime(2026, 6, 1);

  // Sections that must always render for a complete life story.
  const requiredSections = <String>[
    'thai_consumer_hero',
    'thai_consumer_life_timeline',
    'thai_consumer_future_prediction',
    'thai_consumer_life_dashboard',
    'thai_consumer_strengths',
    'thai_consumer_cautions',
    'thai_consumer_advice',
    'thai_consumer_source',
  ];

  const placeholderTokens = <String>[
    'TODO',
    'FIXME',
    'lorem',
    'Lorem',
    'ipsum',
    'PLACEHOLDER',
    'placeholder',
    'undefined',
    'NaN',
    'null',
    'TBD',
    'tbd',
    'xxx',
    'XXX',
    '{{',
    '}}',
    r'${',
    '#ERR',
  ];

  // Latin-only strings legitimately present in the Thai report.
  const latinAllowlist = <String>{
    'KnowMe',
    'AI',
    'KNOWME',
  };

  final thai = RegExp(r'[\u0E00-\u0E7F]');
  final latinLetters = RegExp(r'[A-Za-z]');

  bool isEnglishLeak(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return false;
    if (thai.hasMatch(s)) return false; // contains Thai → not a leak
    if (latinAllowlist.contains(s)) return false;
    // Count Latin letters; short labels (brand, abbreviations) are fine.
    final letters = latinLetters.allMatches(s).length;
    return letters >= 12;
  }

  Future<void> pump(WidgetTester tester, dynamic consumer) async {
    await tester.binding.setSurfaceSize(const Size(420, 4200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
          useMaterial3: true,
        ),
        home: ThaiMirrorResultPage(consumerState: consumer),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> sectionTexts(WidgetTester tester, String key) {
    final finder = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(Text),
    );
    return tester
        .widgetList<Text>(finder)
        .map((t) => t.data ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  for (final profile in ThaiQaHarnessProfiles.all) {
    testWidgets('profile ${profile.id} — story coverage', (tester) async {
      final result = ThaiMirrorPipeline.generate(profile.birthData);
      expect(result.mirrorResult, isNotNull);

      final lifePeriods = LifePeriodEngine.fromBirthDate(
        profile.birthData.dateOnly,
        asOf: asOf,
      );
      final consumer = ThaiMirrorConsumerPresenter.present(
        result.mirrorResult!,
        lifePeriods: lifePeriods,
      );

      await pump(tester, consumer);

      // 1) No layout overflow during build/paint.
      expect(tester.takeException(), isNull,
          reason: 'layout overflow for ${profile.id}');

      final headings = <String>[];
      for (final section in requiredSections) {
        // 2) Section renders.
        expect(find.byKey(Key(section)), findsOneWidget,
            reason: 'missing section "$section" for ${profile.id}');

        // 3) No empty cards.
        final texts = sectionTexts(tester, section);
        expect(texts, isNotEmpty,
            reason: 'empty section "$section" for ${profile.id}');

        headings.add(texts.first);
      }

      // 4) No duplicated section headings.
      final dupes = <String>{};
      final seen = <String>{};
      for (final h in headings) {
        if (!seen.add(h)) dupes.add(h);
      }
      expect(dupes, isEmpty,
          reason: 'duplicated section headings $dupes for ${profile.id}');

      // 5) No placeholder copy + 6) no English leakage across the whole page.
      final allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((s) => s.trim().isNotEmpty);

      for (final text in allTexts) {
        for (final token in placeholderTokens) {
          expect(text.contains(token), isFalse,
              reason: 'placeholder "$token" in "$text" (${profile.id})');
        }
        expect(isEnglishLeak(text), isFalse,
            reason: 'English leakage "$text" (${profile.id})');
      }
    });
  }
}
