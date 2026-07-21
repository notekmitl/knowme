/// Meaning predicate for a [ThaiInterpretationFact].

enum ThaiMeaningPredicate {

  lagnaSignIs,

  lagnaLordIs,

  houseSignIs,

  houseLordIs,

  myanmarPositionIs,

  mahabhutaPositionIs,

}



extension ThaiMeaningPredicateLabels on ThaiMeaningPredicate {

  String get id {

    return switch (this) {

      ThaiMeaningPredicate.lagnaSignIs => 'LAGNA_SIGN_IS',

      ThaiMeaningPredicate.lagnaLordIs => 'LAGNA_LORD_IS',

      ThaiMeaningPredicate.houseSignIs => 'HOUSE_SIGN_IS',

      ThaiMeaningPredicate.houseLordIs => 'HOUSE_LORD_IS',

      ThaiMeaningPredicate.myanmarPositionIs => 'MYANMAR_POSITION_IS',

      ThaiMeaningPredicate.mahabhutaPositionIs => 'MAHABHUTA_POSITION_IS',

    };

  }

}



ThaiMeaningPredicate? parseThaiMeaningPredicate(String raw) {

  final normalized = raw.trim().toUpperCase();

  for (final predicate in ThaiMeaningPredicate.values) {

    if (predicate.id == normalized) {

      return predicate;

    }

  }

  return null;

}


