import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_detailed_report_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  test('writes V1.3.5 product QA artifact with full evidence text', () {
    final owner = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Owner',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthHour: 0,
        birthMinute: 35,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      ),
      startedAt: DateTime(2026, 7, 27),
      asOf: DateTime(2026, 7, 27),
    );
    final a = ThaiBetaNarrativeFixtures.fixtureA();
    final b = ThaiBetaNarrativeFixtures.fixtureB();

    String dump(ThaiBetaAnalysis analysis, String label) {
      final report = ThaiDetailedReportComposer.compose(
        birthData: analysis.pipelineResult!.birthData!,
        profile: analysis.profile!,
        timeline: analysis.pipelineResult!.lifePeriods!,
        asOfLocal: analysis.startedAt,
        profileSeed: 1,
      );
      final buf = StringBuffer()
        ..writeln('## $label')
        ..writeln()
        ..writeln('### พื้นดวงตลอดชีวิต');
      for (final t in report.lifetimeTopics) {
        buf
          ..writeln()
          ..writeln('#### ${t.title}')
          ..writeln()
          ..writeln('ข้อมูลดวงที่พบ')
          ..writeln(t.evidenceFound)
          ..writeln()
          ..writeln('คำทำนาย')
          ..writeln(t.prediction)
          ..writeln()
          ..writeln('evidenceIds: ${t.evidenceIds.join(', ')}');
      }
      buf
        ..writeln()
        ..writeln('### อดีต');
      for (final p in report.pastPeriods) {
        buf
          ..writeln()
          ..writeln('#### ${p.phaseName} (${p.ageLabel})')
          ..writeln(p.planetLine)
          ..writeln()
          ..writeln('ข้อมูลดวงที่พบ')
          ..writeln(p.evidenceFound)
          ..writeln()
          ..writeln('คำทำนาย')
          ..writeln(p.prediction);
        for (final e in p.events) {
          buf.writeln('- event: ${e.body}');
        }
      }
      buf
        ..writeln()
        ..writeln('### ปัจจุบัน')
        ..writeln()
        ..writeln('ข้อมูลดวงที่พบ')
        ..writeln(report.currentReading.evidenceFound)
        ..writeln()
        ..writeln('คำทำนาย')
        ..writeln(report.currentReading.prediction);
      if (report.currentReading.conflictNote.isNotEmpty) {
        buf
          ..writeln()
          ..writeln(report.currentReading.conflictNote);
      }
      buf
        ..writeln()
        ..writeln('### อนาคต');
      for (final p in report.futurePeriods) {
        buf
          ..writeln()
          ..writeln('#### ${p.phaseName} (${p.ageLabel})')
          ..writeln(p.evidenceFound)
          ..writeln(p.prediction);
      }
      buf
        ..writeln()
        ..writeln('### คำแนะนำท้ายรายงาน')
        ..writeln(report.closingAdvice.recommendations)
        ..writeln(report.closingAdvice.cautions)
        ..writeln(report.closingAdvice.healthDisclaimer)
        ..writeln()
        ..writeln(
          'evidence count=${report.allEvidence.length} '
          'events=${report.allEvents.length}',
        );
      return buf.toString();
    }

    final md = StringBuffer()
      ..writeln('# Thai Life Map V1.3.5 — Product QA Artifact')
      ..writeln()
      ..writeln('Synthetic fixtures only. No Swiss Ephemeris.')
      ..writeln()
      ..writeln(dump(owner, 'Owner-equivalent fixture'))
      ..writeln(dump(a, 'Fixture A (complete birth time)'))
      ..writeln(dump(b, 'Fixture B (no birth time)'));

    final outDir = Directory(
      'test/validation/thai_beta/life_map/v135/output',
    )..createSync(recursive: true);
    final file = File('${outDir.path}/v135_product_qa.md');
    file.writeAsStringSync(md.toString());
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('ข้อมูลดวงที่พบ'));
    expect(file.readAsStringSync(), contains('คำทำนาย'));
  });
}
