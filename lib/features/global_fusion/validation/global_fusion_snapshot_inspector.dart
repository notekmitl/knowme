import '../domain/global_confidence_band.dart';
import '../domain/global_fusion_snapshot.dart';
import '../domain/global_lens_id.dart';

/// Inspectable JSON/debug views for Global Fusion snapshots.
abstract final class GlobalFusionSnapshotInspector {
  static Map<String, dynamic> toJson(GlobalFusionSnapshot snapshot) {
    return {
      'version': snapshot.version,
      'generatedAt': snapshot.generatedAt.toIso8601String(),
      'coverage': {
        'astrology': {
          'available': snapshot.coverage.astrology.available,
          'completedLensCount': snapshot.coverage.astrology.completedLensCount,
          'totalLensCount': snapshot.coverage.astrology.totalLensCount,
          'completedLensIds': snapshot.coverage.astrology.completedLensIds,
        },
        'personality': {
          'available': snapshot.coverage.personality.available,
          'weightedCoverage': snapshot.coverage.personality.weightedCoverage,
          'availableLensIds': snapshot.coverage.personality.availableLensIds
              .map((id) => id.storageKey)
              .toList(),
        },
        'hasBothMirrors': snapshot.coverage.hasBothMirrors,
      },
      'confidence': {
        'formulaVersion': snapshot.confidence.formulaVersion,
        'composite': snapshot.confidence.composite,
        'band': snapshot.confidence.band.id,
        'coverageScore': snapshot.confidence.coverageScore,
        'coverageContribution': snapshot.confidence.coverageContribution,
        'agreementBonus': snapshot.confidence.agreementBonus,
        'tensionPenalty': snapshot.confidence.tensionPenalty,
      },
      'normalizedThemes': snapshot.normalizedThemes
          .map(
            (theme) => {
              'globalThemeId': theme.globalThemeId,
              'evidenceCount': theme.evidence.length,
              'mirrors': theme.evidence
                  .map((e) => e.sourceMirror.id)
                  .toSet()
                  .toList(),
            },
          )
          .toList(),
      'agreementCount': snapshot.agreements.length,
      'tensionCount': snapshot.tensions.length,
    };
  }

  static String toDebugReport(GlobalFusionSnapshot snapshot) {
    final buffer = StringBuffer()
      ..writeln('Global Fusion Snapshot (GF-F2)')
      ..writeln('version: ${snapshot.version}')
      ..writeln('generatedAt: ${snapshot.generatedAt.toIso8601String()}')
      ..writeln()
      ..writeln('Coverage')
      ..writeln(
        '  astrology: ${snapshot.coverage.astrology.available} '
        '(${snapshot.coverage.astrology.completedLensCount}/'
        '${snapshot.coverage.astrology.totalLensCount})',
      )
      ..writeln(
        '  personality: ${snapshot.coverage.personality.available} '
        '(weighted=${snapshot.coverage.personality.weightedCoverage})',
      )
      ..writeln('  both: ${snapshot.coverage.hasBothMirrors}')
      ..writeln()
      ..writeln('Normalized themes (${snapshot.normalizedThemes.length})');

    for (final theme in snapshot.normalizedThemes) {
      final mirrors = theme.evidence
          .map((e) => e.sourceMirror.id)
          .toSet()
          .join(', ');
      buffer.writeln(
        '  - ${theme.globalThemeId} '
        '[evidence=${theme.evidence.length}, mirrors=$mirrors]',
      );
    }

    buffer
      ..writeln()
      ..writeln('Confidence v1')
      ..writeln('  formula: ${snapshot.confidence.formulaVersion}')
      ..writeln('  composite: ${snapshot.confidence.composite}')
      ..writeln('  band: ${snapshot.confidence.band.id}')
      ..writeln('  coverageScore: ${snapshot.confidence.coverageScore}')
      ..writeln(
        '  coverageContribution: ${snapshot.confidence.coverageContribution}',
      )
      ..writeln('  agreementBonus: ${snapshot.confidence.agreementBonus}')
      ..writeln('  tensionPenalty: ${snapshot.confidence.tensionPenalty}')
      ..writeln('  agreements: ${snapshot.agreements.length}')
      ..writeln('  tensions: ${snapshot.tensions.length}');

    return buffer.toString();
  }
}
