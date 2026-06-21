import 'package:flutter/material.dart';

import '../../../models/thai_mirror_section_id.dart';
import '../../models/thai_mirror_section_card_state.dart';
import '../../thai_mirror_view_state.dart';
import '../widgets/thai_mirror_evidence_explorer.dart';
import '../widgets/thai_mirror_hero_section.dart';
import '../widgets/thai_mirror_profile_context_card.dart';
import '../widgets/thai_mirror_section_card.dart';
import '../widgets/thai_mirror_top_themes_section.dart';

/// Thai Mirror Result Page — pure consumer of [ThaiMirrorViewState] only.
class ThaiMirrorResultPage extends StatelessWidget {
  const ThaiMirrorResultPage({
    super.key,
    required this.viewState,
  });

  final ThaiMirrorViewState viewState;

  static const sectionIds = <ThaiMirrorSectionId>[
    ThaiMirrorSectionId.coreSelf,
    ThaiMirrorSectionId.thinkingStyle,
    ThaiMirrorSectionId.emotionalWorld,
    ThaiMirrorSectionId.relationships,
    ThaiMirrorSectionId.workAndAmbition,
    ThaiMirrorSectionId.strengths,
    ThaiMirrorSectionId.growthAreas,
    ThaiMirrorSectionId.growthPath,
  ];

  static const expandedDefaults = <ThaiMirrorSectionId>{
    ThaiMirrorSectionId.coreSelf,
    ThaiMirrorSectionId.thinkingStyle,
    ThaiMirrorSectionId.emotionalWorld,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThaiMirrorHeroSection(state: viewState.hero),
              const SizedBox(height: 28),
              ThaiMirrorTopThemesSection(themes: viewState.topThemes),
              const SizedBox(height: 28),
              ...sectionIds.map(
                (id) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ThaiMirrorSectionCard(
                    state: _sectionStateFor(id),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ThaiMirrorEvidenceExplorer(
                state: viewState.evidenceExplorer,
              ),
              const SizedBox(height: 16),
              ThaiMirrorProfileContextCard(
                state: viewState.profileContext,
              ),
              if (viewState.disclaimers.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...viewState.disclaimers.map(
                  (disclaimer) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      disclaimer,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ThaiMirrorSectionCardState _sectionStateFor(ThaiMirrorSectionId id) {
    for (final section in viewState.sections) {
      if (section.id == id) return section;
    }

    return ThaiMirrorSectionCardState(
      id: id,
      titleTh: id.titleTh,
      titleEn: id.titleEn,
      summary: null,
      themeChips: const [],
      evidenceCount: 0,
      isExpandedDefault: expandedDefaults.contains(id),
    );
  }
}
