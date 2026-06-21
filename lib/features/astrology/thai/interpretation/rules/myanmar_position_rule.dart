import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../contracts/thai_interpretation_contract.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_fact.dart';
import 'thai_meaning_rule.dart';

/// Emits one core [MYANMAR_POSITION_IS] fact per myanmar position signal.
final class MyanmarPositionRule implements ThaiMeaningRule {
  const MyanmarPositionRule();

  @override
  String get ruleId => ThaiInterpretationContract.myanmarPositionRuleId;

  @override
  String get ruleVersion => ThaiMeaningRuleSupport.ruleVersion;

  @override
  ThaiSignalFactType get appliesTo => ThaiSignalFactType.myanmarPosition;

  @override
  ThaiMeaningPredicate get predicate => ThaiMeaningPredicate.myanmarPositionIs;

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
