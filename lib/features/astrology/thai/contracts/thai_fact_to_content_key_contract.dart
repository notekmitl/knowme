import '../interpretation/enums/thai_meaning_predicate.dart';

/// Neutral shared contract for fact-to-content-key lookup mapping.
///
/// [canResolve] and [resolveKey] are implemented by the lookup mapper in C1+.
/// Theme and Content Lookup both depend on this contract only.
abstract final class ThaiFactToContentKeyContract {
  /// C0 Lookup Mapper predicates (1:1 mapping only).
  static const supportedPredicates = <ThaiMeaningPredicate>[
    ThaiMeaningPredicate.lagnaSignIs,
    ThaiMeaningPredicate.lagnaLordIs,
    ThaiMeaningPredicate.myanmarPositionIs,
    ThaiMeaningPredicate.mahabhutaPositionIs,
  ];

  /// Predicates intentionally deferred in C0 (no text emission).
  static const deferredPredicates = <ThaiMeaningPredicate>[
    ThaiMeaningPredicate.houseSignIs,
    ThaiMeaningPredicate.houseLordIs,
  ];
}
