class BaziSummary {
  const BaziSummary({
    required this.paragraph1,
    required this.paragraph2,
    this.paragraph3,
  });

  final String paragraph1;
  final String paragraph2;
  final String? paragraph3;

  List<String> get paragraphs => [
        paragraph1,
        paragraph2,
        if (paragraph3 != null) paragraph3!,
      ];
}
