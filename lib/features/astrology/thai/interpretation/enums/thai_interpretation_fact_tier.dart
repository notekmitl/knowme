/// Tier for a [ThaiInterpretationFact].

enum ThaiInterpretationFactTier {

  core,

  supporting,

}



extension ThaiInterpretationFactTierLabels on ThaiInterpretationFactTier {

  String get id {

    return switch (this) {

      ThaiInterpretationFactTier.core => 'core',

      ThaiInterpretationFactTier.supporting => 'supporting',

    };

  }

}



ThaiInterpretationFactTier? parseThaiInterpretationFactTier(String raw) {

  final normalized = raw.trim().toLowerCase();

  for (final tier in ThaiInterpretationFactTier.values) {

    if (tier.id == normalized) {

      return tier;

    }

  }

  return null;

}


