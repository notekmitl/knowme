import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';

import 'global_confidence_band.dart';

/// Deterministic human-meaning reflection block (GF-F3 — no AI).
class GlobalReflectionUnit {
  const GlobalReflectionUnit({
    required this.category,
    required this.themeId,
    required this.reflection,
    required this.evidenceSummary,
    required this.confidenceBand,
  });

  final FusionCategory category;
  final String themeId;
  final String reflection;
  final String evidenceSummary;
  final GlobalConfidenceBand confidenceBand;
}

/// Internal classification for narrative composition (not user-facing label).
enum GlobalReflectionKind {
  theme,
  agreement,
  tension,
}
