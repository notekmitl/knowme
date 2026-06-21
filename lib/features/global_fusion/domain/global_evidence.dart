import 'global_lens_id.dart';

/// Traceable evidence pointing only to mirror outputs — never raw systems.
class GlobalEvidence {
  const GlobalEvidence({
    required this.sourceMirror,
    required this.sourceThemeId,
    required this.referenceKind,
    required this.referenceId,
    this.weight = 1.0,
  });

  /// Which mirror produced this evidence.
  final GlobalLensId sourceMirror;

  /// Theme id as emitted by the source mirror (not a raw system field).
  final String sourceThemeId;

  /// Kind of mirror artifact (e.g. signal, agreement, lens_theme).
  final String referenceKind;

  /// Identifier within the mirror artifact (signal type, theme id, etc.).
  final String referenceId;

  final double weight;
}
