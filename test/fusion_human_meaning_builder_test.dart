import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_human_meaning_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_human_meaning_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v3_insight_copy.dart';

void main() {
  test('human meaning builder produces pattern-based hero for mock lenses', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());

    final hero = FusionHumanMeaningBuilder.buildHeroSupporting(result);
    final moment = FusionHumanMeaningBuilder.buildKnowMeMoment(result);

    expect(hero, contains('หลายศาสตร์เห็นตรงกันว่า'));
    expect(hero, contains('ช่วงเวลาที่คุณมีพลังที่สุด'));
    expect(hero, isNot(contains('จะ')));
    expect(moment, contains('หลายศาสตร์ไม่ได้สะท้อนว่าคุณต้องเป็นใคร'));
    expect(moment, FusionHumanMeaningCopy.knowMeMomentAutonomyBody);
  });

  test('presenter maps V3 insight copy to strengths and knowme moment', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    expect(vm.hero.supportingReflection, contains('หลายศาสตร์เห็นตรงกันว่า'));
    expect(vm.strengths, isNotEmpty);
    expect(
      vm.strengths.every((s) => s.description.contains('\n')),
      isTrue,
    );
    expect(
      vm.strengths.any(
        (s) =>
            s.title == 'การรับผิดชอบต่อทางเลือก' ||
            s.title == 'ความมั่นคงในการลงมือทำ',
      ),
      isTrue,
    );
    expect(vm.knowMeMoment.title, FusionResultV3InsightCopy.knowMeMomentTitle);
    expect(vm.knowMeMoment.body, isNotEmpty);
    expect(vm.knowMeMoment.body, contains('หลายศาสตร์เห็นตรงกันว่า'));
    expect(
      vm.surprisingInsight?.formattedBody,
      contains('พยายามเป็นคนที่ไม่ใช่ตัวเอง'),
    );
  });
}
