import '../../foundation/models/profile_warning.dart';

import 'thai_interpretation_fact.dart';



/// Bundle of meaning assertions derived from a [ThaiSignalBundle].

class ThaiInterpretationBundle {

  const ThaiInterpretationBundle({

    required this.bundleId,

    required this.sourceBundleId,

    required this.extractorVersion,

    required this.interpreterVersion,

    required this.interpretedAt,

    required this.hasBirthTime,

    required this.facts,

    this.warnings = const [],

  });



  final String bundleId;

  final String sourceBundleId;

  final String extractorVersion;

  final String interpreterVersion;

  final DateTime interpretedAt;

  final bool hasBirthTime;

  final List<ThaiInterpretationFact> facts;

  final List<ProfileWarning> warnings;



  factory ThaiInterpretationBundle.fromMap(Map<String, dynamic> map) {

    final factsRaw = map['facts'];

    if (factsRaw is! List) {

      throw FormatException('Invalid facts: $factsRaw');

    }



    final interpretedAtRaw = map['interpretedAt'];

    if (interpretedAtRaw is! String) {

      throw FormatException('Invalid interpretedAt: $interpretedAtRaw');

    }



    return ThaiInterpretationBundle(

      bundleId: _requiredString(map['bundleId']),

      sourceBundleId: _requiredString(map['sourceBundleId']),

      extractorVersion: _requiredString(map['extractorVersion']),

      interpreterVersion: _requiredString(map['interpreterVersion']),

      interpretedAt: DateTime.parse(interpretedAtRaw).toUtc(),

      hasBirthTime: map['hasBirthTime'] == true,

      facts: List<ThaiInterpretationFact>.unmodifiable(

        factsRaw

            .whereType<Map>()

            .map(

              (item) => ThaiInterpretationFact.fromMap(

                Map<String, dynamic>.from(item),

              ),

            )

            .toList(growable: false),

      ),

      warnings: List<ProfileWarning>.unmodifiable(

        _warningsFromMapList(map['warnings']),

      ),

    );

  }



  Map<String, dynamic> toMap() {

    return {

      'bundleId': bundleId,

      'sourceBundleId': sourceBundleId,

      'extractorVersion': extractorVersion,

      'interpreterVersion': interpreterVersion,

      'interpretedAt': interpretedAt.toUtc().toIso8601String(),

      'hasBirthTime': hasBirthTime,

      'facts': facts.map((fact) => fact.toMap()).toList(growable: false),

      'warnings': warnings

          .map(

            (warning) => {

              'code': warning.code,

              'severity': warning.severity.name,

              'message': warning.message,

              'affectedFields': warning.affectedFields,

            },

          )

          .toList(growable: false),

    };

  }



  @override

  bool operator ==(Object other) {

    return other is ThaiInterpretationBundle &&

        other.bundleId == bundleId &&

        other.sourceBundleId == sourceBundleId &&

        other.extractorVersion == extractorVersion &&

        other.interpreterVersion == interpreterVersion &&

        other.interpretedAt == interpretedAt &&

        other.hasBirthTime == hasBirthTime &&

        _factListEquals(other.facts, facts) &&

        _warningListEquals(other.warnings, warnings);

  }



  @override

  int get hashCode => Object.hash(

        bundleId,

        sourceBundleId,

        extractorVersion,

        interpreterVersion,

        interpretedAt,

        hasBirthTime,

        Object.hashAll(facts),

        Object.hashAll(warnings),

      );



  static String _requiredString(dynamic raw) {

    if (raw is! String || raw.trim().isEmpty) {

      throw FormatException('Invalid string field: $raw');

    }

    return raw.trim();

  }



  static List<ProfileWarning> _warningsFromMapList(dynamic raw) {

    if (raw is! List) return const [];



    return raw

        .whereType<Map>()

        .map((item) {

          final code = item['code'];

          final severityRaw = item['severity'];

          final message = item['message'];

          if (code is! String || message is! String) {

            throw FormatException('Invalid warning: $item');

          }



          final severity = ProfileWarningSeverity.values.firstWhere(

            (value) => value.name == severityRaw,

            orElse: () => throw FormatException('Invalid severity: $severityRaw'),

          );



          final affectedFields = item['affectedFields'];

          return ProfileWarning(

            code: code,

            severity: severity,

            message: message,

            affectedFields: affectedFields is List

                ? affectedFields.whereType<String>().toList(growable: false)

                : const [],

          );

        })

        .toList(growable: false);

  }



  static bool _factListEquals(

    List<ThaiInterpretationFact> a,

    List<ThaiInterpretationFact> b,

  ) {

    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {

      if (a[i] != b[i]) return false;

    }

    return true;

  }



  static bool _warningListEquals(

    List<ProfileWarning> a,

    List<ProfileWarning> b,

  ) {

    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {

      final left = a[i];

      final right = b[i];

      if (left.code != right.code ||

          left.severity != right.severity ||

          left.message != right.message ||

          left.affectedFields.length != right.affectedFields.length) {

        return false;

      }

      for (var j = 0; j < left.affectedFields.length; j++) {

        if (left.affectedFields[j] != right.affectedFields[j]) {

          return false;

        }

      }

    }

    return true;

  }

}


