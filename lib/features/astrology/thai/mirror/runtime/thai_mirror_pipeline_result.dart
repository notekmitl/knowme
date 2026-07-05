import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';

import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../models/thai_mirror_result.dart';
import '../presentation/thai_mirror_view_state.dart';

/// Outcome of [ThaiMirrorPipeline.generate] — success or captured failure.
///
/// Never throws to callers; inspect [isSuccess] before reading payload fields.
class ThaiMirrorPipelineResult {
  const ThaiMirrorPipelineResult.success({
    required this.viewState,
    required this.profile,
    required this.mirrorResult,
    required this.generatedAt,
    required this.birthData,
    this.lifePeriods,
  }) : errorMessage = null;

  const ThaiMirrorPipelineResult.failure({
    required this.errorMessage,
  })  : viewState = null,
        profile = null,
        mirrorResult = null,
        generatedAt = null,
        birthData = null,
        lifePeriods = null;

  final ThaiMirrorViewState? viewState;
  final ThaiAstrologyProfile? profile;
  final ThaiMirrorResult? mirrorResult;
  final DateTime? generatedAt;
  final ThaiBirthData? birthData;

  /// Life Period Engine *evidence* (computed from the canonical birth profile).
  /// Drives the V8 Life Timeline. Null when birth date is unavailable.
  final LifeTimeline? lifePeriods;
  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null &&
      viewState != null &&
      profile != null &&
      mirrorResult != null &&
      generatedAt != null;

  bool get isFailure => !isSuccess;
}
