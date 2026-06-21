import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';

import '../constants/narrative_runtime_version.dart';
import '../domain/narrative_result.dart';
import '../engines/narrative_confidence_composer.dart';
import '../engines/narrative_paragraph_builder.dart';

/// Production narrative runtime — consumes [HumanPatternSnapshot] only.
abstract final class NarrativeRuntimeService {
  static NarrativeResult generate({
    required HumanPatternSnapshot patternSnapshot,
    DateTime? createdAt,
  }) {
    final now = (createdAt ?? DateTime.now()).toUtc();
    final sections = NarrativeParagraphBuilder.buildSections(patternSnapshot);

    final confidenceInputs = sections
        .map(
          (section) => NarrativeSectionConfidenceInput(
            paragraphCount: section.paragraphs.length,
            confidence: section.confidence,
          ),
        )
        .toList(growable: false);

    return NarrativeResult(
      sourceSnapshotId: patternSnapshot.snapshotId,
      sourceStructuralHash: patternSnapshot.structuralHash,
      sections: sections,
      confidence: NarrativeConfidenceComposer.forResult(confidenceInputs),
      runtimeVersion: NarrativeRuntimeVersion.version,
      createdAt: now,
    );
  }
}
