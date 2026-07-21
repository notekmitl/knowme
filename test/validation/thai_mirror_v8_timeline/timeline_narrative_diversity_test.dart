import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// V8 — Timeline narrative diversity.
///
/// Two people in the *same* planetary period should still read differently once
/// their weekday, age, lagna lord and evidence differ. This audit builds 40
/// varied profiles and measures similarity of their full timeline narrative
/// (current-stage intro + every period summary/changes/easier/harder/evidence).
void main() {
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

  const lagnaLords = [
    'lagna_lord_saturn',
    'lagna_lord_jupiter',
    'lagna_lord_venus',
    'lagna_lord_mars',
    'lagna_lord_mercury',
    'lagna_lord_moon',
    'lagna_lord_sun',
  ];
  const themeBanks = [
    ['disciplined', 'analytical', 'builder', 'reliability'],
    ['leader', 'ambitious', 'independent', 'leadership'],
    ['empathetic', 'loyal', 'creative', 'empathy'],
    ['curious', 'visionary', 'big_picture', 'communication'],
    ['stable', 'supportive', 'practical', 'persistence'],
  ];

  String timelineText(int i) {
    final birth = DateTime(1960 + (i % 45), 1 + (i % 12), 1 + (i % 27));
    final state = TimelinePresenter.build(
      lifePeriods: LifePeriodEngine.fromBirthDate(
        birth,
        asOf: DateTime(2026, 6, 26),
      ),
      lagnaLordKey: lagnaLords[i % lagnaLords.length],
      orderedThemeIds: themeBanks[i % themeBanks.length],
      topThemeTags: ['จุดเด่น$i', 'แกนหลัก$i', 'ตัวตน$i'],
      profileSeed: (i * 2654435761) ^ (i << 7),
    )!;
    final buffer = StringBuffer(state.currentStage.intro);
    for (final p in state.periods) {
      buffer
        ..write(p.summary)
        ..write(p.whatChanges)
        ..write(p.easier)
        ..write(p.harder)
        ..write(p.evidenceLine);
    }
    return buffer.toString();
  }

  test('timeline narratives are not duplicates across 40 profiles', () {
    final texts = [for (var i = 0; i < 40; i++) timelineText(i)];

    var maxSim = 0.0;
    var total = 0.0;
    var pairs = 0;
    var identical = 0;
    for (var i = 0; i < texts.length; i++) {
      for (var j = i + 1; j < texts.length; j++) {
        final s = sim(texts[i], texts[j]);
        total += s;
        pairs++;
        if (texts[i] == texts[j]) identical++;
        if (s > maxSim) maxSim = s;
      }
    }
    final avg = total / pairs;

    // ignore: avoid_print
    print('\n=== V8 TIMELINE NARRATIVE DIVERSITY (40 profiles) ===\n'
        'max=${maxSim.toStringAsFixed(1)}%  avg=${avg.toStringAsFixed(1)}%  '
        'identicalPairs=$identical');

    expect(identical, 0, reason: 'two timelines are byte-identical');
    expect(avg, lessThan(70),
        reason: 'timelines feel like the same article on average');
  });
}
