/// Serializable agreement finding for snapshot codec.
class KnowMeMirrorSnapshotAgreement {
  const KnowMeMirrorSnapshotAgreement({
    required this.id,
    required this.patternType,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
    required this.supportingSystems,
    required this.supportingLensKeys,
    required this.confidence,
  });

  final String id;
  final String patternType;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> themeIds;
  final List<String> supportingSystems;
  final List<String> supportingLensKeys;
  final double confidence;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternType': patternType,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'themeIds': themeIds,
      'supportingSystems': supportingSystems,
      'supportingLensKeys': supportingLensKeys,
      'confidence': confidence,
    };
  }

  factory KnowMeMirrorSnapshotAgreement.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorSnapshotAgreement(
      id: _requiredString(map['id']),
      patternType: _requiredString(map['patternType']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      themeIds: _stringList(map['themeIds']),
      supportingSystems: _stringList(map['supportingSystems']),
      supportingLensKeys: _stringList(map['supportingLensKeys']),
      confidence: _requiredDouble(map['confidence']),
    );
  }
}

class KnowMeMirrorSnapshotTension {
  const KnowMeMirrorSnapshotTension({
    required this.id,
    required this.patternType,
    required this.mirrorDimension,
    required this.themeIds,
    required this.patternFamilies,
    required this.supportingSystems,
    required this.supportingLensKeys,
    required this.reasonCode,
  });

  final String id;
  final String patternType;
  final String mirrorDimension;
  final List<String> themeIds;
  final List<String> patternFamilies;
  final List<String> supportingSystems;
  final List<String> supportingLensKeys;
  final String reasonCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternType': patternType,
      'mirrorDimension': mirrorDimension,
      'themeIds': themeIds,
      'patternFamilies': patternFamilies,
      'supportingSystems': supportingSystems,
      'supportingLensKeys': supportingLensKeys,
      'reasonCode': reasonCode,
    };
  }

  factory KnowMeMirrorSnapshotTension.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorSnapshotTension(
      id: _requiredString(map['id']),
      patternType: _requiredString(map['patternType']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      themeIds: _stringList(map['themeIds']),
      patternFamilies: _stringList(map['patternFamilies']),
      supportingSystems: _stringList(map['supportingSystems']),
      supportingLensKeys: _stringList(map['supportingLensKeys']),
      reasonCode: _requiredString(map['reasonCode']),
    );
  }
}

class KnowMeMirrorSnapshotReinforcement {
  const KnowMeMirrorSnapshotReinforcement({
    required this.id,
    required this.patternType,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
    required this.supportingSystem,
    required this.supportingLensKey,
    required this.evidenceCount,
    required this.structuralWeight,
  });

  final String id;
  final String patternType;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> themeIds;
  final String supportingSystem;
  final String supportingLensKey;
  final int evidenceCount;
  final double structuralWeight;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternType': patternType,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'themeIds': themeIds,
      'supportingSystem': supportingSystem,
      'supportingLensKey': supportingLensKey,
      'evidenceCount': evidenceCount,
      'structuralWeight': structuralWeight,
    };
  }

  factory KnowMeMirrorSnapshotReinforcement.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorSnapshotReinforcement(
      id: _requiredString(map['id']),
      patternType: _requiredString(map['patternType']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      themeIds: _stringList(map['themeIds']),
      supportingSystem: _requiredString(map['supportingSystem']),
      supportingLensKey: _requiredString(map['supportingLensKey']),
      evidenceCount: _requiredInt(map['evidenceCount']),
      structuralWeight: _requiredDouble(map['structuralWeight']),
    );
  }
}

class KnowMeMirrorSnapshotBlindSpot {
  const KnowMeMirrorSnapshotBlindSpot({
    required this.id,
    required this.patternType,
    required this.mirrorDimension,
    required this.mirrorKey,
    required this.reasonCode,
    required this.availableSystems,
  });

  final String id;
  final String patternType;
  final String mirrorDimension;
  final String? mirrorKey;
  final String reasonCode;
  final List<String> availableSystems;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternType': patternType,
      'mirrorDimension': mirrorDimension,
      'mirrorKey': mirrorKey,
      'reasonCode': reasonCode,
      'availableSystems': availableSystems,
    };
  }

  factory KnowMeMirrorSnapshotBlindSpot.fromMap(Map<String, dynamic> map) {
    final mirrorKey = map['mirrorKey'];
    return KnowMeMirrorSnapshotBlindSpot(
      id: _requiredString(map['id']),
      patternType: _requiredString(map['patternType']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      mirrorKey: mirrorKey is String && mirrorKey.isNotEmpty ? mirrorKey : null,
      reasonCode: _requiredString(map['reasonCode']),
      availableSystems: _stringList(map['availableSystems']),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}

int _requiredInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  throw FormatException('Invalid int: $raw');
}
