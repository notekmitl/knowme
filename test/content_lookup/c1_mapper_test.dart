import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content_lookup/mapper/thai_fact_to_content_key_mapper.dart';
import 'package:knowme/features/astrology/thai/interpretation/constants/thai_interpreter_version.dart';
import 'package:knowme/features/astrology/thai/interpretation/contracts/thai_interpretation_contract.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_interpretation_fact_tier.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/house_sign_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/lagna_lord_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/lagna_sign_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/mahabhuta_position_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/myanmar_position_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/thai_meaning_rule.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_evidence.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_fact_type.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_provenance.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_source.dart';

ThaiInterpretationFact _factFromRule(
  ThaiMeaningRule rule,
  ThaiSignal signal,
) {
  final facts = rule.interpret(
    signal,
    ThaiMeaningRuleContext(
      signals: [signal],
      hasBirthTime: true,
      sourceBundleId: 'test-bundle',
    ),
  );
  expect(facts, hasLength(1));
  return facts.first;
}

ThaiSignal _signal({
  required String signalId,
  required ThaiSignalFactType factType,
  Map<String, String> facts = const {},
}) {
  return ThaiSignal(
    signalId: signalId,
    source: ThaiSignalSource.sidereal,
    factType: factType,
    evidence: ThaiSignalEvidence(
      factKeys: ['test:$signalId'],
      displayEn: 'test',
      displayTh: 'test',
    ),
    confidenceWeight: 0.95,
    contentKeyRefs: const [],
    provenance: const ThaiSignalProvenance(
      engineVersion: 'test',
      extractorVersion: 'test',
      enginePath: const ['test'],
      requiresBirthTime: true,
    ),
    facts: facts,
  );
}

ThaiInterpretationFact _manualFact({
  required ThaiMeaningPredicate predicate,
  required String objectRef,
  Map<String, String> context = const {},
}) {
  return ThaiInterpretationFact(
    factId: 'test:$predicate:$objectRef',
    predicate: predicate,
    objectRef: objectRef,
    context: context,
    tier: ThaiInterpretationFactTier.core,
    evidence: ThaiInterpretationEvidence(
      primarySignalId: 'test_signal',
      sourceSignalIds: const ['test_signal'],
      structuralFactKeys: const [],
    ),
    confidence: 0.95,
    provenance: ThaiInterpretationProvenance(
      interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
      ruleId: ThaiInterpretationContract.lagnaSignRuleId,
      ruleVersion: 'v1',
      derived: false,
    ),
  );
}

void main() {
  group('C1 lagna sign mapping', () {
    test('LAGNA_SIGN_IS maps to lagna_{objectRef}', () {
      final fact = _factFromRule(
        const LagnaSignRule(),
        _signal(
          signalId: 'lagna_sign_virgo',
          factType: ThaiSignalFactType.lagnaSign,
        ),
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isTrue);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), 'lagna_virgo');
    });
  });

  group('C1 lagna lord mapping', () {
    test('LAGNA_LORD_IS maps to lagna_lord_{objectRef}', () {
      final fact = _factFromRule(
        const LagnaLordRule(),
        _signal(
          signalId: 'lagna_lord_mercury',
          factType: ThaiSignalFactType.lagnaLord,
        ),
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isTrue);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), 'lagna_lord_mercury');
    });
  });

  group('C1 myanmar mapping', () {
    test('MYANMAR_POSITION_IS maps to objectRef', () {
      final fact = _factFromRule(
        const MyanmarPositionRule(),
        _signal(
          signalId: 'myanmar_seven_2',
          factType: ThaiSignalFactType.myanmarPosition,
        ),
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isTrue);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), 'myanmar_seven_2');
    });
  });

  group('C1 mahabhuta mapping', () {
    test('MAHABHUTA_POSITION_IS maps to objectRef', () {
      final fact = _factFromRule(
        const MahabhutaPositionRule(),
        _signal(
          signalId: 'mahabhuta_pyadhi',
          factType: ThaiSignalFactType.mahabhutaPosition,
        ),
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isTrue);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), 'mahabhuta_pyadhi');
    });
  });

  group('C1 house deferred', () {
    test('HOUSE_SIGN_IS is not resolvable and returns null key', () {
      final fact = _factFromRule(
        const HouseSignRule(),
        _signal(
          signalId: 'house_10_sign_virgo',
          factType: ThaiSignalFactType.houseSign,
          facts: const {'houseNumber': '10'},
        ),
      );

      expect(fact.predicate, ThaiMeaningPredicate.houseSignIs);
      expect(ThaiFactToContentKeyMapper.canResolve(fact), isFalse);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), isNull);
    });

    test('HOUSE_LORD_IS is not resolvable and returns null key', () {
      final fact = _manualFact(
        predicate: ThaiMeaningPredicate.houseLordIs,
        objectRef: 'mercury',
        context: const {'houseNumber': '10'},
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isFalse);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), isNull);
    });
  });

  group('C1 context rejection', () {
    test('supported predicate with non-empty context is not resolvable', () {
      final fact = _manualFact(
        predicate: ThaiMeaningPredicate.lagnaSignIs,
        objectRef: 'virgo',
        context: const {'houseNumber': '1'},
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isFalse);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), isNull);
    });
  });

  group('C1 deterministic mapping', () {
    test('resolveKey is stable across repeated calls', () {
      final fact = _factFromRule(
        const LagnaSignRule(),
        _signal(
          signalId: 'lagna_sign_aries',
          factType: ThaiSignalFactType.lagnaSign,
        ),
      );

      final first = ThaiFactToContentKeyMapper.resolveKey(fact);
      final second = ThaiFactToContentKeyMapper.resolveKey(fact);

      expect(first, 'lagna_aries');
      expect(second, first);
      expect(ThaiFactToContentKeyMapper.canResolve(fact), isTrue);
    });

    test('canResolve false always yields null resolveKey', () {
      final fact = _manualFact(
        predicate: ThaiMeaningPredicate.houseSignIs,
        objectRef: 'virgo',
        context: const {'houseNumber': '10'},
      );

      expect(ThaiFactToContentKeyMapper.canResolve(fact), isFalse);
      expect(ThaiFactToContentKeyMapper.resolveKey(fact), isNull);
    });
  });

  group('C1 import boundary validation', () {
    test('mapper does not import forbidden packages', () {
      final source = File(
        'lib/features/astrology/thai/content_lookup/mapper/thai_fact_to_content_key_mapper.dart',
      ).readAsStringSync();

      final forbiddenImportPatterns = [
        'content/registry',
        'content/repository',
        'content/providers',
        'theme/',
        'mirror/',
        'fusion/',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'mapper must not import $pattern',
        );
        expect(
          RegExp('import "([^"]*$pattern)').hasMatch(source),
          isFalse,
          reason: 'mapper must not import $pattern',
        );
      }
    });
  });
}
