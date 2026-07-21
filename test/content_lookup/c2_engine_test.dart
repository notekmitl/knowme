import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_content_lookup_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_meaning_preservation_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/enums/thai_content_fragment_kind.dart';
import 'package:knowme/features/astrology/thai/content_lookup/thai_content_lookup_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/rules/thai_meaning_rule.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';

const _bangkokOffset = Duration(hours: 7);

final _resolutionIdPattern = RegExp(
  r'^[A-Z_]+:[a-z0-9_.-]+(:ctx-[a-zA-Z0-9=,]+)?:[a-zA-Z]+$',
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

ThaiInterpretationEngineResult _interpret(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  final signalBundle = ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  ).bundle;
  return ThaiInterpretationEngine.interpret(signalBundle);
}

ThaiInterpretationFact _firstFact(
  ThaiInterpretationEngineResult result,
  ThaiMeaningPredicate predicate,
) {
  return result.bundle.facts.firstWhere(
    (fact) => fact.predicate == predicate,
  );
}

void main() {
  group('C2 lagna sign resolution', () {
    test('emits title and coreNature fragments for LAGNA_SIGN_IS', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final fact = _firstFact(interpretation, ThaiMeaningPredicate.lagnaSignIs);
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      final fragments = result.bundle.fragments
          .where((fragment) => fragment.sourceFactId == fact.factId)
          .toList();

      expect(fragments, hasLength(2));
      expect(
        fragments.map((fragment) => fragment.fragmentKind).toSet(),
        equals({
          ThaiContentFragmentKind.title,
          ThaiContentFragmentKind.coreNature,
        }),
      );
      expect(fragments.first.contentKey, 'lagna_${fact.objectRef}');
      expect(fragments.every((fragment) => fragment.text.isNotEmpty), isTrue);
    });
  });

  group('C2 lagna lord resolution', () {
    test('emits fragments for LAGNA_LORD_IS', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final fact = _firstFact(interpretation, ThaiMeaningPredicate.lagnaLordIs);
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      final fragments = result.bundle.fragments
          .where((fragment) => fragment.sourceFactId == fact.factId)
          .toList();

      expect(fragments, hasLength(2));
      expect(fragments.first.contentKey, 'lagna_lord_${fact.objectRef}');
    });
  });

  group('C2 myanmar resolution', () {
    test('emits fragments for MYANMAR_POSITION_IS when present', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2, minute: 0),
      );
      final facts = interpretation.bundle.facts
          .where(
            (fact) => fact.predicate == ThaiMeaningPredicate.myanmarPositionIs,
          )
          .toList();
      expect(facts, isNotEmpty);

      final fact = facts.first;
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);
      final fragments = result.bundle.fragments
          .where((fragment) => fragment.sourceFactId == fact.factId)
          .toList();

      expect(fragments, hasLength(2));
      expect(fragments.first.contentKey, fact.objectRef);
    });
  });

  group('C2 mahabhuta resolution', () {
    test('emits fragments for MAHABHUTA_POSITION_IS', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2, minute: 0),
      );
      final fact = _firstFact(
        interpretation,
        ThaiMeaningPredicate.mahabhutaPositionIs,
      );
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);
      final fragments = result.bundle.fragments
          .where((fragment) => fragment.sourceFactId == fact.factId)
          .toList();

      expect(fragments, hasLength(2));
      expect(fragments.first.contentKey, fact.objectRef);
    });
  });

  group('C2 house skipped', () {
    test('HOUSE_SIGN_IS and HOUSE_LORD_IS emit no fragments', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final houseFacts = interpretation.bundle.facts.where(
        (fact) =>
            fact.predicate == ThaiMeaningPredicate.houseSignIs ||
            fact.predicate == ThaiMeaningPredicate.houseLordIs,
      );
      expect(houseFacts, isNotEmpty);

      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);
      final houseFactIds = houseFacts.map((fact) => fact.factId).toSet();

      expect(
        result.bundle.fragments
            .where((fragment) => houseFactIds.contains(fragment.sourceFactId)),
        isEmpty,
      );
      expect(
        result.warnings
            .where(
              (warning) => warning.code.contains('DEFERRED'),
            ),
        isEmpty,
      );
    });
  });

  group('C2 resolutionId determinism', () {
    test('resolutionId matches frozen formula for TC-01 lagna sign', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final fact = _firstFact(interpretation, ThaiMeaningPredicate.lagnaSignIs);
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      final title = result.bundle.fragments.firstWhere(
        (fragment) =>
            fragment.sourceFactId == fact.factId &&
            fragment.fragmentKind == ThaiContentFragmentKind.title,
      );

      final expected = ThaiContentLookupEngine.resolutionId(
        fact: fact,
        fragmentKind: ThaiContentFragmentKind.title,
      );

      expect(title.resolutionId, expected);
      expect(title.resolutionId, 'LAGNA_SIGN_IS:${fact.objectRef}:title');
      expect(_resolutionIdPattern.hasMatch(title.resolutionId), isTrue);
    });

    test('house fact resolutionId helper includes context suffix when present',
        () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final fact = _firstFact(interpretation, ThaiMeaningPredicate.houseSignIs);

      final resolutionId = ThaiContentLookupEngine.resolutionId(
        fact: fact,
        fragmentKind: ThaiContentFragmentKind.coreNature,
      );

      expect(
        resolutionId,
        'HOUSE_SIGN_IS:${fact.objectRef}:'
        '${ThaiMeaningRuleSupport.formatContextSuffix(fact.context)}:'
        'coreNature',
      );
    });
  });

  group('C2 resolutionBundleId determinism', () {
    test('resolutionBundleId matches frozen formula', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      expect(
        result.bundle.resolutionBundleId,
        ThaiContentLookupEngine.resolutionBundleId(
          sourceInterpretationBundleId: interpretation.bundle.bundleId,
        ),
      );
      expect(
        result.bundle.resolutionBundleId,
        '${interpretation.bundle.bundleId}|${ThaiContentLookupContract.resolverVersion}',
      );
      expect(result.bundle.resolutionBundleId, isNot(contains('resolvedAt')));
    });
  });

  group('C2 bundled meaning preservation', () {
    test('fragments do not emit meaningRef in bundled mode', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      expect(
        ThaiMeaningPreservationContract.bundledPipelineEmitMeaningRef,
        isFalse,
      );
      expect(
        result.bundle.fragments.every((fragment) => fragment.meaningRef == null),
        isTrue,
      );
      expect(
        result.bundle.fragments.every(
          (fragment) => fragment.sourceFactId.isNotEmpty,
        ),
        isTrue,
      );
    });
  });

  group('C2 deterministic run', () {
    test('100x lookup yields stable resolutionBundleId and fragments', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2, minute: 0),
      );

      ThaiContentLookupEngineResult? baseline;
      for (var i = 0; i < 100; i++) {
        final result = ThaiContentLookupEngine.lookup(interpretation.bundle);
        baseline ??= result;

        expect(result.bundle.resolutionBundleId, baseline.bundle.resolutionBundleId);
        expect(result.bundle.fragments, baseline.bundle.fragments);
        expect(result.warnings, baseline.warnings);
      }
    });
  });

  group('C2 fragment policy', () {
    test('only title and coreNature kinds are emitted', () {
      final interpretation = _interpret(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );
      final result = ThaiContentLookupEngine.lookup(interpretation.bundle);

      final kinds = result.bundle.fragments
          .map((fragment) => fragment.fragmentKind)
          .toSet();
      for (final kind in kinds) {
        expect(
          ThaiContentLookupContract.supportedFragmentKinds,
          contains(kind),
        );
      }
      expect(
        result.bundle.fragments
            .where(
              (fragment) =>
                  fragment.fragmentKind == ThaiContentFragmentKind.summary ||
                  fragment.fragmentKind == ThaiContentFragmentKind.strength ||
                  fragment.fragmentKind == ThaiContentFragmentKind.challenge ||
                  fragment.fragmentKind == ThaiContentFragmentKind.growthPath,
            ),
        isEmpty,
      );
    });
  });

  group('C2 import boundary validation', () {
    test('engine does not import forbidden packages', () {
      final source = File(
        'lib/features/astrology/thai/content_lookup/thai_content_lookup_engine.dart',
      ).readAsStringSync();

      final forbiddenImportPatterns = [
        'theme/',
        'mirror/',
        'fusion/',
        'interpretation/rules/',
        'interpretation/router/',
        'interpretation/thai_interpretation_engine.dart',
        'signal/',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'engine must not import $pattern',
        );
      }
    });
  });
}
