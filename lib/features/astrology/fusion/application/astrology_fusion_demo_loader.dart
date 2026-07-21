import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/services/astrology_firestore_service.dart';
import 'package:knowme/services/bazi_firestore_service.dart';

import '../adapters/mock_lenses.dart';
import '../domain/entities/astrology_fusion_status.dart';
import '../domain/entities/astrology_fusion_result.dart';
import '../domain/models/astrology_fusion_real_input.dart';
import '../domain/models/source_lens_versions.dart';
import 'astrology_fusion_generator.dart';
import 'astrology_fusion_regeneration_service.dart';
import 'source_lens_version_resolver.dart';

enum AstrologyFusionDemoSource {
  real,
  mock,
  snapshot,
}

class AstrologyFusionDemoLoadResult {
  const AstrologyFusionDemoLoadResult({
    required this.result,
    required this.source,
    this.status,
  });

  final AstrologyFusionResult result;
  final AstrologyFusionDemoSource source;
  final AstrologyFusionStatus? status;
}

/// Loads fusion output for the internal demo screen.
abstract final class AstrologyFusionDemoLoader {
  static Future<AstrologyFusionDemoLoadResult> load({
    AstrologyFirestoreService? westernService,
    BaziFirestoreService? baziService,
    AstrologyFusionRegenerationService? regenerationService,
    String? uid,
  }) async {
    final resolvedUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      final input = await _loadRealInput(
        uid: resolvedUid,
        westernService: westernService,
        baziService: baziService,
      );

      if (input.western != null || input.bazi != null || input.thai != null) {
        final service =
            regenerationService ?? AstrologyFusionRegenerationService();
        final loadResult = await service.loadOrGenerate(
          uid: resolvedUid,
          input: input,
        );

        return AstrologyFusionDemoLoadResult(
          source: loadResult.usedSnapshot
              ? AstrologyFusionDemoSource.snapshot
              : AstrologyFusionDemoSource.real,
          status: loadResult.status,
          result: loadResult.snapshot.toResult(),
        );
      }
    }

    return AstrologyFusionDemoLoadResult(
      source: AstrologyFusionDemoSource.mock,
      result: AstrologyFusionGenerator.generate(allMockLenses()),
    );
  }

  static Future<AstrologyFusionRealInput> _loadRealInput({
    required String uid,
    AstrologyFirestoreService? westernService,
    BaziFirestoreService? baziService,
  }) async {
    final westernServiceResolved = westernService ?? AstrologyFirestoreService();
    final baziServiceResolved = baziService ?? BaziFirestoreService();

    final western = await westernServiceResolved.getWesternNatalChart(uid);
    final bazi = await baziServiceResolved.getChineseBaziChart(uid);
    final thai = _loadThaiMirror();

    return AstrologyFusionRealInput(
      western: western,
      bazi: bazi,
      thai: thai,
    );
  }

  static ThaiMirrorResult? _loadThaiMirror() {
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    return pipeline.mirrorResult;
  }

  @visibleForTesting
  static AstrologyFusionResult buildFromParts({
    AstrologyChartModel? western,
    BaziChartModel? bazi,
    ThaiMirrorResult? thai,
  }) {
    if (western == null && bazi == null && thai == null) {
      return AstrologyFusionGenerator.generate(allMockLenses());
    }

    return AstrologyFusionGenerator.generateFromRealData(
      AstrologyFusionRealInput(
        western: western,
        bazi: bazi,
        thai: thai,
      ),
    );
  }

  @visibleForTesting
  static SourceLensVersions resolveSourceVersions({
    AstrologyChartModel? western,
    BaziChartModel? bazi,
    ThaiMirrorResult? thai,
  }) {
    return SourceLensVersionResolver.fromInput(
      AstrologyFusionRealInput(
        western: western,
        bazi: bazi,
        thai: thai,
      ),
    );
  }
}
