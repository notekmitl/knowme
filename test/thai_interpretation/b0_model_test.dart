import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/interpretation/constants/thai_interpreter_version.dart';
import 'package:knowme/features/astrology/thai/interpretation/contracts/thai_interpretation_contract.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_interpretation_fact_tier.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_bundle.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart';
import 'package:knowme/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart';
import 'package:knowme/features/astrology/thai/signal/constants/thai_signal_extractor_version.dart';

ThaiInterpretationEvidence _sampleEvidence({
  String primarySignalId = 'lagna_sign_virgo',
}) {
  return ThaiInterpretationEvidence(
    primarySignalId: primarySignalId,
    sourceSignalIds: [primarySignalId],
    structuralFactKeys: ['lagna:lagna_virgo'],
    auditRef: 'chart.lagna.signKey',
  );
}

ThaiInterpretationProvenance _sampleProvenance() {
  return ThaiInterpretationProvenance(
    interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
    ruleId: ThaiInterpretationContract.lagnaSignRuleId,
    ruleVersion: 'v1',
    derived: false,
  );
}

ThaiInterpretationFact _sampleFact({
  String factId =
      'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
}) {
  return ThaiInterpretationFact(
    factId: factId,
    predicate: ThaiMeaningPredicate.lagnaSignIs,
    objectRef: 'virgo',
    context: const {},
    tier: ThaiInterpretationFactTier.core,
    evidence: _sampleEvidence(),
    confidence: 0.95,
    provenance: _sampleProvenance(),
  );
}

ThaiInterpretationBundle _sampleBundle() {
  return ThaiInterpretationBundle(
    bundleId: 'bundle-id-placeholder',
    sourceBundleId: 'source-bundle-id-placeholder',
    extractorVersion: ThaiSignalExtractorContract.extractorVersion,
    interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
    interpretedAt: DateTime.utc(2026, 6, 15, 10, 30),
    hasBirthTime: true,
    facts: [_sampleFact()],
    warnings: const [
      ProfileWarning(
        code: 'TEST_WARNING',
        severity: ProfileWarningSeverity.low,
        message: 'test',
      ),
    ],
  );
}

void main() {
  group('B0 model construction', () {
    test('ThaiInterpretationFact holds B0 required fields', () {
      final fact = _sampleFact();

      expect(fact.predicate, ThaiMeaningPredicate.lagnaSignIs);
      expect(fact.predicate.id, 'LAGNA_SIGN_IS');
      expect(fact.objectRef, 'virgo');
      expect(fact.context, isEmpty);
      expect(fact.tier, ThaiInterpretationFactTier.core);
      expect(fact.confidence, 0.95);
      expect(fact.provenance.derived, isFalse);
    });

    test('ThaiInterpretationEvidence enforces primary in source list', () {
      expect(
        () => ThaiInterpretationEvidence(
          primarySignalId: 'lagna_sign_virgo',
          sourceSignalIds: const ['house_1_sign_virgo'],
          structuralFactKeys: const [],
        ),
        throwsArgumentError,
      );
    });

    test('ThaiInterpretationBundle stores bundleId without generating it', () {
      final bundle = _sampleBundle();
      expect(bundle.bundleId, 'bundle-id-placeholder');
      expect(bundle.sourceBundleId, 'source-bundle-id-placeholder');
      expect(bundle.extractorVersion, 'v0.2.0');
      expect(bundle.interpreterVersion, 'v0.1.0');
    });
  });

  group('B0 serialization', () {
    test('ThaiInterpretationFact round-trips through map', () {
      final original = ThaiInterpretationFact(
        factId:
            'house_sign_rule_v1:HOUSE_SIGN_IS:virgo:ctx-houseNumber=10@house_10_sign_virgo',
        predicate: ThaiMeaningPredicate.houseSignIs,
        objectRef: 'virgo',
        context: const {'houseNumber': '10'},
        tier: ThaiInterpretationFactTier.core,
        evidence: ThaiInterpretationEvidence(
          primarySignalId: 'house_10_sign_virgo',
          sourceSignalIds: const ['house_10_sign_virgo'],
          structuralFactKeys: const ['house:10', 'sign:lagna_virgo'],
        ),
        confidence: 0.70,
        provenance: ThaiInterpretationProvenance(
          interpreterVersion: ThaiInterpreterVersionContract.interpreterVersion,
          ruleId: ThaiInterpretationContract.houseSignRuleId,
          ruleVersion: 'v1',
          derived: false,
        ),
      );
      final restored = ThaiInterpretationFact.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.predicate, ThaiMeaningPredicate.houseSignIs);
      expect(restored.context, {'houseNumber': '10'});
    });

    test('ThaiInterpretationBundle round-trips through map', () {
      final original = _sampleBundle();
      final restored = ThaiInterpretationBundle.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.facts, hasLength(1));
      expect(restored.warnings.first.code, 'TEST_WARNING');
    });

    test('predicate and tier parse from string ids', () {
      expect(parseThaiMeaningPredicate('HOUSE_LORD_IS'),
          ThaiMeaningPredicate.houseLordIs);
      expect(parseThaiInterpretationFactTier('core'),
          ThaiInterpretationFactTier.core);
    });
  });

  group('B0 equality', () {
    test('ThaiInterpretationFact value equality', () {
      final left = _sampleFact();
      final right = _sampleFact();
      final different = _sampleFact(
        factId: 'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
      );

      expect(left, right);
      expect(left.hashCode, right.hashCode);
      expect(left == different, isTrue);
    });

    test('ThaiInterpretationBundle value equality', () {
      final left = _sampleBundle();
      final right = _sampleBundle();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });
  });

  group('B0 forbidden field audit', () {
    test('contract allowed and forbidden field names are disjoint', () {
      for (final forbidden in ThaiInterpretationContract.forbiddenFactFieldNames) {
        expect(
          ThaiInterpretationContract.interpretationFactFieldNames,
          isNot(contains(forbidden)),
        );
      }
    });

    test('interpretation model sources do not declare forbidden fields', () {
      final modelPaths = [
        'lib/features/astrology/thai/interpretation/models/thai_interpretation_fact.dart',
        'lib/features/astrology/thai/interpretation/models/thai_interpretation_bundle.dart',
        'lib/features/astrology/thai/interpretation/models/thai_interpretation_evidence.dart',
        'lib/features/astrology/thai/interpretation/models/thai_interpretation_provenance.dart',
      ];

      for (final path in modelPaths) {
        final source = File(path).readAsStringSync();
        for (final forbidden
            in ThaiInterpretationContract.forbiddenFactFieldNames) {
          expect(
            source.contains('final $forbidden'),
            isFalse,
            reason: '$path must not declare forbidden field $forbidden',
          );
          expect(
            source.contains('String $forbidden'),
            isFalse,
            reason: '$path must not declare forbidden field $forbidden',
          );
        }
      }
    });

    test('serialized fact map keys match allowed field names only', () {
      final keys = _sampleFact().toMap().keys.toList();
      for (final key in keys) {
        expect(
          ThaiInterpretationContract.interpretationFactFieldNames,
          contains(key),
        );
      }
    });
  });

  group('B0 import boundary validation', () {
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

      expect(dartFiles, isNotEmpty);

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        for (final pattern in forbiddenImportPatterns) {
          expect(
            RegExp("import '[^']*$pattern").hasMatch(source),
            isFalse,
            reason: '${file.path} must not import $pattern',
          );
          expect(
            RegExp('import "([^"]*$pattern)').hasMatch(source),
            isFalse,
            reason: '${file.path} must not import $pattern',
          );
        }
      }
    });
  });
}
