import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../contracts/thai_interpretation_contract.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_fact.dart';
import 'thai_meaning_rule.dart';

/// Emits one core [LAGNA_LORD_IS] fact per lagna lord signal.
final class LagnaLordRule implements ThaiMeaningRule {
  const LagnaLordRule();

  static const _signalIdPrefix = 'lagna_lord_';

  @override
  String get ruleId => ThaiInterpretationContract.lagnaLordRuleId;

  @override
  String get ruleVersion => ThaiMeaningRuleSupport.ruleVersion;

  @override
  ThaiSignalFactType get appliesTo => ThaiSignalFactType.lagnaLord;

  @override
  ThaiMeaningPredicate get predicate => ThaiMeaningPredicate.lagnaLordIs;

  @override
  List<ThaiInterpretationFact> interpret(
    ThaiSignal signal,
    ThaiMeaningRuleContext context,
  ) {
    final objectRef = ThaiMeaningRuleSupport.suffixAfterPrefix(
      signal.signalId,
      _signalIdPrefix,
    );

    return [
      ThaiMeaningRuleSupport.buildCoreFact(
        ruleId: ruleId,
        predicate: predicate,
        objectRef: objectRef,
        context: const {},
        signal: signal,
      ),
    ];
  }
}
