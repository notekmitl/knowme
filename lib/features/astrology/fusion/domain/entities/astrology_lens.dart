/// Known astrology lens kinds. Architecture supports additional lens ids via [lensId].
enum AstrologyLens {
  westernNatal,
  chineseBazi,
  thaiAstrology,
}

extension AstrologyLensIds on AstrologyLens {
  String get lensId {
    return switch (this) {
      AstrologyLens.westernNatal => 'western_natal',
      AstrologyLens.chineseBazi => 'chinese_bazi',
      AstrologyLens.thaiAstrology => 'thai_astrology',
    };
  }
}
