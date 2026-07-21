import '../enums/thai_interpretation_fact_tier.dart';

import '../enums/thai_meaning_predicate.dart';

import 'thai_interpretation_evidence.dart';

import 'thai_interpretation_provenance.dart';



/// Meaning assertion derived from [ThaiSignal] values.

///

/// Structural meaning only — no content text, themes, or domain taxonomy.

class ThaiInterpretationFact {

  const ThaiInterpretationFact({

    required this.factId,

    required this.predicate,

    required this.objectRef,

    required this.context,

    required this.tier,

    required this.evidence,

    required this.confidence,

    required this.provenance,

  });



  final String factId;

  final ThaiMeaningPredicate predicate;

  final String objectRef;

  final Map<String, String> context;

  final ThaiInterpretationFactTier tier;

  final ThaiInterpretationEvidence evidence;

  final double confidence;

  final ThaiInterpretationProvenance provenance;



  factory ThaiInterpretationFact.fromMap(Map<String, dynamic> map) {

    final predicateRaw = map['predicate'];

    ThaiMeaningPredicate? predicate;

    if (predicateRaw is ThaiMeaningPredicate) {

      predicate = predicateRaw;

    } else if (predicateRaw is String) {

      predicate = parseThaiMeaningPredicate(predicateRaw);

    }

    if (predicate == null) {

      throw FormatException('Invalid predicate: $predicateRaw');

    }



    final tierRaw = map['tier'];

    ThaiInterpretationFactTier? tier;

    if (tierRaw is ThaiInterpretationFactTier) {

      tier = tierRaw;

    } else if (tierRaw is String) {

      tier = parseThaiInterpretationFactTier(tierRaw);

    }

    if (tier == null) {

      throw FormatException('Invalid tier: $tierRaw');

    }



    final evidenceRaw = map['evidence'];

    if (evidenceRaw is! Map) {

      throw FormatException('Invalid evidence: $evidenceRaw');

    }



    final provenanceRaw = map['provenance'];

    if (provenanceRaw is! Map) {

      throw FormatException('Invalid provenance: $provenanceRaw');

    }



    final confidence = map['confidence'];

    if (confidence is! num) {

      throw FormatException('Invalid confidence: $confidence');

    }



    return ThaiInterpretationFact(

      factId: _requiredString(map['factId']),

      predicate: predicate,

      objectRef: _requiredString(map['objectRef']),

      context: _stringMap(map['context']),

      tier: tier,

      evidence: ThaiInterpretationEvidence.fromMap(

        Map<String, dynamic>.from(evidenceRaw),

      ),

      confidence: confidence.toDouble(),

      provenance: ThaiInterpretationProvenance.fromMap(

        Map<String, dynamic>.from(provenanceRaw),

      ),

    );

  }



  Map<String, dynamic> toMap() {

    return {

      'factId': factId,

      'predicate': predicate.id,

      'objectRef': objectRef,

      'context': Map<String, String>.from(context),

      'tier': tier.id,

      'evidence': evidence.toMap(),

      'confidence': confidence,

      'provenance': provenance.toMap(),

    };

  }



  @override

  bool operator ==(Object other) {

    return other is ThaiInterpretationFact &&

        other.factId == factId &&

        other.predicate == predicate &&

        other.objectRef == objectRef &&

        _mapEquals(other.context, context) &&

        other.tier == tier &&

        other.evidence == evidence &&

        other.confidence == confidence &&

        other.provenance == provenance;

  }



  @override

  int get hashCode => Object.hash(

        factId,

        predicate,

        objectRef,

        Object.hashAll(context.entries.map((e) => Object.hash(e.key, e.value))),

        tier,

        evidence,

        confidence,

        provenance,

      );



  static String _requiredString(dynamic raw) {

    if (raw is! String || raw.trim().isEmpty) {

      throw FormatException('Invalid string field: $raw');

    }

    return raw.trim();

  }



  static Map<String, String> _stringMap(dynamic raw) {

    if (raw is! Map) {

      return const {};

    }



    final result = <String, String>{};

    raw.forEach((key, value) {

      if (key is String && value is String) {

        result[key] = value;

      }

    });

    return Map<String, String>.unmodifiable(result);

  }



  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {

    if (a.length != b.length) return false;

    for (final entry in a.entries) {

      if (b[entry.key] != entry.value) return false;

    }

    return true;

  }

}


