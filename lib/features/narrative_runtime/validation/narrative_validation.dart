import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';

import '../domain/narrative_result.dart';

class NarrativeValidationReport {
  const NarrativeValidationReport({
    required this.passed,
    required this.issues,
    required this.paragraphCount,
    required this.evidenceAnchoredCount,
    required this.lineageCompleteCount,
  });

  final bool passed;
  final List<String> issues;
  final int paragraphCount;
  final int evidenceAnchoredCount;
  final int lineageCompleteCount;
}

/// Validates narrative runtime output integrity.
abstract final class NarrativeValidation {
  static NarrativeValidationReport validate({
    required HumanPatternSnapshot sourceSnapshot,
    required NarrativeResult result,
  }) {
    final issues = <String>[];
    var evidenceAnchored = 0;
    var lineageComplete = 0;

    if (result.sourceSnapshotId != sourceSnapshot.snapshotId) {
      issues.add('source snapshot id mismatch');
    }
    if (result.sourceStructuralHash != sourceSnapshot.structuralHash) {
      issues.add('source structural hash mismatch');
    }
    if (result.sections.length != 4) {
      issues.add('expected four narrative mode sections');
    }

    final paragraphIds = <String>{};
    for (final section in result.sections) {
      for (final paragraph in section.paragraphs) {
        if (!paragraphIds.add(paragraph.paragraphId)) {
          issues.add('duplicate paragraph id: ${paragraph.paragraphId}');
        }

        if (paragraph.text.trim().isEmpty) {
          issues.add('empty paragraph text: ${paragraph.paragraphId}');
        }

        if (paragraph.confidence.composite < 0 ||
            paragraph.confidence.composite > 1) {
          issues.add('invalid paragraph confidence: ${paragraph.paragraphId}');
        }

        final activationExists = sourceSnapshot.activations.any(
          (item) => item.activationId == paragraph.activationId,
        );
        if (!activationExists) {
          issues.add('orphan activation: ${paragraph.activationId}');
        }

        if (paragraph.evidence.isEmpty) {
          issues.add('paragraph without evidence: ${paragraph.paragraphId}');
          continue;
        }

        evidenceAnchored++;

        for (final evidence in paragraph.evidence) {
          final lineage = evidence.lineage;
          if (!_lineageComplete(lineage)) {
            issues.add('incomplete lineage: ${paragraph.paragraphId}');
            continue;
          }
          if (lineage.narrativeParagraphId != paragraph.paragraphId) {
            issues.add('lineage paragraph mismatch: ${paragraph.paragraphId}');
          }
          if (lineage.patternId != paragraph.patternId) {
            issues.add('lineage pattern mismatch: ${paragraph.paragraphId}');
          }
          lineageComplete++;
        }
      }
    }

    if (result.confidence.composite < 0 || result.confidence.composite > 1) {
      issues.add('invalid result confidence');
    }

    return NarrativeValidationReport(
      passed: issues.isEmpty,
      issues: issues,
      paragraphCount: result.paragraphCount,
      evidenceAnchoredCount: evidenceAnchored,
      lineageCompleteCount: lineageComplete,
    );
  }

  static bool _lineageComplete(dynamic lineage) {
    return lineage.narrativeParagraphId.isNotEmpty &&
        lineage.patternId.isNotEmpty &&
        lineage.activationId.isNotEmpty &&
        lineage.humanModelPatternId.isNotEmpty &&
        lineage.humanModelSnapshotId.isNotEmpty &&
        lineage.fusionFindingId.isNotEmpty &&
        lineage.mirrorFindingId.isNotEmpty &&
        lineage.mirrorSnapshotId.isNotEmpty &&
        lineage.mirrorRoleId.isNotEmpty &&
        lineage.sourceThemeId.isNotEmpty;
  }
}
