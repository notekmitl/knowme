/// Internal Taksa role runtime key — metadata only, never user-facing.
///
/// Allowed ids match frozen Canon `taksaRole.*` ontology exactly.
abstract final class ThaiTaksaRoleRuntimeKey {
  static const boriwan = 'taksaRole.boriwan';
  static const ayu = 'taksaRole.ayu';
  static const det = 'taksaRole.det';
  static const sri = 'taksaRole.sri';
  static const mula = 'taksaRole.mula';
  static const utsaha = 'taksaRole.utsaha';
  static const montri = 'taksaRole.montri';
  static const kalakini = 'taksaRole.kalakini';

  static const allowedIds = {
    boriwan,
    ayu,
    det,
    sri,
    mula,
    utsaha,
    montri,
    kalakini,
  };

  /// Exact Thai labels from frozen Canon ontology (no meanings).
  static const primaryThaiLabels = {
    boriwan: 'บริวาร',
    ayu: 'อายุ',
    det: 'เดช',
    sri: 'ศรี',
    mula: 'มูละ',
    utsaha: 'อุตสาหะ',
    montri: 'มนตรี',
    kalakini: 'กาฬกิณี',
  };

  static bool isAllowed(String? id) => id != null && allowedIds.contains(id);
}

/// Skipped-reason when Taksa Canon evidence has no runtime/report signal.
abstract final class TaksaRuntimeSkippedReason {
  static const noRuntimeTaksaSignal = 'NO_RUNTIME_TAKSA_SIGNAL';
}
