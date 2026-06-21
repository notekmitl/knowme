import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v22_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_confidence_badge.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_consensus_widget.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_story_hero.dart';

void main() {
  test('v22 growth narrative personalizes autonomy copy', () {
    final narrative = FusionResultV22Copy.personalGrowthNarrative(
      title: 'อิสระและการพึ่งพาตัวเอง',
      description: 'มีโอกาสเมื่อกล้าตัดสินใจ',
    );

    expect(narrative, contains('เมื่อคุณเชื่อมั่นในเสียงของตัวเอง'));
    expect(narrative, contains('เส้นทางที่เหมาะกับตัวเองที่สุด'));
  });

  testWidgets('v22 story hero shows fusion evidence and explore cta', (tester) async {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: FusionStoryHero(
          data: vm.hero,
          lensTitles: vm.lensAgreements.map((item) => item.title).toList(),
          alignedCount: vm.lensAgreements.length,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FusionStoryHero), findsOneWidget);
    expect(find.text('Fusion Evidence'), findsOneWidget);
    expect(find.text(FusionResultV22Copy.exploreCta), findsOneWidget);
    expect(find.byType(FusionConfidenceBadge), findsOneWidget);
  });

  testWidgets('v22 result page renders consensus convergence widget', (
    tester,
  ) async {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AstrologyFusionResultPage(result: result, showAppBar: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(FusionConsensusWidget),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(FusionConsensusWidget), findsOneWidget);
    expect(find.textContaining('3/3'), findsWidgets);
  });
}
