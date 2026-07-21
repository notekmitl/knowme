import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_evidence.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

import 'adapter_helpers.dart';
import 'lens_theme_output.dart';
import '../registry/theme_registry.dart';

/// Maps Thai Mirror V1 output → [LensThemeOutput] without rewriting mirror logic.
abstract final class ThaiRealAdapter {
  static List<LensThemeOutput> adapt(ThaiMirrorResult mirror) {
    final outputs = <LensThemeOutput>[];
    final seenThemes = <String>{};

    for (final themeRef in mirror.topThemes) {
      final themeId = themeRef.themeId.trim().toLowerCase();
      if (!FusionThemeRegistry.contains(themeId)) continue;
      if (!seenThemes.add(themeId)) continue;

      final evidence = _evidenceForTheme(mirror, themeId);
      if (evidence.isEmpty) continue;

      final output = FusionAdapterHelpers.buildRegistered(
        lensId: FusionAdapterHelpers.thaiLensId,
        themeId: themeId,
        confidence: _confidenceValue(themeRef.confidence),
        evidence: evidence,
      );
      if (output != null) outputs.add(output);
    }

    return FusionAdapterHelpers.dedupeByTheme(outputs);
  }

  static List<String> _evidenceForTheme(
    ThaiMirrorResult mirror,
    String themeId,
  ) {
    final evidence = <String>[];
    final seen = <String>{};

    void add(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty || !seen.add(normalized)) return;
      evidence.add(normalized);
    }

    for (final section in mirror.sections) {
      _collectSectionEvidence(
        section: section,
        themeId: themeId,
        add: add,
      );
    }

    return evidence;
  }

  static void _collectSectionEvidence({
    required ThaiMirrorSection section,
    required String themeId,
    required void Function(String value) add,
  }) {
    final themeInSection = section.supportingThemes.any(
      (theme) => theme.themeId.trim().toLowerCase() == themeId,
    );
    if (!themeInSection) return;

    for (final row in section.evidence) {
      if (!_supportsTheme(row, themeId)) continue;
      add(_formatEvidence(row));
    }
  }

  static bool _supportsTheme(ThaiMirrorEvidence row, String themeId) {
    if (row.supportedThemeIds.isEmpty) return true;
    return row.supportedThemeIds
        .map((id) => id.trim().toLowerCase())
        .contains(themeId);
  }

  static String _formatEvidence(ThaiMirrorEvidence row) {
    return '${row.lensSource.labelEn}: ${row.contentKey}';
  }

  static double _confidenceValue(ThaiThemeConfidenceLevel level) {
    return switch (level) {
      ThaiThemeConfidenceLevel.low => 0.55,
      ThaiThemeConfidenceLevel.medium => 0.75,
      ThaiThemeConfidenceLevel.high => 0.9,
    };
  }
}
