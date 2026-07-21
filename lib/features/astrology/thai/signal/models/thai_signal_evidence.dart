/// Structural evidence attached to a [ThaiSignal].
class ThaiSignalEvidence {
  const ThaiSignalEvidence({
    required this.factKeys,
    required this.displayEn,
    required this.displayTh,
    this.auditRef,
  });

  final List<String> factKeys;
  final String displayEn;
  final String displayTh;
  final String? auditRef;
}
