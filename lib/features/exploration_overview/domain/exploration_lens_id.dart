/// Core exploration lenses tracked by Exploration Overview (EO-F0).
enum ExplorationLensId {
  westernNatal,
  chineseBazi,
  thaiAstrology,
  mbti,
  eq,
  bigFive;

  String get id => switch (this) {
        ExplorationLensId.westernNatal => 'western_natal',
        ExplorationLensId.chineseBazi => 'chinese_bazi',
        ExplorationLensId.thaiAstrology => 'thai_astrology',
        ExplorationLensId.mbti => 'mbti',
        ExplorationLensId.eq => 'eq',
        ExplorationLensId.bigFive => 'big_five',
      };

  static const astrologyLenses = <ExplorationLensId>[
    ExplorationLensId.westernNatal,
    ExplorationLensId.chineseBazi,
    ExplorationLensId.thaiAstrology,
  ];

  static const personalityLenses = <ExplorationLensId>[
    ExplorationLensId.mbti,
    ExplorationLensId.eq,
    ExplorationLensId.bigFive,
  ];

  static const all = <ExplorationLensId>[
    ...astrologyLenses,
    ...personalityLenses,
  ];
}
