import 'thai_mirror_evidence.dart';
import 'thai_mirror_section_id.dart';
import 'thai_mirror_theme_ref.dart';

/// One self-understanding section in [ThaiMirrorResult].
class ThaiMirrorSection {
  const ThaiMirrorSection({
    required this.id,
    required this.title,
    required this.titleTh,
    this.summary,
    this.supportingThemes = const [],
    this.evidence = const [],
  });

  final ThaiMirrorSectionId id;
  final String title;
  final String titleTh;

  /// Reflective narrative summary — populated by narrative generator (V1.1+).
  /// Null in structural assembly phase (V1).
  final String? summary;

  /// Themes ranked within this section (deterministic order: score desc).
  final List<ThaiMirrorThemeRef> supportingThemes;

  /// Traceable lens evidence backing themes in this section.
  final List<ThaiMirrorEvidence> evidence;

  bool get hasSummary => summary != null && summary!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorSection &&
        other.id == id &&
        other.title == title &&
        other.titleTh == titleTh &&
        other.summary == summary &&
        _themeListEquals(other.supportingThemes, supportingThemes) &&
        _evidenceListEquals(other.evidence, evidence);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        titleTh,
        summary,
        Object.hashAll(supportingThemes),
        Object.hashAll(evidence),
      );

  static bool _themeListEquals(
    List<ThaiMirrorThemeRef> a,
    List<ThaiMirrorThemeRef> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _evidenceListEquals(
    List<ThaiMirrorEvidence> a,
    List<ThaiMirrorEvidence> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
