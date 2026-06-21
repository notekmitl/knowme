import '../../foundation/models/thai_astrology_profile.dart';
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
  }) : errorMessage = null;

  const ThaiMirrorPipelineResult.failure({
    required this.errorMessage,
  })  : viewState = null,
        profile = null,
        mirrorResult = null,
        generatedAt = null;

  final ThaiMirrorViewState? viewState;
  final ThaiAstrologyProfile? profile;
  final ThaiMirrorResult? mirrorResult;
  final DateTime? generatedAt;
  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null &&
      viewState != null &&
      profile != null &&
      mirrorResult != null &&
      generatedAt != null;

  bool get isFailure => !isSuccess;
}
