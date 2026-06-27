import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_profiles.dart';

/// Screenshot Regression Harness.
///
/// Renders the **production** consumer report (same pipeline + page) for every
/// QA Harness profile (A…H) across Desktop / Tablet / Mobile viewports and saves
/// deterministic per-section PNG baselines. This is the baseline for future
/// visual regression: any layout/copy drift changes a golden.
///
/// Regenerate baselines after intentional UI changes:
///   flutter test test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart --update-goldens
///
/// Determinism note: the Life Timeline's "current age" is pinned to [_asOf] so
/// goldens do not drift day-to-day.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fixed reference date → deterministic current-life-stage across runs.
  final asOf = DateTime(2026, 6, 1);

  const viewports = <({String id, double width, double height})>[
    (id: 'desktop', width: 1440, height: 2600),
    (id: 'tablet', width: 768, height: 3200),
    (id: 'mobile', width: 390, height: 3600),
  ];

  // Curated high-signal sections (kept small to avoid large-raster flakiness).
  const sections = <String>[
    'thai_consumer_hero',
    'thai_consumer_life_timeline',
    'thai_consumer_future_prediction',
    'thai_consumer_life_dashboard',
    'thai_consumer_strengths',
    'thai_consumer_advice',
  ];

  Future<void> pump(
    WidgetTester tester,
    dynamic consumer,
    ({String id, double width, double height}) vp,
  ) async {
    await tester.binding.setSurfaceSize(Size(vp.width, vp.height));
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

  for (final profile in ThaiQaHarnessProfiles.all) {
    for (final vp in viewports) {
      testWidgets('profile ${profile.id} · ${vp.id}', (tester) async {
        final result = ThaiMirrorPipeline.generate(profile.birthData);
        expect(result.mirrorResult, isNotNull,
            reason: 'pipeline produced no result for ${profile.id}');

        final lifePeriods = LifePeriodEngine.fromBirthDate(
          profile.birthData.dateOnly,
          asOf: asOf,
        );
        final consumer = ThaiMirrorConsumerPresenter.present(
          result.mirrorResult!,
          lifePeriods: lifePeriods,
        );

        await pump(tester, consumer, vp);

        final id = profile.id.toLowerCase();
        for (final section in sections) {
          final finder = find.byKey(Key(section));
          if (finder.evaluate().isEmpty) continue; // section optional
          await expectLater(
            finder.first,
            matchesGoldenFile('screenshots/${id}_${vp.id}_$section.png'),
          );
        }
      });
    }
  }
}
