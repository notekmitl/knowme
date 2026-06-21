import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/constants/thai_interpreter_version.dart';
import 'package:knowme/features/astrology/thai/interpretation/contracts/thai_interpretation_contract.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_interpretation_fact_tier.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart';
import 'package:knowme/features/astrology/thai/interpretation/router/thai_meaning_router.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/house_sign_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/lagna_sign_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/myanmar_position_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/thai_meaning_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_evidence.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_fact_type.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_provenance.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_source.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_bundle.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

ThaiSignalBundle _signalBundle(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  return ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  ).bundle;
}

ThaiMeaningRuleContext _ruleContext(List<ThaiSignal> signals) {
  return ThaiMeaningRuleContext(
    signals: signals,
    hasBirthTime: true,
    sourceBundleId: 'test-bundle',
  );
}

ThaiSignal _syntheticSignal({
  required String signalId,
  required ThaiSignalFactType factType,
  required ThaiSignalSource source,
  required double confidenceWeight,
  Map<String, String> facts = const {},
}) {
  return ThaiSignal(
    signalId: signalId,
    source: source,
    factType: factType,
    evidence: ThaiSignalEvidence(
      factKeys: ['test:$signalId'],
      displayEn: 'test',
      displayTh: 'test',
    ),
    confidenceWeight: confidenceWeight,
    contentKeyRefs: const [],
    provenance: const ThaiSignalProvenance(
      engineVersion: 'test',
      extractorVersion: 'test',
      enginePath: ['test'],
      requiresBirthTime: true,
    ),
    facts: facts,
  );
}

String _interpretationDeterministicKey(ThaiBirthData birth) {
  final result = ThaiInterpretationEngine.interpret(_signalBundle(birth));
  final factIds = result.bundle.facts.map((fact) => fact.factId).toList();
  return '${result.bundle.bundleId}|${result.bundle.hasBirthTime}|$factIds';
}

void main() {
  group('B1 LagnaSignRule', () {
    test('emits one core LAGNA_SIGN_IS fact with B0 factId', () {
      final signal = _syntheticSignal(
        signalId: 'lagna_sign_virgo',
        factType: ThaiSignalFactType.lagnaSign,
        source: ThaiSignalSource.sidereal,
        confidenceWeight: 0.95,
      );

      final facts = const LagnaSignRule().interpret(signal, _ruleContext([signal]));

      expect(facts, hasLength(1));
      expect(facts.first.predicate, ThaiMeaningPredicate.lagnaSignIs);
      expect(facts.first.objectRef, 'virgo');
      expect(facts.first.tier, ThaiInterpretationFactTier.core);
      expect(facts.first.confidence, 0.95);
      expect(
        facts.first.factId,
        'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
      );
    });
  });

  group('B1 HouseSignRule', () {
    test('emits one core HOUSE_SIGN_IS fact with house context', () {
      final signal = _syntheticSignal(
        signalId: 'house_10_sign_virgo',
        factType: ThaiSignalFactType.houseSign,
        source: ThaiSignalSource.house,
        confidenceWeight: 0.70,
        facts: const {'houseNumber': '10'},
      );

      final facts = const HouseSignRule().interpret(signal, _ruleContext([signal]));

      expect(facts, hasLength(1));
      expect(facts.first.predicate, ThaiMeaningPredicate.houseSignIs);
      expect(facts.first.context, {'houseNumber': '10'});
      expect(facts.first.confidence, 0.70);
      expect(
        facts.first.factId,
        'house_sign_rule_v1:HOUSE_SIGN_IS:virgo:ctx-houseNumber=10@house_10_sign_virgo',
      );
    });
  });

  group('B1 MyanmarPositionRule', () {
    test('emits one core MYANMAR_POSITION_IS fact', () {
      final signal = _syntheticSignal(
        signalId: 'myanmar_seven_2',
        factType: ThaiSignalFactType.myanmarPosition,
        source: ThaiSignalSource.sevenNumbers,
        confidenceWeight: 0.50,
      );

      final facts =
          const MyanmarPositionRule().interpret(signal, _ruleContext([signal]));

      expect(facts, hasLength(1));
      expect(facts.first.predicate, ThaiMeaningPredicate.myanmarPositionIs);
      expect(facts.first.objectRef, 'myanmar_seven_2');
      expect(
        facts.first.factId,
        'myanmar_position_rule_v1:MYANMAR_POSITION_IS:myanmar_seven_2@myanmar_seven_2',
      );
    });
  });

  group('B1 ThaiMeaningRouter', () {
    test('routes each factType to exactly one rule', () {
      for (final factType in ThaiSignalFactType.values) {
        expect(ThaiMeaningRouter.ruleFor(factType), isNotNull);
      }
    });

    test('skips legacyV1 signals with warning', () {
      final signal = _syntheticSignal(
        signalId: 'legacy_test',
        factType: ThaiSignalFactType.lagnaSign,
        source: ThaiSignalSource.legacyV1,
        confidenceWeight: 0.95,
      );

      final result = ThaiMeaningRouter.route(
        ThaiMeaningRouterInput(
          signals: [signal],
          hasBirthTime: true,
          sourceBundleId: 'bundle',
        ),
      );

      expect(result.facts, isEmpty);
      expect(result.warnings.single.code, 'MEANING_RULE_SKIPPED');
    });
  });

  group('B1 ThaiInterpretationEngine', () {
    test('factId determinism for TC-01', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final first = ThaiInterpretationEngine.interpret(_signalBundle(birth));
      final second = ThaiInterpretationEngine.interpret(_signalBundle(birth));

      expect(
        first.bundle.facts.map((fact) => fact.factId).toList(),
        second.bundle.facts.map((fact) => fact.factId).toList(),
      );

      final lagnaSign = first.bundle.facts.firstWhere(
        (fact) => fact.predicate == ThaiMeaningPredicate.lagnaSignIs,
      );
      expect(
        lagnaSign.factId,
        'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
      );
    });

    test('bundleId determinism for TC-01', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final first = ThaiInterpretationEngine.interpret(_signalBundle(birth));
      final second = ThaiInterpretationEngine.interpret(_signalBundle(birth));

      expect(first.bundle.bundleId, second.bundle.bundleId);
      expect(first.bundle.facts, hasLength(26));
    });

    test('bundleId determinism for GC-05 includes seven-number facts', () {
      final birth = _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2);
      final first = ThaiInterpretationEngine.interpret(_signalBundle(birth));
      final second = ThaiInterpretationEngine.interpret(_signalBundle(birth));

      expect(first.bundle.bundleId, second.bundle.bundleId);
      expect(first.bundle.facts, hasLength(40));
    });

    test('duplicate merge keeps higher confidence fact', () {
      final lowConfidence = ThaiInterpretationFact(
        factId: 'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
        predicate: ThaiMeaningPredicate.lagnaSignIs,
        objectRef: 'virgo',
        context: const {},
        tier: ThaiInterpretationFactTier.core,
        evidence: ThaiInterpretationEvidence(
          primarySignalId: 'lagna_sign_virgo',
          sourceSignalIds: const ['lagna_sign_virgo'],
          structuralFactKeys: const ['a'],
        ),
        confidence: 0.10,
        provenance: const ThaiInterpretationProvenance(
          interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
          ruleId: ThaiInterpretationContract.lagnaSignRuleId,
          ruleVersion: 'v1',
          derived: false,
        ),
      );
      final highConfidence = ThaiInterpretationFact(
        factId: lowConfidence.factId,
        predicate: lowConfidence.predicate,
        objectRef: lowConfidence.objectRef,
        context: lowConfidence.context,
        tier: lowConfidence.tier,
        evidence: ThaiInterpretationEvidence(
          primarySignalId: 'lagna_sign_virgo',
          sourceSignalIds: const ['lagna_sign_virgo'],
          structuralFactKeys: const ['b'],
        ),
        confidence: 0.95,
        provenance: lowConfidence.provenance,
      );

      final deduped = ThaiInterpretationEngine.dedupeFacts([
        lowConfidence,
        highConfidence,
        lowConfidence,
      ]);

      expect(deduped, hasLength(1));
      expect(deduped.single.confidence, 0.95);
      expect(deduped.single.evidence.structuralFactKeys, ['b']);
    });

    test('no birth time bundle has only seven-number facts', () {
      final birth = _bangkokBirth(
        year: 1972,
        month: 4,
        day: 4,
        hour: 2,
        hasBirthTime: false,
      );
      final result = ThaiInterpretationEngine.interpret(_signalBundle(birth));

      expect(result.bundle.hasBirthTime, isFalse);
      expect(
        result.bundle.facts.where(
          (fact) =>
              fact.predicate == ThaiMeaningPredicate.lagnaSignIs ||
              fact.predicate == ThaiMeaningPredicate.houseSignIs,
        ),
        isEmpty,
      );
      expect(result.bundle.facts, hasLength(14));
    });

    test('100× deterministic interpretation key', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final baseline = _interpretationDeterministicKey(birth);

      for (var i = 0; i < 100; i++) {
        expect(
          _interpretationDeterministicKey(birth),
          baseline,
          reason: 'iteration $i',
        );
      }
    });
  });

  group('B1 import boundary validation', () {
    test('interpretation engine sources do not import forbidden packages', () {
      final interpretationDir = Directory(
        'lib/features/astrology/thai/interpretation',
      );
      final forbiddenImportPatterns = [
        'content/',
        'theme/',
        'mirror/',
        'fusion/',
      ];

      final dartFiles = interpretationDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        for (final pattern in forbiddenImportPatterns) {
          expect(
            RegExp("import '[^']*$pattern").hasMatch(source),
            isFalse,
            reason: '${file.path} must not import $pattern',
          );
        }
      }
    });
  });
}
