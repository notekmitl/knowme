import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart'
    show PlanetRelation;

/// Thai Astrology Knowledge — **Planet Relationship** domain (V1 model, V2
/// data-driven).
///
/// The knowledge base is a traceable evidence layer that records, for every
/// directed planet pair, **what relationship the rule asserts** and **what
/// documented source (if any) backs it**.
///
/// As of Knowledge Importer **V2** the records are no longer hardcoded: they are
/// loaded from JSON (`knowledge/planet_relationships/`) by
/// `PlanetRelationshipKnowledgeImporter`. This file defines only the in-memory
/// model + coverage report; it owns no data and changes no engine behaviour.

/// The school of thought a relationship rule is attributed to.
enum PlanetRelationshipSchool { thaiTraditional, vedic, knowmeCustom, unknown }

extension PlanetRelationshipSchoolLabel on PlanetRelationshipSchool {
  String get label => switch (this) {
        PlanetRelationshipSchool.thaiTraditional =>
          'Thai traditional (โหราศาสตร์ไทย / พรหมชาติ)',
        PlanetRelationshipSchool.vedic => 'Vedic (naisargika maitri)',
        PlanetRelationshipSchool.knowmeCustom => 'Custom KnowMe rule',
        PlanetRelationshipSchool.unknown => 'Unknown',
      };
}

/// Confidence in the documented source. [none] is the unsourced default.
enum PlanetRelationshipConfidence { none, low, medium, high }

/// Lifecycle status of a knowledge record.
enum PlanetRelationshipStatus {
  /// No source recorded yet (the seeded default).
  unknown,

  /// A source is proposed but not yet verified.
  candidate,

  /// Confirmed against a documented source.
  verified,

  /// Sources disagree.
  disputed,

  /// Superseded / no longer used.
  deprecated,
}

/// A documented — or explicitly undocumented — source for one relationship rule.
class PlanetRelationshipSource {
  const PlanetRelationshipSource({
    required this.school,
    required this.name,
    required this.reference,
    this.author,
    this.edition,
    this.publisher,
    this.year,
    this.page,
    this.quote,
  });

  final PlanetRelationshipSchool school;

  /// Human-readable source name (e.g. a book title). `'Unknown'` when undocumented.
  final String name;
  final String? author;
  final String? edition;
  final String? publisher;
  final int? year;

  /// Citation / URL / text identifier. `'Unknown'` when undocumented.
  final String reference;
  final String? page;

  /// A short verbatim quote supporting the relationship, if available.
  final String? quote;

  /// The honest default: no documented provenance.
  static const unknown = PlanetRelationshipSource(
    school: PlanetRelationshipSchool.unknown,
    name: 'Unknown',
    reference: 'Unknown',
  );

  bool get isDocumented =>
      school != PlanetRelationshipSchool.unknown && name != 'Unknown';
}

/// Evidence backing one relationship rule: its [source], [confidence], [status],
/// whether it was [verified] against the source, and free-text [notes].
class PlanetRelationshipEvidence {
  const PlanetRelationshipEvidence({
    required this.source,
    required this.confidence,
    required this.status,
    required this.verified,
    required this.notes,
  });

  final PlanetRelationshipSource source;
  final PlanetRelationshipConfidence confidence;
  final PlanetRelationshipStatus status;
  final bool verified;
  final String notes;

  /// The honest seeded default: unverified, unknown source/status.
  static const unverified = PlanetRelationshipEvidence(
    source: PlanetRelationshipSource.unknown,
    confidence: PlanetRelationshipConfidence.none,
    status: PlanetRelationshipStatus.unknown,
    verified: false,
    notes: 'No documented Thai/Vedic source recorded yet. The relation mirrors '
        'the frozen PlanetRelationshipMatrix and is pending verification.',
  );
}

/// One knowledge record for a single **directed** planet pair (from → to).
class PlanetRelationshipRecord {
  const PlanetRelationshipRecord({
    required this.from,
    required this.to,
    required this.relation,
    required this.evidence,
  });

  final LifePlanet from;
  final LifePlanet to;

  /// The relationship this rule asserts for `from → to`.
  final PlanetRelation relation;

  final PlanetRelationshipEvidence evidence;

  // --- Flattened accessors (the record fields) -----------------------------
  PlanetRelationshipSource get source => evidence.source;
  PlanetRelationshipSchool get school => evidence.source.school;
  String get sourceName => evidence.source.name;
  String? get author => evidence.source.author;
  String? get edition => evidence.source.edition;
  String? get publisher => evidence.source.publisher;
  int? get year => evidence.source.year;
  String get reference => evidence.source.reference;
  String? get page => evidence.source.page;
  String? get quote => evidence.source.quote;
  PlanetRelationshipConfidence get confidence => evidence.confidence;
  PlanetRelationshipStatus get status => evidence.status;
  bool get verified => evidence.verified;
  String get notes => evidence.notes;
}

/// The Planet Relationship knowledge base: the set of imported records plus a
/// [coverage] report. **Data-driven** — built by
/// `PlanetRelationshipKnowledgeImporter` from JSON, never hardcoded here.
class PlanetRelationshipKnowledge {
  PlanetRelationshipKnowledge(Iterable<PlanetRelationshipRecord> records)
      : records = List.unmodifiable(records);

  final List<PlanetRelationshipRecord> records;

  /// The record for one directed pair, or null if absent.
  PlanetRelationshipRecord? recordFor(LifePlanet from, LifePlanet to) {
    for (final r in records) {
      if (r.from == from && r.to == to) return r;
    }
    return null;
  }

  /// Coverage report over all records.
  PlanetRelationshipCoverageReport coverage() =>
      PlanetRelationshipCoverageReport.of(records);
}

/// Knowledge Coverage Report — relation split (friend/enemy/neutral) and status
/// split (unknown/candidate/verified/disputed/deprecated), plus coverage %.
class PlanetRelationshipCoverageReport {
  const PlanetRelationshipCoverageReport({
    required this.total,
    required this.friend,
    required this.enemy,
    required this.neutral,
    required this.unknown,
    required this.candidate,
    required this.verified,
    required this.disputed,
    required this.deprecated,
  });

  factory PlanetRelationshipCoverageReport.of(
    Iterable<PlanetRelationshipRecord> records,
  ) {
    var friend = 0;
    var enemy = 0;
    var neutral = 0;
    var unknown = 0;
    var candidate = 0;
    var verified = 0;
    var disputed = 0;
    var deprecated = 0;
    var total = 0;
    for (final r in records) {
      total++;
      switch (r.relation) {
        case PlanetRelation.friend:
          friend++;
        case PlanetRelation.enemy:
          enemy++;
        case PlanetRelation.neutral:
          neutral++;
      }
      switch (r.status) {
        case PlanetRelationshipStatus.unknown:
          unknown++;
        case PlanetRelationshipStatus.candidate:
          candidate++;
        case PlanetRelationshipStatus.verified:
          verified++;
        case PlanetRelationshipStatus.disputed:
          disputed++;
        case PlanetRelationshipStatus.deprecated:
          deprecated++;
      }
    }
    return PlanetRelationshipCoverageReport(
      total: total,
      friend: friend,
      enemy: enemy,
      neutral: neutral,
      unknown: unknown,
      candidate: candidate,
      verified: verified,
      disputed: disputed,
      deprecated: deprecated,
    );
  }

  final int total;
  final int friend;
  final int enemy;
  final int neutral;
  final int unknown;
  final int candidate;
  final int verified;
  final int disputed;
  final int deprecated;

  /// Verified ÷ total — the "Coverage %" of *verified* knowledge.
  double get verifiedPercent => total == 0 ? 0 : verified / total * 100;

  List<String> toReportLines() => [
        'Planet Relationship Knowledge — Coverage Report',
        'Total relationships : $total',
        'Friend              : $friend',
        'Enemy               : $enemy',
        'Neutral             : $neutral',
        'Unknown (status)    : $unknown',
        'Candidate           : $candidate',
        'Verified            : $verified',
        'Disputed            : $disputed',
        'Deprecated          : $deprecated',
        'Coverage %          : ${verifiedPercent.toStringAsFixed(1)}%',
      ];
}
