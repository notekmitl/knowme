import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_readiness_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/application/source_lens_version_resolver.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_entry_status.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_lens_catalog.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_readiness.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_routes.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/astrology_fusion_home_card.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/knowme_journey_section.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

AstrologyChartModel _ariesWesternChart() {
  return AstrologyChartModel.fromMap({
    'big3': {'sun': 'Aries', 'moon': 'Cancer', 'rising': 'Leo'},
    'planets': {},
    'insight': {},
    'overall_summary': {},
  });
}

class _FakeLensProbe extends AstrologyFusionLensProbe {
  _FakeLensProbe(this._result);

  final AstrologyFusionLensProbeResult _result;

  @override
  Future<AstrologyFusionLensProbeResult> probe(String uid) async => _result;
}

void main() {
  group('AstrologyFusionEntryStatus rules', () {
    test('maps lens counts to entry status', () {
      expect(
        AstrologyFusionReadiness.statusForCount(
          completedLensCount: 0,
          totalLensCount: 3,
        ),
        AstrologyFusionEntryStatus.unavailable,
      );
      expect(
        AstrologyFusionReadiness.statusForCount(
          completedLensCount: 1,
          totalLensCount: 3,
        ),
        AstrologyFusionEntryStatus.partiallyAvailable,
      );
      expect(
        AstrologyFusionReadiness.statusForCount(
          completedLensCount: 2,
          totalLensCount: 3,
        ),
        AstrologyFusionEntryStatus.available,
      );
      expect(
        AstrologyFusionReadiness.statusForCount(
          completedLensCount: 3,
          totalLensCount: 3,
        ),
        AstrologyFusionEntryStatus.available,
      );
    });
  });

  group('AstrologyFusionReadinessService', () {
    test('reports one completed lens as partially available', () async {
      final service = AstrologyFusionReadinessService(
        lensProbe: _FakeLensProbe(
          AstrologyFusionLensProbeResult(
            completedLensIds: const ['western_natal'],
            input: AstrologyFusionRealInput(western: _ariesWesternChart()),
          ),
        ),
      );

      final readiness = await service.evaluate('user_1');

      expect(readiness.completedLensCount, 1);
      expect(readiness.totalLensCount, AstrologyFusionLensCatalog.totalLensCount);
      expect(readiness.status, AstrologyFusionEntryStatus.partiallyAvailable);
      expect(readiness.canOpenFusion, isTrue);
    });
  });

  group('AstrologyFusionEntryService', () {
    test('blocks open when no lenses are available', () async {
      final fakeProbe = _FakeLensProbe(
        const AstrologyFusionLensProbeResult(
          completedLensIds: [],
          input: AstrologyFusionRealInput(),
        ),
      );
      final service = AstrologyFusionEntryService(
        lensProbe: fakeProbe,
        readinessService: AstrologyFusionReadinessService(
          lensProbe: fakeProbe,
        ),
        regenerationService: AstrologyFusionRegenerationService(
          repository: InMemoryAstrologyFusionRepository(),
        ),
      );

      final state = await service.evaluate('user_1');

      expect(state.canOpen, isFalse);
      expect(state.readiness.status, AstrologyFusionEntryStatus.unavailable);
      expect(state.snapshotStatus, isNull);
    });

    test('reports up to date snapshot for unchanged lenses', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final input = AstrologyFusionRealInput(western: _ariesWesternChart());
      final versions = SourceLensVersionResolver.fromInput(input);
      final regeneration = AstrologyFusionRegenerationService(
        repository: repository,
      );
      await regeneration.loadOrGenerate(uid: 'user_1', input: input);

      final fakeProbe = _FakeLensProbe(
        AstrologyFusionLensProbeResult(
          completedLensIds: const ['western_natal'],
          input: input,
        ),
      );
      final service = AstrologyFusionEntryService(
        lensProbe: fakeProbe,
        readinessService: AstrologyFusionReadinessService(
          lensProbe: fakeProbe,
        ),
        regenerationService: regeneration,
      );

      final state = await service.evaluate('user_1');

      expect(state.canOpen, isTrue);
      expect(state.isSnapshotUpToDate, isTrue);
      expect(state.needsRefresh, isFalse);
    });
  });

  group('AstrologyFusionHomeCard', () {
    testWidgets('shows unavailable copy without action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstrologyFusionHomeCard(
              entryState: AstrologyFusionEntryState(
                readiness: AstrologyFusionReadiness(
                  completedLensCount: 0,
                  totalLensCount: 3,
                  status: AstrologyFusionEntryStatus.unavailable,
                  completedLensIds: const [],
                ),
                canOpen: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Astrology Fusion'), findsOneWidget);
      expect(find.textContaining('เริ่มต้นด้วยการทำดวงอย่างน้อย 1 ระบบ'),
          findsOneWidget);
      expect(find.text('ดูผลลัพธ์'), findsNothing);
    });

    testWidgets('shows available copy with action button and up to date badge',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstrologyFusionHomeCard(
              entryState: const AstrologyFusionEntryState(
                readiness: AstrologyFusionReadiness(
                  completedLensCount: 3,
                  totalLensCount: 3,
                  status: AstrologyFusionEntryStatus.available,
                  completedLensIds: [
                    'western_natal',
                    'chinese_bazi',
                    'thai_astrology',
                  ],
                ),
                canOpen: true,
                snapshotStatus: AstrologyFusionStatus.upToDate,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fusion พร้อมแล้ว'), findsOneWidget);
      expect(find.text('Up To Date'), findsOneWidget);
      expect(find.text('ดูผลลัพธ์'), findsOneWidget);
    });
  });

  group('HomeDiscoveryHub', () {
    testWidgets('groups astrology before tests and overview sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDiscoveryHub(
                entryState: const AstrologyFusionEntryState(
                  readiness: AstrologyFusionReadiness(
                    completedLensCount: 2,
                    totalLensCount: 3,
                    status: AstrologyFusionEntryStatus.available,
                    completedLensIds: ['western_natal', 'chinese_bazi'],
                  ),
                  canOpen: true,
                ),
                globalFusionEntry: FusionEntryState(canOpen: true),
                personalityMirrorEntry: const PersonalityMirrorEntryState(
                  canOpen: false,
                  canShowFullExperience: false,
                  coverage: null,
                ),
              ),
            ),
          ),
        ),
      );

      final astrologySection =
          tester.getTopLeft(find.text(AppText.t('fusion_v11_lens_astrology')));
      final testsSection =
          tester.getTopLeft(find.text(AppText.t('home_discovery_tests_title')));
      final overviewSection = tester.getTopLeft(
        find.text(AppText.t('home_discovery_overview_title')),
      );
      final fusionOffset = tester.getTopLeft(find.text('Astrology Fusion'));
      final eqOffset = tester.getTopLeft(find.text(AppText.t('fusion_v11_lens_eq')));

      expect(astrologySection.dy, lessThan(testsSection.dy));
      expect(testsSection.dy, lessThan(overviewSection.dy));
      expect(fusionOffset.dy, lessThan(eqOffset.dy));
    });
  });

  group('Navigation', () {
    test('production route name is registered', () {
      expect(AstrologyFusionRoutes.resultRouteName, '/astrology-fusion');
    });
  });
}
