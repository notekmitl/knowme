import 'package:knowme/features/narrative_runtime/integration/home_narrative_mapper.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_result.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';

import '../domain/home_profile_completion.dart';
import '../presentation/home_screen_v2_models.dart';
import '../presentation/home_screen_v3_models.dart';
import '../presentation/home_v3_copy.dart';
import '../presentation/home_v38_human_translation.dart';
import '../presentation/home_v38_identity_copy.dart';
import '../validation/home_v2_golden_scenario.dart';
import 'home_v2_assembler.dart';

/// Maps existing Home sources into emotional Home V3.8 surface.
abstract final class HomeV3Assembler {
  static HomeScreenV3Data fromSources(
    HomeV2SourceBundle sources, {
    NarrativeResult? narrativeResult,
  }) {
    final themeIds = _recurringThemeIds(sources);
    final narrativeOverlay = HomeNarrativeMapper.overlay(narrativeResult);
    final completion = _completion(sources, narrativeResult);

    final hero = _hero(sources, themeIds, narrativeOverlay, completion);
    final signature = _signature(themeIds, narrativeOverlay);
    final insight = _insight(sources, themeIds, narrativeOverlay);

    return HomeScreenV3Data(
      hero: hero,
      signature: signature,
      insight: insight,
      profile: _profile(sources.profileInput, sources.profileFields),
      psychologyTests: _psychologyTests(sources.personalityCoverage),
      more: _more(sources),
      completion: completion,
      showRecoveryBanner: completion.showRecoveryBanner,
      narrativePreview: _narrativePreview(
        sources.personalityCoverage,
        narrativeResult,
        completion,
      ),
    );
  }

  static HomeProfileCompletion _completion(
    HomeV2SourceBundle sources,
    NarrativeResult? narrativeResult,
  ) {
    final coverage = sources.personalityCoverage;
    final astrologyComplete = sources.profileInput.isBirthProfileComplete &&
        (sources.astrologyEntry.canOpen || sources.astrologyFusion != null);
    final narrativeUnlocked = (coverage?.hasMbti ?? false) &&
        (coverage?.hasBigFive ?? false) &&
        (coverage?.hasAnyEq ?? false) &&
        narrativeResult != null &&
        narrativeResult.paragraphCount > 0;

    return HomeProfileCompletion.fromCoverage(
      astrologyComplete: astrologyComplete,
      coverage: coverage,
      narrativeUnlocked: narrativeUnlocked,
    );
  }

  static HomeNarrativePreviewSectionData _narrativePreview(
    PersonalityCoverage? coverage,
    NarrativeResult? narrativeResult,
    HomeProfileCompletion completion,
  ) {
    final hasMbti = coverage?.hasMbti ?? false;
    if (!hasMbti ||
        narrativeResult == null ||
        narrativeResult.paragraphCount == 0) {
      return const HomeNarrativePreviewSectionData(
        isVisible: false,
        previewText: '',
        lockedSectionCount: 0,
        ctaLabel: '',
      );
    }

    final preview = _previewText(narrativeResult);
    final locked = completion.narrativeUnlocked
        ? 0
        : (narrativeResult.sections.length - 1).clamp(1, 4);

    return HomeNarrativePreviewSectionData(
      isVisible: preview.isNotEmpty,
      previewText: preview,
      lockedSectionCount: locked,
      ctaLabel: HomeV3Copy.narrativePreviewCta,
    );
  }

  static String _previewText(NarrativeResult narrative) {
    final identity = narrative.sectionFor(NarrativeMode.identity);
    if (identity != null && identity.paragraphs.isNotEmpty) {
      return identity.paragraphs.first.text;
    }
    for (final section in narrative.sections) {
      if (section.paragraphs.isNotEmpty) {
        return section.paragraphs.first.text;
      }
    }
    return '';
  }

  static HomeScreenV3Data fromGolden(HomeV2GoldenScenario scenario) {
    return fromSources(HomeV2Assembler.bundleFromGolden(scenario));
  }

  static HomeHeroSectionData _hero(
    HomeV2SourceBundle sources,
    List<String> themeIds,
    HomeNarrativeOverlay? narrativeOverlay,
    HomeProfileCompletion completion,
  ) {
    if (completion.showUnlockHero) {
      return HomeHeroSectionData(
        isAvailable: true,
        identity: HomeV3Copy.unlockHeroTitle,
        supportingReflection: HomeV3Copy.unlockHeroBody.replaceFirst(
          '35%',
          '${completion.progressPercent}%',
        ),
        emptyHint: '',
        canOpenFullResult: false,
        showUnlockCta: true,
        unlockCtaTitle: HomeV3Copy.unlockCtaTitle,
        unlockCtaSubtitle: HomeV3Copy.unlockCtaSubtitle,
        unlockProgressLabel:
            'Your profile is only ${completion.progressPercent}% discovered.',
      );
    }

    if (narrativeOverlay != null &&
        narrativeOverlay.heroIdentity.trim().isNotEmpty) {
      return HomeHeroSectionData(
        isAvailable: true,
        identity: narrativeOverlay.heroIdentity,
        supportingReflection: narrativeOverlay.heroSupporting,
        emptyHint: '',
        canOpenFullResult: sources.astrologyEntry.canOpen,
      );
    }

    final fusion = sources.astrologyFusion;
    if (fusion == null) {
      return HomeHeroSectionData(
        isAvailable: false,
        identity: '',
        supportingReflection: '',
        emptyHint: sources.profileInput.isBirthProfileComplete
            ? HomeV3Copy.heroEmptyHint
            : HomeV3Copy.profileCompletenessEmpty,
        canOpenFullResult: sources.astrologyEntry.canOpen,
      );
    }

    final rawIdentity = _rawHeroText(fusion);
    final rawSupporting = _rawSupportingText(fusion);

    return HomeHeroSectionData(
      isAvailable: true,
      identity: HomeV38IdentityCopy.headline(rawIdentity),
      supportingReflection: HomeV38IdentityCopy.supporting(
        rawSupporting,
        fallback: _supportingFromThemes(themeIds),
      ),
      emptyHint: '',
      canOpenFullResult: sources.astrologyEntry.canOpen,
    );
  }

  static HomeKnowMeSignatureSectionData _signature(
    List<String> themeIds,
    HomeNarrativeOverlay? narrativeOverlay,
  ) {
    if (narrativeOverlay != null &&
        narrativeOverlay.signatureLabels.isNotEmpty) {
      return HomeKnowMeSignatureSectionData(
        themeLabels: narrativeOverlay.signatureLabels,
        emptyHint: '',
        isVisible: true,
      );
    }

    final labels = themeIds
        .take(3)
        .map(HomeV38HumanTranslation.signatureLabel)
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

    return HomeKnowMeSignatureSectionData(
      themeLabels: labels,
      emptyHint: labels.isEmpty ? HomeV3Copy.signatureEmptyHint : '',
      isVisible: labels.isNotEmpty,
    );
  }

  static HomeKnowMeInsightSectionData _insight(
    HomeV2SourceBundle sources,
    List<String> themeIds,
    HomeNarrativeOverlay? narrativeOverlay,
  ) {
    if (narrativeOverlay != null &&
        narrativeOverlay.insightCards.isNotEmpty) {
      return HomeKnowMeInsightSectionData(
        cards: narrativeOverlay.insightCards,
        emptyHint: '',
        canOpenFullInsight:
            sources.globalFusionEntry.canOpen && narrativeOverlay.insightCards.isNotEmpty,
      );
    }

    final cards = themeIds
        .take(3)
        .map(HomeV38HumanTranslation.insightCard)
        .toList(growable: false);

    return HomeKnowMeInsightSectionData(
      cards: cards,
      emptyHint: cards.isEmpty ? HomeV3Copy.insightEmptyHint : '',
      canOpenFullInsight: sources.globalFusionEntry.canOpen && cards.isNotEmpty,
    );
  }

  static HomeCompactProfileSectionData _profile(
    ExplorationProfileInput input,
    Map<String, String> fields,
  ) {
    final filled = [
      input.hasName,
      input.hasBirthDate,
      input.hasBirthPlace,
    ].where((value) => value).length;

    final ratio = filled / 3;
    final label = switch (ratio) {
      1.0 => HomeV3Copy.profileCompletenessComplete,
      > 0 => HomeV3Copy.profileCompletenessPartial,
      _ => HomeV3Copy.profileCompletenessEmpty,
    };

    final name = fields['name']?.trim();
    return HomeCompactProfileSectionData(
      name: (name == null || name.isEmpty) ? HomeV3Copy.profileEmptyName : name,
      birthDate: _fieldOrPlaceholder(fields['birthDate']),
      birthPlace: _fieldOrPlaceholder(fields['birthPlace']),
      completenessLabel: label,
      completenessRatio: ratio,
      isEmpty: !input.hasAnyProfileData,
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

  static HomeMoreSectionData _more(HomeV2SourceBundle sources) {
    return HomeMoreSectionData(
      items: [
        HomeMoreItemData(
          id: 'astrology',
          title: 'ดวงชะตา',
          description: 'ดวงรายวัน รายสัปดาห์ รายเดือน',
          enabled: sources.astrologyEntry.canOpen,
        ),
        HomeMoreItemData(
          id: 'fusion',
          title: 'ภาพรวมหลายมุมมอง',
          description: 'ข้อมูลรวมจากทุกศาสตร์',
          enabled: sources.globalFusionEntry.canOpen,
        ),
        HomeMoreItemData(
          id: 'profile',
          title: 'โปรไฟล์',
          description: 'ข้อมูลส่วนตัวและการตั้งค่า',
          enabled: true,
        ),
        HomeMoreItemData(
          id: 'settings',
          title: 'ตั้งค่า',
          description: 'การแจ้งเตือน ความเป็นส่วนตัว',
          enabled: true,
        ),
      ],
    );
  }

  static String _rawHeroText(AstrologyFusionResult fusion) {
    final primary = fusion.fusionInsight.primary;
    if (primary != null && primary.description.trim().isNotEmpty) {
      return _firstSentence(primary.description.trim());
    }
    if (fusion.reflection.summary.trim().isNotEmpty) {
      return _firstSentence(fusion.reflection.summary.trim());
    }
    if (primary != null && primary.title.trim().isNotEmpty) {
      return primary.title.trim();
    }
    return '';
  }

  static String _rawSupportingText(AstrologyFusionResult fusion) {
    if (fusion.reflection.keyInsights.isNotEmpty) {
      return _truncateLines(
        fusion.reflection.keyInsights.first.trim(),
        maxLines: 2,
      );
    }

    final primary = fusion.fusionInsight.primary;
    if (primary != null && primary.description.trim().isNotEmpty) {
      final parts = _splitSentences(primary.description.trim(), maxParts: 3);
      if (parts.length > 1) {
        return parts.sublist(1).take(2).join(' ');
      }
    }

    if (fusion.reflection.summary.trim().isNotEmpty) {
      final first = _firstSentence(fusion.reflection.summary.trim());
      final remainder = fusion.reflection.summary.trim();
      if (remainder.length > first.length) {
        return _truncateLines(
          remainder.substring(first.length).trim(),
          maxLines: 2,
        );
      }
    }

    return '';
  }

  static String _supportingFromThemes(List<String> themeIds) {
    if (themeIds.isEmpty) return HomeV38IdentityCopy.defaultSupporting;
    final first = HomeV38HumanTranslation.insightCard(themeIds.first);
    return first.supportingExplanation;
  }

  static List<String> _recurringThemeIds(HomeV2SourceBundle sources) {
    final scores = <String, int>{};

    void score(String themeId, {int weight = 1}) {
      final key = themeId.trim().toLowerCase();
      if (key.isEmpty) return;
      if (HomeV38HumanTranslation.signatureLabel(key) == 'จุดเด่นของคุณ') {
        return;
      }
      scores[key] = (scores[key] ?? 0) + weight;
    }

    final global = sources.globalFusionSnapshot;
    if (global != null) {
      for (final activation in global.normalizedThemes) {
        score(activation.globalThemeId, weight: 2);
      }
      for (final agreement in global.agreements) {
        score(agreement.themeId, weight: 2);
      }
    }

    final astrology = sources.astrologySnapshot;
    if (astrology != null) {
      for (final agreement in astrology.agreements) {
        for (final theme in agreement.sourceThemeIds) {
          score(theme);
        }
      }
      for (final signal in astrology.signals) {
        score(signal.type.name);
        for (final theme in signal.sourceThemes) {
          score(theme);
        }
      }
    }

    final personality = sources.personalitySnapshot;
    if (personality != null) {
      for (final agreement in personality.agreements) {
        score(agreement.themeId);
      }
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final seenLabels = <String>{};
    final result = <String>[];

    for (final entry in ranked) {
      final label = HomeV38HumanTranslation.signatureLabel(entry.key);
      if (seenLabels.contains(label)) continue;
      seenLabels.add(label);
      result.add(entry.key);
      if (result.length >= 3) break;
    }

    return result;
  }

  static String _firstSentence(String text) {
    final parts = _splitSentences(text, maxParts: 1);
    return parts.isNotEmpty ? parts.first : text;
  }

  static List<String> _splitSentences(String text, {required int maxParts}) {
    final parts = text
        .split(RegExp(r'(?<=[。．.!?])\s*|(?<=[\n])'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return [text];
    return parts.take(maxParts).toList(growable: false);
  }

  static String _truncateLines(String text, {required int maxLines}) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= maxLines) return text;
    return lines.take(maxLines).join('\n');
  }

  static String _fieldOrPlaceholder(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return HomeV3Copy.profileEmptyField;
    }
    return trimmed;
  }
}
