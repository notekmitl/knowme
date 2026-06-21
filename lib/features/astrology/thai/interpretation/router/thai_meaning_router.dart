import '../../foundation/models/profile_warning.dart';
import '../../signal/models/thai_signal.dart';
import '../../signal/models/thai_signal_fact_type.dart';
import '../../signal/models/thai_signal_source.dart';
import '../models/thai_interpretation_fact.dart';
import '../rules/house_lord_rule.dart';
import '../rules/house_sign_rule.dart';
import '../rules/lagna_lord_rule.dart';
import '../rules/lagna_sign_rule.dart';
import '../rules/mahabhuta_position_rule.dart';
import '../rules/myanmar_position_rule.dart';
import '../rules/thai_meaning_rule.dart';

/// Routes [ThaiSignal] values to atomic meaning rules.
abstract final class ThaiMeaningRouter {
  static const _rules = <ThaiSignalFactType, ThaiMeaningRule>{
    ThaiSignalFactType.lagnaSign: LagnaSignRule(),
    ThaiSignalFactType.lagnaLord: LagnaLordRule(),
    ThaiSignalFactType.houseSign: HouseSignRule(),
    ThaiSignalFactType.houseLord: HouseLordRule(),
    ThaiSignalFactType.myanmarPosition: MyanmarPositionRule(),
    ThaiSignalFactType.mahabhutaPosition: MahabhutaPositionRule(),
  };

  static ThaiMeaningRouterResult route(ThaiMeaningRouterInput input) {
    final context = ThaiMeaningRuleContext(
      signals: input.signals,
      hasBirthTime: input.hasBirthTime,
      sourceBundleId: input.sourceBundleId,
    );

    final facts = <ThaiInterpretationFact>[];
    final warnings = <ProfileWarning>[];

    for (final signal in input.signals) {
      if (signal.source == ThaiSignalSource.legacyV1) {
        warnings.add(_legacyWarning(signal.signalId));
        continue;
      }

      final rule = _rules[signal.factType];
      if (rule == null) {
        warnings.add(_missingRuleWarning(signal));
        continue;
      }

      final interpreted = rule.interpret(signal, context);
      if (interpreted.isEmpty) {
        warnings.add(_skippedWarning(signal));
        continue;
      }

      facts.addAll(interpreted);
    }

    return ThaiMeaningRouterResult(
      facts: List<ThaiInterpretationFact>.unmodifiable(facts),
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );
  }

  static ThaiMeaningRule? ruleFor(ThaiSignalFactType factType) {
    return _rules[factType];
  }

  static ProfileWarning _legacyWarning(String signalId) {
    return ProfileWarning(
      code: 'MEANING_RULE_SKIPPED',
      severity: ProfileWarningSeverity.medium,
      message: 'Legacy V1 signal skipped: $signalId',
      affectedFields: [signalId],
    );
  }

  static ProfileWarning _missingRuleWarning(ThaiSignal signal) {
    return ProfileWarning(
      code: 'MEANING_RULE_NOT_FOUND',
      severity: ProfileWarningSeverity.high,
      message: 'No meaning rule for fact type: ${signal.factType.id}',
      affectedFields: [signal.signalId],
    );
  }

  static ProfileWarning _skippedWarning(ThaiSignal signal) {
    return ProfileWarning(
      code: 'MEANING_RULE_SKIPPED',
      severity: ProfileWarningSeverity.medium,
      message: 'Meaning rule returned no facts for signal: ${signal.signalId}',
      affectedFields: [signal.signalId],
    );
  }
}

class ThaiMeaningRouterInput {
  const ThaiMeaningRouterInput({
    required this.signals,
    required this.hasBirthTime,
    required this.sourceBundleId,
  });

  final List<ThaiSignal> signals;
  final bool hasBirthTime;
  final String sourceBundleId;
}

class ThaiMeaningRouterResult {
  const ThaiMeaningRouterResult({
    required this.facts,
    required this.warnings,
  });

  final List<ThaiInterpretationFact> facts;
  final List<ProfileWarning> warnings;
}
