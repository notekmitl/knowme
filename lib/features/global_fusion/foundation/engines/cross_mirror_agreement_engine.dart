import 'dart:convert';

import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_findings.dart';

/// GF3 — detects agreement on shared mirror keys across mirror snapshots.
abstract final class CrossMirrorAgreementEngine {
  static List<GlobalFusionCrossMirrorAgreement> detect(
    GlobalFusionInput input,
  ) {
    final byMirrorKey = <String, Map<String, _AgreementCluster>>{};

    for (final ref in input.mirrors) {
      for (final agreement in ref.snapshot.agreements) {
        final roleMap = byMirrorKey.putIfAbsent(
          agreement.mirrorKey,
          () => {},
        );
        final cluster = roleMap.putIfAbsent(
          ref.mirrorRoleId,
          () => _AgreementCluster(
            mirrorKey: agreement.mirrorKey,
            mirrorDimension: agreement.mirrorDimension,
          ),
        );
        cluster.add(agreement);
      }
    }

    final results = <GlobalFusionCrossMirrorAgreement>[];
    for (final entry in byMirrorKey.entries) {
      final roles = entry.value.keys.toList()..sort();
      if (roles.length < 2) continue;

      final themeIds = <String>{};
      final findingIds = <String>[];
      var confidenceSum = 0.0;
      var confidenceCount = 0;
      String mirrorDimension = entry.value.values.first.mirrorDimension;

      for (final role in roles) {
        final cluster = entry.value[role]!;
        themeIds.addAll(cluster.themeIds);
        findingIds.addAll(cluster.findingIds);
        confidenceSum += cluster.meanConfidence;
        confidenceCount++;
      }

      final sortedThemes = themeIds.toList()..sort();
      final sortedFindings = findingIds.toList()..sort();
      final sortedRoles = List<String>.from(roles);
      final agreementStrength = confidenceCount == 0
          ? 0.0
          : (confidenceSum / confidenceCount).clamp(0.0, 1.0);

      results.add(
        GlobalFusionCrossMirrorAgreement(
          id: _findingId(
            prefix: 'gf_agreement',
            mirrorKey: entry.key,
            roles: sortedRoles,
          ),
          mirrorKey: entry.key,
          mirrorDimension: mirrorDimension,
          mirrorRoleIds: sortedRoles,
          mirrorFindingIds: sortedFindings,
          themeIds: sortedThemes,
          confidence: agreementStrength,
          agreementStrength: agreementStrength,
        ),
      );
    }

    results.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return results;
  }

  static String _findingId({
    required String prefix,
    required String mirrorKey,
    required List<String> roles,
  }) {
    final payload = '$prefix|$mirrorKey|${roles.join(',')}';
    return '${prefix}_${sha256Hex(payload)}';
  }

  static String sha256Hex(String input) {
    final bytes = utf8.encode(input);
    return _simpleHash(bytes);
  }

  static String _simpleHash(List<int> bytes) {
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class _AgreementCluster {
  _AgreementCluster({
    required this.mirrorKey,
    required this.mirrorDimension,
  });

  final String mirrorKey;
  final String mirrorDimension;
  final Set<String> themeIds = {};
  final List<String> findingIds = [];
  var _confidenceSum = 0.0;
  var _count = 0;

  double get meanConfidence => _count == 0 ? 0 : _confidenceSum / _count;

  void add(dynamic agreement) {
    themeIds.addAll(agreement.themeIds);
    findingIds.add(agreement.id);
    _confidenceSum += agreement.confidence;
    _count++;
  }
}
