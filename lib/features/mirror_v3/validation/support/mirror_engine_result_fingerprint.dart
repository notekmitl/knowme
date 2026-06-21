import '../../engine/models/knowme_mirror_engine_result.dart';

/// Structural fingerprint for consistency comparison.
abstract final class MirrorEngineResultFingerprint {
  static Map<String, dynamic> fromResult(KnowMeMirrorEngineResult result) {
    final mirrors = List.of(result.bundle.mirrors)
      ..sort((a, b) => a.mirrorId.compareTo(b.mirrorId));

    return {
      'structuralHash': result.bundle.structuralHash,
      'mirrorIds': mirrors.map((mirror) => mirror.mirrorId).toList(),
      'compositeConfidence': result.compositeConfidence,
      'agreements': result.agreements.map((item) => item.id).toList()..sort(),
      'tensions': result.tensions.map((item) => item.id).toList()..sort(),
      'reinforcements':
          result.reinforcements.map((item) => item.id).toList()..sort(),
      'blindSpots': result.blindSpots.map((item) => item.id).toList()..sort(),
    };
  }

  static bool equals(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    return _listEquals(a['mirrorIds'], b['mirrorIds']) &&
        a['structuralHash'] == b['structuralHash'] &&
        a['compositeConfidence'] == b['compositeConfidence'] &&
        _listEquals(a['agreements'], b['agreements']) &&
        _listEquals(a['tensions'], b['tensions']) &&
        _listEquals(a['reinforcements'], b['reinforcements']) &&
        _listEquals(a['blindSpots'], b['blindSpots']);
  }

  static bool _listEquals(dynamic a, dynamic b) {
    if (a is! List || b is! List) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
