import 'fusion_support_level.dart';

/// User-facing fusion intelligence signal types.
enum FusionSignalType {
  autonomy,
  structure,
  growth,
  connection,
  adaptation,
  expression,
  reflection,
  leadership,
  creativity,
  transformation,
}

/// Aggregated cross-lens signal for reflection and tendencies.
class FusionSignal {
  const FusionSignal({
    required this.type,
    required this.sourceThemes,
    required this.supportingLenses,
    required this.supportLevel,
  });

  final FusionSignalType type;
  final List<String> sourceThemes;
  final List<String> supportingLenses;
  final FusionSupportLevel supportLevel;
}
