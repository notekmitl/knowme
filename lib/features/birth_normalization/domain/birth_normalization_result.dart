import 'birth_normalization_reason.dart';
import 'normalized_birth.dart';

/// The outcome of normalization: either a valid [NormalizedBirth] or an
/// explained failure (e.g. missing/unparseable birth date).
class BirthNormalizationResult {
  const BirthNormalizationResult._({
    required this.isValid,
    this.birth,
    this.error,
    this.reasons = const [],
  });

  factory BirthNormalizationResult.success(NormalizedBirth birth) =>
      BirthNormalizationResult._(
        isValid: true,
        birth: birth,
        reasons: birth.reasons,
      );

  factory BirthNormalizationResult.invalid(
    String error, {
    List<BirthNormalizationReason> reasons = const [],
  }) =>
      BirthNormalizationResult._(
        isValid: false,
        error: error,
        reasons: reasons,
      );

  final bool isValid;
  final NormalizedBirth? birth;
  final String? error;
  final List<BirthNormalizationReason> reasons;
}
