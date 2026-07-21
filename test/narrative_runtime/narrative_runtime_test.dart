import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/integration/home_narrative_mapper.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_pattern_snapshot_resolver.dart';
import 'package:knowme/features/narrative_runtime/integration/profile_narrative_mapper.dart';
import 'package:knowme/features/narrative_runtime/narrative_runtime_domain.dart';

void main() {
  group('NR1 Narrative Runtime Service', () {
    late HumanPatternSnapshot snapshot;
    late NarrativeResult result;

    setUpAll(() {
      snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      result = NarrativeRuntimeService.generate(
        patternSnapshot: snapshot,
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );
    });

    test('generates four narrative mode sections', () {
      expect(result.sections.length, 4);
      expect(
        result.sections.map((section) => section.mode).toSet(),
        equals(NarrativeMode.values.toSet()),
      );
    });

    test('paragraphs derive from activated patterns only', () {
      expect(result.paragraphCount, greaterThan(0));
      for (final section in result.sections) {
        for (final paragraph in section.paragraphs) {
          expect(
            snapshot.activations.any(
              (activation) => activation.patternId == paragraph.patternId,
            ),
            isTrue,
          );
        }
      }
    });

    test('is deterministic for fixed snapshot and createdAt', () {
      final a = NarrativeRuntimeService.generate(
        patternSnapshot: snapshot,
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );
      final b = NarrativeRuntimeService.generate(
        patternSnapshot: snapshot,
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );

      expect(a.sourceSnapshotId, b.sourceSnapshotId);
      expect(a.paragraphCount, b.paragraphCount);
      expect(
        a.sections.first.paragraphs.first.text,
        b.sections.first.paragraphs.first.text,
      );
    });
  });

  group('NR2 Narrative Evidence and Lineage', () {
    test('every paragraph retains full traceability chain', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(patternSnapshot: snapshot);
      expect(result.paragraphCount, greaterThan(0));

      for (final section in result.sections) {
        for (final paragraph in section.paragraphs) {
          expect(paragraph.evidence, isNotEmpty);
          for (final evidence in paragraph.evidence) {
            final lineage = evidence.lineage;
            expect(lineage.narrativeParagraphId, paragraph.paragraphId);
            expect(lineage.patternId, paragraph.patternId);
            expect(lineage.activationId, paragraph.activationId);
            expect(lineage.humanModelPatternId, isNotEmpty);
            expect(lineage.humanModelSnapshotId, isNotEmpty);
            expect(lineage.fusionFindingId, isNotEmpty);
            expect(lineage.mirrorFindingId, isNotEmpty);
            expect(lineage.mirrorSnapshotId, isNotEmpty);
            expect(lineage.mirrorRoleId, isNotEmpty);
            expect(lineage.sourceThemeId, isNotEmpty);
          }
        }
      }
    });
  });

  group('NR3 Narrative Confidence', () {
    test('confidence is layered not pattern passthrough', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(patternSnapshot: snapshot);

      expect(result.confidence.composite, inInclusiveRange(0.0, 1.0));
      expect(result.confidence.evidenceDepthScore, inInclusiveRange(0.0, 1.0));
      expect(result.confidence.coverageScore, inInclusiveRange(0.0, 1.0));

      if (result.paragraphCount > 0) {
        final paragraph = result.sections
            .expand((section) => section.paragraphs)
            .first;
        expect(paragraph.confidence.composite, inInclusiveRange(0.0, 1.0));
        expect(paragraph.confidence.band, isIn(['high', 'medium', 'low']));
      }
    });
  });

  group('NR4 Narrative Validation', () {
    test('passes validation for recovery snapshot', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(patternSnapshot: snapshot);
      final report = NarrativeValidation.validate(
        sourceSnapshot: snapshot,
        result: result,
      );

      expect(report.passed, isTrue, reason: report.issues.join('; '));
      expect(report.evidenceAnchoredCount, report.paragraphCount);
    });
  });

  group('NR5 Recovery Runtime Integration', () {
    test('resolver produces narrative from simulated pattern snapshot', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(
        patternSnapshot: snapshot,
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );

      expect(snapshot.activations.length, greaterThan(0));
      expect(result.paragraphCount, greaterThan(0));

      final validation = NarrativeValidation.validate(
        sourceSnapshot: snapshot,
        result: result,
      );
      expect(validation.passed, isTrue, reason: validation.issues.join('; '));
    });
  });

  group('NR6 Surface Integration Mappers', () {
    test('home mapper produces hero and insight overlay', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(patternSnapshot: snapshot);
      final overlay = HomeNarrativeMapper.overlay(result);

      expect(overlay, isNotNull);
      expect(overlay!.heroIdentity.trim(), isNotEmpty);
      expect(overlay.signatureLabels, isNotEmpty);
      expect(overlay.insightCards, isNotEmpty);
    });

    test('profile mapper exposes all narrative modes', () {
      final snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = NarrativeRuntimeService.generate(patternSnapshot: snapshot);
      final profile = ProfileNarrativeMapper.fromResult(result);

      expect(profile.isAvailable, isTrue);
      expect(profile.sourceSnapshotId, result.sourceSnapshotId);
      expect(
        profile.identityParagraphs.length +
            profile.relationshipParagraphs.length +
            profile.decisionParagraphs.length +
            profile.growthParagraphs.length,
        greaterThan(0),
      );
    });
  });
}
