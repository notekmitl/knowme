import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_rollout_monitoring.dart';

/// Rollout monitoring safety guards for invited-beta evidence badge phase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Monitoring payload privacy', () {
    test('1 template payload has no raw Canon ids', () {
      final template = ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate();
      expect(ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe(template), isTrue);
      expect(jsonEncode(template).contains('unit.'), isFalse);
    });

    test('2 template payload has no source page', () {
      final template = ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate();
      expect(template.keys.contains('sourcePage'), isFalse);
      expect(ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe(template), isTrue);
    });

    test('3 template payload has no birth date/time/place', () {
      final template = ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate();
      for (final key in template.keys) {
        expect(key.toLowerCase().contains('birth'), isFalse);
      }
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe({
          'birthDate': '1972-04-04',
        }),
        isFalse,
      );
    });

    test('4 template payload has no remedy data', () {
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe({
          'remedy': 3,
        }),
        isFalse,
      );
    });

    test('5 template payload has no prediction text', () {
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe({
          'predictionText': 'sample',
        }),
        isFalse,
      );
    });

    test('template file matches code template', () {
      final file = File(
        'tool/output/thai_public_evidence_badge_rollout_monitoring_template.json',
      );
      final fromFile = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final fromCode = ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate();
      expect(fromFile['phase'], fromCode['phase']);
      expect(fromFile['featureFlagState'], fromCode['featureFlagState']);
      expect(fromFile['stopCriteria'], fromCode['stopCriteria']);
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe(
          fromFile.map((k, v) => MapEntry(k, v)),
        ),
        isTrue,
      );
    });
  });

  group('Stop criteria and rollback', () {
    test('6 stop criteria complete', () {
      expect(ThaiEvidenceBadgeRolloutMonitoring.stopCriteriaComplete(), isTrue);
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.stopCriteria,
        contains('badge_leaked_to_public_surface'),
      );
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.stopCriteria,
        contains('majority_interprets_badge_as_guarantee'),
      );
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.stopCriteria,
        contains('feature_flag_or_allow_list_bypass'),
      );
    });

    test('7 rollback rule is flag off', () {
      expect(ThaiEvidenceBadgeRolloutMonitoring.rollbackRuleIsFlagOff(), isTrue);
      expect(
        ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate()['rollbackRule'],
        contains('off'),
      );
    });

    test('off hides badge for invited beta audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.off,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });
  });

  group('Active state unchanged', () {
    test('invited_beta remains active configuration', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      expect(
        ThaiEvidenceBadgeFeatureFlag.state,
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      );
    });

    test('monitoring declares public release inactive', () {
      final template = ThaiEvidenceBadgeRolloutMonitoring.emptyReportTemplate();
      expect(template['publicReleaseActive'], isFalse);
      expect(template['allUserRolloutActive'], isFalse);
    });
  });

  group('Public regression', () {
    test('public fingerprint unchanged', () async {
      final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );
      final enriched = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      final after = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        enriched.pipelineResult,
      );
      expect(before, after);
    });
  });
}
