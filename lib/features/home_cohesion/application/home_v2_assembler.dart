import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_entry_status.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_result.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_readiness.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';
import 'package:knowme/features/global_fusion/application/narrative/global_narrative_builder.dart';
import 'package:knowme/features/global_fusion/domain/global_reflection_unit.dart';
import 'package:knowme/features/personality_mirror/application/narrative/personality_mirror_narrative_builder.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_narrative_view.dart';
import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

import '../presentation/home_screen_v2_models.dart';
import '../presentation/home_v2_copy.dart';
import '../validation/home_cohesion_golden_fixtures.dart';
import '../validation/home_cohesion_golden_scenario.dart';
import '../validation/home_v2_golden_scenario.dart';

/// Maps loaded sources into user-centric Home V2 sections.
abstract final class HomeV2Assembler {
  static HomeScreenV2Data fromSources(HomeV2SourceBundle sources) {
    return HomeScreenV2Data(
      profile: _profile(sources.profileInput, sources.profileFields),
      astrologySummary: _astrologySummary(
        sources.astrologyFusion,
        sources.astrologyEntry,
        sources.profileInput,
      ),
      combinedReflection: _combinedReflection(
        sources.astrologyFusion,
        sources.personalityNarrative,
        sources.globalReflections,
        sources.globalFusionEntry,
        sources.personalityEntry,
      ),
      psychologyTests: _psychologyTests(sources.personalityCoverage),
      more: _more(
        astrologyEntry: sources.astrologyEntry,
        globalFusionEntry: sources.globalFusionEntry,
      ),
    );
  }

  static HomeScreenV2Data fromGolden(HomeV2GoldenScenario scenario) {
    return fromSources(bundleFromGolden(scenario));
  }

  static HomeV2SourceBundle bundleFromGolden(HomeV2GoldenScenario scenario) {
    final cohesionScenario = switch (scenario) {
      HomeV2GoldenScenario.emptyUser => HomeCohesionGoldenScenario.emptyUser,
      HomeV2GoldenScenario.partialUser => HomeCohesionGoldenScenario.mirrorReady,
      HomeV2GoldenScenario.advancedUser =>
        HomeCohesionGoldenScenario.everythingReady,
    };

    final pair = HomeCohesionGoldenFixtures.load(cohesionScenario);
    final fusionResult = pair.astrologySnapshot?.toResult();

    PersonalityMirrorNarrativeView? narrative;
    final coverage = pair.personalitySnapshot?.coverage;
    if (pair.personalitySnapshot != null) {
      narrative = PersonalityMirrorNarrativeBuilder.build(
        pair.personalitySnapshot!,
      );
    }

    final globalReflections = pair.globalFusionSnapshot == null
        ? const <GlobalReflectionUnit>[]
        : GlobalNarrativeBuilder.fromSnapshot(pair.globalFusionSnapshot!);

    return HomeV2SourceBundle(
      profileInput: _profileInputForScenario(scenario),
      profileFields: _profileFieldsForScenario(scenario),
      astrologyFusion: fusionResult,
      astrologyEntry: AstrologyFusionEntryState(
        readiness: AstrologyFusionReadiness(
          completedLensCount: fusionResult == null ? 0 : 2,
          totalLensCount: 3,
          status: fusionResult == null
              ? AstrologyFusionEntryStatus.unavailable
              : AstrologyFusionEntryStatus.available,
          completedLensIds:
              fusionResult == null ? const [] : const ['western', 'bazi'],
        ),
        canOpen: fusionResult != null,
      ),
      personalityEntry: PersonalityMirrorEntryState(
        canOpen: coverage != null &&
            PersonalityMirrorEntryService.canOpenMirror(coverage),
        canShowFullExperience: coverage != null &&
            PersonalityMirrorEntryService.canShowFullExperience(coverage),
        coverage: coverage,
      ),
      globalFusionEntry: FusionEntryState(
        canOpen: pair.globalFusionSnapshot != null,
      ),
      personalityNarrative: narrative,
      personalityCoverage: coverage,
      globalReflections: globalReflections,
      astrologySnapshot: pair.astrologySnapshot,
      personalitySnapshot: pair.personalitySnapshot,
      globalFusionSnapshot: pair.globalFusionSnapshot,
    );
  }

  static HomeProfileSectionData _profile(
    ExplorationProfileInput input,
    Map<String, String> fields,
  ) {
    final filled = [
      input.hasName,
      input.hasBirthDate,
      input.hasBirthTime,
      input.hasBirthPlace,
    ].where((value) => value).length;

    final ratio = filled / 4;
    final label = switch (ratio) {
      1.0 => HomeV2Copy.profileCompletenessComplete,
      > 0 => HomeV2Copy.profileCompletenessPartial,
      _ => HomeV2Copy.profileCompletenessEmpty,
    };

    final name = fields['name']?.trim();
    return HomeProfileSectionData(
      name: (name == null || name.isEmpty) ? HomeV2Copy.profileEmptyName : name,
      birthDate: _fieldOrPlaceholder(fields['birthDate']),
      birthTime: _fieldOrPlaceholder(fields['birthTime']),
      birthPlace: _fieldOrPlaceholder(fields['birthPlace']),
      completenessLabel: label,
      completenessRatio: ratio,
      isEmpty: !input.hasAnyProfileData,
    );
  }

  static HomeAstrologySummarySectionData _astrologySummary(
    AstrologyFusionResult? fusion,
    AstrologyFusionEntryState entry,
    ExplorationProfileInput profile,
  ) {
    if (fusion == null) {
      return HomeAstrologySummarySectionData(
        isAvailable: false,
        identity: '',
        summary: '',
        reflectionSummary: '',
        emptyHint: profile.isBirthProfileComplete
            ? HomeV2Copy.astrologyEmptyHint
            : HomeV2Copy.profileCompletenessEmpty,
        canOpenFullResult: entry.canOpen,
      );
    }

    return HomeAstrologySummarySectionData(
      isAvailable: true,
      identity: _astrologyIdentity(fusion),
      summary: _astrologySummaryText(fusion),
      reflectionSummary: fusion.reflection.summary,
      emptyHint: '',
      canOpenFullResult: entry.canOpen,
    );
  }

  static HomeCombinedReflectionSectionData _combinedReflection(
    AstrologyFusionResult? fusion,
    PersonalityMirrorNarrativeView? personalityNarrative,
    List<GlobalReflectionUnit> globalReflections,
    FusionEntryState globalFusionEntry,
    PersonalityMirrorEntryState personalityEntry,
  ) {
    final units = <HomeCombinedReflectionUnitData>[];

    if (fusion != null) {
      final text = fusion.reflection.keyInsights.isNotEmpty
          ? fusion.reflection.keyInsights.first
          : fusion.reflection.summary;
      if (text.trim().isNotEmpty) {
        units.add(
          HomeCombinedReflectionUnitData(
            label: HomeV2Copy.labelAstrologyAngle,
            text: text,
          ),
        );
      }
    }

    if (personalityEntry.canOpen && personalityNarrative != null) {
      final text = personalityNarrative.heroParagraphs.isNotEmpty
          ? personalityNarrative.heroParagraphs.first
          : (personalityNarrative.patternCards.isNotEmpty
              ? personalityNarrative.patternCards.first.body
              : '');
      if (text.trim().isNotEmpty) {
        units.add(
          HomeCombinedReflectionUnitData(
            label: HomeV2Copy.labelPersonalityAngle,
            text: text,
          ),
        );
      }
    }

    for (final reflection in globalReflections) {
      if (units.length >= 3) break;
      if (reflection.reflection.trim().isEmpty) continue;
      units.add(
        HomeCombinedReflectionUnitData(
          label: HomeV2Copy.labelCrossAngle,
          text: reflection.reflection,
        ),
      );
    }

    final limited = units.take(3).toList(growable: false);

    return HomeCombinedReflectionSectionData(
      units: limited,
      emptyHint: limited.isEmpty ? HomeV2Copy.combinedReflectionEmptyHint : '',
      canOpenFullResult: globalFusionEntry.canOpen && limited.isNotEmpty,
    );
  }

  static HomePsychologyTestsSectionData _psychologyTests(
    PersonalityCoverage? coverage,
  ) {
    final c = coverage ??
        const PersonalityCoverage(
          availableLensIds: [],
          missingLensIds: [],
          eqModulesCompleted: 0,
          eqModulesExpected: 6,
          weightedCoverage: 0,
        );

    HomePsychologyTestStatus mbtiStatus() {
      if (c.hasMbti) return HomePsychologyTestStatus.completed;
      return HomePsychologyTestStatus.notStarted;
    }

    HomePsychologyTestStatus eqStatus() {
      if (c.eqModulesCompleted >= c.eqModulesExpected &&
          c.eqModulesExpected > 0) {
        return HomePsychologyTestStatus.completed;
      }
      if (c.eqModulesCompleted > 0) {
        return HomePsychologyTestStatus.inProgress;
      }
      return HomePsychologyTestStatus.notStarted;
    }

    HomePsychologyTestStatus bigFiveStatus() {
      if (c.hasBigFive) return HomePsychologyTestStatus.completed;
      return HomePsychologyTestStatus.notStarted;
    }

    return HomePsychologyTestsSectionData(
      tests: [
        HomePsychologyTestItemData(
          id: 'mbti',
          title: 'MBTI',
          description: 'สำรวจแนวโน้มบุคลิกภาพของคุณ',
          status: mbtiStatus(),
        ),
        HomePsychologyTestItemData(
          id: 'eq',
          title: 'EQ',
          description: 'สำรวจความฉลาดทางอารมณ์ของคุณ',
          status: eqStatus(),
        ),
        HomePsychologyTestItemData(
          id: 'big_five',
          title: 'Big Five',
          description: 'สำรวจลักษณะบุคลิกหลักของคุณ',
          status: bigFiveStatus(),
        ),
      ],
    );
  }

  static HomeMoreSectionData _more({
    required AstrologyFusionEntryState astrologyEntry,
    required FusionEntryState globalFusionEntry,
  }) {
    return HomeMoreSectionData(
      items: [
        HomeMoreItemData(
          id: 'astrology',
          title: 'ดวงชะตา',
          description: 'ดูผลดวงและบทสะท้อนเต็ม',
          enabled: astrologyEntry.canOpen,
        ),
        HomeMoreItemData(
          id: 'fusion',
          title: 'ภาพรวมจากหลายมุม',
          description: 'ดูการสะท้อนข้ามมุมมอง',
          enabled: globalFusionEntry.canOpen,
        ),
        HomeMoreItemData(
          id: 'profile',
          title: 'โปรไฟล์',
          description: 'แก้ไขข้อมูลส่วนตัว',
          enabled: true,
        ),
        HomeMoreItemData(
          id: 'settings',
          title: 'การตั้งค่า',
          description: 'ตั้งค่าแอป',
          enabled: true,
        ),
      ],
    );
  }

  static String _astrologyIdentity(AstrologyFusionResult fusion) {
    final primary = fusion.fusionInsight.primary;
    if (primary != null && primary.title.trim().isNotEmpty) {
      return primary.title.trim();
    }

    if (fusion.topThemes.isNotEmpty) {
      final theme = ThemeRegistry.getById(fusion.topThemes.first);
      if (theme != null) return theme.name;
    }

    return 'ภาพรวมดวงของคุณ';
  }

  static String _astrologySummaryText(AstrologyFusionResult fusion) {
    final primary = fusion.fusionInsight.primary;
    if (primary != null && primary.description.trim().isNotEmpty) {
      return primary.description.trim();
    }
    return fusion.reflection.summary;
  }

  static String _fieldOrPlaceholder(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return HomeV2Copy.profileEmptyField;
    }
    return trimmed;
  }

  static ExplorationProfileInput _profileInputForScenario(
    HomeV2GoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomeV2GoldenScenario.emptyUser => ExplorationProfileInput.empty,
      HomeV2GoldenScenario.partialUser => ExplorationProfileInput.birthComplete,
      HomeV2GoldenScenario.advancedUser => ExplorationProfileInput.birthComplete,
    };
  }

  static Map<String, String> _profileFieldsForScenario(
    HomeV2GoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomeV2GoldenScenario.emptyUser => const {},
      HomeV2GoldenScenario.partialUser => const {
          'name': 'KnowMe Explorer',
          'birthDate': '1990-05-15',
          'birthTime': '09:30',
          'birthPlace': 'Bangkok',
        },
      HomeV2GoldenScenario.advancedUser => const {
          'name': 'KnowMe Explorer',
          'birthDate': '1990-05-15',
          'birthTime': '09:30',
          'birthPlace': 'Bangkok',
        },
    };
  }
}

/// Raw inputs for [HomeV2Assembler] — loaded outside widgets.
class HomeV2SourceBundle {
  const HomeV2SourceBundle({
    required this.profileInput,
    required this.profileFields,
    required this.astrologyFusion,
    required this.astrologyEntry,
    required this.personalityEntry,
    required this.globalFusionEntry,
    required this.personalityNarrative,
    required this.personalityCoverage,
    required this.globalReflections,
    this.astrologySnapshot,
    this.personalitySnapshot,
    this.globalFusionSnapshot,
  });

  final ExplorationProfileInput profileInput;
  final Map<String, String> profileFields;
  final AstrologyFusionResult? astrologyFusion;
  final AstrologyFusionEntryState astrologyEntry;
  final PersonalityMirrorEntryState personalityEntry;
  final FusionEntryState globalFusionEntry;
  final PersonalityMirrorNarrativeView? personalityNarrative;
  final PersonalityCoverage? personalityCoverage;
  final List<GlobalReflectionUnit> globalReflections;
  final AstrologyFusionSnapshot? astrologySnapshot;
  final PersonalityMirrorSnapshot? personalitySnapshot;
  final GlobalFusionSnapshot? globalFusionSnapshot;
}
