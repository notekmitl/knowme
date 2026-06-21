import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content_lookup/constants/thai_content_resolver_version.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_content_bundle_identity_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_content_fragment_identity_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_content_lookup_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/contracts/thai_meaning_preservation_contract.dart';
import 'package:knowme/features/astrology/thai/content_lookup/enums/thai_content_fragment_kind.dart';
import 'package:knowme/features/astrology/thai/content_lookup/models/thai_content_fragment.dart';
import 'package:knowme/features/astrology/thai/content_lookup/models/thai_content_fragment_meaning_ref.dart';
import 'package:knowme/features/astrology/thai/content_lookup/models/thai_content_resolution_bundle.dart';
import 'package:knowme/features/astrology/thai/contracts/thai_fact_to_content_key_contract.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/interpretation/enums/thai_meaning_predicate.dart';

ThaiContentFragment _sampleFragment({
  String resolutionId = 'LAGNA_SIGN_IS:virgo:title',
  ThaiContentFragmentKind fragmentKind = ThaiContentFragmentKind.title,
  String text = 'ลัคนากุมภ์',
  String sourceFactId =
      'lagna_sign_rule_v1:LAGNA_SIGN_IS:virgo@lagna_sign_virgo',
  String contentKey = 'lagna_virgo',
  String? contentVersion,
  ThaiContentFragmentMeaningRef? meaningRef,
  int? fragmentIndex,
}) {
  return ThaiContentFragment(
    resolutionId: resolutionId,
    fragmentKind: fragmentKind,
    text: text,
    sourceFactId: sourceFactId,
    contentKey: contentKey,
    contentVersion: contentVersion,
    meaningRef: meaningRef,
    fragmentIndex: fragmentIndex,
  );
}

ThaiContentResolutionBundle _sampleBundle() {
  return ThaiContentResolutionBundle(
    resolutionBundleId: 'interp-bundle-id|v0.1.0',
    sourceInterpretationBundleId: 'interp-bundle-id',
    resolverVersion: ThaiContentResolverVersionContract.resolverVersion,
    resolvedAt: DateTime.utc(2026, 6, 15, 12, 0),
    fragments: [
      _sampleFragment(),
      _sampleFragment(
        resolutionId: 'LAGNA_SIGN_IS:virgo:coreNature',
        fragmentKind: ThaiContentFragmentKind.coreNature,
        text: 'ธาตุดิน คุณสมบัติวิเคราะห์',
      ),
    ],
    warnings: const [
      ProfileWarning(
        code: 'CONTENT_FRAGMENT_FIELD_EMPTY',
        severity: ProfileWarningSeverity.low,
        message: 'test warning',
      ),
    ],
  );
}

void main() {
  group('C0 model construction', () {
    test('ThaiContentFragment holds lean required fields', () {
      final fragment = _sampleFragment();

      expect(fragment.resolutionId, 'LAGNA_SIGN_IS:virgo:title');
      expect(fragment.fragmentKind, ThaiContentFragmentKind.title);
      expect(fragment.text, 'ลัคนากุมภ์');
      expect(fragment.sourceFactId, contains('LAGNA_SIGN_IS'));
      expect(fragment.contentKey, 'lagna_virgo');
      expect(fragment.contentVersion, isNull);
      expect(fragment.meaningRef, isNull);
      expect(fragment.fragmentIndex, isNull);
    });

    test('ThaiContentFragmentMeaningRef stores optional export coordinates', () {
      final meaningRef = ThaiContentFragmentMeaningRef(
        predicate: ThaiMeaningPredicate.lagnaSignIs,
        objectRef: 'virgo',
        context: const {},
      );

      expect(meaningRef.predicate.id, 'LAGNA_SIGN_IS');
      expect(meaningRef.objectRef, 'virgo');
      expect(meaningRef.context, isEmpty);
    });

    test('ThaiContentResolutionBundle stores ids without generating them', () {
      final bundle = _sampleBundle();

      expect(bundle.resolutionBundleId, 'interp-bundle-id|v0.1.0');
      expect(bundle.sourceInterpretationBundleId, 'interp-bundle-id');
      expect(bundle.resolverVersion, 'v0.1.0');
      expect(bundle.fragments, hasLength(2));
    });

    test('ThaiFactToContentKeyContract lists C0 supported predicates', () {
      expect(
        ThaiFactToContentKeyContract.supportedPredicates,
        hasLength(4),
      );
      expect(
        ThaiFactToContentKeyContract.deferredPredicates,
        containsAll([
          ThaiMeaningPredicate.houseSignIs,
          ThaiMeaningPredicate.houseLordIs,
        ]),
      );
    });
  });

  group('C0 serialization', () {
    test('ThaiContentFragment round-trips through map', () {
      final original = _sampleFragment(
        contentVersion: 'v1',
        meaningRef: ThaiContentFragmentMeaningRef(
          predicate: ThaiMeaningPredicate.lagnaSignIs,
          objectRef: 'virgo',
          context: const {},
        ),
        fragmentIndex: 0,
      );
      final restored = ThaiContentFragment.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.meaningRef?.predicate, ThaiMeaningPredicate.lagnaSignIs);
    });

    test('ThaiContentFragmentMeaningRef round-trips through map', () {
      final original = ThaiContentFragmentMeaningRef(
        predicate: ThaiMeaningPredicate.houseSignIs,
        objectRef: 'virgo',
        context: const {'houseNumber': '10'},
      );
      final restored = ThaiContentFragmentMeaningRef.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.context, {'houseNumber': '10'});
    });

    test('ThaiContentResolutionBundle round-trips through map', () {
      final original = _sampleBundle();
      final restored = ThaiContentResolutionBundle.fromMap(original.toMap());

      expect(restored, original);
      expect(restored.fragments, hasLength(2));
      expect(restored.warnings.first.code, 'CONTENT_FRAGMENT_FIELD_EMPTY');
    });

    test('fragment kind parses from string id', () {
      expect(
        parseThaiContentFragmentKind('coreNature'),
        ThaiContentFragmentKind.coreNature,
      );
    });
  });

  group('C0 equality', () {
    test('ThaiContentFragment value equality', () {
      final left = _sampleFragment();
      final right = _sampleFragment();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });

    test('ThaiContentFragment distinguishes optional fields', () {
      final withVersion = _sampleFragment(contentVersion: 'v1');
      final withoutVersion = _sampleFragment();

      expect(withVersion, isNot(withoutVersion));
    });

    test('ThaiContentResolutionBundle value equality', () {
      final left = _sampleBundle();
      final right = _sampleBundle();

      expect(left, right);
      expect(left.hashCode, right.hashCode);
    });
  });

  group('C0 forbidden field audit', () {
    test('allowed and forbidden fragment field names are disjoint', () {
      for (final forbidden
          in ThaiMeaningPreservationContract.forbiddenFragmentFieldNames) {
        expect(
          ThaiMeaningPreservationContract.allowedFragmentFieldNames,
          isNot(contains(forbidden)),
        );
      }
    });

    test('bundled minimum trace fields are allowed', () {
      for (final field
          in ThaiMeaningPreservationContract.bundledMinimumTraceFieldNames) {
        expect(
          ThaiMeaningPreservationContract.allowedFragmentFieldNames,
          contains(field),
        );
      }
    });

    test('content lookup model sources do not declare forbidden fields', () {
      final modelPaths = [
        'lib/features/astrology/thai/content_lookup/models/thai_content_fragment.dart',
        'lib/features/astrology/thai/content_lookup/models/thai_content_fragment_meaning_ref.dart',
        'lib/features/astrology/thai/content_lookup/models/thai_content_resolution_bundle.dart',
      ];

      for (final path in modelPaths) {
        final source = File(path).readAsStringSync();
        for (final forbidden
            in ThaiMeaningPreservationContract.forbiddenFragmentFieldNames) {
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

    test('serialized fragment map keys match allowed field names only', () {
      final keys = _sampleFragment(
        contentVersion: 'v1',
        meaningRef: ThaiContentFragmentMeaningRef(
          predicate: ThaiMeaningPredicate.lagnaSignIs,
          objectRef: 'virgo',
          context: const {},
        ),
      ).toMap().keys.toList();

      for (final key in keys) {
        if (key == 'meaningRef') {
          continue;
        }
        expect(
          ThaiMeaningPreservationContract.allowedFragmentFieldNames,
          contains(key),
        );
      }
    });

    test('frozen contracts document identity formulas without generation', () {
      expect(
        ThaiContentFragmentIdentityContract.resolutionIdFormula,
        contains('predicate.id'),
      );
      expect(
        ThaiContentBundleIdentityContract.resolutionBundleIdFormula,
        contains('sourceInterpretationBundleId'),
      );
      expect(ThaiContentLookupContract.supportedFragmentKinds, hasLength(2));
      expect(
        ThaiMeaningPreservationContract.bundledPipelineEmitMeaningRef,
        isFalse,
      );
    });
  });

  group('C0 import boundary validation', () {
    test('content_lookup sources do not import forbidden packages', () {
      final contentLookupDir = Directory(
        'lib/features/astrology/thai/content_lookup',
      );
      final forbiddenImportPatterns = [
        'theme/',
        'mirror/',
        'fusion/',
        'signal/',
        'interpretation/rules/',
        'interpretation/router/',
        'interpretation/thai_interpretation_engine.dart',
      ];

      final dartFiles = contentLookupDir
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

    test('neutral contract does not import forbidden packages', () {
      final source = File(
        'lib/features/astrology/thai/contracts/thai_fact_to_content_key_contract.dart',
      ).readAsStringSync();

      final forbiddenImportPatterns = [
        'theme/',
        'mirror/',
        'fusion/',
        'signal/',
        'content_lookup/',
        'interpretation/rules/',
        'interpretation/router/',
        'interpretation/thai_interpretation_engine.dart',
      ];

      for (final pattern in forbiddenImportPatterns) {
        expect(
          RegExp("import '[^']*$pattern").hasMatch(source),
          isFalse,
          reason: 'neutral contract must not import $pattern',
        );
      }
    });
  });
}
