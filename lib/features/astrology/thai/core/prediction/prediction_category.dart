import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V10 — the seven life areas the Prediction Intelligence Foundation reasons
/// about. These are *prediction categories*, mapped onto the V9 [LifeDomain]
/// affinities (which the life-period engine already scores) so the prediction
/// layer never re-derives domain strength.
enum PredictionCategory {
  career,
  finance,
  relationship,
  health,
  learning,
  personalGrowth,
  family,
}

/// A category's contribution from one [LifeDomain] (weights sum to ~1.0 per
/// category). Deterministic config — no copy.
class CategoryDomainWeight {
  const CategoryDomainWeight(this.domain, this.weight);
  final LifeDomain domain;
  final double weight;
}

extension PredictionCategoryMapping on PredictionCategory {
  /// Stable, documented mapping from a prediction category to the V9 life
  /// domains that compose it.
  List<CategoryDomainWeight> get domainWeights => switch (this) {
        PredictionCategory.career => const [
            CategoryDomainWeight(LifeDomain.career, 0.7),
            CategoryDomainWeight(LifeDomain.opportunity, 0.3),
          ],
        PredictionCategory.finance => const [
            CategoryDomainWeight(LifeDomain.money, 0.8),
            CategoryDomainWeight(LifeDomain.career, 0.2),
          ],
        PredictionCategory.relationship => const [
            CategoryDomainWeight(LifeDomain.love, 0.85),
            CategoryDomainWeight(LifeDomain.health, 0.15),
          ],
        PredictionCategory.health => const [
            CategoryDomainWeight(LifeDomain.health, 0.8),
            CategoryDomainWeight(LifeDomain.love, 0.2),
          ],
        PredictionCategory.learning => const [
            CategoryDomainWeight(LifeDomain.growth, 0.6),
            CategoryDomainWeight(LifeDomain.opportunity, 0.4),
          ],
        PredictionCategory.personalGrowth => const [
            CategoryDomainWeight(LifeDomain.growth, 0.7),
            CategoryDomainWeight(LifeDomain.health, 0.3),
          ],
        PredictionCategory.family => const [
            CategoryDomainWeight(LifeDomain.love, 0.6),
            CategoryDomainWeight(LifeDomain.health, 0.4),
          ],
      };

  /// The dominant domain for this category (highest weight).
  LifeDomain get primaryDomain => domainWeights.first.domain;

  /// All categories in a fixed order (stable iteration for determinism).
  static const List<PredictionCategory> all = PredictionCategory.values;
}
