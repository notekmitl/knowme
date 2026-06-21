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
import 'package:knowme/features/astrology/thai/interpretation/rules/thai_meaning_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_fact_type.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_source.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_bundle.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';

const _bangkokOffset = Duration(hours: 7);

final _factIdPattern = RegExp(
  r'^[a-z0-9_]+:[A-Z_]+:[a-z0-9_.-]+(:ctx-[a-zA-Z0-9=,]+)?@[a-z0-9_.-]+$',
);

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

({ThaiSignalBundle signalBundle, ThaiInterpretationEngineResult result})
    _interpret(ThaiBirthData birth) {
  final signalBundle = _signalBundle(birth);
  final result = ThaiInterpretationEngine.interpret(signalBundle);
  return (signalBundle: signalBundle, result: result);
}

Map<ThaiMeaningPredicate, int> _predicateDistribution(
  List<ThaiInterpretationFact> facts,
) {
  final counts = <ThaiMeaningPredicate, int>{};
  for (final fact in facts) {
    counts.update(fact.predicate, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

void _assertEvidenceIntegrity({
  required ThaiInterpretationFact fact,
  required Map<String, ThaiSignal> signalsById,
}) {
  expect(
    fact.evidence.sourceSignalIds,
    contains(fact.evidence.primarySignalId),
  );
  expect(fact.evidence.sourceSignalIds, isNotEmpty);

  final signal = signalsById[fact.evidence.primarySignalId];
  expect(signal, isNotNull, reason: 'missing source signal for ${fact.factId}');
  expect(
    fact.evidence.structuralFactKeys,
    signal!.evidence.factKeys,
    reason: 'structuralFactKeys mismatch for ${fact.factId}',
  );
}

void _assertFactIdentity(ThaiInterpretationFact fact) {
  expect(_factIdPattern.hasMatch(fact.factId), isTrue, reason: fact.factId);
  expect(fact.factId, contains(fact.predicate.id));
  expect(fact.factId, endsWith('@${fact.evidence.primarySignalId}'));
  expect(fact.tier, ThaiInterpretationFactTier.core);
  expect(fact.provenance.derived, isFalse);

  final rebuilt = ThaiMeaningRuleSupport.buildFactId(
    ruleId: fact.provenance.ruleId,
    predicate: fact.predicate,
    objectRef: fact.objectRef,
    context: fact.context,
    primarySignalId: fact.evidence.primarySignalId,
  );
  expect(rebuilt, fact.factId);
}

void _assertForbiddenKnowledge(ThaiInterpretationFact fact) {
  final serialized = fact.toMap();
  for (final forbidden in ThaiInterpretationContract.forbiddenFactFieldNames) {
    expect(serialized.containsKey(forbidden), isFalse);
  }
  for (final allowed in ThaiInterpretationContract.interpretationFactFieldNames) {
    expect(serialized.containsKey(allowed), isTrue);
  }
}

void main() {
  group('B2 Interpretation Parity Audit', () {
    test('TC-01 — signal count, fact count, predicate distribution', () {
      final audited = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );

      expect(audited.signalBundle.signals, hasLength(26));
      expect(audited.result.bundle.facts, hasLength(26));
      expect(
        _predicateDistribution(audited.result.bundle.facts),
        {
          ThaiMeaningPredicate.lagnaSignIs: 1,
          ThaiMeaningPredicate.lagnaLordIs: 1,
          ThaiMeaningPredicate.houseSignIs: 12,
          ThaiMeaningPredicate.houseLordIs: 12,
        },
      );
    });

    test('GC-05 — full signal and fact parity with seven numbers', () {
      final audited = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      expect(audited.signalBundle.signals, hasLength(40));
      expect(audited.result.bundle.facts, hasLength(40));
      expect(
        _predicateDistribution(audited.result.bundle.facts),
        {
          ThaiMeaningPredicate.lagnaSignIs: 1,
          ThaiMeaningPredicate.lagnaLordIs: 1,
          ThaiMeaningPredicate.houseSignIs: 12,
          ThaiMeaningPredicate.houseLordIs: 12,
          ThaiMeaningPredicate.myanmarPositionIs: 7,
          ThaiMeaningPredicate.mahabhutaPositionIs: 7,
        },
      );
    });

    test('GC-05 no birth time — seven-number facts only', () {
      final audited = _interpret(
        _bangkokBirth(
          year: 1972,
          month: 4,
          day: 4,
          hour: 2,
          hasBirthTime: false,
        ),
      );

      expect(audited.signalBundle.signals, hasLength(14));
      expect(audited.result.bundle.facts, hasLength(14));
      expect(
        audited.result.bundle.facts.every(
          (fact) =>
              fact.predicate == ThaiMeaningPredicate.myanmarPositionIs ||
              fact.predicate == ThaiMeaningPredicate.mahabhutaPositionIs,
        ),
        isTrue,
      );
    });
  });

  group('B2 Evidence Integrity Audit', () {
    test('all GC-05 facts satisfy evidence contract', () {
      final audited = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );
      final signalsById = {
        for (final signal in audited.signalBundle.signals)
          signal.signalId: signal,
      };

      for (final fact in audited.result.bundle.facts) {
        _assertEvidenceIntegrity(fact: fact, signalsById: signalsById);
      }
    });
  });

  group('B2 Fact Identity Audit', () {
    test('all GC-05 factIds are deterministic, stable, and unique', () {
      final first = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );
      final second = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      final firstIds = first.result.bundle.facts.map((f) => f.factId).toList();
      final secondIds =
          second.result.bundle.facts.map((f) => f.factId).toList();

      expect(firstIds.toSet(), hasLength(firstIds.length));
      expect(firstIds, secondIds);

      for (final fact in first.result.bundle.facts) {
        _assertFactIdentity(fact);
      }
    });
  });

  group('B2 Bundle Identity Audit', () {
    test('bundleId is deterministic and does not include interpretedAt', () {
      final first = _interpret(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      );
      final second = _interpret(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      );

      expect(first.result.bundle.bundleId, second.result.bundle.bundleId);
      expect(
        first.result.bundle.bundleId.contains(
          first.result.bundle.interpretedAt.toIso8601String(),
        ),
        isFalse,
      );
    });

    test('bundleId uses sorted factIds regardless of processing order', () {
      final audited = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final sortedIds = audited.result.bundle.facts
          .map((fact) => fact.factId)
          .toList()
        ..sort();
      final reversedIds = sortedIds.reversed.toList();

      final fromSorted = [
        '${audited.signalBundle.bundleId}'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '${ThaiInterpreterVersionContract.interpreterVersion}'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '${sortedIds.join(',')}',
      ].single;

      final fromReversed = [
        '${audited.signalBundle.bundleId}'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '${ThaiInterpreterVersionContract.interpreterVersion}'
        '${ThaiInterpretationContract.bundleIdDelimiter}'
        '${reversedIds.join(',')}',
      ].single;

      expect(audited.result.bundle.bundleId, fromSorted);
      expect(fromSorted, isNot(fromReversed));
    });
  });

  group('B2 Duplicate Audit', () {
    test('dedupe keeps higher confidence and first on tie', () {
      final baseEvidence = ThaiInterpretationEvidence(
        primarySignalId: 'lagna_sign_virgo',
        sourceSignalIds: const ['lagna_sign_virgo'],
        structuralFactKeys: const ['low'],
      );
      final highEvidence = ThaiInterpretationEvidence(
        primarySignalId: 'lagna_sign_virgo',
        sourceSignalIds: const ['lagna_sign_virgo'],
        structuralFactKeys: const ['high'],
      );
      const provenance = ThaiInterpretationProvenance(
        interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
        ruleId: ThaiInterpretationContract.lagnaSignRuleId,
        ruleVersion: 'v1',
        derived: false,
      );

      final factId =
          'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo';
      final low = ThaiInterpretationFact(
        factId: factId,
        predicate: ThaiMeaningPredicate.lagnaSignIs,
        objectRef: 'virgo',
        context: const {},
        tier: ThaiInterpretationFactTier.core,
        evidence: baseEvidence,
        confidence: 0.10,
        provenance: provenance,
      );
      final high = ThaiInterpretationFact(
        factId: factId,
        predicate: low.predicate,
        objectRef: low.objectRef,
        context: low.context,
        tier: low.tier,
        evidence: highEvidence,
        confidence: 0.95,
        provenance: provenance,
      );
      final tieA = ThaiInterpretationFact(
        factId: factId,
        predicate: low.predicate,
        objectRef: low.objectRef,
        context: low.context,
        tier: low.tier,
        evidence: ThaiInterpretationEvidence(
          primarySignalId: 'lagna_sign_virgo',
          sourceSignalIds: const ['lagna_sign_virgo'],
          structuralFactKeys: const ['tie-a'],
        ),
        confidence: 0.50,
        provenance: provenance,
      );
      final tieB = ThaiInterpretationFact(
        factId: factId,
        predicate: low.predicate,
        objectRef: low.objectRef,
        context: low.context,
        tier: low.tier,
        evidence: ThaiInterpretationEvidence(
          primarySignalId: 'lagna_sign_virgo',
          sourceSignalIds: const ['lagna_sign_virgo'],
          structuralFactKeys: const ['tie-b'],
        ),
        confidence: 0.50,
        provenance: provenance,
      );

      final merged = ThaiInterpretationEngine.dedupeFacts([
        low,
        high,
        low,
      ]);
      expect(merged.single.confidence, 0.95);
      expect(merged.single.evidence.structuralFactKeys, ['high']);

      final tieMerged = ThaiInterpretationEngine.dedupeFacts([tieA, tieB]);
      expect(tieMerged.single.evidence.structuralFactKeys, ['tie-a']);
    });
  });

  group('B2 Boundary Audit', () {
    test('interpretation sources do not import forbidden packages', () {
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

  group('B2 Forbidden Knowledge Audit', () {
    test('serialized facts contain only allowed meaning fields', () {
      final audited = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      for (final fact in audited.result.bundle.facts) {
        _assertForbiddenKnowledge(fact);
      }
    });
  });

  group('B2 Stability Assessment', () {
    test('100× deterministic bundle identity for GC-05', () {
      final birth = _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2);
      final baselineBundleId = _interpret(birth).result.bundle.bundleId;
      final baselineFactIds = _interpret(birth)
          .result
          .bundle
          .facts
          .map((fact) => fact.factId)
          .toList();

      for (var i = 0; i < 100; i++) {
        final result = _interpret(birth).result.bundle;
        expect(result.bundleId, baselineBundleId, reason: 'iteration $i');
        expect(
          result.facts.map((fact) => fact.factId).toList(),
          baselineFactIds,
          reason: 'iteration $i',
        );
      }
    });
  });
}
