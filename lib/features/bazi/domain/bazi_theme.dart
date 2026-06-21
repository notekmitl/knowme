class BaziTheme {
  final String coreSelf;
  final List<String> strengths;
  final List<String> growthAreas;

  const BaziTheme({
    required this.coreSelf,
    required this.strengths,
    required this.growthAreas,
  });
}

class BaziDominantHighlight {
  final String headline;
  final String intro;
  final List<String> associations;

  const BaziDominantHighlight({
    required this.headline,
    required this.intro,
    required this.associations,
  });
}
