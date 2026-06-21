import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_consensus_narrative_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_contradiction_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_life_lesson_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_life_pattern_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_wisdom_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v5_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v6_copy.dart';

void main() {
  test('life pattern builder produces recurring questions not traits', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final pattern = FusionLifePatternBuilder.build(result);

    expect(pattern, isNotNull);
    expect(pattern!.formattedBody, contains('คำถามเดิม'));
    expect(pattern.recurringQuestions, isNotEmpty);
    expect(pattern.formattedBody, isNot(contains('บุคลิก')));
  });

  test('life lesson builder uses symbolic teaching language', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final lesson = FusionLifeLessonBuilder.build(result);

    expect(lesson, isNotNull);
    expect(lesson!.body, contains('ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า'));
  });

  test('consensus narrative explains why lenses agree', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final narrative = FusionConsensusNarrativeBuilder.build(
      result,
      centralThemeLabel: 'ความเป็นอิสระ',
    );

    expect(narrative, isNotNull);
    expect(narrative!.lensNarratives.length, greaterThanOrEqualTo(2));
    expect(narrative.themeConclusion, contains('Theme กลาง'));
  });

  test('wisdom builder adds resolution to contradiction', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final contradiction = FusionContradictionBuilder.build(result);
    final wisdom = FusionWisdomBuilder.build(contradiction);

    expect(contradiction, isNotNull);
    expect(wisdom, isNotNull);
    expect(
      contradiction!.formattedWithWisdom(wisdom),
      contains('อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง'),
    );
  });

  test('presenter maps V5 pattern and destiny layers', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    expect(vm.lifePattern, isNotNull);
    expect(vm.lifePattern!.title, FusionResultV5Copy.lifePatternTitle);
    expect(vm.lifeLesson, isNotNull);
    expect(vm.lifeLesson!.title, FusionResultV5Copy.lifeLessonTitle);
    expect(vm.consensusNarrative, isNotNull);
    expect(
      vm.futureDirection!.title,
      FusionResultV6Copy.directionTitle,
    );
    expect(
      vm.knowMeMoment.body,
      contains('อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง'),
    );
  });
}
