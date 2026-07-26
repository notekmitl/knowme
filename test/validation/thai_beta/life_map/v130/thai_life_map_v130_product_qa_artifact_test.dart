import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// Writes V1.3.0 product QA artifact (UI-full text) from TimelinePresenter.
void main() {
  test('write V1.3.0 product QA artifact', () {
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.3.0 — Product QA Artifact')
      ..writeln()
      ..writeln(
        'Synthetic fixtures only (no PII). Path: `TimelinePresenter.build`.',
      )
      ..writeln()
      ..writeln('## V1.2.9 failure phrases (must be absent)')
      ..writeln()
      ..writeln('- ผลกระทบหลักอยู่ที่')
      ..writeln('- ขอบเขตงาน / ขยายบทบาท')
      ..writeln('- ควบคู่กับด้าน')
      ..writeln('- repeated ช่วงนั้น openings')
      ..writeln();

    // Primary Production-style fixture (Sunday / age 39 — 8 periods).
    final primaryWeekday = DateTime.sunday;
    const primaryAge = 39;
    final primaryTimeline = LifePeriodEngine.build(
      birthWeekday: primaryWeekday,
      currentAge: primaryAge,
    );
    final primary = TimelinePresenter.build(
      lifePeriods: primaryTimeline,
      lagnaLordKey: 'sun',
      orderedThemeIds: const ['structure'],
      topThemeTags: const ['มั่นคง'],
      profileSeed: 17,
    )!;

    buf.writeln('## Primary fixture — weekday=$primaryWeekday age=$primaryAge');
    buf.writeln();
    buf.writeln('### Full 8 periods (UI fields)');
    buf.writeln();
    for (final p in primary.periods) {
      final bucket = p.isPast
          ? 'PAST'
          : p.isCurrent
          ? 'CURRENT'
          : 'FUTURE';
      final card = [
        p.summary,
        if (p.whatChanges.isNotEmpty) p.whatChanges,
        if (p.harder.isNotEmpty) p.harder,
        if (p.advice.isNotEmpty) p.advice,
      ].join('\n\n');
      final markerCount =
          LifeMapPlainThaiRenderer.countMarker(card, 'ช่วงนั้น');
      buf.writeln('#### $bucket — ${p.planetLine} (${p.ageLabel})');
      buf.writeln();
      buf.writeln(
        '**Evidence:** keyword=`${p.keyword}`, stage=`${p.stageLabel}`, '
        'bucket=`$bucket`',
      );
      buf.writeln();
      buf.writeln('**UI text:**');
      buf.writeln();
      buf.writeln(card);
      buf.writeln();
      buf.writeln('- `ช่วงนั้น` count: $markerCount');
      buf.writeln(
        '- domain dump: '
        '${LifeMapPlainThaiRenderer.hasDomainDumpTail(card)}',
      );
      buf.writeln(
        '- hard jargon: ${LifeMapPlainThaiRenderer.hasHardJargon(card)}',
      );
      buf.writeln();
      expect(markerCount, lessThanOrEqualTo(1));
      expect(LifeMapPlainThaiRenderer.hasDomainDumpTail(card), isFalse);
      expect(LifeMapPlainThaiRenderer.hasHardJargon(card), isFalse);
      expect(LifeMapVerdictCopy.violatesPrimaryBody(card), isFalse);
    }

    // Breadth samples across weekdays / ages.
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
        final timeline = LifePeriodEngine.build(
          birthWeekday: weekday,
          currentAge: age,
        );
        final state = TimelinePresenter.build(
          lifePeriods: timeline,
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
          if (bucket == 'PAST' && !p.isPast) continue;
          final card = [
            p.summary,
            if (p.harder.isNotEmpty) 'harder: ${p.harder}',
            if (p.advice.isNotEmpty) 'advice: ${p.advice}',
          ].join('\n');
          buf.writeln('### $bucket — ${p.planetLine}');
          buf.writeln();
          buf.writeln(card);
          buf.writeln();
          expect(
            LifeMapPlainThaiRenderer.countMarker(card, 'ช่วงนั้น'),
            lessThanOrEqualTo(1),
          );
          expect(LifeMapVerdictCopy.violatesPrimaryBody(p.summary), isFalse);
        }
      }
    }

    final out = File(
      'test/validation/thai_beta/life_map/v130/output/v130_product_qa.md',
    );
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(buf.toString());
    expect(out.existsSync(), isTrue);
    expect(out.lengthSync(), greaterThan(3000));
  });
}
