import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';

import '../domain/models/astrology_fusion_real_input.dart';
import '../domain/models/source_lens_versions.dart';

/// Resolves deterministic source lens fingerprints for regeneration checks.
abstract final class SourceLensVersionResolver {
  static const String westernContractVersion = 'western_natal_v1';

  static SourceLensVersions fromInput(AstrologyFusionRealInput input) {
    return SourceLensVersions(
      westernVersion: westernVersion(input.western),
      baziVersion: baziVersion(input.bazi),
      thaiVersion: thaiVersion(input.thai),
    );
  }

  static String? westernVersion(AstrologyChartModel? western) {
    if (western == null) return null;

    final big3 = western.big3;
    final sun = big3['sun']?.toString() ?? '';
    final moon = big3['moon']?.toString() ?? '';
    final rising = big3['rising']?.toString() ?? '';
    return '$westernContractVersion|$sun|$moon|$rising';
  }

  static String? baziVersion(BaziChartModel? bazi) {
    if (bazi == null) return null;
    return '${bazi.version}|${bazi.engineVersion}|${bazi.dayMaster.stem}';
  }

  static String? thaiVersion(ThaiMirrorResult? thai) {
    if (thai == null) return null;

    final themeIds = thai.topThemes.map((theme) => theme.themeId).join(',');
    return '${thai.contractVersion}|$themeIds';
  }
}
