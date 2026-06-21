import '../models/thai_mirror_result.dart';
import 'models/thai_mirror_evidence_explorer_state.dart';
import 'models/thai_mirror_hero_state.dart';
import 'models/thai_mirror_profile_context_state.dart';
import 'models/thai_mirror_section_card_state.dart';
import 'models/thai_mirror_theme_card_state.dart';

/// Immutable UI view state for Thai Mirror Result Page.
class ThaiMirrorViewState {
  const ThaiMirrorViewState({
    required this.hero,
    required this.topThemes,
    required this.sections,
    required this.evidenceExplorer,
    required this.profileContext,
    required this.disclaimers,
    required this.narrativeStatus,
  });

  static const empty = ThaiMirrorViewState(
    hero: ThaiMirrorHeroState(
      titleTh: ThaiMirrorHeroState.defaultTitleTh,
      titleEn: ThaiMirrorHeroState.defaultTitleEn,
      reflectionSummary: ThaiMirrorHeroState.fallbackReflectionSummary,
      topThemeNames: [],
    ),
    topThemes: [],
    sections: [],
    evidenceExplorer: ThaiMirrorEvidenceExplorerState.empty,
    profileContext: ThaiMirrorProfileContextState.empty,
    disclaimers: [],
    narrativeStatus: ThaiMirrorNarrativeStatus.structuralOnly,
  );

  final ThaiMirrorHeroState hero;
  final List<ThaiMirrorThemeCardState> topThemes;
  final List<ThaiMirrorSectionCardState> sections;
  final ThaiMirrorEvidenceExplorerState evidenceExplorer;
  final ThaiMirrorProfileContextState profileContext;
  final List<String> disclaimers;
  final ThaiMirrorNarrativeStatus narrativeStatus;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorViewState &&
        other.hero == hero &&
        other.evidenceExplorer == evidenceExplorer &&
        other.profileContext == profileContext &&
        other.narrativeStatus == narrativeStatus &&
        _themeListEquals(other.topThemes, topThemes) &&
        _sectionListEquals(other.sections, sections) &&
        _stringListEquals(other.disclaimers, disclaimers);
  }

  @override
  int get hashCode => Object.hash(
        hero,
        evidenceExplorer,
        profileContext,
        narrativeStatus,
        Object.hashAll(topThemes),
        Object.hashAll(sections),
        Object.hashAll(disclaimers),
      );

  static bool _themeListEquals(
    List<ThaiMirrorThemeCardState> a,
    List<ThaiMirrorThemeCardState> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sectionListEquals(
    List<ThaiMirrorSectionCardState> a,
    List<ThaiMirrorSectionCardState> b,
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
}
