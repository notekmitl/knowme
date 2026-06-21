import '../../contracts/thai_fact_to_content_key_contract.dart';
import '../../interpretation/enums/thai_meaning_predicate.dart';
import '../../interpretation/models/thai_interpretation_fact.dart';

/// C1 Lookup Mapper — maps [ThaiInterpretationFact] to content registry keys.
///
/// Fact → contentKey only. No registry reads, fragments, or bundles.
abstract final class ThaiFactToContentKeyMapper {
  static bool canResolve(ThaiInterpretationFact fact) {
    if (fact.context.isNotEmpty) {
      return false;
    }

    if (ThaiFactToContentKeyContract.deferredPredicates.contains(fact.predicate)) {
      return false;
    }

    return ThaiFactToContentKeyContract.supportedPredicates.contains(
      fact.predicate,
    );
  }

  static String? resolveKey(ThaiInterpretationFact fact) {
    if (!canResolve(fact)) {
      return null;
    }

    return switch (fact.predicate) {
      ThaiMeaningPredicate.lagnaSignIs => 'lagna_${fact.objectRef}',
      ThaiMeaningPredicate.lagnaLordIs => 'lagna_lord_${fact.objectRef}',
      ThaiMeaningPredicate.myanmarPositionIs => fact.objectRef,
      ThaiMeaningPredicate.mahabhutaPositionIs => fact.objectRef,
      ThaiMeaningPredicate.houseSignIs ||
      ThaiMeaningPredicate.houseLordIs =>
        null,
    };
  }
}
