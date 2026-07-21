import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Deterministic SHA-256 of a Thai report snapshot.
///
/// Keys are sorted recursively before encoding so the hash is stable regardless
/// of map ordering — two identical reports always yield the same [reportHash],
/// giving research a tamper-evident fingerprint of exactly what the user saw.
abstract final class ThaiBetaReportHash {
  static String of(Map<String, dynamic> reportSnapshot) {
    final canonical = jsonEncode(_canonicalize(reportSnapshot));
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      return {
        for (final key in sortedKeys) key: _canonicalize(value[key]),
      };
    }
    if (value is List) {
      return value.map(_canonicalize).toList();
    }
    return value;
  }
}
