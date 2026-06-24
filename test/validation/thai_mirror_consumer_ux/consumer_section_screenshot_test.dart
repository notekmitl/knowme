import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_birth_data_confidence_banner.dart';

import 'analysis/consumer_ux_validation_runner.dart';
import '../../ui/thai_mirror_consumer_fixtures.dart';

/// Real Flutter renders saved as PNG (via golden comparator, not pixel diff).
/// Run: flutter test .../consumer_section_screenshot_test.dart --update-goldens
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('consumer UX screenshots', () {
    Future<void> pumpConsumer(WidgetTester tester, dynamic consumer) async {
      await tester.binding.setSurfaceSize(const Size(390, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
            useMaterial3: true,
          ),
          home: ThaiMirrorResultPage(consumerState: consumer),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('profile A — consumer sections', (tester) async {
      final consumer = ConsumerUxValidationRunner.presentProfile(
        ConsumerUxValidationRunner.profiles.first,
        hasBirthTime: true,
      );
      await pumpConsumer(tester, consumer);

      await expectLater(
        find.byKey(const Key('thai_consumer_hero')),
        matchesGoldenFile('screenshots/profile_a_01_hero.png'),
      );
      await expectLater(
        find.byKey(ThaiMirrorBirthDataConfidenceBanner.sectionKey),
        matchesGoldenFile('screenshots/profile_a_02_birth_confidence.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_strengths')),
        matchesGoldenFile('screenshots/profile_a_03_strengths.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_cautions')),
        matchesGoldenFile('screenshots/profile_a_04_cautions.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_advice')),
        matchesGoldenFile('screenshots/profile_a_05_advice.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_life_dashboard')),
        matchesGoldenFile('screenshots/profile_a_06_life_dashboard.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_source')),
        matchesGoldenFile('screenshots/profile_a_07_source.png'),
      );
      await expectLater(
        find.byKey(const Key('thai_consumer_footer')),
        matchesGoldenFile('screenshots/profile_a_08_footer.png'),
      );
    });

    testWidgets('profile A — missing birth time banner', (tester) async {
      final consumer = ConsumerUxValidationRunner.presentProfile(
        ConsumerUxValidationRunner.profiles.first,
        hasBirthTime: false,
      );
      await pumpConsumer(tester, consumer);
      await expectLater(
        find.byKey(ThaiMirrorBirthDataConfidenceBanner.sectionKey),
        matchesGoldenFile('screenshots/profile_a_no_birth_time_banner.png'),
      );
    });

    testWidgets('fixture — full page reference', (tester) async {
      await pumpConsumer(tester, sampleConsumerViewState());
      await expectLater(
        find.byType(ThaiMirrorResultPage),
        matchesGoldenFile('screenshots/full_page_fixture.png'),
      );
    });

    for (final profile in ConsumerUxValidationRunner.profiles) {
      testWidgets('profile ${profile.id} differentiation', (tester) async {
        final consumer = ConsumerUxValidationRunner.presentProfile(
          profile,
          hasBirthTime: true,
        );
        await pumpConsumer(tester, consumer);
        final id = profile.id.toLowerCase();
        await expectLater(
          find.byKey(const Key('thai_consumer_hero')),
          matchesGoldenFile('screenshots/profile_${id}_hero.png'),
        );
        await expectLater(
          find.byKey(const Key('thai_consumer_life_dashboard')),
          matchesGoldenFile('screenshots/profile_${id}_dashboard.png'),
        );
      });
    }
  });
}
