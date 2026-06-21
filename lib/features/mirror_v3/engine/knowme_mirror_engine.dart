import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../constants/knowme_mirror_version_contract.dart';
import '../models/knowme_mirror_chart_bundle.dart';
import '../models/knowme_mirror_object.dart';
import 'engines/knowme_mirror_agreement_engine.dart';
import 'engines/knowme_mirror_blind_spot_engine.dart';
import 'engines/knowme_mirror_confidence_composer.dart';
import 'engines/knowme_mirror_reinforcement_engine.dart';
import 'engines/knowme_mirror_tension_engine.dart';
import 'knowme_mirror_evidence_preserver.dart';
import 'models/knowme_mirror_engine_input.dart';
import 'models/knowme_mirror_engine_result.dart';

/// MV1 shared reflection engine for cross-system synthesis.
abstract final class KnowMeMirrorEngine {
  static KnowMeMirrorEngineResult reflect(KnowMeMirrorEngineInput input) {
    final signals = input.signals;
    final availableSystems =
        signals.map((signal) => signal.systemId).toSet();

    final agreements = KnowMeMirrorAgreementEngine.detect(signals);
    final tensions = KnowMeMirrorTensionEngine.detect(signals);
    final reinforcements = KnowMeMirrorReinforcementEngine.detect(signals);
    final blindSpots = KnowMeMirrorBlindSpotEngine.detect(
      signals: signals,
      availableSystems: availableSystems,
    );

    final compositeConfidence = KnowMeMirrorConfidenceComposer.compose(
      signals: signals,
      agreements: agreements,
      tensions: tensions,
      reinforcements: reinforcements,
      blindSpots: blindSpots,
    );

    final mirrors = KnowMeMirrorEvidencePreserver.buildMirrorObjects(
      lineage: input.lineage,
      signals: signals,
      agreements: agreements,
      compositeConfidence: compositeConfidence,
    );

    final bundle = KnowMeMirrorChartBundle(
      mirrorBundleId: _mirrorBundleId(input.lineage.mirrorScopeId),
      mirrorDomainVersion: KnowMeMirrorVersionContract.mirrorDomainVersion,
      mirrorScopeId: input.lineage.mirrorScopeId,
      generatedAt: input.generatedAt.toUtc(),
      lineage: input.lineage,
      mirrors: mirrors,
      structuralHash: _structuralHash(
        mirrorScopeId: input.lineage.mirrorScopeId,
        mirrors: mirrors,
      ),
    );

    return KnowMeMirrorEngineResult(
      bundle: bundle,
      agreements: agreements,
      tensions: tensions,
      reinforcements: reinforcements,
      blindSpots: blindSpots,
      compositeConfidence: compositeConfidence,
    );
  }

  static String _mirrorBundleId(String mirrorScopeId) {
    return '$mirrorScopeId|${KnowMeMirrorVersionContract.mirrorDomainVersion}';
  }

  static String _structuralHash({
    required String mirrorScopeId,
    required List<KnowMeMirrorObject> mirrors,
  }) {
    final canonical = jsonEncode({
      'mirrorScopeId': mirrorScopeId,
      'mirrorDomainVersion': KnowMeMirrorVersionContract.mirrorDomainVersion,
      'mirrors': mirrors.map((mirror) => mirror.toMap()).toList(),
    });
    return sha256.convert(utf8.encode(canonical)).toString();
  }
}
