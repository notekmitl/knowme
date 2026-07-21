import 'personality_confidence.dart';
import 'personality_lens_evidence.dart';
import 'personality_lens_id.dart';
import 'personality_lens_theme_output.dart';

/// Adapter output for a single personality lens (PF-2 deliverable).
class PersonalityLensSnapshot {
  const PersonalityLensSnapshot({
    required this.lensId,
    required this.themes,
    required this.lensConfidence,
    required this.sourceVersion,
    required this.available,
  });

  final PersonalityLensId lensId;
  final List<PersonalityLensThemeOutput> themes;
  final PersonalityConfidence lensConfidence;
  final PersonalitySourceVersionMeta sourceVersion;
  final bool available;

  factory PersonalityLensSnapshot.unavailable(PersonalityLensId lensId) {
    return PersonalityLensSnapshot(
      lensId: lensId,
      themes: const [],
      lensConfidence: 0,
      sourceVersion: const PersonalitySourceVersionMeta(
        scoredQuestionCount: 0,
        scoringVersion: 0,
      ),
      available: false,
    );
  }
}
