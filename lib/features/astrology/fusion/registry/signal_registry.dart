import '../domain/entities/fusion_signal.dart';

/// Maps canonical theme ids to user-facing [FusionSignalType] values.
abstract final class FusionSignalRegistry {
  static const Map<String, FusionSignalType> themeToSignal = {
    // Autonomy
    'independent': FusionSignalType.autonomy,
    'leadership': FusionSignalType.autonomy,
    'driven': FusionSignalType.autonomy,

    // Structure
    'structured': FusionSignalType.structure,
    'responsible': FusionSignalType.structure,
    'reliable': FusionSignalType.structure,
    'persistent': FusionSignalType.structure,

    // Growth
    'growth_focused': FusionSignalType.growth,
    'adaptable': FusionSignalType.growth,
    'openness': FusionSignalType.growth,

    // Connection
    'supportive': FusionSignalType.connection,
    'diplomatic': FusionSignalType.connection,
    'loyal': FusionSignalType.connection,
    'independent_connection': FusionSignalType.connection,

    // Expression
    'expressive': FusionSignalType.expression,
    'responsive': FusionSignalType.expression,
    'passionate': FusionSignalType.expression,

    // Reflection
    'analytical': FusionSignalType.reflection,
    'reflection': FusionSignalType.reflection,
    'overthinking': FusionSignalType.reflection,

    // Creativity
    'creative': FusionSignalType.creativity,

    // Adaptation (flexible thinking — distinct from growth cluster)
    'flexible': FusionSignalType.adaptation,
  };

  static FusionSignalType? signalForTheme(String themeId) {
    return themeToSignal[themeId.trim().toLowerCase()];
  }

  static List<String> themesForSignal(FusionSignalType type) {
    return themeToSignal.entries
        .where((entry) => entry.value == type)
        .map((entry) => entry.key)
        .toList();
  }

  static bool mapsToSignal(String themeId) =>
      signalForTheme(themeId) != null;
}
