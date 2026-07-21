import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v23_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v4_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v5_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_consensus_widget.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_knowme_moment_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_peak_potential_section.dart';

void main() {
  testWidgets('v23 peak potential section uses narrative band not cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FusionPeakPotentialSection())),
    );

    expect(
      find.textContaining(FusionResultV23Copy.peakPotentialTitle),
      findsOneWidget,
    );
    expect(
      find.text('เมื่อคุณเป็นเจ้าของการตัดสินใจ'),
      findsOneWidget,
    );
  });

  testWidgets('v23 result page flow includes peak potential and knowme moment', (
    tester,
  ) async {
    final result = AstrologyFusionGenerator.generate(allMockLenses());

    await tester.binding.setSurfaceSize(const Size(800, 2800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AstrologyFusionResultPage(result: result, showAppBar: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FusionConsensusWidget), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV23Copy.peakPotentialTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionPeakPotentialSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining(FusionResultV4Copy.contradictionTitle),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(FusionKnowMeMomentSection), findsOneWidget);

    final peakOffset = tester.getTopLeft(
      find.textContaining(FusionResultV23Copy.peakPotentialTitle),
    );
    final growthOffset = tester.getTopLeft(find.text('เส้นทางเติบโต'));
    expect(peakOffset.dy, lessThan(growthOffset.dy));
  });
}
