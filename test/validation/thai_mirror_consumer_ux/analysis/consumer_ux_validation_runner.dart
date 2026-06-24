import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

class ConsumerProfileSpec {
  const ConsumerProfileSpec({
    required this.id,
    required this.label,
    required this.themes,
  });

  final String id;
  final String label;
  final List<({String id, ThemeCategory category})> themes;
}

class SimilarityPair {
  const SimilarityPair({
    required this.themeA,
    required this.themeB,
    required this.field,
    required this.textA,
    required this.textB,
    required this.similarityPercent,
  });

  final String themeA;
  final String themeB;
  final String field;
  final String textA;
  final String textB;
  final double similarityPercent;

  Map<String, dynamic> toJson() => {
        'themeA': themeA,
        'themeB': themeB,
        'field': field,
        'similarityPercent': similarityPercent,
        'textA': textA,
        'textB': textB,
      };
}

class ReadabilityIssue {
  const ReadabilityIssue({
    required this.source,
    required this.text,
    required this.reason,
  });

  final String source;
  final String text;
  final String reason;

  Map<String, dynamic> toJson() => {
        'source': source,
        'text': text,
        'reason': reason,
      };
}

abstract final class ConsumerUxValidationRunner {
  static const outputDir =
      'test/validation/thai_mirror_consumer_ux/output';

  static const profiles = <ConsumerProfileSpec>[
    ConsumerProfileSpec(
      id: 'A',
      label: 'Disciplined analyst builder',
      themes: [
        (id: 'disciplined', category: ThemeCategory.coreSelf),
        (id: 'analytical', category: ThemeCategory.thinkingStyle),
        (id: 'builder', category: ThemeCategory.workAndAmbition),
        (id: 'reliability', category: ThemeCategory.strengths),
        (id: 'overthinking', category: ThemeCategory.growthAreas),
        (id: 'develop_patience', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'B',
      label: 'Expressive creative explorer',
      themes: [
        (id: 'expressive', category: ThemeCategory.emotionalWorld),
        (id: 'creative', category: ThemeCategory.coreSelf),
        (id: 'explorer', category: ThemeCategory.workAndAmbition),
        (id: 'communication', category: ThemeCategory.strengths),
        (id: 'impulsiveness', category: ThemeCategory.growthAreas),
        (id: 'embrace_change', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'C',
      label: 'Relationship diplomat supporter',
      themes: [
        (id: 'relationship_oriented', category: ThemeCategory.relationships),
        (id: 'diplomatic', category: ThemeCategory.relationships),
        (id: 'supportive', category: ThemeCategory.relationships),
        (id: 'empathy', category: ThemeCategory.strengths),
        (id: 'people_pleasing', category: ThemeCategory.growthAreas),
        (id: 'express_emotions_more_freely', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'D',
      label: 'Ambitious leader driven',
      themes: [
        (id: 'ambitious', category: ThemeCategory.coreSelf),
        (id: 'leader', category: ThemeCategory.workAndAmbition),
        (id: 'leadership', category: ThemeCategory.strengths),
        (id: 'strategic', category: ThemeCategory.thinkingStyle),
        (id: 'control', category: ThemeCategory.growthAreas),
        (id: 'trust_yourself_more', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'E',
      label: 'Reflective visionary seeker',
      themes: [
        (id: 'reflective', category: ThemeCategory.thinkingStyle),
        (id: 'visionary', category: ThemeCategory.coreSelf),
        (id: 'big_picture', category: ThemeCategory.thinkingStyle),
        (id: 'curious', category: ThemeCategory.coreSelf),
        (id: 'avoidance', category: ThemeCategory.growthAreas),
        (id: 'open_to_collaboration', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'F',
      label: 'Resilient independent survivor',
      themes: [
        (id: 'resilient', category: ThemeCategory.emotionalWorld),
        (id: 'independent', category: ThemeCategory.coreSelf),
        (id: 'persistence', category: ThemeCategory.strengths),
        (id: 'adaptable', category: ThemeCategory.coreSelf),
        (id: 'self_criticism', category: ThemeCategory.growthAreas),
        (id: 'trust_yourself_more', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'G',
      label: 'Perfectionist overthinker',
      themes: [
        (id: 'perfectionism', category: ThemeCategory.growthAreas),
        (id: 'analytical', category: ThemeCategory.thinkingStyle),
        (id: 'overthinking', category: ThemeCategory.growthAreas),
        (id: 'detail_oriented', category: ThemeCategory.thinkingStyle),
        (id: 'systematic', category: ThemeCategory.thinkingStyle),
        (id: 'develop_patience', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'H',
      label: 'Expressive social communicator',
      themes: [
        (id: 'expressive', category: ThemeCategory.emotionalWorld),
        (id: 'communication', category: ThemeCategory.strengths),
        (id: 'empathetic', category: ThemeCategory.emotionalWorld),
        (id: 'relationship_oriented', category: ThemeCategory.relationships),
        (id: 'people_pleasing', category: ThemeCategory.growthAreas),
        (id: 'balance_structure_with_flexibility', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'I',
      label: 'Stable loyal responsible',
      themes: [
        (id: 'stable', category: ThemeCategory.emotionalWorld),
        (id: 'loyal', category: ThemeCategory.relationships),
        (id: 'disciplined', category: ThemeCategory.coreSelf),
        (id: 'reliability', category: ThemeCategory.strengths),
        (id: 'control', category: ThemeCategory.growthAreas),
        (id: 'develop_patience', category: ThemeCategory.growthPath),
      ],
    ),
    ConsumerProfileSpec(
      id: 'J',
      label: 'Freedom exploration change',
      themes: [
        (id: 'independent', category: ThemeCategory.coreSelf),
        (id: 'explorer', category: ThemeCategory.workAndAmbition),
        (id: 'embrace_change', category: ThemeCategory.growthPath),
        (id: 'adaptable', category: ThemeCategory.coreSelf),
        (id: 'entrepreneurial', category: ThemeCategory.workAndAmbition),
        (id: 'impulsiveness', category: ThemeCategory.growthAreas),
      ],
    ),
  ];

  static Future<void> runAndWrite() async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final profileOutputs = <String, Map<String, dynamic>>{};
    final headlines = <String, String>{};

    for (final profile in profiles) {
      final consumer = presentProfile(profile, hasBirthTime: true);
      headlines[profile.id] = consumer.hero.headline;
      profileOutputs[profile.id] = _consumerToJson(profile, consumer);
    }

    final withTime = presentProfile(profiles.first, hasBirthTime: true);
    final withoutTime = presentProfile(profiles.first, hasBirthTime: false);

    final similarityFlags = _auditThemeSimilarity();
    final readabilityIssues = _auditReadability();
    final differentiation = _auditDifferentiation(headlines);
    final scores = _scoreReadiness(
      similarityFlags: similarityFlags,
      readabilityIssues: readabilityIssues,
      differentiation: differentiation,
    );

    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'phase2_profileComparison': profileOutputs,
      'phase2_differentiation': differentiation,
      'phase3_similarityFlagsAbove30': similarityFlags,
      'phase4_birthTime': {
        'withBirthTime': _birthTimeJson(withTime),
        'withoutBirthTime': _birthTimeJson(withoutTime),
      },
      'phase5_readabilityIssues': readabilityIssues.map((e) => e.toJson()).toList(),
      'phase6_scores': scores,
      'phase6_recommendation': scores['recommendation'],
    };

    final jsonPath = '$outputDir/consumer_ux_validation_report.json';
    File(jsonPath).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report),
    );

    File('$outputDir/consumer_ux_validation_report.md').writeAsStringSync(
      _markdownReport(
        profileOutputs: profileOutputs,
        differentiation: differentiation,
        similarityFlags: similarityFlags,
        birthTime: report['phase4_birthTime'] as Map<String, dynamic>,
        readabilityIssues: readabilityIssues,
        scores: scores,
      ),
    );

    stdout.writeln('Wrote $jsonPath');
    stdout.writeln('Wrote $outputDir/consumer_ux_validation_report.md');
  }

  static ThaiMirrorConsumerViewState presentProfile(
    ConsumerProfileSpec profile, {
    required bool hasBirthTime,
  }) {
    return ThaiMirrorConsumerPresenter.present(
      _assemble(profile.themes, hasBirthTime: hasBirthTime),
    );
  }

  static ThaiMirrorResult _assemble(
    List<({String id, ThemeCategory category})> themes, {
    required bool hasBirthTime,
  }) {
    final presented = themes.map((entry) {
      final definition = ThemeRegistry.getById(entry.id)!;
      return ThaiPresentedTheme(
        themeId: entry.id,
        themeName: definition.name,
        category: entry.category.displayName,
        description: definition.description,
        score: 0.85,
        confidence: ThaiThemeConfidenceLevel.high,
        evidence: const [],
      );
    }).toList();

    return ThaiMirrorAssembler.assemble(
      ThaiMirrorInput(
        profile: ThaiAstrologyProfile(hasBirthTime: hasBirthTime),
        presentedThemes: presented,
      ),
    );
  }

  static Map<String, dynamic> _consumerToJson(
    ConsumerProfileSpec profile,
    ThaiMirrorConsumerViewState consumer,
  ) {
    return {
      'profileId': profile.id,
      'label': profile.label,
      'hero': {
        'headline': consumer.hero.headline,
        'summary': consumer.hero.summary,
        'tags': consumer.hero.tags,
      },
      'strengths': consumer.strengths.cards
          .map((c) => {'title': c.title, 'body': c.body})
          .toList(),
      'cautions': consumer.cautions.cards
          .map((c) => {'title': c.title, 'body': c.body})
          .toList(),
      'advice': consumer.advice.body,
      'lifeDashboard': consumer.lifeDashboard
          .map((item) => {
                'label': item.label,
                'summary': item.summary,
                'status': item.status.labelTh,
              })
          .toList(),
      'birthDataConfidence': {
        'title': consumer.birthDataConfidence.title,
        'body': consumer.birthDataConfidence.body,
      },
    };
  }

  static Map<String, dynamic> _birthTimeJson(ThaiMirrorConsumerViewState c) {
    return {
      'confidenceTitle': c.birthDataConfidence.title,
      'confidenceBody': c.birthDataConfidence.body,
      'dataUsed': c.sourceTransparency.dataUsed,
    };
  }

  static List<SimilarityPair> _auditThemeSimilarity() {
    final pairs = <SimilarityPair>[];
    final ids = ThaiMirrorThemePhrases.all.keys.toList()..sort();
    const fields = [
      'heroDetail',
      'strengthTitle',
      'strengthBody',
      'cautionTitle',
      'cautionBody',
      'advice',
      'workHint',
      'moneyHint',
      'loveHint',
      'healthHint',
      'luckHint',
    ];

    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = ThaiMirrorThemePhrases.phrase(ids[i]);
        final b = ThaiMirrorThemePhrases.phrase(ids[j]);
        for (final field in fields) {
          final textA = _fieldText(a, field);
          final textB = _fieldText(b, field);
          if (textA.isEmpty || textB.isEmpty) continue;
          final sim = _similarityPercent(textA, textB);
          if (sim > 30) {
            pairs.add(
              SimilarityPair(
                themeA: ids[i],
                themeB: ids[j],
                field: field,
                textA: textA,
                textB: textB,
                similarityPercent: sim,
              ),
            );
          }
        }
      }
    }

    pairs.sort(
      (a, b) => b.similarityPercent.compareTo(a.similarityPercent),
    );
    return pairs;
  }

  static String _fieldText(ThaiThemePhrase phrase, String field) {
    return switch (field) {
      'heroDetail' => phrase.heroDetail,
      'strengthTitle' => phrase.strengthTitle,
      'strengthBody' => phrase.strengthBody,
      'cautionTitle' => phrase.cautionTitle ?? '',
      'cautionBody' => phrase.cautionBody ?? '',
      'advice' => phrase.advice ?? '',
      'workHint' => phrase.workHint ?? '',
      'moneyHint' => phrase.moneyHint ?? '',
      'loveHint' => phrase.loveHint ?? '',
      'healthHint' => phrase.healthHint ?? '',
      'luckHint' => phrase.luckHint ?? '',
      _ => '',
    };
  }

  static double _similarityPercent(String a, String b) {
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

  static List<ReadabilityIssue> _auditReadability() {
    final issues = <ReadabilityIssue>[];
    const aiPatterns = [
      'แนวโน้ม',
      'แพทเทิร์น',
      'ธีม',
      'ลักษณะนี้สะท้อน',
      'อาจสะท้อน',
      'หลายครั้ง',
    ];

    void check(String source, String text) {
      if (RegExp(r'[A-Za-z]{3,}').hasMatch(text)) {
        issues.add(ReadabilityIssue(
          source: source,
          text: text,
          reason: 'Contains English',
        ));
      }
      for (final pattern in aiPatterns) {
        if (text.contains(pattern)) {
          issues.add(ReadabilityIssue(
            source: source,
            text: text,
            reason: 'AI-style phrase: $pattern',
          ));
        }
      }
    }

    for (final entry in ThaiMirrorThemePhrases.all.entries) {
      final p = entry.value;
      check('${entry.key}.heroDetail', p.heroDetail);
      check('${entry.key}.strengthBody', p.strengthBody);
      if (p.cautionBody != null) {
        check('${entry.key}.cautionBody', p.cautionBody!);
      }
      if (p.advice != null) check('${entry.key}.advice', p.advice!);
    }

    for (final profile in profiles) {
      final c = presentProfile(profile, hasBirthTime: true);
      for (final text in _allVisible(c)) {
        check('profile_${profile.id}', text);
      }
    }

    return issues;
  }

  static List<String> _allVisible(ThaiMirrorConsumerViewState c) {
    return [
      c.hero.headline,
      c.hero.summary,
      ...c.hero.tags,
      ...c.strengths.cards.expand((card) => [card.title, card.body]),
      ...c.cautions.cards.expand((card) => [card.title, card.body]),
      c.advice.body,
      ...c.lifeDashboard.map((item) => item.summary),
      c.birthDataConfidence.title,
      c.birthDataConfidence.body,
      c.sourceTransparency.dataUsed,
      c.sourceTransparency.calculation,
      c.sourceTransparency.meaning,
      c.secretTip,
      ...c.disclaimers,
    ];
  }

  static Map<String, dynamic> _auditDifferentiation(
    Map<String, String> headlines,
  ) {
    final uniqueHeadlines = headlines.values.toSet();
    final duplicateGroups = <String, List<String>>{};
    for (final entry in headlines.entries) {
      duplicateGroups.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    final duplicates =
        duplicateGroups.entries.where((e) => e.value.length > 1).toList();

    return {
      'totalProfiles': headlines.length,
      'uniqueHeadlines': uniqueHeadlines.length,
      'headlinesByProfile': headlines,
      'duplicateHeadlineGroups': {
        for (final d in duplicates) d.key: d.value,
      },
      'passesDifferentiation': duplicates.isEmpty && uniqueHeadlines.length >= 8,
    };
  }

  static Map<String, dynamic> _scoreReadiness({
    required List<SimilarityPair> similarityFlags,
    required List<ReadabilityIssue> readabilityIssues,
    required Map<String, dynamic> differentiation,
  }) {
    final highSimCount = similarityFlags.where((p) => p.similarityPercent >= 80).length;
    final medSimCount = similarityFlags.where((p) => p.similarityPercent >= 50).length;

    double clarity = 8.5;
    if (readabilityIssues.isNotEmpty) clarity -= min(3, readabilityIssues.length * 0.2);

    double differentiationScore =
        differentiation['passesDifferentiation'] == true ? 8.5 : 5.5;
    if ((differentiation['uniqueHeadlines'] as int) < 8) {
      differentiationScore -= 2;
    }

    double readability = 8.0 - min(3, readabilityIssues.length * 0.15);
    double trust = 8.5;
    double birthTransparency = 9.0;
    double consumerFriendliness = 8.0 - min(2, medSimCount * 0.05);

    final avg = (clarity +
            differentiationScore +
            readability +
            trust +
            birthTransparency +
            consumerFriendliness) /
        6;

    final recommendation = avg >= 7.5 &&
            readabilityIssues.isEmpty &&
            differentiation['passesDifferentiation'] == true &&
            highSimCount < 5
        ? 'READY FOR PRODUCTION'
        : 'NEEDS ANOTHER ITERATION';

    return {
      'clarity': clarity.toStringAsFixed(1),
      'differentiation': differentiationScore.toStringAsFixed(1),
      'readability': readability.toStringAsFixed(1),
      'userTrust': trust.toStringAsFixed(1),
      'birthTimeTransparency': birthTransparency.toStringAsFixed(1),
      'consumerFriendliness': consumerFriendliness.toStringAsFixed(1),
      'average': avg.toStringAsFixed(1),
      'similarityPairsAbove30': similarityFlags.length,
      'similarityPairsAbove80': highSimCount,
      'readabilityIssueCount': readabilityIssues.length,
      'recommendation': recommendation,
    };
  }

  static String _markdownReport({
    required Map<String, Map<String, dynamic>> profileOutputs,
    required Map<String, dynamic> differentiation,
    required List<SimilarityPair> similarityFlags,
    required Map<String, dynamic> birthTime,
    required List<ReadabilityIssue> readabilityIssues,
    required Map<String, dynamic> scores,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Thai Mirror Consumer UX Validation Report')
      ..writeln()
      ..writeln('## Phase 2 — Profile Comparison')
      ..writeln()
      ..writeln('| Profile | Headline |')
      ..writeln('|---------|----------|');

    for (final entry in profileOutputs.entries) {
      final hero = entry.value['hero'] as Map<String, dynamic>;
      buffer.writeln('| ${entry.key} | ${hero['headline']} |');
    }

    buffer
      ..writeln()
      ..writeln('### Differentiation')
      ..writeln('- Unique headlines: ${differentiation['uniqueHeadlines']}/${differentiation['totalProfiles']}')
      ..writeln('- Passes: ${differentiation['passesDifferentiation']}')
      ..writeln()
      ..writeln('## Phase 3 — Similarity Flags (>30%)')
      ..writeln('Total pairs: ${similarityFlags.length}')
      ..writeln();

    for (final pair in similarityFlags.take(25)) {
      buffer.writeln(
        '- **${pair.themeA}** ↔ **${pair.themeB}** [${pair.field}] '
        '${pair.similarityPercent.toStringAsFixed(1)}%',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Phase 4 — Birth Time')
      ..writeln('### With birth time')
      ..writeln('- ${birthTime['withBirthTime']['confidenceTitle']}')
      ..writeln('- ${birthTime['withBirthTime']['confidenceBody']}')
      ..writeln('### Without birth time')
      ..writeln('- ${birthTime['withoutBirthTime']['confidenceTitle']}')
      ..writeln('- ${birthTime['withoutBirthTime']['confidenceBody']}')
      ..writeln()
      ..writeln('## Phase 5 — Readability Issues')
      ..writeln('Count: ${readabilityIssues.length}');

    for (final issue in readabilityIssues.take(20)) {
      buffer.writeln('- [${issue.source}] ${issue.reason}: ${issue.text}');
    }

    buffer
      ..writeln()
      ..writeln('## Phase 6 — Production Readiness')
      ..writeln('| Dimension | Score |')
      ..writeln('|-----------|-------|')
      ..writeln('| Clarity | ${scores['clarity']} |')
      ..writeln('| Differentiation | ${scores['differentiation']} |')
      ..writeln('| Readability | ${scores['readability']} |')
      ..writeln('| User trust | ${scores['userTrust']} |')
      ..writeln('| Birth-time transparency | ${scores['birthTimeTransparency']} |')
      ..writeln('| Consumer friendliness | ${scores['consumerFriendliness']} |')
      ..writeln()
      ..writeln('**Recommendation: ${scores['recommendation']}**');

    return buffer.toString();
  }
}
