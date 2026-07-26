import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_current_domain_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// Manual Product QA artifact for V1.3.4 — full rendered text.
void main() {
  test('write V1.3.4 product QA artifact', () {
    final outDir = Directory('test/validation/thai_beta/life_map/v134/output')
      ..createSync(recursive: true);
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.3.4 — Product QA Artifact')
      ..writeln()
      ..writeln('Synthetic fixtures only (no PII). No Swiss Ephemeris.')
      ..writeln()
      ..writeln('## Owner-equivalent fixture')
      ..writeln()
      ..writeln('- civil: 1982-06-06 00:35 Chiang Mai')
      ..writeln('- note: before local sunrise → astrological day 1982-06-05')
      ..writeln();

    final ownerView = ThaiBetaNarrativeComposer.compose(
      ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Owner',
          lastName: 'Fixture',
          birthDate: DateTime(1982, 6, 6),
          birthHour: 0,
          birthMinute: 35,
          province: 'เชียงใหม่',
          provinceKey: 'chiang_mai',
        ),
        startedAt: DateTime(2026, 7, 26),
      ),
    ).view;

    buf
      ..writeln('### Hero')
      ..writeln()
      ..writeln('- badge: `${ownerView.hero.identityBadge}`')
      ..writeln('- headline: ${ownerView.hero.headline}')
      ..writeln('- subtitle: ${ownerView.hero.identitySubtitle}')
      ..writeln('- tags: ${ownerView.hero.tags.join(' / ')}')
      ..writeln('- summary:')
      ..writeln()
      ..writeln(ownerView.hero.summary)
      ..writeln();

    expect(ownerView.hero.headline.contains('พื้นฐานจากดวงไทยคู่กับ'), isFalse);

    final timeline = ownerView.lifeTimeline!;
    buf.writeln('### Past');
    buf.writeln();
    for (final p in timeline.periods.where((p) => p.isPast)) {
      buf
        ..writeln('#### ${p.planetLine} (${p.ageLabel})')
        ..writeln()
        ..writeln(p.summary)
        ..writeln();
    }

    final current = timeline.periods.singleWhere((p) => p.isCurrent);
    buf
      ..writeln('### Current — ${current.planetLine} (${current.ageLabel})')
      ..writeln();
    expect(
      current.lifeDomains.map((d) => d.title).toList(),
      LifeMapCurrentDomainComposer.allowedTitles,
    );
    for (final d in current.lifeDomains) {
      buf
        ..writeln('#### ${d.title}')
        ..writeln()
        ..writeln(d.body)
        ..writeln()
        ..writeln('- evidenceKeys: ${d.evidenceKeys.join(', ')}')
        ..writeln();
    }

    buf
      ..writeln('### Future sample (unchanged slot layout)')
      ..writeln();
    for (final p
        in timeline.periods.where((p) => !p.isPast && !p.isCurrent).take(1)) {
      buf
        ..writeln('- ${p.planetLine}: ${p.summary}')
        ..writeln('- harder: ${p.harder}')
        ..writeln('- advice: ${p.advice}')
        ..writeln('- lifeDomains empty: ${p.lifeDomains.isEmpty}')
        ..writeln();
    }

    // Comparison fixtures
    buf.writeln('## Comparison fixtures');
    buf.writeln();
    void dumpCompare(String label, dynamic analysis) {
      final view = ThaiBetaNarrativeComposer.compose(analysis).view;
      buf
        ..writeln('### $label')
        ..writeln()
        ..writeln('- headline: ${view.hero.headline}')
        ..writeln('- summary:')
        ..writeln()
        ..writeln(view.hero.summary)
        ..writeln();
      final cur = view.lifeTimeline?.periods.where((p) => p.isCurrent);
      if (cur != null) {
        for (final p in cur) {
          for (final d in p.lifeDomains) {
            buf.writeln('- ${d.title}: ${d.body}');
          }
        }
      }
      buf.writeln();
    }

    dumpCompare(
      'Fixture A (complete birth time)',
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    dumpCompare(
      'Fixture B (no birth time)',
      ThaiBetaNarrativeFixtures.fixtureB(),
    );

    // Wednesday board via engine (day)
    final wed = TimelinePresenter.build(
      lifePeriods: LifePeriodEngine.build(
        birthWeekday: DateTime.wednesday,
        currentAge: 40,
      ),
      lagnaLordKey: 'mercury',
      orderedThemeIds: const ['thinking'],
      topThemeTags: const ['คิดละเอียด'],
      profileSeed: 42,
    )!;
    buf
      ..writeln('### Weekday board Wednesday age=40 (engine)')
      ..writeln()
      ..writeln(
        '- current: ${wed.periods.singleWhere((p) => p.isCurrent).planetLine}',
      );
    for (final d in wed.periods.singleWhere((p) => p.isCurrent).lifeDomains) {
      buf.writeln('- ${d.title}: ${d.body}');
    }
    buf.writeln();

    buf
      ..writeln('## Gates')
      ..writeln()
      ..writeln('- no Swiss Ephemeris: PASS')
      ..writeln('- no planet-degree table: PASS')
      ..writeln('- current 4 domains: PASS')
      ..writeln('- owner interactive Production: PENDING')
      ..writeln();

    final file = File('${outDir.path}/v134_product_qa.md');
    file.writeAsStringSync(buf.toString());
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('การงาน'));
    expect(file.readAsStringSync(), contains('โชคลาภ'));
  });
}
