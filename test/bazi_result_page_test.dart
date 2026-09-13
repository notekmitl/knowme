import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/presentation/pages/bazi/bazi_result_page.dart';
import 'package:knowme/presentation/providers/bazi_provider.dart';
import 'package:knowme/presentation/providers/locale_provider.dart';
import 'package:knowme/services/profile_service.dart';
import 'package:provider/provider.dart';

class _NoopLensProbe implements AstrologyFusionLensProbe {
  _NoopLensProbe([this.completedLensIds = const []]);

  final List<String> completedLensIds;

  @override
  Future<AstrologyFusionLensProbeResult> probe(String uid) async {
    return AstrologyFusionLensProbeResult(
      completedLensIds: completedLensIds,
      input: AstrologyFusionRealInput(),
    );
  }
}

class _NoopFusionRepository implements AstrologyFusionRepository {
  @override
  Future<void> deleteFusion(String uid) async {}

  @override
  Future<AstrologyFusionSnapshot?> loadFusion(String uid) async => null;

  @override
  Future<void> saveFusion(String uid, AstrologyFusionSnapshot snapshot) async {}
}

AstrologyGenerationCoordinator _readyCoordinator({
  bool generationFails = false,
}) {
  const profile = ProfileModel(
    name: 'Test User',
    gender: 'male',
    birthDate: '1990-05-12',
    birthTime: '15:30',
    birthPlace: 'Bangkok, Thailand',
    latitude: 13.7563,
    longitude: 100.5018,
    timezone: 'Asia/Bangkok',
  );
  return AstrologyGenerationCoordinator(
    profileService: ProfileService.testing((_) async => profile),
    lensProbe: _NoopLensProbe([AstrologyLens.chineseBazi.lensId]),
    fusionRepository: _NoopFusionRepository(),
    fusionService: AstrologyFusionRegenerationService(
      repository: InMemoryAstrologyFusionRepository(),
    ),
    generateBazi: (_, _) async {
      if (generationFails) throw StateError('generation failed');
    },
    generateWestern: (_, _) async {},
    loadBaziInputHash: (_) async => generationFails
        ? 'stale-input-hash'
        : '7e5deacba21e9abc250024b1448bcf902b6efd41f1c4f4a121be0bdcc1a0154b',
  );
}

Widget _wrap(Widget child, BaziProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<BaziProvider>.value(value: provider),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('shows failed state when chart is null', (tester) async {
    final provider = BaziProvider(loadChartFn: (_) async => null);

    await tester.pumpWidget(
      _wrap(
        BaziResultPage(
          userId: 'test-uid',
          generationCoordinator: _readyCoordinator(),
        ),
        provider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AstrologyFlowCopy.failedTitle), findsOneWidget);
    expect(find.text(AstrologyFlowCopy.retryCta), findsOneWidget);
  });

  testWidgets('renders the fact-only Compatibility V1 projection', (
    tester,
  ) async {
    final chart = BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known);
    final provider = BaziProvider(loadChartFn: (_) async => chart);

    await tester.pumpWidget(
      _wrap(
        BaziResultPage(
          userId: 'test-uid',
          generationCoordinator: _readyCoordinator(),
        ),
        provider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KnowMe BaZi Compatibility V1'), findsWidgets);
    expect(find.textContaining('ไม่ใช่มาตรฐานสากล'), findsOneWidget);
    expect(find.text('ผลเสาหลักที่ยืนยันได้'), findsOneWidget);
    expect(find.text('庚午 (geng/wu) — ทอง + ไฟ'), findsOneWidget);
    expect(find.byKey(const Key('bazi-export-pdf')), findsOneWidget);

    expect(find.text('Strengths'), findsNothing);
    expect(find.text('Growth Areas'), findsNothing);
    expect(find.text('Year Zodiac Personality'), findsNothing);
    expect(find.text('Overall Chinese Lens Summary'), findsNothing);
  });

  testWidgets('does not expose a stale chart when regeneration fails', (
    tester,
  ) async {
    final chart = BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known);
    final provider = BaziProvider(loadChartFn: (_) async => chart);

    await tester.pumpWidget(
      _wrap(
        BaziResultPage(
          userId: 'stale-test-uid',
          generationCoordinator: _readyCoordinator(generationFails: true),
        ),
        provider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AstrologyFlowCopy.failedTitle), findsOneWidget);
    expect(find.text('ผลเสาหลักที่ยืนยันได้'), findsNothing);
  });
}
