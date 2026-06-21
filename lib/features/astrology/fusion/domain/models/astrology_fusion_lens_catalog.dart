import '../entities/astrology_lens.dart';

/// Registered astrology fusion lenses — extensible for future N-lens support.
class AstrologyFusionLensDefinition {
  const AstrologyFusionLensDefinition({
    required this.lensId,
    required this.title,
  });

  final String lensId;
  final String title;
}

abstract final class AstrologyFusionLensCatalog {
  static const List<AstrologyFusionLensDefinition> lenses = [
    AstrologyFusionLensDefinition(
      lensId: 'western_natal',
      title: 'Western Natal',
    ),
    AstrologyFusionLensDefinition(
      lensId: 'chinese_bazi',
      title: 'Chinese BaZi',
    ),
    AstrologyFusionLensDefinition(
      lensId: 'thai_astrology',
      title: 'Thai Astrology',
    ),
  ];

  static int get totalLensCount => lenses.length;

  static List<String> get lensIds =>
      lenses.map((lens) => lens.lensId).toList(growable: false);
}
