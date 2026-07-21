/// Rule provenance for a [ThaiInterpretationFact].

class ThaiInterpretationProvenance {

  const ThaiInterpretationProvenance({

    required this.interpreterVersion,

    required this.ruleId,

    required this.ruleVersion,

    required this.derived,

  });



  final String interpreterVersion;

  final String ruleId;

  final String ruleVersion;

  final bool derived;



  factory ThaiInterpretationProvenance.fromMap(Map<String, dynamic> map) {

    return ThaiInterpretationProvenance(

      interpreterVersion: _requiredString(map['interpreterVersion']),

      ruleId: _requiredString(map['ruleId']),

      ruleVersion: _requiredString(map['ruleVersion']),

      derived: map['derived'] == true,

    );

  }



  Map<String, dynamic> toMap() {

    return {

      'interpreterVersion': interpreterVersion,

      'ruleId': ruleId,

      'ruleVersion': ruleVersion,

      'derived': derived,

    };

  }



  @override

  bool operator ==(Object other) {

    return other is ThaiInterpretationProvenance &&

        other.interpreterVersion == interpreterVersion &&

        other.ruleId == ruleId &&

        other.ruleVersion == ruleVersion &&

        other.derived == derived;

  }



  @override

  int get hashCode =>

      Object.hash(interpreterVersion, ruleId, ruleVersion, derived);



  static String _requiredString(dynamic raw) {

    if (raw is! String || raw.trim().isEmpty) {

      throw FormatException('Invalid provenance string: $raw');

    }

    return raw.trim();

  }

}


