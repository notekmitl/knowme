/// Curated Thai narrative block model for V1.1 presentation layer.
library;

import 'thai_beta_narrative_domain.dart';

/// Narrative section a curated block belongs to.
enum CuratedNarrativeSection {
  hero,
  strength,
  domain,
  dashboard,
  advice,
}

/// Relationship between primary and secondary traits in a block.
enum CuratedRelationshipType {
  primaryOnly,
  primarySecondary,
  tension,
  domainPrimary,
  domainPair,
  fallback,
}

/// A complete pre-written Thai narrative block — never assembled from clauses.
class CuratedNarrativeBlock {
  const CuratedNarrativeBlock({
    required this.id,
    required this.section,
    this.domain,
    this.primaryTraitIds = const [],
    this.secondaryTraitIds = const [],
    this.primarySemanticTags = const [],
    this.secondarySemanticTags = const [],
    this.relationshipType = CuratedRelationshipType.primaryOnly,
    this.minimumConfidence = 0.0,
    this.requiresBirthTime = false,
    this.safeWithoutBirthTime = false,
    this.observableBehavior,
    this.strengthText,
    this.tensionText,
    this.adviceText,
    this.heroSentences = const [],
    this.domainOverview,
    this.domainWhy,
    this.dashboardCurrent,
    this.dashboardWhy,
    this.sourceSignalIds = const [],
  });

  final String id;
  final CuratedNarrativeSection section;
  final ThaiBetaLifeDomain? domain;
  final List<String> primaryTraitIds;
  final List<String> secondaryTraitIds;
  final List<String> primarySemanticTags;
  final List<String> secondarySemanticTags;
  final CuratedRelationshipType relationshipType;
  final double minimumConfidence;
  final bool requiresBirthTime;
  final bool safeWithoutBirthTime;
  final String? observableBehavior;
  final String? strengthText;
  final String? tensionText;
  final String? adviceText;
  final List<String> heroSentences;
  final String? domainOverview;
  final String? domainWhy;
  final String? dashboardCurrent;
  final String? dashboardWhy;
  final List<String> sourceSignalIds;
}

/// Result of selecting a curated block.
class CuratedBlockSelection {
  const CuratedBlockSelection({
    required this.block,
    required this.matchLevel,
  });

  final CuratedNarrativeBlock block;
  final int matchLevel;
}
