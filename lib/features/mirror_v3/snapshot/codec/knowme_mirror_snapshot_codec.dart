import 'dart:convert';

import '../constants/knowme_mirror_snapshot_version_contract.dart';
import '../models/knowme_mirror_snapshot.dart';

/// MV3.3 snapshot codec — map/json round-trip without persistence wiring.
abstract final class KnowMeMirrorSnapshotCodec {
  static const codecVersion =
      KnowMeMirrorSnapshotVersionContract.codecVersion;

  static Map<String, dynamic> toMap(KnowMeMirrorSnapshot snapshot) {
    return {
      'codecVersion': codecVersion,
      ...snapshot.toMap(),
    };
  }

  static KnowMeMirrorSnapshot fromMap(Map<String, dynamic> map) {
    final payload = Map<String, dynamic>.from(map)..remove('codecVersion');
    return KnowMeMirrorSnapshot.fromMap(payload);
  }

  static String toJson(KnowMeMirrorSnapshot snapshot) {
    return jsonEncode(toMap(snapshot));
  }

  static KnowMeMirrorSnapshot fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid snapshot json root: $decoded');
    }
    return fromMap(decoded);
  }
}
