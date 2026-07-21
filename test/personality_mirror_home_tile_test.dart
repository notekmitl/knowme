import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_entry_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_readiness.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/knowme_journey_section.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

void main() {
  setUp(() {
    AppText.lang = 'th';
  });

  testWidgets('home discovery hub shows personality mirror tile in tests group', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeDiscoveryHub(
              entryState: const AstrologyFusionEntryState(
                readiness: AstrologyFusionReadiness(
                  completedLensCount: 0,
                  totalLensCount: 3,
                  status: AstrologyFusionEntryStatus.unavailable,
                  completedLensIds: [],
                ),
                canOpen: false,
              ),
              globalFusionEntry: const FusionEntryState(canOpen: false),
              personalityMirrorEntry: PersonalityMirrorEntryState.fromCoverage(
                _coverage(hasMbti: true, hasBigFive: true),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(AppText.t('personality_mirror_home_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('personality_mirror_home_subtitle_partial')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('home_discovery_tests_section_desc')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('home_big_five_discovery_body')),
      findsOneWidget,
    );

    final cognitiveY = tester
        .getTopLeft(find.text(AppText.t('fusion_v11_lens_cognitive')))
        .dy;
    final bigFiveY = tester
        .getTopLeft(find.text(AppText.t('big_five_test_title')))
        .dy;
    final eqY = tester
        .getTopLeft(find.text(AppText.t('fusion_v11_lens_eq')))
        .dy;
    final summaryY = tester
        .getTopLeft(find.text(AppText.t('home_discovery_mbti_summary_title')))
        .dy;
    final mirrorY = tester
        .getTopLeft(find.text(AppText.t('personality_mirror_home_title')))
        .dy;

    expect(bigFiveY, greaterThan(cognitiveY));
    expect(eqY, greaterThan(bigFiveY));
    expect(summaryY, greaterThan(eqY));
    expect(mirrorY, greaterThan(summaryY));
  });
}

PersonalityCoverage _coverage({
  bool hasMbti = false,
  bool hasBigFive = false,
  bool hasEq = false,
}) {
  final available = <PersonalityLensId>[];
  if (hasMbti) available.add(PersonalityLensId.mbti);
  if (hasBigFive) available.add(PersonalityLensId.bigFive);
  if (hasEq) available.add(PersonalityLensId.eqAwareness);

  return PersonalityCoverage(
    availableLensIds: available,
    missingLensIds: PersonalityLensId.all
        .where((id) => !available.contains(id))
        .toList(),
    eqModulesCompleted: hasEq ? 1 : 0,
    eqModulesExpected: PersonalityLensId.eqLenses.length,
    weightedCoverage: 0.5,
  );
}
