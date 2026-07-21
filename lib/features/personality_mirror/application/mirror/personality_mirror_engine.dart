import '../../domain/personality_lens_id.dart';
import '../../domain/personality_lens_snapshot.dart';
import '../../domain/personality_mirror_snapshot.dart';
import '../personality_lens_load_result.dart';
import 'personality_agreement_engine.dart';
import 'personality_confidence_composer.dart';
import 'personality_mirror_theme_signal.dart';
import 'personality_tension_engine.dart';

/// Builds [PersonalityMirrorSnapshot] from PF-2 loader output.
abstract final class PersonalityMirrorEngine {
  static PersonalityMirrorSnapshot build(PersonalityLensLoadResult load) {
    final signals = PersonalityMirrorThemeSignalExtractor.extract(load);
    final agreements = PersonalityAgreementEngine.detect(signals);
    final tensions = PersonalityTensionEngine.detect(signals);
    final compositeConfidence = PersonalityConfidenceComposer.compose(
      load: load,
      agreements: agreements,
      tensions: tensions,
    );

    final lensSnapshots = PersonalityLensId.all
        .map((id) => load.snapshots[id])
        .whereType<PersonalityLensSnapshot>()
        .toList(growable: false);

    return PersonalityMirrorSnapshot(
      version: PersonalityMirrorSnapshot.versionId,
      lensSnapshots: lensSnapshots,
      agreements: agreements,
      tensions: tensions,
      compositeConfidence: compositeConfidence,
      coverage: load.coverage,
    );
  }
}
