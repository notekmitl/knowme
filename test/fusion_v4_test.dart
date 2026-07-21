import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_contradiction_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_future_possibility_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_surprising_insight_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v4_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v6_copy.dart';

void main() {
  test('contradiction builder produces two-sided life pattern', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final contradiction = FusionContradictionBuilder.build(result);

    expect(contradiction, isNotNull);
    expect(contradiction!.poleA, isNotEmpty);
    expect(contradiction.poleB, isNotEmpty);
    expect(contradiction.formattedBody, contains('แต่ในเวลาเดียวกัน'));
  });

  test('future possibility builder avoids fortune-telling language', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final possibility = FusionFuturePossibilityBuilder.build(result);

    expect(possibility, isNotNull);
    final combined =
        '${possibility!.opportunity}${possibility.challenge}${possibility.futureReflection}';
    expect(combined, isNot(contains('แน่นอน')));
    expect(combined, isNot(contains('ดวงชะตากำหนด')));
    expect(combined, isNot(contains('โชคชะตาฟ้าลิขิต')));
    expect(combined, anyOf(
      contains('อาจ'),
      contains('มีแนวโน้ม'),
      contains('มักปรากฏเมื่อ'),
    ));
  });

  test('surprising insight builder picks distinctive headline', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final insight = FusionSurprisingInsightBuilder.build(result);

    expect(insight, isNotNull);
    expect(insight!.headline, isNotEmpty);
    expect(insight.reflection, isNotEmpty);
  });

  test('presenter maps V4 layers for mock result', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    expect(vm.futureDirection, isNotNull);
    expect(
      vm.futureDirection!.title,
      FusionResultV6Copy.directionTitle,
    );
    expect(vm.surprisingInsight, isNotNull);
    expect(
      vm.surprisingInsight!.title,
      FusionResultV4Copy.surprisingInsightTitle,
    );
    expect(vm.knowMeMoment.title, FusionResultV4Copy.contradictionTitle);
    expect(vm.knowMeMoment.body, contains('หลายศาสตร์เห็นตรงกันว่า'));
    expect(
      vm.surprisingInsight!.formattedBody,
      contains('พยายามเป็นคนที่ไม่ใช่ตัวเอง'),
    );
  });
}
