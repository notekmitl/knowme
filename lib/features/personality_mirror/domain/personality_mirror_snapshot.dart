import 'personality_agreement.dart';
import 'personality_confidence.dart';
import 'personality_coverage.dart';
import 'personality_lens_snapshot.dart';
import 'personality_tension.dart';

/// Full mirror output contract (PF-3 builder — not produced in PF-2).
class PersonalityMirrorSnapshot {
  const PersonalityMirrorSnapshot({
    required this.version,
    required this.lensSnapshots,
    required this.agreements,
    required this.tensions,
    required this.compositeConfidence,
    required this.coverage,
  });

  static const String versionId = 'personality_mirror.v1';

  final String version;
  final List<PersonalityLensSnapshot> lensSnapshots;
  final List<PersonalityAgreement> agreements;
  final List<PersonalityTension> tensions;
  final PersonalityConfidence compositeConfidence;
  final PersonalityCoverage coverage;
}
