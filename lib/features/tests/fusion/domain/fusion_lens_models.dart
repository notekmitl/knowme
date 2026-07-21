import 'package:knowme/features/tests/mbti_summary/domain/mbti_summary_models.dart';

/// High-level lens kinds for Fusion v1.1 (no deep signals).
enum FusionLensKind {
  astrology,
  personality,
  eq,
}

/// One lens with coarse theme tags only.
class FusionLensSnapshot {
  const FusionLensSnapshot({
    required this.kind,
    required this.themes,
  });

  final FusionLensKind kind;

  /// Subset of [FusionLensThemeIds].
  final Set<String> themes;
}

/// Read-only high-level inputs for lens synthesis.
class FusionLensInput {
  const FusionLensInput({
    this.lenses = const [],
    this.mbtiAlignment,
  });

  final List<FusionLensSnapshot> lenses;
  final MbtiSummaryAlignment? mbtiAlignment;

  bool get canSynthesize => lenses.length >= 2;
}

/// Deterministic Fusion v1.1 output (single narrative sections).
class FusionLensContent {
  const FusionLensContent({
    required this.agreement,
    required this.tension,
    required this.synthesis,
    required this.disclosure,
  });

  final String agreement;
  final String tension;
  final String synthesis;
  final String disclosure;
}

/// Coarse cross-lens theme ids (high-level only).
abstract final class FusionLensThemeIds {
  static const reflection = 'reflection';
  static const relationship = 'relationship';
  static const logic = 'logic';
  static const emotion = 'emotion';
  static const exploration = 'exploration';

  static const all = <String>[
    reflection,
    relationship,
    logic,
    emotion,
    exploration,
  ];
}
