import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_rollback_drill_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_rollback_drill_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_rollback_drill_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

class _FakeAudienceAccess implements ThaiBetaEvidenceBadgeAudienceAccess {
  _FakeAudienceAccess({required this.researchAccess, this.userId});
  final ThaiResearchAccess researchAccess;
  final String? userId;
  @override
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch() => Stream.value(
        ThaiBetaEvidenceBadgeAudienceSnapshot(
          researchAccess: researchAccess,
          userId: userId,
        ),
      );
}

/// Rollback drill — flag off / re-enable internal_only safety validation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiPublicEvidenceBadgeRollbackDrillAudit audit;
  late ThaiCanonEvidenceRepository repository;
  late ThaiBetaAnalysis analysis;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiPublicEvidenceBadgeRollbackDrillRunner.run(
      repository: repository,
    );
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
    analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Test',
        lastName: 'User',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  });

  setUp(() {
    ThaiEvidenceBadgeFeatureFlag.resetToDefault();
  });

  Future<void> pumpReport(
    WidgetTester tester, {
    required ThaiEvidenceBadgeFeatureFlagState flag,
    ThaiBetaEvidenceBadgeAudience? audience,
      ThaiBetaEvidenceBadgeAudienceAccess? access,
    List<ThaiPublicEvidenceBadgeBetaViewModel>? badges,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          featureFlagOverride: flag,
          audienceOverride: audience,
          audienceAccess: access,
          badgeViewModelsOverride: badges ?? const [safeBadge],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ThaiPublicEvidenceBadgeRollbackDrillRunner', () {
    test('writes rollback drill summary artifact', () {
      final map = ThaiPublicEvidenceBadgeRollbackDrillReport.toMap(audit);
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_public_evidence_badge_rollback_drill_summary.json')
          .writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(map['phase'], 'Public Evidence Badge Rollback Drill');
      expect(map['rollbackAction'], 'off');
      expect(map['reEnableAction'], 'internal_only');
    });

    test('overall rollback drill passes', () {
      expect(audit.overallPassed, isTrue);
      expect(audit.rollbackOffPassed, isTrue);
      expect(audit.reEnableInternalOnlyPassed, isTrue);
      expect(audit.fingerprintStableAcrossStates, isTrue);
      expect(audit.systemsNotRolledBack, isTrue);
      expect(audit.leakageViolations, 0);
    });
  });

  group('Rollback drill — internal_only active baseline', () {
    test('1 internal_only admin may see badge', () {
      expect(
        ThaiPublicEvidenceBadgeRollbackDrillValidator.auditReEnableInternalOnly(),
        isTrue,
      );
    });

    testWidgets('1 internal_only admin sees badge on ThaiBetaReportPage', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.admin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });
  });

  group('Rollback drill — flag off', () {
    test('2 off hides badge for admin', () {
      expect(ThaiPublicEvidenceBadgeRollbackDrillValidator.auditRollbackOff(), isTrue);
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.off,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });

    testWidgets('2 off admin does not see badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.admin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('3 off normal user does not see badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.notAdmin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('4 off anonymous does not see badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('5 off invited-beta-only does not see badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    test('dart-define off parses correctly', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('off'),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
    });
  });

  group('Rollback drill — re-enable internal_only', () {
    testWidgets('6 re-enable internal_only admin sees badge again', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.admin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);

      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.admin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });

    testWidgets('7 re-enable normal user still blocked', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        access: _FakeAudienceAccess(researchAccess:ThaiResearchAccess.notAdmin),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('8 re-enable invited-beta-only still blocked', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    test('activation config supports invited_beta after drill', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      expect(
        ThaiEvidenceBadgeFeatureFlag.state,
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      );
    });
  });

  group('Rollback drill — systems not rolled back', () {
    test('9-12 flag changes do not alter Canon enrichment fingerprint', () async {
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

      ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
      final afterOff = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        enriched.pipelineResult,
      );
      expect(before, afterOff);

      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      final afterReEnable = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        enriched.pipelineResult,
      );
      expect(before, afterReEnable);
    });

    test('11 rollback does not change Mirror consumer copy', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
      final viewOff = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      final viewOn = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      expect(
        viewOff.lifeTimeline!.periods.first.summary,
        viewOn.lifeTimeline!.periods.first.summary,
      );
      expect(
        viewOff.lifeTimeline!.periods.first.summary
            .contains(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel),
        isFalse,
      );
    });
  });

  group('Rollback drill — surface isolation', () {
    testWidgets('13 ThaiMirrorResultPage has no badge before or after rollback', (
      tester,
    ) async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      await tester.pumpWidget(
        MaterialApp(home: ThaiMirrorResultPage(consumerState: view)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);

      ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
      await tester.pumpWidget(
        MaterialApp(home: ThaiMirrorResultPage(consumerState: view)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    test('14 Home has no badge import', () {
      final source = File('lib/presentation/pages/home/home_page.dart')
          .readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });

    test('15 Daily Mirror has no badge import', () {
      final source = File(
        'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });
  });

  group('Rollback drill — leakage safety', () {
    testWidgets('16 no forbidden content when re-enabled for admin', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
      );
      final chips = tester
          .widgetList<Chip>(
            find.descendant(
              of: find.byType(ThaiBetaEvidenceBadgePanel),
              matching: find.byType(Chip),
            ),
          )
          .map((chip) => chip.label is Text ? (chip.label as Text).data ?? '' : '')
          .join(' ');
      expect(RegExp(r'\bp\d+\b').hasMatch(chips), isFalse);
      expect(RegExp(r'unit\.|planet\.').hasMatch(chips), isFalse);
      expect(chips.contains('ดวงขึ้น'), isFalse);
      expect(chips.contains('ดวงตก'), isFalse);
      expect(chips.contains('%'), isFalse);
    });
  });

  group('Rollback drill — public fingerprint', () {
    test('17 fingerprint unchanged across internal_only, off, re-enable', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final baseline = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );

      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      final fpInternal = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );

      ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
      final fpOff = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );

      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      final fpReEnable = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );

      expect(fpInternal, baseline);
      expect(fpOff, baseline);
      expect(fpReEnable, baseline);
      expect(audit.fingerprintStableAcrossStates, isTrue);
    });
  });
}
