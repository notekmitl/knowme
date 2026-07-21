/// Deterministic insight copy for MBTI Summary fusion.
class MbtiSummaryHeroInsight {
  const MbtiSummaryHeroInsight({
    required this.identityLine,
    required this.roleLabel,
    this.roleLabelEnglish,
    required this.paragraphs,
  });

  final String identityLine;
  final String roleLabel;
  final String? roleLabelEnglish;
  final List<String> paragraphs;
}

class MbtiSummaryProfileInsight {
  const MbtiSummaryProfileInsight({
    required this.subtitle,
    required this.paragraph,
  });

  final String subtitle;
  final String paragraph;
}

class MbtiSummaryInsightPair {
  const MbtiSummaryInsightPair({
    required this.headline,
    required this.body,
  });

  final String headline;
  final String body;
}

class MbtiSummaryThinkingInsight {
  const MbtiSummaryThinkingInsight({
    required this.items,
  });

  final List<MbtiSummaryInsightPair> items;
}

class MbtiSummaryGrowthInsight {
  const MbtiSummaryGrowthInsight({
    required this.items,
  });

  final List<MbtiSummaryInsightPair> items;
}

class MbtiSummaryConfidenceExtras {
  const MbtiSummaryConfidenceExtras({
    required this.strengthBullets,
    required this.careerSuggestions,
  });

  final List<String> strengthBullets;
  final List<String> careerSuggestions;
}

class MbtiSummaryInsightBundle {
  const MbtiSummaryInsightBundle({
    required this.hero,
    required this.profileInsight,
    required this.thinkingInsight,
    required this.growthInsight,
    required this.confidenceExtras,
  });

  final MbtiSummaryHeroInsight hero;
  final MbtiSummaryProfileInsight profileInsight;
  final MbtiSummaryThinkingInsight thinkingInsight;
  final MbtiSummaryGrowthInsight growthInsight;
  final MbtiSummaryConfidenceExtras confidenceExtras;
}

