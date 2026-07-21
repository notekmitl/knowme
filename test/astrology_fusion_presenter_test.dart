import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v3_insight_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v6_copy.dart';

void main() {
  test('presenter maps mock result sections', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    expect(vm.hero.headline, isNotEmpty);
    expect(vm.hero.supportingReflection, contains('หลายศาสตร์เห็นตรงกันว่า'));
    expect(vm.lensAgreements.length, greaterThan(0));
    expect(vm.strengths.length, greaterThan(0));
    expect(vm.growthPaths.length, greaterThan(0));
    expect(vm.lensAgreements.first.meaning, contains('สนับสนุนเรื่อง'));
    expect(vm.knowMeMoment.body, isNotEmpty);
    expect(vm.finalMessage, isNotNull);
    expect(vm.finalMessage!.title, FusionResultV6Copy.finalMessageTitle);
  });

  test('V3 peak potential copy uses human situations', () {
    expect(
      FusionResultV3InsightCopy.peakPotentialItems.first.title,
      'เมื่อคุณเป็นเจ้าของการตัดสินใจ',
    );
  });
}
