import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v4_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v6_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_direction_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_final_message_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_life_chapter_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_growth_path_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_lens_agreement_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_knowme_moment_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_peak_potential_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_psychology_discovery_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_result_hero_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_strengths_warnings_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_surprising_insight_section.dart';

void main() {
  testWidgets('premium fusion result renders all narrative sections', (tester) async {
    final result = AstrologyFusionGenerator.generate(allMockLenses());

    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AstrologyFusionResultPage(result: result, showAppBar: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FusionResultHeroSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV6Copy.lifeChapterTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionLifeChapterSection), findsOneWidget);

    expect(find.byType(FusionLensAgreementSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('จุดแข็งของคุณ'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionStrengthsWarningsSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('เมื่อคุณอยู่ในจุดที่ดีที่สุด'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionPeakPotentialSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('เส้นทางเติบโต'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionGrowthPathSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV6Copy.directionTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionDirectionSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV4Copy.surprisingInsightTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionSurprisingInsightSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV4Copy.contradictionTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionKnowMeMomentSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV6Copy.finalMessageTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionFinalMessageSection), findsOneWidget);

    expect(find.byType(FusionPsychologyDiscoverySection), findsNothing);
    expect(find.text('บุคลิก MBTI'), findsNothing);
  });
}
