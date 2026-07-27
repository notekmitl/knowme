/// V1.3.5 — one deterministic Thai astrology evidence atom.
///
/// Facts only; no user-facing prose. Narrative composers must reference
/// [evidenceId] and must not invent planetary longitudes or unsupported bodies.
class ThaiEvidenceItem {
  const ThaiEvidenceItem({
    required this.evidenceId,
    required this.category,
    required this.topic,
    required this.facts,
    required this.derivationRef,
    this.ruleVersion = ruleVersionV135,
    this.ageOrDateRange = '',
    this.direction = ThaiEvidenceDirection.neutral,
    this.strength = 0,
    this.conflictGroupId,
  });

  static const ruleVersionV135 = 'v135.1';

  final String evidenceId;
  final String ruleVersion;
  final ThaiEvidenceCategory category;
  final ThaiEvidenceTopic topic;
  final List<String> facts;
  final String ageOrDateRange;
  final ThaiEvidenceDirection direction;
  final int strength;
  final String derivationRef;
  final String? conflictGroupId;
}

enum ThaiEvidenceCategory {
  natalFoundation,
  houseFrame,
  lifePeriod,
  planetBond,
  periodScore,
  annualTaksa,
  birthdayYear,
  conflict,
}

enum ThaiEvidenceTopic {
  overview,
  personality,
  career,
  money,
  love,
  health,
  periodPast,
  periodCurrent,
  periodFuture,
  birthdayYear,
  advice,
}

enum ThaiEvidenceDirection { supportive, challenging, mixed, neutral, quiet }
