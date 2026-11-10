/// Provenance of an existing dashboard phrase, before trial display editing.
/// This metadata does not participate in theme, evidence or variant selection.
class ThaiMirrorDashboardCopySource {
  const ThaiMirrorDashboardCopySource({
    required this.text,
    required this.themeId,
    required this.requestedAspect,
    required this.sourceAspect,
    required this.sourceField,
    required this.matchingAspectText,
    required this.matchingSourceField,
  });

  final String text;
  final String themeId;
  final String requestedAspect;
  final String sourceAspect;
  final String sourceField;
  final String matchingAspectText;
  final String matchingSourceField;
}
