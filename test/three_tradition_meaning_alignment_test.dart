import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_meaning_alignment.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

void main() {
  final thai = AstrologyLens.thaiAstrology.lensId;
  final chinese = AstrologyLens.chineseBazi.lensId;
  final western = AstrologyLens.westernNatal.lensId;

  test('three matching supported meanings produce one reading', () {
    final result = ThreeTraditionMeaningAlignment.select(
      ThreeTraditionConsensus.analyzeOutputs([
        _source(thai, 'independent'),
        _source(chinese, 'independent'),
        _source(western, 'independent'),
      ]),
    );
    expect(result?.title, 'ทิศทางและการตัดสินใจ');
    expect(result?.relation, ThirdMeaningRelation.same);
    expect(result?.sources.length, 3);
  });

  test(
    'two matching and one reviewed near meaning make one qualified reading',
    () {
      final result = ThreeTraditionMeaningAlignment.select(
        ThreeTraditionConsensus.analyzeOutputs([
          _source(thai, 'independent'),
          _source(chinese, 'independent'),
          _source(western, 'leadership'),
        ]),
      );
      expect(result?.relation, ThirdMeaningRelation.near);
      expect(result?.reading, contains('การอ่านประกอบกัน'));
      expect(
        result?.reading,
        contains('ไม่ใช่คำยืนยันว่าทั้งสามศาสตร์กล่าวตรงกัน'),
      );
      expect(result?.sources[western]?.themeId, 'leadership');
    },
  );

  test('clearly opposed meanings suppress a combined prediction', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      _source(thai, 'expressive'),
      _source(chinese, 'expressive'),
      _source(western, 'reserved'),
    ]);
    expect(
      ThreeTraditionMeaningAlignment.relation('expressive', 'reserved'),
      ThirdMeaningRelation.conflict,
    );
    expect(ThreeTraditionMeaningAlignment.select(reading), isNull);
  });

  test('matching evidence cannot override a supported conflict in one lens', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      _source(thai, 'expressive'),
      _source(chinese, 'expressive'),
      _source(western, 'expressive'),
      _source(western, 'reserved'),
    ]);
    expect(ThreeTraditionMeaningAlignment.select(reading), isNull);
  });

  test('missing or below-threshold third evidence cannot fill the gap', () {
    for (final third in <LensThemeOutput?>[
      null,
      _source(western, 'leadership', confidence: 0.59),
      _source(western, 'leadership', evidence: const []),
      _source(western, 'structured'),
    ]) {
      final reading = ThreeTraditionConsensus.analyzeOutputs([
        _source(thai, 'independent'),
        _source(chinese, 'independent'),
        ?third,
      ]);
      expect(ThreeTraditionMeaningAlignment.select(reading), isNull);
    }
    expect(ThreeTraditionConsensus.minimumAgreementConfidence, 0.6);
  });
}

LensThemeOutput _source(
  String lens,
  String theme, {
  double confidence = 0.6,
  List<String> evidence = const ['calculated fixture fact'],
}) {
  final registered = FusionThemeRegistry.getById(theme)!;
  return LensThemeOutput(
    lensId: lens,
    themeId: theme,
    category: registered.category,
    family: registered.family,
    confidence: confidence,
    evidence: evidence,
  );
}
