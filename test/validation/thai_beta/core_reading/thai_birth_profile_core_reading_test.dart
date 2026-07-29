import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
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
      expect(text, isNot(contains('อย่าใช้ข้อความนี้แทน')));
      expect(text, isNot(contains('แทนการสังเกตพฤติกรรมจริง')));
    },
  );

  test('summary and closing meet product acceptance density', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final summary = reading.sections.singleWhere(
      (section) =>
          section.title == ThaiBirthProfileCoreReadingCopy.summaryTitle,
    );
    final closing = reading.sections.singleWhere(
      (section) =>
          section.title == ThaiBirthProfileCoreReadingCopy.closingTitle,
    );

    expect(summary.paragraphs.length, inInclusiveRange(3, 4));
    expect(closing.paragraphs, isNotEmpty);
    expect(closing.paragraphs.length, lessThanOrEqualTo(3));
    expect(summary.paragraphs.join('\n'), contains('แกนสำคัญของพื้นดวงนี้'));
  });

  test('each life domain keeps its own traceable evidence owner', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final expectedEvidence = {
      ThaiBirthProfileCoreReadingCopy.workTitle: 'mirror:work_and_ambition',
      ThaiBirthProfileCoreReadingCopy.moneyTitle: 'mirror:money',
      ThaiBirthProfileCoreReadingCopy.relationshipsTitle:
          'mirror:relationships',
      ThaiBirthProfileCoreReadingCopy.wellbeingTitle: 'mirror:wellbeing',
    };

    for (final entry in expectedEvidence.entries) {
      final section = reading.sections.singleWhere(
        (candidate) => candidate.title == entry.key,
      );
      expect(section.paragraphs, isNotEmpty, reason: entry.key);
      expect(section.domain, isNot(ThaiBirthProfileCoreDomain.summary));
      for (final claim in section.claims) {
        expect(claim.domain, section.domain, reason: entry.key);
        expect(claim.semanticKey, isNotEmpty, reason: entry.key);
        expect(claim.evidenceKeys, isNotEmpty, reason: entry.key);
        expect(
          claim.evidenceKeys.any((key) => key.startsWith(entry.value)),
          isTrue,
          reason: '${entry.key}: ${claim.text}',
        );
      }
    }
  });

  test(
    'known rewording of one semantic claim is rejected as near-duplicate',
    () {
      const first = ThaiBirthProfileCoreParagraph(
        text: 'คุณมักรับงานมากเกินไปเพราะคิดว่าต้องเป็นผู้นำเสมอ',
        domain: ThaiBirthProfileCoreDomain.work,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'mirror:work:risk:overcommit',
        evidenceKeys: ['mirror:work_and_ambition:risk'],
      );
      const reworded = ThaiBirthProfileCoreParagraph(
        text: 'คุณอาจรับงานมากเกิน เพราะรู้สึกว่าตัวเองต้องนำอยู่เสมอ',
        domain: ThaiBirthProfileCoreDomain.work,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'mirror:work:risk:overcommit',
        evidenceKeys: ['mirror:work_and_ambition:risk'],
      );

      expect(
        ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(reworded, first),
        isTrue,
      );
    },
  );

  test(
    'exact duplicate text is rejected even with a different semantic key',
    () {
      const first = ThaiBirthProfileCoreParagraph(
        text: 'คุณมักวางแผนงานก่อนลงมือ',
        domain: ThaiBirthProfileCoreDomain.work,
        role: ThaiBirthProfileCoreClaimRole.interpretation,
        semanticKey: 'mirror:work:planning',
        evidenceKeys: ['mirror:work_and_ambition:overview'],
      );
      const duplicate = ThaiBirthProfileCoreParagraph(
        text: 'คุณมักวางแผนงานก่อนลงมือ',
        domain: ThaiBirthProfileCoreDomain.work,
        role: ThaiBirthProfileCoreClaimRole.interpretation,
        semanticKey: 'mirror:work:second-key',
        evidenceKeys: ['mirror:work_and_ambition:overview'],
      );

      expect(
        ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(duplicate, first),
        isTrue,
      );
    },
  );

  test(
    'semantic domain policy rejects evidence from the wrong life domain',
    () {
      expect(
        ThaiBirthProfileCoreDomainPolicy.accepts(
          ThaiBirthProfileCoreDomain.money,
          const ['mirror:relationships:overview'],
        ),
        isFalse,
      );
      expect(
        ThaiBirthProfileCoreDomainPolicy.accepts(
          ThaiBirthProfileCoreDomain.money,
          const ['mirror:money:overview', 'theme:builder'],
        ),
        isTrue,
      );
    },
  );

  test(
    'each product domain contains supported synthesis, not mixed ownership',
    () {
      final reading = ThaiBirthProfileCoreReading.fromAnalysis(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final productDomains = reading.sections.where(
        (section) => {
          ThaiBirthProfileCoreDomain.work,
          ThaiBirthProfileCoreDomain.money,
          ThaiBirthProfileCoreDomain.relationships,
          ThaiBirthProfileCoreDomain.wellbeing,
        }.contains(section.domain),
      );

      for (final section in productDomains) {
        expect(
          section.claims.any(
            (claim) => claim.role == ThaiBirthProfileCoreClaimRole.synthesis,
          ),
          isTrue,
          reason: section.title,
        );
        final synthesis = section.claims.firstWhere(
          (claim) => claim.role == ThaiBirthProfileCoreClaimRole.synthesis,
        );
        expect(synthesis.text, contains('พลังที่ควรนำมาเป็นฐาน'));
        expect(synthesis.text, contains('แล้วเปลี่ยนพลังนั้นเป็นการลงมือ'));
        expect(
          section.claims.every((claim) => claim.domain == section.domain),
          isTrue,
          reason: section.title,
        );
      }
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

    final summary = reading.sections.singleWhere(
      (section) => section.domain == ThaiBirthProfileCoreDomain.summary,
    );
    final fullSynthesis = summary.claims.firstWhere(
      (claim) => claim.role == ThaiBirthProfileCoreClaimRole.synthesis,
    );
    expect(fullSynthesis.text, contains('พลังที่ควรนำมาเป็นฐาน'));
    expect(fullSynthesis.text, contains('โดยเฝ้าดูไม่ให้'));
    expect(fullSynthesis.text, contains('แล้วเปลี่ยนพลังนั้นเป็นการลงมือ'));
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
    expect(find.byKey(const Key('thai_consumer_hero')), findsNothing);
    expect(
      find.byKey(const Key('thai_consumer_signature_insight')),
      findsNothing,
    );
    expect(find.byKey(const Key('thai_consumer_life_dashboard')), findsNothing);
    expect(find.byKey(const Key('thai_consumer_strengths')), findsNothing);
    expect(find.byKey(const Key('thai_consumer_cautions')), findsNothing);
    expect(find.byKey(const Key('thai_consumer_advice')), findsNothing);
    expect(find.byKey(const Key('thai_consumer_narrative')), findsNothing);
    expect(
      find.byKey(const Key('thai_consumer_reflection_summary')),
      findsNothing,
    );
    expect(find.byKey(const Key('thai_consumer_closing')), findsNothing);
    expect(find.byKey(const Key('thai_consumer_source')), findsOneWidget);
    final mirror = tester.widget<ThaiMirrorResultPage>(
      find.byType(ThaiMirrorResultPage),
    );
    expect(mirror.timelineAndTransparencyOnly, isTrue);
    expect(
      tester.getTopLeft(core).dy,
      lessThan(tester.getTopLeft(timeline).dy),
    );
    expect(
      tester.getTopLeft(divider).dy,
      lessThan(tester.getTopLeft(timeline).dy),
    );
  });

  testWidgets('Thai Mirror default still renders the lifelong report', (
    tester,
  ) async {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiMirrorResultPage(
          disableAnimations: true,
          consumerState: analysis.consumerViewState!,
        ),
      ),
    );
    await tester.pump();

    final mirror = tester.widget<ThaiMirrorResultPage>(
      find.byType(ThaiMirrorResultPage),
    );
    expect(mirror.timelineAndTransparencyOnly, isFalse);
    expect(find.byKey(const Key('thai_consumer_hero')), findsOneWidget);
    expect(
      find.byKey(const Key('thai_consumer_life_dashboard')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thai_consumer_strengths')), findsOneWidget);
    expect(find.byKey(const Key('thai_consumer_cautions')), findsOneWidget);
    expect(find.byKey(const Key('thai_consumer_advice')), findsOneWidget);
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

  test('PDF contains Core once and omits legacy lifelong semantics', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final view = analysis.consumerViewState!;
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
    final titles = export.sections.map((section) => section.title).toList();
    final text = export.fullPlainText;

    expect(
      titles.where((title) => title == ThaiBirthProfileCoreReading.reportTitle),
      hasLength(1),
    );
    expect(text, isNot(contains(view.hero.headline)));
    expect(text, isNot(contains(view.signatureInsight.signature)));
    expect(titles, isNot(contains(view.strengths.title)));
    expect(titles, isNot(contains(view.cautions.title)));
    expect(titles, isNot(contains(view.advice.title)));
    expect(titles, isNot(contains(view.reflectionSummary.title)));
    for (final narrative in view.narrativeSections) {
      expect(titles, isNot(contains(narrative.label)));
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
    expect(text, isNot(contains('สรุปดวงสำคัญ')));
    expect(text, isNot(contains('โครงสร้างดวงหลัก')));
    expect(text, isNot(contains('ภาพรวมชีวิต')));
    expect(text, isNot(contains('ตัวตนและนิสัยลึก ๆ')));
    expect(text, isNot(contains('อย่าใช้ข้อความนี้แทน')));
  });
}
