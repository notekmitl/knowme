/// Cross-mirror agreement finding (GF3).
class GlobalFusionCrossMirrorAgreement {
  const GlobalFusionCrossMirrorAgreement({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.mirrorRoleIds,
    required this.mirrorFindingIds,
    required this.themeIds,
    required this.confidence,
    required this.agreementStrength,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> mirrorRoleIds;
  final List<String> mirrorFindingIds;
  final List<String> themeIds;
  final double confidence;
  final double agreementStrength;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'mirrorRoleIds': mirrorRoleIds,
      'mirrorFindingIds': mirrorFindingIds,
      'themeIds': themeIds,
      'confidence': confidence,
      'agreementStrength': agreementStrength,
    };
  }

  factory GlobalFusionCrossMirrorAgreement.fromMap(Map<String, dynamic> map) {
    return GlobalFusionCrossMirrorAgreement(
      id: _requiredString(map['id']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      mirrorRoleIds: _stringList(map['mirrorRoleIds']),
      mirrorFindingIds: _stringList(map['mirrorFindingIds']),
      themeIds: _stringList(map['themeIds']),
      confidence: _requiredDouble(map['confidence']),
      agreementStrength: _requiredDouble(map['agreementStrength']),
    );
  }
}

/// Cross-mirror tension finding (GF4).
class GlobalFusionCrossMirrorTension {
  const GlobalFusionCrossMirrorTension({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.positiveMirrorRoleId,
    required this.tensionMirrorRoleId,
    required this.positiveMirrorFindingId,
    required this.tensionMirrorFindingId,
    required this.themeIds,
    required this.reasonCode,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final String positiveMirrorRoleId;
  final String tensionMirrorRoleId;
  final String positiveMirrorFindingId;
  final String tensionMirrorFindingId;
  final List<String> themeIds;
  final String reasonCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'positiveMirrorRoleId': positiveMirrorRoleId,
      'tensionMirrorRoleId': tensionMirrorRoleId,
      'positiveMirrorFindingId': positiveMirrorFindingId,
      'tensionMirrorFindingId': tensionMirrorFindingId,
      'themeIds': themeIds,
      'reasonCode': reasonCode,
    };
  }

  factory GlobalFusionCrossMirrorTension.fromMap(Map<String, dynamic> map) {
    return GlobalFusionCrossMirrorTension(
      id: _requiredString(map['id']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      positiveMirrorRoleId: _requiredString(map['positiveMirrorRoleId']),
      tensionMirrorRoleId: _requiredString(map['tensionMirrorRoleId']),
      positiveMirrorFindingId: _requiredString(map['positiveMirrorFindingId']),
      tensionMirrorFindingId: _requiredString(map['tensionMirrorFindingId']),
      themeIds: _stringList(map['themeIds']),
      reasonCode: _requiredString(map['reasonCode']),
    );
  }
}

/// Cross-mirror reinforcement finding (GF5).
class GlobalFusionCrossMirrorReinforcement {
  const GlobalFusionCrossMirrorReinforcement({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.mirrorRoleIds,
    required this.mirrorFindingIds,
    required this.themeIds,
    required this.evidenceCount,
    required this.reinforcementBoost,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> mirrorRoleIds;
  final List<String> mirrorFindingIds;
  final List<String> themeIds;
  final int evidenceCount;
  final double reinforcementBoost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'mirrorRoleIds': mirrorRoleIds,
      'mirrorFindingIds': mirrorFindingIds,
      'themeIds': themeIds,
      'evidenceCount': evidenceCount,
      'reinforcementBoost': reinforcementBoost,
    };
  }

  factory GlobalFusionCrossMirrorReinforcement.fromMap(
    Map<String, dynamic> map,
  ) {
    return GlobalFusionCrossMirrorReinforcement(
      id: _requiredString(map['id']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      mirrorRoleIds: _stringList(map['mirrorRoleIds']),
      mirrorFindingIds: _stringList(map['mirrorFindingIds']),
      themeIds: _stringList(map['themeIds']),
      evidenceCount: _requiredInt(map['evidenceCount']),
      reinforcementBoost: _requiredDouble(map['reinforcementBoost']),
    );
  }
}

/// Cross-mirror blind spot candidate (GF6).
class GlobalFusionCrossMirrorBlindSpot {
  const GlobalFusionCrossMirrorBlindSpot({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.reflectingMirrorRoleId,
    required this.blindMirrorRoleId,
    required this.reflectingMirrorFindingId,
    required this.blindMirrorFindingId,
    required this.reasonCode,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final String reflectingMirrorRoleId;
  final String blindMirrorRoleId;
  final String reflectingMirrorFindingId;
  final String blindMirrorFindingId;
  final String reasonCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'reflectingMirrorRoleId': reflectingMirrorRoleId,
      'blindMirrorRoleId': blindMirrorRoleId,
      'reflectingMirrorFindingId': reflectingMirrorFindingId,
      'blindMirrorFindingId': blindMirrorFindingId,
      'reasonCode': reasonCode,
    };
  }

  factory GlobalFusionCrossMirrorBlindSpot.fromMap(Map<String, dynamic> map) {
    return GlobalFusionCrossMirrorBlindSpot(
      id: _requiredString(map['id']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      reflectingMirrorRoleId: _requiredString(map['reflectingMirrorRoleId']),
      blindMirrorRoleId: _requiredString(map['blindMirrorRoleId']),
      reflectingMirrorFindingId:
          _requiredString(map['reflectingMirrorFindingId']),
      blindMirrorFindingId: _requiredString(map['blindMirrorFindingId']),
      reasonCode: _requiredString(map['reasonCode']),
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
