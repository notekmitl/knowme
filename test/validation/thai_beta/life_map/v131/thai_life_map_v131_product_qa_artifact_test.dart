import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// Writes V1.3.1 product QA artifact from TimelinePresenter.
void main() {
  test('write V1.3.1 product QA artifact', () {
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.3.1 — Product QA Artifact')
      ..writeln()
      ..writeln(
        'Synthetic fixtures only (no PII). Path: `TimelinePresenter.build`.',
      )
      ..writeln()
      ..writeln('## V1.3.0 failure phrases (must be absent)')
      ..writeln()
      ..writeln('- แย่งกันอยู่ / abstract duel pressures')
      ..writeln('- Past as 3-bullet summary only')
      ..writeln('- hero disclaimer soft-sell line')
      ..writeln();

    final primaryWeekday = DateTime.sunday;
    const primaryAge = 39;
    final primary = TimelinePresenter.build(
      lifePeriods: LifePeriodEngine.build(
        birthWeekday: primaryWeekday,
        currentAge: primaryAge,
      ),
      lagnaLordKey: 'sun',
      orderedThemeIds: const ['structure'],
      topThemeTags: const ['มั่นคง'],
      profileSeed: 17,
    )!;

    buf.writeln('## Primary fixture — weekday=$primaryWeekday age=$primaryAge');
    buf.writeln();
    for (final p in primary.periods) {
      final bucket = p.isPast
          ? 'PAST'
          : p.isCurrent
          ? 'CURRENT'
          : 'FUTURE';
      final card = [
        p.summary,
        if (p.harder.isNotEmpty) 'harder: ${p.harder}',
        if (p.advice.isNotEmpty) 'advice: ${p.advice}',
      ].join('\n\n');
      final marker = LifeMapPlainThaiRenderer.countMarker(card, 'ช่วงนั้น');
      buf.writeln('### $bucket — ${p.planetLine} (${p.ageLabel})');
      buf.writeln();
      buf.writeln(
        '**Evidence:** keyword=`${p.keyword}`, stage=`${p.stageLabel}`',
      );
      buf.writeln();
      buf.writeln(card);
      buf.writeln();
      buf.writeln('- `ช่วงนั้น` count: $marker');
      buf.writeln(
        '- abstract duel: ${LifeMapPlainThaiRenderer.hasAbstractDuel(card)}',
      );
      buf.writeln(
        '- beats: ${p.isPast ? '(see semantics via presenter path)' : 'n/a'}',
      );
      buf.writeln();
      expect(marker, equals(0));
      expect(LifeMapPlainThaiRenderer.hasPastSoftOpener(card), isFalse);
      expect(LifeMapPlainThaiRenderer.hasVagueRelationshipForm(card), isFalse);
      expect(LifeMapPlainThaiRenderer.hasAbstractDuel(card), isFalse);
      expect(LifeMapVerdictCopy.violatesPrimaryBody(p.summary), isFalse);
      if (p.isPast) {
        final words =
            (p.summary.replaceAll(RegExp(r'\s+'), '').runes.length / 2.5)
                .round();
        expect(words, greaterThanOrEqualTo(40));
      }
    }

    for (final weekday in [
      DateTime.sunday,
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
    ]) {
      for (final age in [12, 25, 39, 55, 72]) {
        final state = TimelinePresenter.build(
          lifePeriods: LifePeriodEngine.build(
            birthWeekday: weekday,
            currentAge: age,
          ),
          lagnaLordKey: 'sun',
          orderedThemeIds: const ['structure'],
          topThemeTags: const ['มั่นคง'],
          profileSeed: weekday + age,
        )!;
        buf.writeln('## Sample weekday=$weekday age=$age');
        buf.writeln();
        for (final p in state.periods) {
          final bucket = p.isPast
              ? 'PAST'
              : p.isCurrent
              ? 'CURRENT'
              : 'FUTURE';
          buf.writeln('### $bucket — ${p.planetLine}');
          buf.writeln();
          buf.writeln(p.summary);
          if (p.harder.isNotEmpty) buf.writeln('\nharder: ${p.harder}');
          if (p.advice.isNotEmpty) buf.writeln('\nadvice: ${p.advice}');
          buf.writeln();
          expect(LifeMapPlainThaiRenderer.hasAbstractDuel(p.summary), isFalse);
          expect(
            LifeMapPlainThaiRenderer.countMarker(p.summary, 'ช่วงนั้น'),
            equals(0),
          );
          expect(
            LifeMapPlainThaiRenderer.hasPastSoftOpener(p.summary),
            isFalse,
          );
          expect(
            LifeMapPlainThaiRenderer.hasVagueRelationshipForm(
              '${p.summary}\n${p.harder}\n${p.advice}',
            ),
            isFalse,
          );
        }
      }
    }

    final out = File(
      'test/validation/thai_beta/life_map/v131/output/v131_product_qa.md',
    );
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(buf.toString());
    expect(out.existsSync(), isTrue);
    expect(out.lengthSync(), greaterThan(3000));
  });
}
