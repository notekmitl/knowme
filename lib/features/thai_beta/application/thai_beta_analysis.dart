import 'package:flutter/foundation.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/normalized_birth.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';

import '../domain/thai_beta_engine_versions.dart';
import '../domain/thai_beta_input.dart';
import '../domain/thai_beta_normalized_snapshot.dart';
import '../domain/thai_beta_report_hash.dart';
import '../domain/thai_beta_report_snapshot.dart';

/// Result of running the beta analysis for one submission.
class ThaiBetaAnalysis {
  const ThaiBetaAnalysis._({
    required this.input,
    required this.startedAt,
    this.normalizedBirth,
    this.normalizedSnapshot,
    this.consumerViewState,
    this.profile,
    this.engineVersions,
    this.reportSnapshot,
    this.reportHash,
    this.pipelineResult,
    this.errorMessage,
  });

  final ThaiBetaInput input;

  /// When the research session began (carried through to [durationSeconds]).
  final DateTime startedAt;

  final NormalizedBirth? normalizedBirth;
  final ThaiBetaNormalizedSnapshot? normalizedSnapshot;
  final ThaiMirrorConsumerViewState? consumerViewState;
  final ThaiAstrologyProfile? profile;
  final ThaiBetaEngineVersions? engineVersions;
  final Map<String, dynamic>? reportSnapshot;

  /// SHA-256 of [reportSnapshot]; null on failure.
  final String? reportHash;

  /// Full pipeline output for internal/beta Canon evidence enrichment only.
  final ThaiMirrorPipelineResult? pipelineResult;

  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null &&
      consumerViewState != null &&
      normalizedSnapshot != null &&
      profile != null;

  /// Test-only failed analysis (no engine run). Used to prove export state
  /// clears on failure without inventing prediction output.
  @visibleForTesting
  factory ThaiBetaAnalysis.failedForTest({
    required ThaiBetaInput input,
    DateTime? startedAt,
    String errorMessage = 'ไม่สามารถสร้างผลวิเคราะห์ได้',
  }) {
    return ThaiBetaAnalysis._(
      input: input,
      startedAt: startedAt ?? DateTime.now(),
      errorMessage: errorMessage,
    );
  }
}

/// The beta's single entry point: turns user input into the existing Thai report.
///
/// Flow (no new astrology pipeline):
/// `ThaiBetaInput → RawBirthInput → BirthNormalizer → ThaiEngineAdapter →
/// ThaiMirrorPipeline → existing Thai report view state`.
abstract final class ThaiBetaAnalysisRunner {
  static ThaiBetaAnalysis run(ThaiBetaInput input, {DateTime? startedAt}) {
    final sessionStart = startedAt ?? DateTime.now();
    final raw = RawBirthInput(
      birthDate: input.birthDate,
      birthHour: input.hasBirthTime ? input.birthHour : null,
      birthMinute: input.birthMinute,
      // English resolver key drives coordinate lookup; Thai label is the display.
      province: input.provinceKey ?? input.province,
      placeLabel: input.province,
      timeZoneId: 'Asia/Bangkok',
    );

    final normalization = BirthNormalizer.normalize(raw);
    final birth = normalization.birth;
    if (!normalization.isValid || birth == null) {
      return ThaiBetaAnalysis._(
        input: input,
        startedAt: sessionStart,
        errorMessage:
            normalization.error ?? 'ไม่สามารถประมวลผลข้อมูลวันเกิดได้',
      );
    }

    final birthData = ThaiEngineAdapter.fromContext(birth.thai);
    final pipeline = ThaiMirrorPipeline.generate(birthData);
    if (pipeline.isFailure ||
        pipeline.mirrorResult == null ||
        pipeline.profile == null) {
      return ThaiBetaAnalysis._(
        input: input,
        startedAt: sessionStart,
        normalizedBirth: birth,
        normalizedSnapshot:
            ThaiBetaNormalizedSnapshot.fromNormalizedBirth(birth),
        errorMessage: pipeline.errorMessage ?? 'ไม่สามารถสร้างผลวิเคราะห์ได้',
      );
    }

    final view = ThaiMirrorConsumerPresenter.present(
      pipeline.mirrorResult!,
      lifePeriods: pipeline.lifePeriods,
    );
    final profile = pipeline.profile!;
    final reportSnapshot =
        ThaiBetaReportSnapshot.build(profile: profile, view: view);

    return ThaiBetaAnalysis._(
      input: input,
      startedAt: sessionStart,
      normalizedBirth: birth,
      normalizedSnapshot: ThaiBetaNormalizedSnapshot.fromNormalizedBirth(birth),
      consumerViewState: view,
      profile: profile,
      engineVersions: ThaiBetaEngineVersions(
        thaiFoundationVersion: profile.calculationStandardVersion,
        birthNormalizationVersion:
            ThaiBetaEngineVersions.currentBirthNormalizationVersion,
        betaSchemaVersion: ThaiBetaEngineVersions.currentBetaSchemaVersion,
      ),
      reportSnapshot: reportSnapshot,
      reportHash: ThaiBetaReportHash.of(reportSnapshot),
      pipelineResult: pipeline,
    );
  }
}
