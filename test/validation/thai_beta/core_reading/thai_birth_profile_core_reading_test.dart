import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_birth_profile_core_reading_section.dart';

import '../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  const titles = [
    'สรุปตัวคุณจากพื้นดวง',
    'การงาน',
    'การเงิน',
    'ความรักและความสัมพันธ์',
    'สุขภาพและพลังชีวิตตามตำรา',
    'สิ่งที่ดวงนี้อยากบอกคุณ',
    'ดวงนี้วิเคราะห์จากอะไร',
  ];

  test('full birth data builds all evidence-backed core sections', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );

    expect(reading.title, ThaiBirthProfileCoreReading.reportTitle);
    expect(reading.sections.map((s) => s.title), orderedEquals(titles));
    expect(reading.sections.every((s) => s.evidenceKeys.isNotEmpty), isTrue);
    expect(
      reading.sections.last.publicParagraphs.join('\n'),
      contains('ลัคนาอยู่ที่ราศี'),
    );
  });

  test('no-time reading never claims lagna or houses', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureB(),
    );
    final publicText = reading.sections
        .expand((section) => section.publicParagraphs)
        .join('\n');

    expect(reading.hasBirthTime, isFalse);
    expect(publicText, contains('ไม่มีเวลาเกิด'));
    expect(publicText, isNot(contains('ลัคนาอยู่ที่')));
    expect(publicText, isNot(contains('ภพที่')));
  });

  test(
    'before sunrise and after sunrise use different astrological day facts',
    () {
      final before = ThaiBirthProfileCoreReading.fromAnalysis(
        ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise(),
      );
      final after = ThaiBirthProfileCoreReading.fromAnalysis(
        ThaiBetaNarrativeFixtures.wednesdayDaytime(),
      );
      final beforeStructure = before.sections.last.publicParagraphs.join('\n');
      final afterStructure = after.sections.last.publicParagraphs.join('\n');

      expect(beforeStructure, contains('ก่อนพระอาทิตย์ขึ้น'));
      expect(beforeStructure, contains('ใช้วันก่อนหน้า'));
      expect(afterStructure, contains('หลังพระอาทิตย์ขึ้น'));
      expect(beforeStructure, isNot(equals(afterStructure)));
    },
  );

  test('different date and place produce meaningfully different readings', () {
    final a = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final c = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureC(),
    );

    expect(
      a.sections.expand((s) => s.publicParagraphs).join('\n'),
      isNot(equals(c.sections.expand((s) => s.publicParagraphs).join('\n'))),
    );
  });

  test('same input is deterministic', () {
    final first = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final second = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );

    expect(
      first.sections.expand((s) => s.publicParagraphs).join('\n'),
      equals(second.sections.expand((s) => s.publicParagraphs).join('\n')),
    );
  });

  test(
    'public narrative has no repeated system labels or duplicate claims',
    () {
      final reading = ThaiBirthProfileCoreReading.fromAnalysis(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final paragraphs = reading.sections
          .expand((section) => section.publicParagraphs)
          .toList();
      final normalized = paragraphs
          .map(
            (paragraph) => paragraph
                .replaceAll(RegExp(r'[\s·•:;,.!?()\-–—]+'), '')
                .toLowerCase(),
          )
          .toList();
      final text = paragraphs.join('\n');

      expect(normalized.toSet(), hasLength(normalized.length));
      expect(text, isNot(contains('หลักจากพื้นดวง')));
      expect(text, isNot(contains('คำอ่านพื้นดวง')));
      expect(text, isNot(contains('แนวทางใช้ประโยชน์')));
    },
  );

  test('lifelong core reading excludes age and current-period predictions', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final text = reading.sections
        .expand((section) => section.publicParagraphs)
        .join('\n');

    for (final forbidden in [
      'อายุ ',
      'ช่วงนี้',
      'ตอนนี้',
      'ช่วงปัจจุบัน',
      'ช่วงถัดไป',
      'อนาคต',
      'จังหวะปัจจุบัน',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
  });

  testWidgets('core reading appears before Timeline on the report page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: ThaiBetaNarrativeFixtures.fixtureA(),
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
      ),
    );
    await tester.pump();

    final core = find.byKey(const Key('thai_birth_profile_core_reading'));
    final timeline = find.byKey(const Key('thai_consumer_life_timeline'));
    final divider = find.byKey(
      const Key('thai_birth_profile_timeline_divider'),
    );
    expect(core, findsOneWidget);
    expect(timeline, findsOneWidget);
    expect(divider, findsOneWidget);
    expect(
      tester.getTopLeft(core).dy,
      lessThan(tester.getTopLeft(timeline).dy),
    );
    expect(
      tester.getTopLeft(divider).dy,
      lessThan(tester.getTopLeft(timeline).dy),
    );
  });

  testWidgets('methodology is collapsed by default and can be expanded', (
    tester,
  ) async {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ThaiBirthProfileCoreReadingSection(reading: reading),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final methodology = reading.sections.last;
    expect(find.text(methodology.title), findsOneWidget);
    expect(find.text(methodology.paragraphs.first), findsNothing);

    final expansion = find.byKey(const Key('thai_birth_profile_methodology'));
    await tester.ensureVisible(expansion);
    await tester.tap(expansion);
    await tester.pumpAndSettle();
    expect(find.text(methodology.paragraphs.first), findsOneWidget);
  });

  test('web and PDF use the same Core Reading instance content', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final core = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);

    expect(export.sections.first.title, core.title);
    for (final section in core.sections) {
      final exported = export.sections.singleWhere(
        (candidate) => candidate.title == section.title,
      );
      for (final paragraph in section.publicParagraphs) {
        expect(exported.paragraphs, contains(paragraph));
      }
    }
  });

  test('public/PDF text excludes internal evidence identifiers', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
    final text = export.fullPlainText;

    expect(text, isNot(contains('mirror:')));
    expect(text, isNot(contains('theme:')));
    expect(text, isNot(contains('Canon ID')));
    expect(text, isNot(contains('ontology')));
    expect(text, isNot(contains('debug')));
  });
}
