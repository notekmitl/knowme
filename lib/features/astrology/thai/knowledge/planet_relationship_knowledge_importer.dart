import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';

/// Severity of an import issue.
enum PlanetRelationshipImportSeverity { error, warning }

/// One problem found while importing the knowledge JSON.
class PlanetRelationshipImportIssue {
  const PlanetRelationshipImportIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.index,
  });

  final PlanetRelationshipImportSeverity severity;

  /// Machine-readable code, e.g. `schema`, `missing_field`, `unknown_enum`,
  /// `duplicate`, `broken_reference`, `matrix_mismatch`, `missing_coverage`.
  final String code;
  final String message;

  /// Index of the offending record in the `relationships` array, when relevant.
  final int? index;

  bool get isError => severity == PlanetRelationshipImportSeverity.error;

  @override
  String toString() {
    final tag = isError ? 'ERROR' : 'WARN ';
    final at = index == null ? '' : ' [#$index]';
    return '$tag $code$at: $message';
  }
}

/// The result of importing the Planet Relationship knowledge JSON: the loaded
/// [knowledge], any [issues], and the [coverage] report.
class PlanetRelationshipImportResult {
  PlanetRelationshipImportResult({
    required this.knowledge,
    required List<PlanetRelationshipImportIssue> issues,
  })  : issues = List.unmodifiable(issues),
        coverage = knowledge.coverage();

  final PlanetRelationshipKnowledge knowledge;
  final List<PlanetRelationshipImportIssue> issues;
  final PlanetRelationshipCoverageReport coverage;

  List<PlanetRelationshipImportIssue> get errors =>
      issues.where((i) => i.isError).toList(growable: false);
  List<PlanetRelationshipImportIssue> get warnings =>
      issues.where((i) => !i.isError).toList(growable: false);

  /// True when no errors were found (warnings are allowed).
  bool get ok => errors.isEmpty;

  /// The "Knowledge Import Report": validation summary + coverage.
  List<String> toReportLines() => [
        'Planet Relationship Knowledge — Import Report',
        'Status            : ${ok ? 'OK' : 'FAILED'}',
        'Records imported  : ${knowledge.records.length}',
        'Errors            : ${errors.length}',
        'Warnings          : ${warnings.length}',
        '',
        ...coverage.toReportLines(),
        if (issues.isNotEmpty) ...['', 'Issues:'],
        for (final i in issues) '  $i',
      ];
}

/// Loads [PlanetRelationshipKnowledge] from JSON and validates it.
///
/// Validation performed: schema (shape/types), missing required fields, unknown
/// enum values, duplicate `(from,to)`, broken references (invalid/self pairs),
/// optional consistency against the frozen [PlanetRelationshipMatrix], and
/// coverage of all directed inter-planet pairs.
abstract final class PlanetRelationshipKnowledgeImporter {
  static const int expectedPairs = 8 * 7; // 56 directed inter-planet pairs

  /// Bundled canonical knowledge asset (registered in pubspec).
  static const String assetKey =
      'knowledge/planet_relationships/planet_relationships.knowme.json';

  /// Loads + validates the canonical knowledge from the bundled asset.
  static Future<PlanetRelationshipImportResult> loadFromAsset({
    AssetBundle? bundle,
    bool checkMatrix = true,
  }) async {
    final b = bundle ?? rootBundle;
    final jsonString = await b.loadString(assetKey);
    return importJson(jsonString, checkMatrix: checkMatrix);
  }

  static const Set<String> _relationNames = {'friend', 'neutral', 'enemy'};
  static const Set<String> _schoolNames = {
    'thaiTraditional',
    'vedic',
    'knowmeCustom',
    'unknown',
  };
  static const Set<String> _confidenceNames = {'none', 'low', 'medium', 'high'};
  static const Set<String> _statusNames = {
    'unknown',
    'candidate',
    'verified',
    'disputed',
    'deprecated',
  };

  /// Parse + validate a JSON string.
  static PlanetRelationshipImportResult importJson(
    String jsonString, {
    bool checkMatrix = true,
  }) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException catch (e) {
      return PlanetRelationshipImportResult(
        knowledge: PlanetRelationshipKnowledge(const []),
        issues: [
          PlanetRelationshipImportIssue(
            severity: PlanetRelationshipImportSeverity.error,
            code: 'schema',
            message: 'Invalid JSON: ${e.message}',
          ),
        ],
      );
    }
    if (decoded is! Map<String, dynamic>) {
      return PlanetRelationshipImportResult(
        knowledge: PlanetRelationshipKnowledge(const []),
        issues: const [
          PlanetRelationshipImportIssue(
            severity: PlanetRelationshipImportSeverity.error,
            code: 'schema',
            message: 'Top-level JSON must be an object.',
          ),
        ],
      );
    }
    return importMap(decoded, checkMatrix: checkMatrix);
  }

  /// Parse + validate an already-decoded JSON map.
  static PlanetRelationshipImportResult importMap(
    Map<String, dynamic> json, {
    bool checkMatrix = true,
  }) {
    final issues = <PlanetRelationshipImportIssue>[];
    final records = <PlanetRelationshipRecord>[];
    final seen = <String>{};

    void err(String code, String message, [int? index]) => issues.add(
          PlanetRelationshipImportIssue(
            severity: PlanetRelationshipImportSeverity.error,
            code: code,
            message: message,
            index: index,
          ),
        );
    void warn(String code, String message, [int? index]) => issues.add(
          PlanetRelationshipImportIssue(
            severity: PlanetRelationshipImportSeverity.warning,
            code: code,
            message: message,
            index: index,
          ),
        );

    final rels = json['relationships'];
    if (rels is! List) {
      err('schema', 'Missing or non-array "relationships".');
      return PlanetRelationshipImportResult(
        knowledge: PlanetRelationshipKnowledge(records),
        issues: issues,
      );
    }

    for (var i = 0; i < rels.length; i++) {
      final raw = rels[i];
      if (raw is! Map<String, dynamic>) {
        err('schema', 'Relationship entry must be an object.', i);
        continue;
      }

      // Required fields.
      const required = ['from', 'to', 'relation', 'school', 'confidence',
        'status', 'verified'];
      var missing = false;
      for (final f in required) {
        if (raw[f] == null) {
          err('missing_field', 'Missing required field "$f".', i);
          missing = true;
        }
      }
      if (missing) continue;

      // Enum validation.
      final fromName = raw['from'] as String?;
      final toName = raw['to'] as String?;
      final relationName = raw['relation'] as String?;
      final schoolName = raw['school'] as String?;
      final confidenceName = raw['confidence'] as String?;
      final statusName = raw['status'] as String?;
      final verifiedRaw = raw['verified'];

      final from = _planet(fromName);
      final to = _planet(toName);
      if (from == null) {
        err('unknown_enum', 'Unknown planet "from" = "$fromName".', i);
      }
      if (to == null) {
        err('unknown_enum', 'Unknown planet "to" = "$toName".', i);
      }
      if (!_relationNames.contains(relationName)) {
        err('unknown_enum', 'Unknown relation = "$relationName".', i);
      }
      if (!_schoolNames.contains(schoolName)) {
        err('unknown_enum', 'Unknown school = "$schoolName".', i);
      }
      if (!_confidenceNames.contains(confidenceName)) {
        err('unknown_enum', 'Unknown confidence = "$confidenceName".', i);
      }
      if (!_statusNames.contains(statusName)) {
        err('unknown_enum', 'Unknown status = "$statusName".', i);
      }
      if (verifiedRaw is! bool) {
        err('schema', '"verified" must be a boolean.', i);
      }

      if (from == null ||
          to == null ||
          !_relationNames.contains(relationName) ||
          !_schoolNames.contains(schoolName) ||
          !_confidenceNames.contains(confidenceName) ||
          !_statusNames.contains(statusName) ||
          verifiedRaw is! bool) {
        continue;
      }

      // Broken references.
      if (from == to) {
        err('broken_reference',
            'Self-pair ${from.name}->${to.name} is not a relationship.', i);
        continue;
      }

      // Duplicate detection.
      final key = '${from.name}->${to.name}';
      if (!seen.add(key)) {
        err('duplicate', 'Duplicate relationship $key.', i);
        continue;
      }

      final relation = PlanetRelation.values.byName(relationName!);

      // Matrix consistency (warning only — knowledge must not silently diverge
      // from the frozen engine).
      if (checkMatrix) {
        final matrixValue = PlanetRelationshipMatrix.relation(from, to);
        if (matrixValue != relation) {
          warn(
            'matrix_mismatch',
            '$key relation "$relationName" disagrees with frozen matrix '
                '"${matrixValue.name}".',
            i,
          );
        }
      }

      final yearRaw = raw['year'];
      final source = PlanetRelationshipSource(
        school: PlanetRelationshipSchool.values.byName(schoolName!),
        name: (raw['source'] as String?)?.trim().isNotEmpty == true
            ? raw['source'] as String
            : 'Unknown',
        author: _nullableString(raw['author']),
        edition: _nullableString(raw['edition']),
        publisher: _nullableString(raw['publisher']),
        year: yearRaw is int ? yearRaw : int.tryParse('${yearRaw ?? ''}'),
        reference: (raw['reference'] as String?)?.trim().isNotEmpty == true
            ? raw['reference'] as String
            : 'Unknown',
        page: _nullableString(raw['page']),
        quote: _nullableString(raw['quote']),
      );
      final evidence = PlanetRelationshipEvidence(
        source: source,
        confidence:
            PlanetRelationshipConfidence.values.byName(confidenceName!),
        status: PlanetRelationshipStatus.values.byName(statusName!),
        verified: verifiedRaw,
        notes: (raw['notes'] as String?) ?? '',
      );

      records.add(
        PlanetRelationshipRecord(
          from: from,
          to: to,
          relation: relation,
          evidence: evidence,
        ),
      );
    }

    // Coverage completeness: every directed inter-planet pair should be present.
    final present = records.map((r) => '${r.from.name}->${r.to.name}').toSet();
    final missingPairs = <String>[];
    for (final from in LifePlanet.values) {
      for (final to in LifePlanet.values) {
        if (from == to) continue;
        final key = '${from.name}->${to.name}';
        if (!present.contains(key)) missingPairs.add(key);
      }
    }
    if (missingPairs.isNotEmpty) {
      warn(
        'missing_coverage',
        '${missingPairs.length} of $expectedPairs directed pairs missing: '
            '${missingPairs.take(8).join(', ')}'
            '${missingPairs.length > 8 ? ', …' : ''}.',
      );
    }

    return PlanetRelationshipImportResult(
      knowledge: PlanetRelationshipKnowledge(records),
      issues: issues,
    );
  }

  static LifePlanet? _planet(String? name) {
    if (name == null) return null;
    for (final p in LifePlanet.values) {
      if (p.name == name) return p;
    }
    return null;
  }

  static String? _nullableString(Object? v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }
}
