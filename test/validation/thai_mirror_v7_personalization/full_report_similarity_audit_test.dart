import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

/// V7 — Full-report similarity audit.
///
/// Generates 50 synthetic profiles and measures how similar their *rendered
/// reports* are (not just their themes), across the channels that define the
/// "written for me" feeling: headline, hero summary, the signature insight,
/// every section overview, every micro-story example, and the closing.
void main() {
  const lagnas = [
    'lagna_aries', 'lagna_taurus', 'lagna_gemini', 'lagna_cancer',
    'lagna_leo', 'lagna_virgo', 'lagna_libra', 'lagna_scorpio',
    'lagna_sagittarius', 'lagna_capricorn', 'lagna_aquarius', 'lagna_pisces',
  ];
  const categories = [
    ThemeCategory.coreSelf,
    ThemeCategory.thinkingStyle,
    ThemeCategory.emotionalWorld,
    ThemeCategory.relationships,
    ThemeCategory.workAndAmbition,
    ThemeCategory.strengths,
    ThemeCategory.growthAreas,
    ThemeCategory.growthPath,
  ];

  final pool = ThemeRegistry.getAll().map((t) => t.id).toList();

  ThaiMirrorResult assemble(int i) {
    // Deterministic but well-spread theme selection per profile.
    final offset = (i * 7) % pool.length;
    final step = 3 + (i % 5);
    final ids = <String>[];
    var idx = offset;
    while (ids.length < 6) {
      final id = pool[idx % pool.length];
      if (!ids.contains(id)) ids.add(id);
      idx += step;
    }
    final presented = <ThaiPresentedTheme>[];
    for (var k = 0; k < ids.length; k++) {
      final def = ThemeRegistry.getById(ids[k])!;
      presented.add(
        ThaiPresentedTheme(
          themeId: ids[k],
          themeName: def.name,
          category: categories[(i + k) % categories.length].displayName,
          description: def.description,
          score: 0.96 - (k * 0.02) - (i * 0.0001),
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: const [],
        ),
      );
    }
    return ThaiMirrorAssembler.assemble(
      ThaiMirrorInput(
        profile: ThaiAstrologyProfile(
          hasBirthTime: true,
          lagnaKey: lagnas[i % lagnas.length],
          siderealAscendantDeg: (i * 27.5) % 360,
        ),
        presentedThemes: presented,
      ),
    );
  }

  Set<String> trigrams(String text) {
    final n = text.replaceAll(RegExp(r'\s+'), '');
    if (n.length < 3) return {n};
    final g = <String>{};
    for (var i = 0; i <= n.length - 3; i++) {
      g.add(n.substring(i, i + 3));
    }
    return g;
  }

  double sim(String a, String b) {
    if (a == b && a.isNotEmpty) return 100;
    final ga = trigrams(a);
    final gb = trigrams(b);
    if (ga.isEmpty || gb.isEmpty) return 0;
    return ga.intersection(gb).length / ga.union(gb).length * 100;
  }

  ({double max, double avg, int identical, String worst}) channelStats(
    List<String> texts,
    List<String> ids,
  ) {
    var max = 0.0;
    var total = 0.0;
    var pairs = 0;
    var identical = 0;
    var worst = '';
    for (var i = 0; i < texts.length; i++) {
      for (var j = i + 1; j < texts.length; j++) {
        final s = sim(texts[i], texts[j]);
        total += s;
        pairs++;
        if (texts[i] == texts[j] && texts[i].isNotEmpty) identical++;
        if (s > max) {
          max = s;
          worst = '${ids[i]}↔${ids[j]}';
        }
      }
    }
    return (
      max: max,
      avg: pairs == 0 ? 0 : total / pairs,
      identical: identical,
      worst: worst,
    );
  }

  test('V7 full-report personalization audit over 50 profiles', () {
    final reports = <String, ThaiMirrorConsumerViewState>{};
    for (var i = 0; i < 50; i++) {
      reports['P${i.toString().padLeft(2, '0')}'] =
          ThaiMirrorConsumerPresenter.present(assemble(i));
    }
    final ids = reports.keys.toList();
    final states = reports.values.toList();

    final headlines = states.map((s) => s.hero.headline).toList();
    final summaries = states.map((s) => s.hero.summary).toList();
    final signatures = states.map((s) => s.signatureInsight.body).toList();
    final overviews = states
        .map((s) => s.narrativeSections.map((n) => n.overview).join(' '))
        .toList();
    final examples = states
        .map((s) => s.narrativeSections.map((n) => n.example).join(' '))
        .toList();
    final tensions = states
        .map((s) => s.narrativeSections.map((n) => n.tension).join(' '))
        .toList();
    final closings = states.map((s) => s.closingMessage.message).toList();

    final channels = <String, ({double max, double avg, int identical, String worst})>{
      'headline': channelStats(headlines, ids),
      'heroSummary': channelStats(summaries, ids),
      'signatureInsight': channelStats(signatures, ids),
      'sectionOverviews': channelStats(overviews, ids),
      'examples': channelStats(examples, ids),
      'contradictions': channelStats(tensions, ids),
      'closing': channelStats(closings, ids),
    };

    // ignore: avoid_print
    print('\n=== V7 FULL-REPORT SIMILARITY AUDIT (50 profiles) ===');
    channels.forEach((name, st) {
      // ignore: avoid_print
      print('${name.padRight(18)} '
          'max=${st.max.toStringAsFixed(1).padLeft(5)}%  '
          'avg=${st.avg.toStringAsFixed(1).padLeft(5)}%  '
          'identicalPairs=${st.identical}  worst=${st.worst}');
    });

    // Acceptance gates. The defining channels must show no duplicate feeling;
    // averages matter more than the single worst pair, because genuinely
    // similar people *should* read somewhat alike.
    // Identical headlines occur only between profiles whose *entire* dominant
    // facet signature matches (genuinely similar people). We require this to be
    // rare (< 1% of pairs) rather than impossible.
    final pairCount = ids.length * (ids.length - 1) ~/ 2;
    expect(channels['headline']!.identical, lessThan(pairCount * 0.01),
        reason: 'headlines repeat too often');
    expect(channels['headline']!.avg, lessThan(35));

    expect(channels['heroSummary']!.identical, 0);
    expect(channels['heroSummary']!.avg, lessThan(50));

    expect(channels['signatureInsight']!.identical, 0,
        reason: 'the "heart" passage repeated verbatim');
    expect(channels['signatureInsight']!.avg, lessThan(45));

    // Section narratives share a per-area scaffold (area name + a cause→effect
    // line); the worst pair are near-identical profiles, so we guard the
    // *average* and forbid verbatim duplicates.
    expect(channels['sectionOverviews']!.identical, 0);
    expect(channels['sectionOverviews']!.avg, lessThan(62));

    expect(channels['examples']!.avg, lessThan(40));
    expect(channels['contradictions']!.avg, lessThan(45));

    // The closing is shared quiet wisdom, but should not collapse to one note.
    expect(channels['closing']!.avg, lessThan(45));
  });
}
