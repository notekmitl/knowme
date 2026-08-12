/// Report-level authority for assigning one semantic claim to one narrative
/// home. This operates before wording so synonym changes cannot bypass the
/// repetition rule.
class ThaiBetaReportClaimLedger {
  final Map<String, ThaiBetaReportClaimAllocation> _allocations = {};

  Iterable<ThaiBetaReportClaimAllocation> get allocations =>
      _allocations.values;

  bool assign(ThaiBetaReportClaimAllocation allocation) {
    final existing = _allocations[allocation.canonicalId];
    if (existing == null) {
      _allocations[allocation.canonicalId] = allocation;
      return true;
    }
    return existing.section == allocation.section &&
        existing.domain == allocation.domain &&
        existing.horizon == allocation.horizon;
  }

  bool callbackAddsInformation({
    required String canonicalId,
    required String newInformationKey,
  }) {
    final existing = _allocations[canonicalId];
    if (existing == null || newInformationKey.trim().isEmpty) return false;
    return existing.callbackKeys.add(newInformationKey.trim());
  }
}

class ThaiBetaReportClaimAllocation {
  ThaiBetaReportClaimAllocation({
    required this.canonicalId,
    required this.evidenceKeys,
    required this.role,
    required this.section,
    required this.domain,
    required this.horizon,
    this.expressed = false,
    Set<String>? callbackKeys,
  }) : callbackKeys = callbackKeys ?? <String>{};

  final String canonicalId;
  final Set<String> evidenceKeys;
  final String role;
  final String section;
  final String domain;
  final String? horizon;
  bool expressed;
  final Set<String> callbackKeys;
}
