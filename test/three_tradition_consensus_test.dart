import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

void main() {
  final thai = FusionAdapterHelpers.thaiLensId;
  final bazi = FusionAdapterHelpers.baziLensId;
  final western = FusionAdapterHelpers.westernLensId;

  LensThemeOutput output(String lens, String theme, {bool evidence = true}) {
    if (!evidence) {
      final meta = FusionThemeRegistry.getById(theme)!;
      return LensThemeOutput(lensId: lens, themeId: theme,
          category: meta.category, family: meta.family,
          confidence: 0.8, evidence: const []);
    }
    return FusionAdapterHelpers.buildRegistered(
        lensId: lens,
        themeId: theme,
        confidence: 0.8,
        evidence: ['$lens:$theme'],
      )!;
  }

  test('three identical themes form one exact agreement', () {
    final result = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'independent'),
      output(bazi, 'independent'),
      output(western, 'independent'),
    ]);
    expect(result.length, 1);
    expect(result.single.exact, isTrue);
    expect(result.single.sourceCount, 3);
    expect(result.single.sources.keys, [thai, bazi, western]);
    expect(result.single.sources[thai]!.evidence, ['$thai:independent']);
  });

  test('two exact and third similar become one three-lens agreement', () {
    final result = ThreeTraditionConsensus.fromOutputs([
      output(western, 'leadership'),
      output(bazi, 'independent'),
      output(thai, 'independent'),
    ]);
    expect(result.length, 1);
    expect(result.single.sourceCount, 3);
    expect(result.single.exact, isFalse);
    expect(result.single.sources[western]!.themeId, 'leadership');
  });

  test('one tradition, duplicate lens, and empty evidence never imply consensus', () {
    expect(ThreeTraditionConsensus.fromOutputs([
      output(thai, 'independent'),
      output(thai, 'driven'),
      output(bazi, 'independent', evidence: false),
      output('unrecognized', 'independent'),
    ]), isEmpty);
  });

  test('growth-area warning is not conflated with a positive reflection', () {
    expect(ThreeTraditionConsensus.fromOutputs([
      output(thai, 'overthinking'),
      output(bazi, 'analytical'),
      output(western, 'grounded'),
    ]), isEmpty);
    final exactWarning = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'overthinking'),
      output(bazi, 'overthinking'),
    ]);
    expect(exactWarning.single.key, 'overthinking');
    expect(exactWarning.single.sourceCount, 2);
  });
}
