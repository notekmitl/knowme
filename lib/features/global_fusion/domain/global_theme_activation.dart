import 'global_evidence.dart';

/// Normalized theme activation in global theme space (GF-F0).
class GlobalThemeActivation {
  const GlobalThemeActivation({
    required this.globalThemeId,
    required this.evidence,
  });

  final String globalThemeId;
  final List<GlobalEvidence> evidence;
}
