import '../../models/knowme_mirror_lineage_chain.dart';
import 'knowme_mirror_theme_signal.dart';

/// Read-only input bundle for [KnowMeMirrorEngine].
class KnowMeMirrorEngineInput {
  const KnowMeMirrorEngineInput({
    required this.lineage,
    required this.signals,
    required this.generatedAt,
  });

  final KnowMeMirrorLineageChain lineage;
  final List<KnowMeMirrorThemeSignal> signals;
  final DateTime generatedAt;
}
