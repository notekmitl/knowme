/// Structural metadata — no narrative fields.
class KnowMeMirrorMetadata {
  const KnowMeMirrorMetadata({
    required this.prominence,
    required this.confidence,
    required this.agreementCount,
    required this.sourceCount,
    required this.composite,
  });

  final double prominence;
  final double confidence;
  final int agreementCount;
  final int sourceCount;
  final bool composite;

  Map<String, dynamic> toMap() {
    return {
      'prominence': prominence,
      'confidence': confidence,
      'agreementCount': agreementCount,
      'sourceCount': sourceCount,
      'composite': composite,
    };
  }

  factory KnowMeMirrorMetadata.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorMetadata(
      prominence: _requiredDouble(map['prominence']),
      confidence: _requiredDouble(map['confidence']),
      agreementCount: _requiredInt(map['agreementCount']),
      sourceCount: _requiredInt(map['sourceCount']),
      composite: map['composite'] == true,
    );
  }
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
