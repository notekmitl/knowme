import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../constants/thai_interpreter_version.dart';
import '../enums/thai_interpretation_fact_tier.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_evidence.dart';
import '../models/thai_interpretation_fact.dart';
import '../models/thai_interpretation_provenance.dart';

/// Read-only context passed to meaning rules.
class ThaiMeaningRuleContext {
  const ThaiMeaningRuleContext({
    required this.signals,
    required this.hasBirthTime,
    required this.sourceBundleId,
  });

  final List<ThaiSignal> signals;
  final bool hasBirthTime;
  final String sourceBundleId;
}

/// Contract for atomic signal → meaning fact rules.
abstract interface class ThaiMeaningRule {
  String get ruleId;

  String get ruleVersion;

  ThaiSignalFactType get appliesTo;

  ThaiMeaningPredicate get predicate;

  List<ThaiInterpretationFact> interpret(
    ThaiSignal signal,
    ThaiMeaningRuleContext context,
  );
}

/// Shared helpers for B0-compliant meaning rules.
abstract final class ThaiMeaningRuleSupport {
  static const ruleVersion = 'v1';

  static ThaiInterpretationFact buildCoreFact({
    required String ruleId,
    required ThaiMeaningPredicate predicate,
    required String objectRef,
    required Map<String, String> context,
    required ThaiSignal signal,
  }) {
    return ThaiInterpretationFact(
      factId: buildFactId(
        ruleId: ruleId,
        predicate: predicate,
        objectRef: objectRef,
        context: context,
        primarySignalId: signal.signalId,
      ),
      predicate: predicate,
      objectRef: objectRef,
      context: Map<String, String>.unmodifiable(context),
      tier: ThaiInterpretationFactTier.core,
      evidence: evidenceFromSignal(signal),
      confidence: roundConfidence(signal.confidenceWeight),
      provenance: ThaiInterpretationProvenance(
        interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
        ruleId: ruleId,
        ruleVersion: ruleVersion,
        derived: false,
      ),
    );
  }

  static String buildFactId({
    required String ruleId,
    required ThaiMeaningPredicate predicate,
    required String objectRef,
    required Map<String, String> context,
    required String primarySignalId,
  }) {
    final contextSuffix = formatContextSuffix(context);
    final contextSegment =
        contextSuffix.isEmpty ? '' : ':$contextSuffix';
    return '$ruleId:${predicate.id}:$objectRef$contextSegment@$primarySignalId';
  }

  static String formatContextSuffix(Map<String, String> context) {
    if (context.isEmpty) {
      return '';
    }

    final keys = context.keys.toList()..sort();
    return 'ctx-${keys.map((key) => '$key=${context[key]}').join(',')}';
  }

  static ThaiInterpretationEvidence evidenceFromSignal(ThaiSignal signal) {
    return ThaiInterpretationEvidence(
      primarySignalId: signal.signalId,
      sourceSignalIds: [signal.signalId],
      structuralFactKeys: List<String>.unmodifiable(signal.evidence.factKeys),
      auditRef: signal.evidence.auditRef,
    );
  }

  static double roundConfidence(double confidenceWeight) {
    return (confidenceWeight * 100).roundToDouble() / 100;
  }

  static String? requiredFactValue(ThaiSignal signal, String key) {
    final value = signal.facts[key];
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  static String suffixAfterPrefix(String value, String prefix) {
    if (!value.startsWith(prefix)) {
      return value;
    }
    return value.substring(prefix.length);
  }
}
