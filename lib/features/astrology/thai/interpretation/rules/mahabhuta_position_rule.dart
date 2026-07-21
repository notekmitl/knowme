import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../contracts/thai_interpretation_contract.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_fact.dart';
import 'thai_meaning_rule.dart';

/// Emits one core [MAHABHUTA_POSITION_IS] fact per mahabhuta position signal.
final class MahabhutaPositionRule implements ThaiMeaningRule {
  const MahabhutaPositionRule();

  @override
  String get ruleId => ThaiInterpretationContract.mahabhutaPositionRuleId;

  @override
  String get ruleVersion => ThaiMeaningRuleSupport.ruleVersion;

  @override
  ThaiSignalFactType get appliesTo => ThaiSignalFactType.mahabhutaPosition;

  @override
  ThaiMeaningPredicate get predicate => ThaiMeaningPredicate.mahabhutaPositionIs;

  @override
  List<ThaiInterpretationFact> interpret(
    ThaiSignal signal,
    ThaiMeaningRuleContext context,
  ) {
    return [
      ThaiMeaningRuleSupport.buildCoreFact(
        ruleId: ruleId,
        predicate: predicate,
        objectRef: signal.signalId,
        context: const {},
        signal: signal,
      ),
    ];
  }
}
