import 'dart:math';

import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_variants.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

class ContentProfileSpec {
  const ContentProfileSpec({
    required this.id,
    required this.themes,
  });

  final String id;
  final List<({String id, ThemeCategory category})> themes;
}

abstract final class ContentDiversityValidationRunner {
  static const beforePairCountAbove30 = 18;

  static const _profileLagnas = [
    'lagna_aries',
    'lagna_taurus',
    'lagna_gemini',
    'lagna_cancer',
    'lagna_leo',
    'lagna_virgo',
    'lagna_libra',
    'lagna_scorpio',
    'lagna_sagittarius',
    'lagna_capricorn',
    'lagna_aquarius',
    'lagna_pisces',
    'lagna_aries',
    'lagna_taurus',
    'lagna_gemini',
    'lagna_cancer',
    'lagna_leo',
    'lagna_virgo',
    'lagna_libra',
    'lagna_scorpio',
  ];
  static const genericStrengthTitles = {
    'ทำตามที่สัญญา',
    'คิดก่อนลงมือ',
    'ไม่ยอมแพ้ง่าย ๆ',
  };

  static const bannedDashboardLines = {
    'งานที่ให้คุณใช้จุดแข็งและเห็นเป้าหมายชัด คุณมักทำได้ดี',
    'คุณมักใช้เงินอย่างมีแผนและให้ความสำคัญกับความมั่นคง',
    'ความสัมพันธ์ดีขึ้นเมื่อมีความไว้วางใจและเวลาอยู่ด้วยกันอย่างจริงใจ',
    'พักผ่อนพอและแบ่งเวลาพักใจ จะช่วยให้คุณแข็งแรงต่อเนื่อง',
    'โอกาสดีมักมาเมื่อคุณเปิดใจลองสิ่งใหม่ที่เหมาะกับตัวเอง',
  };

  static const profiles = <ContentProfileSpec>[
    ContentProfileSpec(id: 'P01', themes: [
      (id: 'disciplined', category: ThemeCategory.coreSelf),
      (id: 'analytical', category: ThemeCategory.thinkingStyle),
      (id: 'builder', category: ThemeCategory.workAndAmbition),
      (id: 'reliability', category: ThemeCategory.strengths),
      (id: 'overthinking', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P02', themes: [
      (id: 'expressive', category: ThemeCategory.emotionalWorld),
      (id: 'creative', category: ThemeCategory.coreSelf),
      (id: 'explorer', category: ThemeCategory.workAndAmbition),
      (id: 'communication', category: ThemeCategory.strengths),
      (id: 'impulsiveness', category: ThemeCategory.growthAreas),
      (id: 'open_to_collaboration', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P03', themes: [
      (id: 'relationship_oriented', category: ThemeCategory.relationships),
      (id: 'diplomatic', category: ThemeCategory.relationships),
      (id: 'independent_in_relationships', category: ThemeCategory.relationships),
      (id: 'leadership', category: ThemeCategory.strengths),
      (id: 'people_pleasing', category: ThemeCategory.growthAreas),
      (id: 'express_emotions_more_freely', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P04', themes: [
      (id: 'ambitious', category: ThemeCategory.coreSelf),
      (id: 'leader', category: ThemeCategory.workAndAmbition),
      (id: 'leadership', category: ThemeCategory.strengths),
      (id: 'strategic', category: ThemeCategory.thinkingStyle),
      (id: 'control', category: ThemeCategory.growthAreas),
      (id: 'trust_yourself_more', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P05', themes: [
      (id: 'reflective', category: ThemeCategory.thinkingStyle),
      (id: 'visionary', category: ThemeCategory.coreSelf),
      (id: 'big_picture', category: ThemeCategory.thinkingStyle),
      (id: 'curious', category: ThemeCategory.coreSelf),
      (id: 'avoidance', category: ThemeCategory.growthAreas),
      (id: 'open_to_collaboration', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P06', themes: [
      (id: 'resilient', category: ThemeCategory.emotionalWorld),
      (id: 'independent', category: ThemeCategory.coreSelf),
      (id: 'persistence', category: ThemeCategory.strengths),
      (id: 'adaptable', category: ThemeCategory.coreSelf),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
      (id: 'trust_yourself_more', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P07', themes: [
      (id: 'perfectionism', category: ThemeCategory.growthAreas),
      (id: 'analytical', category: ThemeCategory.thinkingStyle),
      (id: 'overthinking', category: ThemeCategory.growthAreas),
      (id: 'detail_oriented', category: ThemeCategory.thinkingStyle),
      (id: 'systematic', category: ThemeCategory.thinkingStyle),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P08', themes: [
      (id: 'expressive', category: ThemeCategory.emotionalWorld),
      (id: 'communication', category: ThemeCategory.strengths),
      (id: 'empathetic', category: ThemeCategory.emotionalWorld),
      (id: 'relationship_oriented', category: ThemeCategory.relationships),
      (id: 'people_pleasing', category: ThemeCategory.growthAreas),
      (id: 'balance_structure_with_flexibility', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P09', themes: [
      (id: 'stable', category: ThemeCategory.emotionalWorld),
      (id: 'loyal', category: ThemeCategory.relationships),
      (id: 'grounded', category: ThemeCategory.coreSelf),
      (id: 'persistence', category: ThemeCategory.strengths),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
      (id: 'express_emotions_more_freely', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P10', themes: [
      (id: 'independent', category: ThemeCategory.coreSelf),
      (id: 'leader', category: ThemeCategory.workAndAmbition),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
      (id: 'specialist', category: ThemeCategory.workAndAmbition),
      (id: 'adaptable', category: ThemeCategory.coreSelf),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
    ]),
    ContentProfileSpec(id: 'P11', themes: [
      (id: 'grounded', category: ThemeCategory.coreSelf),
      (id: 'practical', category: ThemeCategory.coreSelf),
      (id: 'teacher', category: ThemeCategory.workAndAmbition),
      (id: 'reliability', category: ThemeCategory.strengths),
      (id: 'perfectionism', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P12', themes: [
      (id: 'protective', category: ThemeCategory.coreSelf),
      (id: 'protective_of_others', category: ThemeCategory.relationships),
      (id: 'empathy', category: ThemeCategory.strengths),
      (id: 'calm_under_pressure', category: ThemeCategory.emotionalWorld),
      (id: 'control', category: ThemeCategory.growthAreas),
      (id: 'express_emotions_more_freely', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P13', themes: [
      (id: 'fast_moving', category: ThemeCategory.thinkingStyle),
      (id: 'entrepreneurial', category: ThemeCategory.workAndAmbition),
      (id: 'leadership', category: ThemeCategory.strengths),
      (id: 'builder', category: ThemeCategory.workAndAmbition),
      (id: 'impulsiveness', category: ThemeCategory.growthAreas),
      (id: 'embrace_change', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P14', themes: [
      (id: 'sensitive', category: ThemeCategory.emotionalWorld),
      (id: 'reserved', category: ThemeCategory.emotionalWorld),
      (id: 'independent_in_relationships', category: ThemeCategory.relationships),
      (id: 'adaptability', category: ThemeCategory.strengths),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P15', themes: [
      (id: 'calm_under_pressure', category: ThemeCategory.emotionalWorld),
      (id: 'specialist', category: ThemeCategory.workAndAmbition),
      (id: 'innovator', category: ThemeCategory.workAndAmbition),
      (id: 'strategic', category: ThemeCategory.thinkingStyle),
      (id: 'control', category: ThemeCategory.growthAreas),
      (id: 'open_to_collaboration', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P16', themes: [
      (id: 'teacher', category: ThemeCategory.workAndAmbition),
      (id: 'creativity', category: ThemeCategory.strengths),
      (id: 'fast_moving', category: ThemeCategory.thinkingStyle),
      (id: 'diplomatic', category: ThemeCategory.relationships),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P17', themes: [
      (id: 'visionary', category: ThemeCategory.coreSelf),
      (id: 'big_picture', category: ThemeCategory.thinkingStyle),
      (id: 'leader', category: ThemeCategory.workAndAmbition),
      (id: 'persistence', category: ThemeCategory.strengths),
      (id: 'overthinking', category: ThemeCategory.growthAreas),
      (id: 'embrace_change', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P18', themes: [
      (id: 'systematic', category: ThemeCategory.thinkingStyle),
      (id: 'innovator', category: ThemeCategory.workAndAmbition),
      (id: 'persistence', category: ThemeCategory.strengths),
      (id: 'detail_oriented', category: ThemeCategory.thinkingStyle),
      (id: 'self_criticism', category: ThemeCategory.growthAreas),
      (id: 'trust_yourself_more', category: ThemeCategory.growthPath),
    ]),
    ContentProfileSpec(id: 'P19', themes: [
      (id: 'reflective', category: ThemeCategory.thinkingStyle),
      (id: 'creativity', category: ThemeCategory.strengths),
      (id: 'curious', category: ThemeCategory.coreSelf),
      (id: 'balance_structure_with_flexibility', category: ThemeCategory.growthPath),
      (id: 'impulsiveness', category: ThemeCategory.growthAreas),
      (id: 'builder', category: ThemeCategory.workAndAmbition),
    ]),
    ContentProfileSpec(id: 'P20', themes: [
      (id: 'supportive', category: ThemeCategory.relationships),
      (id: 'loyal', category: ThemeCategory.relationships),
      (id: 'practical', category: ThemeCategory.coreSelf),
      (id: 'reliability', category: ThemeCategory.strengths),
      (id: 'avoidance', category: ThemeCategory.growthAreas),
      (id: 'open_to_collaboration', category: ThemeCategory.growthPath),
    ]),
  ];

  static ThaiMirrorConsumerViewState present(ContentProfileSpec profile) {
    return ThaiMirrorConsumerPresenter.present(
      _assemble(profile.themes, profileId: profile.id),
    );
  }

  static Map<String, dynamic> validate() {
    final outputs = <String, ThaiMirrorConsumerViewState>{};
    for (final profile in profiles) {
      outputs[profile.id] = present(profile);
    }

    final themeCoverage = _validateThemeCoverage();
    final genericStrengthViolations = <String>[];
    final bannedDashboardUsage = <String, int>{};
    final pairFlags = <Map<String, dynamic>>[];
    final allPairs = <Map<String, dynamic>>[];

    for (final entry in outputs.entries) {
      final consumer = entry.value;
      final profileThemes = profiles
          .firstWhere((p) => p.id == entry.key)
          .themes
          .map((t) => t.id)
          .toSet();

      for (final card in consumer.strengths.cards) {
        if (genericStrengthTitles.contains(card.title) &&
            !_profileHasStrengthTitle(card.title, profileThemes)) {
          genericStrengthViolations.add('${entry.key}: ${card.title}');
        }
      }

      if (consumer.strengths.cards.length < 3) {
        genericStrengthViolations.add(
          '${entry.key}: only ${consumer.strengths.cards.length} strength cards',
        );
      }

      for (final item in consumer.lifeDashboard) {
        if (bannedDashboardLines.contains(item.summary)) {
          bannedDashboardUsage[item.summary] =
              (bannedDashboardUsage[item.summary] ?? 0) + 1;
        }
      }
    }

    final ids = outputs.keys.toList();
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = outputs[ids[i]]!;
        final b = outputs[ids[j]]!;
        final heroSim = _similarity(a.hero.headline + a.hero.summary, b.hero.headline + b.hero.summary);
        final strengthSim = _similarity(
          a.strengths.cards.map((c) => '${c.title} ${c.body}').join(' '),
          b.strengths.cards.map((c) => '${c.title} ${c.body}').join(' '),
        );
        final dashboardSim = _similarity(
          a.lifeDashboard.map((d) => d.summary).join(' '),
          b.lifeDashboard.map((d) => d.summary).join(' '),
        );
        final adviceSim = _similarity(a.advice.body, b.advice.body);

        final maxSim = [heroSim, strengthSim, dashboardSim, adviceSim]
            .reduce((a, b) => a > b ? a : b);
        final pairEntry = {
          'pair': '${ids[i]}↔${ids[j]}',
          'hero': heroSim,
          'strengths': strengthSim,
          'dashboard': dashboardSim,
          'advice': adviceSim,
          'max': maxSim,
        };
        allPairs.add(pairEntry);

        if ([heroSim, strengthSim, dashboardSim, adviceSim].any((s) => s > 30)) {
          pairFlags.add(pairEntry);
        }
      }
    }

    final maxDashboardRepeat = bannedDashboardUsage.values.fold<int>(
      0,
      (max, count) => max > count ? max : count,
    );

    allPairs.sort((a, b) => (b['max'] as double).compareTo(a['max'] as double));
    final top10SimilarPairs = allPairs.take(10).toList();

    return {
      'themeCoverage': themeCoverage,
      'genericStrengthViolations': genericStrengthViolations,
      'bannedDashboardUsage': bannedDashboardUsage,
      'maxDashboardLineRepeat': maxDashboardRepeat,
      'pairFlagsAbove30': pairFlags,
      'pairCountAbove30': pairFlags.length,
      'beforePairCountAbove30': beforePairCountAbove30,
      'afterPairCountAbove30': pairFlags.length,
      'top10SimilarPairs': top10SimilarPairs,
      'passes': themeCoverage['allThemesCovered'] == true &&
          genericStrengthViolations.isEmpty &&
          maxDashboardRepeat <= 6 &&
          pairFlags.isEmpty,
    };
  }

  static bool _profileHasStrengthTitle(
    String title,
    Set<String> themeIds,
  ) {
    for (final themeId in themeIds) {
      if (ThaiMirrorThemeVariants.allStrengthTitlesForTheme(themeId).contains(title)) {
        return true;
      }
    }
    return false;
  }

  static String _lagnaForProfile(String profileId) {
    final index = int.tryParse(profileId.replaceAll('P', '')) ?? 1;
    return _profileLagnas[(index - 1) % _profileLagnas.length];
  }

  static Map<String, dynamic> _validateThemeCoverage() {
    final missing = <String>[];
    for (final themeId in ThemeRegistry.getAll().map((t) => t.id)) {
      final phrase = ThaiMirrorThemePhrases.phrase(themeId);
      for (final aspect in ['work', 'money', 'love', 'health', 'luck']) {
        final hint = ThaiMirrorThemePhrases.aspectHint(themeId, aspect);
        if (hint.isEmpty) missing.add('$themeId.$aspect');
        if (ThaiMirrorThemeVariants.aspectHintVariants(themeId, aspect).isEmpty) {
          missing.add('$themeId.$aspect.variants');
        }
      }
      if (ThaiMirrorThemeVariants.strengthVariants(themeId).length < 3) {
        missing.add('$themeId.strength.variants');
      }
      final hasStrength = phrase.strengthTitle.isNotEmpty &&
          phrase.strengthBody.isNotEmpty;
      if (!hasStrength &&
          ThaiMirrorThemeVariants.strengthVariants(themeId).isEmpty) {
        missing.add('$themeId.strength');
      }
    }
    return {
      'allThemesCovered': missing.isEmpty,
      'missing': missing,
    };
  }

  static double _similarity(String a, String b) {
    if (a == b) return 100;
    final gramsA = _trigrams(a);
    final gramsB = _trigrams(b);
    if (gramsA.isEmpty || gramsB.isEmpty) return 0;
    final intersection = gramsA.intersection(gramsB).length;
    final union = gramsA.union(gramsB).length;
    return (intersection / union) * 100;
  }

  static Set<String> _trigrams(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    if (normalized.length < 3) return {normalized};
    final grams = <String>{};
    for (var i = 0; i <= normalized.length - 3; i++) {
      grams.add(normalized.substring(i, i + 3));
    }
    return grams;
  }

  static ThaiMirrorResult _assemble(
    List<({String id, ThemeCategory category})> themes, {
    required String profileId,
  }) {
    final profileOffset = profileId.hashCode.abs() % 1000;
    final profileIndex = int.tryParse(profileId.replaceAll('P', '')) ?? 1;
    final presented = themes.asMap().entries.map((entry) {
      final index = entry.key;
      final theme = entry.value;
      final definition = ThemeRegistry.getById(theme.id)!;
      return ThaiPresentedTheme(
        themeId: theme.id,
        themeName: definition.name,
        category: theme.category.displayName,
        description: definition.description,
        score: 0.95 - (index * 0.015) - (profileOffset * 0.00001),
        confidence: ThaiThemeConfidenceLevel.high,
        evidence: const [],
      );
    }).toList();

    return ThaiMirrorAssembler.assemble(
      ThaiMirrorInput(
        profile: ThaiAstrologyProfile(
          hasBirthTime: true,
          lagnaKey: _lagnaForProfile(profileId),
          siderealAscendantDeg: (profileIndex * 27.5) % 360,
        ),
        presentedThemes: presented,
      ),
    );
  }
}
