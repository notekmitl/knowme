import '../../foundation/models/profile_warning.dart';

/// Audit and quality context carried from [ThaiAstrologyProfile].
class ThaiMirrorProfileContext {
  const ThaiMirrorProfileContext({
    required this.hasBirthTime,
    required this.calculationStandardVersion,
    this.warnings = const [],
    this.lagnaKey,
    this.lagnaLordKey,
    this.myanmarKeyCount = 0,
    this.mahabhutaKeyCount = 0,
  });

  final bool hasBirthTime;
  final String calculationStandardVersion;
  final List<ProfileWarning> warnings;
  final String? lagnaKey;
  final String? lagnaLordKey;
  final int myanmarKeyCount;
  final int mahabhutaKeyCount;

  bool get hasLagna => lagnaKey != null;
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorProfileContext &&
        other.hasBirthTime == hasBirthTime &&
        other.calculationStandardVersion == calculationStandardVersion &&
        other.lagnaKey == lagnaKey &&
        other.lagnaLordKey == lagnaLordKey &&
        other.myanmarKeyCount == myanmarKeyCount &&
        other.mahabhutaKeyCount == mahabhutaKeyCount &&
        _warningListEquals(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        hasBirthTime,
        calculationStandardVersion,
        lagnaKey,
        lagnaLordKey,
        myanmarKeyCount,
        mahabhutaKeyCount,
        Object.hashAll(warnings),
      );

  static bool _warningListEquals(
    List<ProfileWarning> a,
    List<ProfileWarning> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
