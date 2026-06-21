import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_direction_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_final_message_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_life_chapter_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_life_test_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_presenter.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v6_copy.dart';

void main() {
  test('life chapter builder produces symbolic chapter narrative', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final chapter = FusionLifeChapterBuilder.build(
      result,
      centralThemeLabel: 'ความเป็นอิสระ',
      alignedLensCount: 3,
    );

    expect(chapter, isNotNull);
    expect(chapter!.chapterTitle, isNotEmpty);
    expect(chapter.chapterNarrative, contains('ช่วงนี้ของชีวิต'));
    expect(chapter.chapterNarrative, contains('บทเรียนสำคัญ'));
    expect(chapter.chapterNarrative, isNot(contains('แน่นอน')));
  });

  test('life test builder uses challenge tone not warning report', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final test = FusionLifeTestBuilder.build(result);

    expect(test, isNotNull);
    expect(test!.body, contains('ชีวิตอาจทดสอบคุณ'));
    expect(test.body, contains('โจทย์ลักษณะนี้อาจกลับมา'));
    expect(test.body, isNot(contains('จุดที่ควรระวัง')));
    expect(test.body, isNot(contains('อ่อนแอ')));
  });

  test('direction builder uses soft future language', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final direction = FusionDirectionBuilder.build(result);

    expect(direction, isNotNull);
    final combined =
        '${direction!.directionA}${direction.directionB}${direction.reflectionQuestion}';
    expect(combined, anyOf(contains('อาจ'), contains('มีแนวโน้ม'), contains('ค่อย ๆ')));
    expect(combined, isNot(contains('แน่นอน')));
    expect(combined, isNot(contains('ดวงชะตากำหนด')));
  });

  test('final message builder returns short memorable message', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final message = FusionFinalMessageBuilder.build(result);

    expect(message, isNotNull);
    expect(message!.message.split('\n').length, lessThanOrEqualTo(5));
    expect(message.message, isNotEmpty);
  });

  test('presenter maps V6 life map layers', () {
    final result = AstrologyFusionGenerator.generate(allMockLenses());
    final vm = FusionResultPresenter.fromResult(result);

    expect(vm.lifeChapter, isNotNull);
    expect(vm.lifeChapter!.title, FusionResultV6Copy.lifeChapterTitle);
    expect(vm.lifeTest, isNotNull);
    expect(vm.lifeTest!.title, FusionResultV6Copy.lifeTestTitle);
    expect(vm.futureDirection, isNotNull);
    expect(vm.futureDirection!.title, FusionResultV6Copy.directionTitle);
    expect(vm.finalMessage, isNotNull);
    expect(vm.finalMessage!.title, FusionResultV6Copy.finalMessageTitle);
  });
}
