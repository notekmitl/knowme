import '../domain/personality_agreement.dart';
import '../domain/personality_confidence_breakdown.dart';
import '../domain/personality_coverage.dart';
import '../domain/personality_mirror_snapshot.dart';
import '../domain/personality_tension.dart';

/// Debug-friendly inspection of [PersonalityMirrorSnapshot] output.
abstract final class PersonalityMirrorSnapshotInspector {
  static Map<String, dynamic> toJson({
    required PersonalityMirrorSnapshot mirror,
    required PersonalityConfidenceBreakdown confidence,
  }) {
    return {
      'version': mirror.version,
      'compositeConfidence': mirror.compositeConfidence,
      'compositeBand': confidence.compositeBand,
      'confidence': confidence.toJson(),
      'coverage': _coverageJson(mirror.coverage),
      'availableLenses': mirror.lensSnapshots
          .where((s) => s.available)
          .map((s) => s.lensId.storageKey)
          .toList(),
      'themeCounts': {
        for (final snapshot in mirror.lensSnapshots.where((s) => s.available))
          snapshot.lensId.storageKey: snapshot.themes.length,
      },
      'agreements': mirror.agreements.map(_agreementJson).toList(),
      'tensions': mirror.tensions.map(_tensionJson).toList(),
    };
  }

  static String toDebugReport({
    required PersonalityMirrorSnapshot mirror,
    required PersonalityConfidenceBreakdown confidence,
  }) {
    final buffer = StringBuffer()
      ..writeln('=== Personality Mirror Snapshot ===')
      ..writeln('version: ${mirror.version}')
      ..writeln(
        'composite: ${mirror.compositeConfidence.toStringAsFixed(3)} '
        '(${confidence.compositeBand})',
      )
      ..writeln('--- Confidence ---')
      ..writeln('baseLensMean: ${confidence.baseLensMean.toStringAsFixed(3)}')
      ..writeln('coverageFactor: ${confidence.coverageFactor.toStringAsFixed(3)}')
      ..writeln(
        'coverageAdjustedBase: '
        '${confidence.coverageAdjustedBase.toStringAsFixed(3)}',
      )
      ..writeln('agreementBoost: ${confidence.agreementBoost.toStringAsFixed(3)}')
      ..writeln(
        'contradictionPenalty: '
        '${confidence.contradictionPenalty.toStringAsFixed(3)}',
      )
      ..writeln('--- Coverage ---')
      ..writeln(
        'weighted: ${mirror.coverage.weightedCoverage.toStringAsFixed(3)}',
      )
      ..writeln('hasMbti: ${mirror.coverage.hasMbti}')
      ..writeln('hasBigFive: ${mirror.coverage.hasBigFive}')
      ..writeln('eqModules: ${mirror.coverage.eqModulesCompleted}/'
          '${mirror.coverage.eqModulesExpected}')
      ..writeln('available: ${mirror.coverage.availableLensIds.map((l) => l.storageKey).join(', ')}')
      ..writeln('--- Agreements (${mirror.agreements.length}) ---');

    for (final agreement in mirror.agreements) {
      buffer.writeln(
        '  [${agreement.kind.name}] ${agreement.themeId} '
        'lenses=${agreement.supportingAgreementLenses.map((l) => l.storageKey).join('+')} '
        'conf=${agreement.confidence.toStringAsFixed(2)}',
      );
    }

    buffer.writeln('--- Tensions (${mirror.tensions.length}) ---');
    for (final tension in mirror.tensions) {
      buffer.writeln(
        '  [${tension.category.name}] ${tension.reasonCode} '
        'themes=${tension.themeIds.join('+')} '
        'lenses=${tension.agreementLensIds.map((l) => l.storageKey).join('+')}',
      );
    }

    buffer.writeln('--- Lens Themes ---');
    for (final snapshot in mirror.lensSnapshots.where((s) => s.available)) {
      buffer.writeln(
        '  ${snapshot.lensId.storageKey} '
        '(conf=${snapshot.lensConfidence.toStringAsFixed(2)}): '
        '${snapshot.themes.map((t) => t.themeId).join(', ')}',
      );
    }

    return buffer.toString();
  }

  static Map<String, dynamic> _coverageJson(PersonalityCoverage coverage) {
    return {
      'weightedCoverage': coverage.weightedCoverage,
      'hasMbti': coverage.hasMbti,
      'hasBigFive': coverage.hasBigFive,
      'eqModulesCompleted': coverage.eqModulesCompleted,
      'eqModulesExpected': coverage.eqModulesExpected,
      'availableLensIds':
          coverage.availableLensIds.map((id) => id.storageKey).toList(),
      'missingLensIds':
          coverage.missingLensIds.map((id) => id.storageKey).toList(),
    };
  }

  static Map<String, dynamic> _agreementJson(PersonalityAgreement agreement) {
    return {
      'kind': agreement.kind.name,
      'themeId': agreement.themeId,
      'sourceThemeIds': agreement.sourceThemeIds,
      'supportingAgreementLenses':
          agreement.supportingAgreementLenses.map((l) => l.storageKey).toList(),
      'confidence': agreement.confidence,
      'family': agreement.family?.name,
      'category': agreement.category?.name,
    };
  }

  static Map<String, dynamic> _tensionJson(PersonalityTension tension) {
    return {
      'category': tension.category.name,
      'themeIds': tension.themeIds,
      'agreementLensIds':
          tension.agreementLensIds.map((l) => l.storageKey).toList(),
      'families': tension.families.map((f) => f.name).toList(),
      'reasonCode': tension.reasonCode,
    };
  }
}
