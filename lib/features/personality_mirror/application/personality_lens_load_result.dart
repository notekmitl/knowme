import '../domain/personality_coverage.dart';
import '../domain/personality_lens_id.dart';
import '../domain/personality_lens_snapshot.dart';

/// Read-only loader output — per-lens snapshots only (no mirror build in PF-2).
class PersonalityLensLoadResult {
  const PersonalityLensLoadResult({
    required this.snapshots,
    required this.coverage,
  });

  final Map<PersonalityLensId, PersonalityLensSnapshot> snapshots;
  final PersonalityCoverage coverage;

  List<PersonalityLensSnapshot> get availableSnapshots => snapshots.values
      .where((snapshot) => snapshot.available)
      .toList(growable: false);

  PersonalityLensSnapshot? snapshotFor(PersonalityLensId lensId) =>
      snapshots[lensId];
}
