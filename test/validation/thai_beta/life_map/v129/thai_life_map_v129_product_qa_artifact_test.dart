import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';

/// Writes full before/after-style QA artifact from production TimelinePresenter.
void main() {
  test('write V1.2.9 product QA artifact', () {
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.2.9 — Product QA Artifact')
      ..writeln()
      ..writeln(
        'Synthetic fixtures only (no PII). Path: `TimelinePresenter.build`.',
      )
      ..writeln()
      ..writeln('## Production-failure regression (must be absent)')
      ..writeln()
      ..writeln('- แกนของชีวิต')
      ..writeln('- บรรยากาศหลัก')
      ..writeln('- มากกว่าเรื่องอื่นในช่วงใกล้เคียง')
      ..writeln('- มีน้ำหนักต่างจากจังหวะ')
      ..writeln();

    final samples = <String>[];
    for (final weekday in [
      DateTime.sunday,
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
    ]) {
      final age = 25 + (weekday % 5) * 7;
      final timeline = LifePeriodEngine.build(
        birthWeekday: weekday,
        currentAge: age,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: 17,
      )!;
      buf.writeln('## Weekday=$weekday age=$age');
      buf.writeln();
      for (final p in state.periods) {
        final bucket = p.isPast
            ? 'PAST'
            : p.isCurrent
            ? 'CURRENT'
            : 'FUTURE';
        buf.writeln('### $bucket — ${p.planetLine} (${p.ageLabel})');
        buf.writeln();
        buf.writeln(
          '**Evidence (non-PII):** planetLine=`${p.planetLine}`, '
          'keyword=`${p.keyword}`, stage=`${p.stageLabel}`, '
          'bucket=`$bucket`',
        );
        buf.writeln();
        buf.writeln('**UI summary:**');
        buf.writeln();
        buf.writeln(p.summary);
        buf.writeln();
        if (!p.isPast) {
          buf.writeln('**whatChanges:** ${p.whatChanges}');
          buf.writeln();
          buf.writeln('**harder (pressure):** ${p.harder}');
          buf.writeln();
          buf.writeln('**advice (consequence):** ${p.advice}');
          buf.writeln();
        }
        expect(LifeMapVerdictCopy.violatesPrimaryBody(p.summary), isFalse);
        expect(LifeMapVerdictCopy.looksLikeAbstractOnly(p.summary), isFalse);
        samples.add(p.summary);
      }
    }

    final joined = samples.join('\n');
    expect(joined.contains('แกนของชีวิต'), isFalse);
    expect(joined.contains('บรรยากาศหลัก'), isFalse);
    expect(joined.contains('มากกว่าเรื่องอื่นในช่วงใกล้เคียง'), isFalse);

    final out = File(
      'test/validation/thai_beta/life_map/v129/output/v129_product_qa.md',
    );
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(buf.toString());
    expect(out.existsSync(), isTrue);
    expect(out.lengthSync(), greaterThan(2000));
  });
}
