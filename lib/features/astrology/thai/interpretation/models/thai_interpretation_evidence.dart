// Signal evidence attached to a ThaiInterpretationFact.
class ThaiInterpretationEvidence {

  ThaiInterpretationEvidence({
    required this.primarySignalId,
    required this.sourceSignalIds,
    required this.structuralFactKeys,
    this.auditRef,
  }) {
    if (sourceSignalIds.isEmpty) {
      throw ArgumentError.value(
        sourceSignalIds,
        'sourceSignalIds',
        'must not be empty',
      );
    }
    if (!sourceSignalIds.contains(primarySignalId)) {
      throw ArgumentError.value(
        primarySignalId,
        'primarySignalId',
        'must be included in sourceSignalIds',
      );
    }
  }



  final String primarySignalId;

  final List<String> sourceSignalIds;

  final List<String> structuralFactKeys;

  final String? auditRef;



  factory ThaiInterpretationEvidence.fromMap(Map<String, dynamic> map) {

    final primarySignalId = map['primarySignalId'];

    if (primarySignalId is! String || primarySignalId.trim().isEmpty) {

      throw FormatException('Invalid primarySignalId: $primarySignalId');

    }



    final sourceSignalIds = _stringList(map['sourceSignalIds']);

    if (sourceSignalIds.isEmpty) {

      throw FormatException('sourceSignalIds must not be empty');

    }



    if (!sourceSignalIds.contains(primarySignalId.trim())) {

      throw FormatException(

        'primarySignalId must be included in sourceSignalIds',

      );

    }



    return ThaiInterpretationEvidence(

      primarySignalId: primarySignalId.trim(),

      sourceSignalIds: List<String>.unmodifiable(sourceSignalIds),

      structuralFactKeys:

          List<String>.unmodifiable(_stringList(map['structuralFactKeys'])),

      auditRef: _optionalString(map['auditRef']),

    );

  }



  Map<String, dynamic> toMap() {

    return {

      'primarySignalId': primarySignalId,

      'sourceSignalIds': sourceSignalIds,

      'structuralFactKeys': structuralFactKeys,

      if (auditRef != null) 'auditRef': auditRef,

    };

  }



  @override

  bool operator ==(Object other) {

    return other is ThaiInterpretationEvidence &&

        other.primarySignalId == primarySignalId &&

        _listEquals(other.sourceSignalIds, sourceSignalIds) &&

        _listEquals(other.structuralFactKeys, structuralFactKeys) &&

        other.auditRef == auditRef;

  }



  @override

  int get hashCode => Object.hash(

        primarySignalId,

        Object.hashAll(sourceSignalIds),

        Object.hashAll(structuralFactKeys),

        auditRef,

      );



  static List<String> _stringList(dynamic raw) {

    if (raw is! List) return const [];

    return raw

        .whereType<String>()

        .map((item) => item.trim())

        .where((item) => item.isNotEmpty)

        .toList(growable: false);

  }



  static String? _optionalString(dynamic raw) {

    if (raw is! String) return null;

    final trimmed = raw.trim();

    return trimmed.isEmpty ? null : trimmed;

  }



  static bool _listEquals(List<String> a, List<String> b) {

    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {

      if (a[i] != b[i]) return false;

    }

    return true;

  }

}


