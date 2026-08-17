import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'thai_beta_canonical_degree.dart';

/// Deterministic SHA-256 of a Thai report snapshot.
///
/// Keys are sorted recursively before encoding. The ascendant audit degree is
/// normalized to KnowMe's fixed-point boundary contract, including when an old
/// Firestore snapshot still contains the legacy raw double representation.
abstract final class ThaiBetaReportHash {
  static String of(Map<String, dynamic> reportSnapshot) {
    final canonical = jsonEncode(_canonicalize(reportSnapshot));
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      return {
        for (final key in sortedKeys)
          key: key == 'siderealAscendantDeg'
              ? ThaiBetaCanonicalDegree.fromSnapshotValue(value[key])
              : _canonicalize(value[key]),
      };
    }
    if (value is List) {
      return value.map(_canonicalize).toList();
    }
    return value;
  }
}
