import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../contracts/thai_interpretation_contract.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_fact.dart';
import 'thai_meaning_rule.dart';

/// Emits one core [HOUSE_LORD_IS] fact per house lord signal.
final class HouseLordRule implements ThaiMeaningRule {
  const HouseLordRule();

  static const _lordMarker = '_lord_';

  @override
  String get ruleId => ThaiInterpretationContract.houseLordRuleId;

  @override
  String get ruleVersion => ThaiMeaningRuleSupport.ruleVersion;

  @override
  ThaiSignalFactType get appliesTo => ThaiSignalFactType.houseLord;

  @override
  ThaiMeaningPredicate get predicate => ThaiMeaningPredicate.houseLordIs;

  @override
  List<ThaiInterpretationFact> interpret(
    ThaiSignal signal,
    ThaiMeaningRuleContext context,
  ) {
    final houseNumber = ThaiMeaningRuleSupport.requiredFactValue(
      signal,
      'houseNumber',
    );
    if (houseNumber == null) {
      return const [];
    }

    final lordIndex = signal.signalId.indexOf(_lordMarker);
    if (lordIndex < 0) {
      return const [];
    }

    final objectRef = signal.signalId.substring(lordIndex + _lordMarker.length);

    return [
      ThaiMeaningRuleSupport.buildCoreFact(
        ruleId: ruleId,
        predicate: predicate,
        objectRef: objectRef,
        context: {'houseNumber': houseNumber},
        signal: signal,
      ),
    ];
  }
}
