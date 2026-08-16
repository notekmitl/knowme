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
    this.evidenceSignature = '',
    this.evidenceType = 'computed',
    this.confidence = 'supported',
    this.primaryExpression = '',
    this.permittedCallback = '',
    this.callbackNewInformation = '',
    this.traceabilityReference = '',
    this.excludedFromFreshness = false,
    this.exclusionReason = '',
    this.renderedOutputs = const [],
  }) : callbackKeys = callbackKeys ?? <String>{};

  final String canonicalId;
  final Set<String> evidenceKeys;
  final String role;
  final String section;
  final String domain;
  final String? horizon;
  bool expressed;
  final Set<String> callbackKeys;
  final String evidenceSignature;
  final String evidenceType;
  final String confidence;
  final String primaryExpression;
  final String permittedCallback;
  final String callbackNewInformation;
  final String traceabilityReference;
  final bool excludedFromFreshness;
  final String exclusionReason;
  final List<String> renderedOutputs;

  bool isPresentIn(String canonicalText) =>
      primaryExpression.trim().isNotEmpty &&
      canonicalText.contains(primaryExpression.trim());

  Map<String, Object?> toJson() => {
    'canonicalId': canonicalId,
    'completeEvidenceSignature': evidenceSignature,
    'evidenceKeys': evidenceKeys.toList()..sort(),
    'evidenceType': evidenceType,
    'confidence': confidence,
    'role': role,
    'primaryExpression': primaryExpression,
    'permittedCallback': permittedCallback,
    'callbackNewInformation': callbackNewInformation,
    'renderedSection': section,
    'domain': domain,
    'horizon': horizon,
    'expressed': expressed,
    'traceabilityReference': traceabilityReference,
    'excludedFromFreshness': excludedFromFreshness,
    'exclusionReason': exclusionReason,
    'renderedOutputs': renderedOutputs,
  };
}
