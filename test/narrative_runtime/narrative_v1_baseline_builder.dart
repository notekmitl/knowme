import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import 'package:knowme/features/narrative_runtime/domain/narrative_evidence.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_lineage.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_paragraph.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_section.dart';
import 'package:knowme/features/narrative_runtime/engines/narrative_confidence_composer.dart';
import 'package:knowme/features/narrative_runtime/registry/narrative_mode_filter.dart';
import 'package:knowme/features/narrative_runtime/registry/narrative_pattern_copy.dart';

/// Frozen V1 paragraph builder — used only for before/after validation metrics.
abstract final class NarrativeV1BaselineBuilder {
  static const maxParagraphsPerMode = 3;

  static List<NarrativeSection> buildSections(HumanPatternSnapshot snapshot) {
    final evidenceByPattern = _groupEvidence(snapshot.evidence);
    final byMode = <NarrativeMode, List<PatternActivation>>{};

    for (final mode in NarrativeModeFilter.allModes()) {
      byMode[mode] = [];
    }

    for (final activation in snapshot.activations) {
      final mode = NarrativeModeFilter.primaryMode(
        patternFamilyId: activation.patternFamilyId,
        dimension: activation.dimension,
      );
      byMode[mode]!.add(activation);
    }

    final sections = <NarrativeSection>[];
    for (final mode in NarrativeModeFilter.allModes()) {
      final activations = byMode[mode]!
        ..sort(
          (a, b) => b.activationStrength.compareTo(a.activationStrength),
        );

      final paragraphs = <NarrativeParagraph>[];
      for (final activation in activations) {
        if (paragraphs.length >= maxParagraphsPerMode) break;
        final evidenceRows = evidenceByPattern[activation.patternId] ?? const [];
        if (evidenceRows.isEmpty) continue;
        paragraphs.add(
          _paragraph(
            snapshot: snapshot,
            activation: activation,
            mode: mode,
            evidenceRows: evidenceRows,
            index: paragraphs.length,
          ),
        );
      }

      sections.add(
        NarrativeSection(
          mode: mode,
          title: mode.sectionTitle,
          paragraphs: paragraphs,
          confidence: NarrativeConfidenceComposer.forSection(paragraphs),
        ),
      );
    }

    return sections;
  }

  static NarrativeParagraph _paragraph({
    required HumanPatternSnapshot snapshot,
    required PatternActivation activation,
    required NarrativeMode mode,
    required List<PatternEvidence> evidenceRows,
    required int index,
  }) {
    final paragraphId = 'nar_${mode.key}_${activation.patternId}_$index';
    final narrativeEvidence = evidenceRows
        .map(
          (row) => NarrativeEvidence(
            evidenceId: 'nar_ev_${paragraphId}_${row.activationId}',
            lineage: NarrativeLineage(
              narrativeParagraphId: paragraphId,
              patternId: activation.patternId,
              activationId: activation.activationId,
              humanModelPatternId: row.humanModelPatternId,
              humanModelSnapshotId: row.humanModelSnapshotId,
              fusionFindingId: row.fusionFindingId,
              mirrorFindingId: row.mirrorFindingId,
              mirrorSnapshotId: row.mirrorSnapshotId,
              mirrorRoleId: row.mirrorRoleId,
              sourceThemeId: row.sourceThemeId,
              themeIds: row.themeIds,
            ),
            mirrorKey: row.mirrorKey,
            systemId: row.systemId,
            weight: row.weight,
            signalIds: row.signalIds,
          ),
        )
        .toList(growable: false);

    return NarrativeParagraph(
      paragraphId: paragraphId,
      mode: mode,
      text: NarrativePatternCopy.paragraph(
        mode: mode,
        patternId: activation.patternId,
        patternLabel: activation.label,
      ),
      patternId: activation.patternId,
      patternLabel: activation.label,
      activationId: activation.activationId,
      activationStrength: activation.activationStrength,
      evidence: narrativeEvidence,
      confidence: NarrativeConfidenceComposer.forParagraph(
        activation: activation,
        evidenceRows: evidenceRows,
        snapshot: snapshot,
      ),
    );
  }

  static Map<String, List<PatternEvidence>> _groupEvidence(
    List<PatternEvidence> evidence,
  ) {
    final grouped = <String, List<PatternEvidence>>{};
    for (final row in evidence) {
      grouped.putIfAbsent(row.registryPatternId, () => []).add(row);
    }
    return grouped;
  }
}
