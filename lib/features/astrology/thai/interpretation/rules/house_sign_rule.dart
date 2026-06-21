import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../contracts/thai_interpretation_contract.dart';
import '../enums/thai_meaning_predicate.dart';
import '../models/thai_interpretation_fact.dart';
import 'thai_meaning_rule.dart';

/// Emits one core [HOUSE_SIGN_IS] fact per house sign signal.
final class HouseSignRule implements ThaiMeaningRule {
  const HouseSignRule();

  static const _signMarker = '_sign_';

  @override
  String get ruleId => ThaiInterpretationContract.houseSignRuleId;

  @override
  String get ruleVersion => ThaiMeaningRuleSupport.ruleVersion;

  @override
  ThaiSignalFactType get appliesTo => ThaiSignalFactType.houseSign;

  @override
  ThaiMeaningPredicate get predicate => ThaiMeaningPredicate.houseSignIs;

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

    final signIndex = signal.signalId.indexOf(_signMarker);
    if (signIndex < 0) {
      return const [];
    }

    final objectRef = signal.signalId.substring(signIndex + _signMarker.length);

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
