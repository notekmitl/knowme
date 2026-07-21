import '../foundation/models/profile_warning.dart';
import '../signal/models/thai_signal_bundle.dart';
import 'constants/thai_interpreter_version.dart';
import 'contracts/thai_interpretation_contract.dart';
import 'models/thai_interpretation_bundle.dart';
import 'models/thai_interpretation_fact.dart';
import 'router/thai_meaning_router.dart';

class ThaiInterpretationEngineResult {
  const ThaiInterpretationEngineResult({
    required this.bundle,
    required this.warnings,
  });

  final ThaiInterpretationBundle bundle;
  final List<ProfileWarning> warnings;
}

/// Interprets structural [ThaiSignal] values into meaning assertions.
abstract final class ThaiInterpretationEngine {
  static ThaiInterpretationEngineResult interpret(ThaiSignalBundle bundle) {
    final routed = ThaiMeaningRouter.route(
      ThaiMeaningRouterInput(
        signals: bundle.signals,
        hasBirthTime: bundle.hasBirthTime,
        sourceBundleId: bundle.bundleId,
      ),
    );

    final facts = dedupeFacts(routed.facts)..sort((a, b) => a.factId.compareTo(b.factId));

    final warnings = List<ProfileWarning>.unmodifiable([
      ...bundle.warnings,
      ...routed.warnings,
    ]);

    final interpretationBundle = ThaiInterpretationBundle(
      bundleId: _bundleId(
        sourceBundleId: bundle.bundleId,
        facts: facts,
      ),
      sourceBundleId: bundle.bundleId,
      extractorVersion: bundle.extractorVersion,
      interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
      interpretedAt: DateTime.now().toUtc(),
      hasBirthTime: bundle.hasBirthTime,
      facts: List<ThaiInterpretationFact>.unmodifiable(facts),
      warnings: warnings,
    );

    return ThaiInterpretationEngineResult(
      bundle: interpretationBundle,
      warnings: warnings,
    );
  }

  static List<ThaiInterpretationFact> dedupeFacts(
    List<ThaiInterpretationFact> facts,
  ) {
    return _dedupeFacts(facts);
  }

  static List<ThaiInterpretationFact> _dedupeFacts(
    List<ThaiInterpretationFact> facts,
  ) {
    final byId = <String, ThaiInterpretationFact>{};
    for (final fact in facts) {
      final existing = byId[fact.factId];
      if (existing == null || fact.confidence > existing.confidence) {
        byId[fact.factId] = fact;
      }
    }
    return byId.values.toList(growable: false);
  }

  static String _bundleId({
    required String sourceBundleId,
    required List<ThaiInterpretationFact> facts,
  }) {
    final factIds = facts.map((fact) => fact.factId).join(',');
    return '$sourceBundleId'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '${ThaiInterpreterVersionContract.interpreterVersion}'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '$factIds';
  }
}
