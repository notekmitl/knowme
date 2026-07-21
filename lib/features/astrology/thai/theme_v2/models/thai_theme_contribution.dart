/// Lean contribution line for a [ThaiThemeScore].
///
/// Trace only — no text, provenance copy, or meaning metadata duplication.
class ThaiThemeContribution {
  const ThaiThemeContribution({
    required this.sourceFactId,
    required this.contentKey,
    required this.contribution,
  });

  final String sourceFactId;
  final String contentKey;
  final double contribution;

  factory ThaiThemeContribution.fromMap(Map<String, dynamic> map) {
    final contribution = map['contribution'];
    if (contribution is! num) {
      throw FormatException('Invalid contribution: $contribution');
    }

    return ThaiThemeContribution(
      sourceFactId: _requiredString(
        map['sourceFactId'] ?? map['source_fact_id'],
      ),
      contentKey: _requiredString(map['contentKey'] ?? map['content_key']),
      contribution: contribution.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceFactId': sourceFactId,
      'contentKey': contentKey,
      'contribution': contribution,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeContribution &&
        other.sourceFactId == sourceFactId &&
        other.contentKey == contentKey &&
        other.contribution == contribution;
  }

  @override
  int get hashCode => Object.hash(sourceFactId, contentKey, contribution);

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }
}
