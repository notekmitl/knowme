import '../spec/thai_mirror_contract.dart';
import 'thai_mirror_profile_context.dart';
import 'thai_mirror_section.dart';
import 'thai_mirror_section_id.dart';
import 'thai_mirror_theme_ref.dart';
import 'thai_narrative_metadata.dart';

/// Self-understanding output contract for Thai Mirror V1.
///
/// Structural assembly fills sections, themes, and evidence.
/// Narrative summaries are optional until [ThaiMirrorNarrativeGeneratorSpec]
/// is implemented.
class ThaiMirrorResult {
  const ThaiMirrorResult({
    required this.contractVersion,
    required this.profileContext,
    required this.topThemes,
    required this.sections,
    this.generatedAt,
    this.disclaimers = ThaiMirrorContract.defaultDisclaimers,
    this.narrativeStatus = ThaiMirrorNarrativeStatus.structuralOnly,
    this.narrativeMetadata = const [],
  });

  final String contractVersion;
  final DateTime? generatedAt;
  final ThaiMirrorProfileContext profileContext;
  final List<ThaiMirrorThemeRef> topThemes;
  final List<ThaiMirrorSection> sections;
  final List<String> disclaimers;
  final ThaiMirrorNarrativeStatus narrativeStatus;
  final List<ThaiNarrativeMetadata> narrativeMetadata;

  ThaiMirrorSection? sectionById(ThaiMirrorSectionId id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }

  List<ThaiMirrorSection> get fusionSections {
    return sections.where((s) => s.id.isFusionSection).toList(growable: false);
  }

  bool get hasNarrative =>
      narrativeStatus == ThaiMirrorNarrativeStatus.complete &&
      sections.every((s) => s.id == ThaiMirrorSectionId.topThemes || s.hasSummary);

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorResult &&
        other.contractVersion == contractVersion &&
        other.generatedAt == generatedAt &&
        other.profileContext == profileContext &&
        other.narrativeStatus == narrativeStatus &&
        _themeListEquals(other.topThemes, topThemes) &&
        _sectionListEquals(other.sections, sections) &&
        _stringListEquals(other.disclaimers, disclaimers) &&
        _metadataListEquals(other.narrativeMetadata, narrativeMetadata);
  }

  @override
  int get hashCode => Object.hash(
        contractVersion,
        generatedAt,
        profileContext,
        narrativeStatus,
        Object.hashAll(topThemes),
        Object.hashAll(sections),
        Object.hashAll(disclaimers),
        Object.hashAll(narrativeMetadata),
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

  static bool _sectionListEquals(
    List<ThaiMirrorSection> a,
    List<ThaiMirrorSection> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _stringListEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _metadataListEquals(
    List<ThaiNarrativeMetadata> a,
    List<ThaiNarrativeMetadata> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Whether narrative summaries have been generated.
enum ThaiMirrorNarrativeStatus {
  structuralOnly,
  partial,
  complete,
}
