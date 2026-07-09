/// Aggregate-only rollout monitoring for invited-beta evidence badge phase.
///
/// No user data, birth data, Canon ids, or prediction content in payloads.
/// Production wiring remains optional — this module defines safe shapes only.
abstract final class ThaiEvidenceBadgeRolloutMonitoring {
  static const phaseName = 'Public Evidence Badge Rollout Monitoring';

  static const activeFlagState = 'invited_beta';

  static const rollbackRule = 'set thai_public_evidence_badge_beta to off';

  /// Immediate stop criteria — any trigger requires flag rollback to `off`.
  static const stopCriteria = <String>[
    'badge_leaked_to_public_surface',
    'normal_user_saw_badge',
    'anonymous_saw_badge',
    'source_prose_leaked',
    'remedy_leaked',
    'taksa_khumsap_rise_fall_leaked',
    'majority_interprets_badge_as_guarantee',
    'forbidden_wording_appeared',
    'fingerprint_regression_failed',
    'feature_flag_or_allow_list_bypass',
  ];

  /// Keys that must never appear in monitoring or telemetry payloads.
  static const forbiddenPayloadKeys = <String>[
    'unitId',
    'unit_id',
    'canonId',
    'canon_id',
    'ontologyId',
    'ontology_id',
    'sourcePage',
    'source_page',
    'sourceProse',
    'source_prose',
    'evidenceRef',
    'evidence_ref',
    'remedy',
    'birthDate',
    'birth_date',
    'birthTime',
    'birth_time',
    'birthPlace',
    'birth_place',
    'prediction',
    'predictionText',
    'prediction_text',
    'email',
    'uid',
    'userId',
    'user_id',
  ];

  /// Empty aggregate report template — fill during monitoring cycles only.
  static Map<String, Object?> emptyReportTemplate() {
    return {
      'phase': phaseName,
      'reportDate': null,
      'featureFlagState': activeFlagState,
      'publicReleaseActive': false,
      'allUserRolloutActive': false,
      'activeSurface': 'ThaiBetaReportPage',
      'activeRoute': '/beta/thai',
      'testerCount': 0,
      'badgeRenderedCount': 0,
      'eligibleBadgeCount': 0,
      'hiddenCategoryCount': 0,
      'invitedBetaAudienceCount': 0,
      'errorCount': 0,
      'leakageIncidents': 0,
      'confusionReports': 0,
      'overconfidenceReports': 0,
      'remedySourceRequests': 0,
      'rollbackNeeded': false,
      'rollbackRule': rollbackRule,
      'stopCriteria': List<String>.from(stopCriteria),
    };
  }

  /// Returns true when [payload] contains only aggregate-safe keys and values.
  static bool isPayloadPrivacySafe(Map<String, Object?> payload) {
    for (final entry in payload.entries) {
      final keyLower = entry.key.toLowerCase();
      for (final forbidden in forbiddenPayloadKeys) {
        if (keyLower == forbidden.toLowerCase()) {
          return false;
        }
      }
      final value = entry.value;
      if (value is Map) {
        if (!isPayloadPrivacySafe(
          value.map((k, v) => MapEntry(k.toString(), v)),
        )) {
          return false;
        }
      } else if (value is Iterable) {
        for (final item in value) {
          if (item is Map) {
            if (!isPayloadPrivacySafe(
              item.map((k, v) => MapEntry(k.toString(), v)),
            )) {
              return false;
            }
          } else if (_valueContainsForbiddenContent(item.toString())) {
            return false;
          }
        }
      } else if (_valueContainsForbiddenContent(value.toString())) {
        return false;
      }
    }
    return true;
  }

  static bool _valueContainsForbiddenContent(String value) {
    if (RegExp(r'\bp\d+\b').hasMatch(value)) return true;
    if (RegExp(r'unit\.|planet\.|mahabhutPosition\.').hasMatch(value)) {
      return true;
    }
    return false;
  }

  static bool stopCriteriaComplete() =>
      stopCriteria.length >= 10 && stopCriteria.every((c) => c.isNotEmpty);

  static bool rollbackRuleIsFlagOff() =>
      rollbackRule.contains('off') && !rollbackRule.contains('internal_only');
}
