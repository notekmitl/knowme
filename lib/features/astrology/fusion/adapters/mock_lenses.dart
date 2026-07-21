import '../domain/entities/astrology_lens.dart';
import '../registry/theme_registry.dart';
import 'lens_theme_output.dart';

LensThemeOutput _mockOutput({
  required String lensId,
  required String themeId,
  required List<String> evidence,
  double confidence = 0.75,
}) {
  final theme = FusionThemeRegistry.getById(themeId);
  if (theme == null) {
    throw ArgumentError('Unknown theme id for mock lens: $themeId');
  }

  return LensThemeOutput(
    lensId: lensId,
    themeId: theme.id,
    category: theme.category,
    family: theme.family,
    confidence: confidence,
    evidence: evidence,
  );
}

/// Mock Western Natal lens themes (AF-01 — no real engine).
List<LensThemeOutput> westernMock() {
  final lensId = AstrologyLens.westernNatal.lensId;
  return [
    _mockOutput(
      lensId: lensId,
      themeId: 'independent',
      evidence: const ['sun_sign', 'rising_sign'],
      confidence: 0.8,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'structured',
      evidence: const ['saturn_placement'],
      confidence: 0.7,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'leadership',
      evidence: const ['mars_placement'],
      confidence: 0.72,
    ),
  ];
}

/// Mock Chinese BaZi lens themes (AF-01 — no real engine).
List<LensThemeOutput> baziMock() {
  final lensId = AstrologyLens.chineseBazi.lensId;
  return [
    _mockOutput(
      lensId: lensId,
      themeId: 'responsible',
      evidence: const ['day_master'],
      confidence: 0.82,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'reliable',
      evidence: const ['element_balance'],
      confidence: 0.78,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'growth_focused',
      evidence: const ['dominant_element'],
      confidence: 0.74,
    ),
  ];
}

/// Mock Thai Astrology lens themes (AF-01 — no real engine).
List<LensThemeOutput> thaiMock() {
  final lensId = AstrologyLens.thaiAstrology.lensId;
  return [
    _mockOutput(
      lensId: lensId,
      themeId: 'supportive',
      evidence: const ['lagna_lord'],
      confidence: 0.76,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'persistent',
      evidence: const ['mahabhuta'],
      confidence: 0.8,
    ),
    _mockOutput(
      lensId: lensId,
      themeId: 'adaptable',
      evidence: const ['myanmar_seven'],
      confidence: 0.77,
    ),
  ];
}

/// Convenience helper for AF-01 integration smoke tests.
List<LensThemeOutput> allMockLenses() {
  return [
    ...westernMock(),
    ...baziMock(),
    ...thaiMock(),
  ];
}
