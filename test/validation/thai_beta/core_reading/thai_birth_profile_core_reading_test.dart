import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_theme_ref.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_birth_profile_core_reading_section.dart';

import '../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  const titles = [
    'สรุปตรง ๆ',
    'หลักการนับวันทางโหราศาสตร์ไทย',
    'โครงสร้างดวงหลัก',
    'การงาน',
    'การเงิน',
    'ความรักและความสัมพันธ์',
    'สุขภาพและพลังชีวิตตามตำรา',
    'คำชี้หลักจากพื้นดวง',
    'ดวงนี้วิเคราะห์จากอะไร',
  ];

  test('full birth data builds all evidence-backed core sections', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );

    expect(reading.title, ThaiBirthProfileCoreReading.reportTitle);
    expect(reading.sections.map((s) => s.title), orderedEquals(titles));
    expect(reading.sections.every((s) => s.evidenceKeys.isNotEmpty), isTrue);
    expect(reading.omissions, isEmpty);
    final structure = reading.sections.singleWhere(
      (section) =>
          section.title == ThaiBirthProfileCoreReadingCopy.chartStructureTitle,
    );
    expect(structure.factRows.length, greaterThanOrEqualTo(3));
    expect(structure.factRows.first.label, 'วันทางโหราศาสตร์');
    expect(
      structure.factRows.any(
        (row) => row.label == 'ลัคนา' && RegExp(r'\d+°\d{2}′').hasMatch(row.value),
      ),
      isTrue,
    );
    final lagnaRow = structure.factRows.singleWhere(
      (row) => row.label == 'ลัคนา',
    );
    expect(
      lagnaRow.evidenceKeys,
      contains('ThaiAstrologyProfile.siderealAscendantDeg'),
    );
    expect(
      structure.factRows.every(
        (row) =>
            row.evidenceKeys.isNotEmpty &&
            row.sourceAtoms.every(
              (atom) => atom.sourceRef.isNotEmpty && atom.rawValue.isNotEmpty,
            ),
      ),
      isTrue,
    );
    expect(
      reading.sections.last.publicParagraphs.join('\n'),
      contains('ลัคนา (ภาพบุคลิกตั้งต้นที่คำนวณจากเวลาและสถานที่เกิด)'),
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
    final domains = reading.sections.map((section) => section.domain);
    expect(domains, isNot(contains(ThaiBirthProfileCoreDomain.work)));
    expect(domains, isNot(contains(ThaiBirthProfileCoreDomain.money)));
    expect(domains, isNot(contains(ThaiBirthProfileCoreDomain.relationships)));
    expect(domains, isNot(contains(ThaiBirthProfileCoreDomain.wellbeing)));
    expect(
      reading.omissions.map((omission) => omission.topic),
      containsAll({
        ThaiBirthProfileCoreReadingCopy.summaryTitle,
        ThaiBirthProfileCoreReadingCopy.workTitle,
        ThaiBirthProfileCoreReadingCopy.moneyTitle,
        ThaiBirthProfileCoreReadingCopy.relationshipsTitle,
        ThaiBirthProfileCoreReadingCopy.wellbeingTitle,
      }),
    );
    expect(
      reading.omissions.every((omission) => omission.reason.isNotEmpty),
      isTrue,
    );
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
      final beforeStructure = before.sections
          .singleWhere(
            (section) =>
                section.title ==
                ThaiBirthProfileCoreReadingCopy.dayCountingTitle,
          )
          .publicParagraphs
          .join('\n');
      final afterStructure = after.sections
          .singleWhere(
            (section) =>
                section.title ==
                ThaiBirthProfileCoreReadingCopy.dayCountingTitle,
          )
          .publicParagraphs
          .join('\n');

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

  test('summary uses specific computed facts before generic theme labels', () {
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

    expect(summary.paragraphs, isNotEmpty);
    expect(closing.paragraphs, isNotEmpty);
    expect(closing.paragraphs.length, lessThanOrEqualTo(3));
    expect(
      summary.paragraphs.join('\n'),
      isNot(contains('แนวโน้มเด่นที่ระบบคำนวณได้คือ')),
    );
    expect(summary.paragraphs.join('\n'), isNot(contains('วันทางโหราศาสตร์')));
    expect(
      summary.paragraphs.join('\n'),
      isNot(contains('จุดตั้งต้นของการอ่าน')),
    );
    expect(summary.paragraphs.join('\n'), isNot(contains('กรอบหลักในการอ่าน')));
  });

  test('each paragraph owns exact typed source facts for its domain', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final expectedHouses = {
      ThaiBirthProfileCoreReadingCopy.workTitle: 10,
      ThaiBirthProfileCoreReadingCopy.moneyTitle: 2,
      ThaiBirthProfileCoreReadingCopy.relationshipsTitle: 7,
      ThaiBirthProfileCoreReadingCopy.wellbeingTitle: 6,
    };

    for (final entry in expectedHouses.entries) {
      final section = reading.sections.singleWhere(
        (candidate) => candidate.title == entry.key,
      );
      expect(section.paragraphs, isNotEmpty, reason: entry.key);
      expect(section.domain, isNot(ThaiBirthProfileCoreDomain.summary));
      for (final claim in section.claims) {
        expect(claim.domain, section.domain, reason: entry.key);
        expect(claim.semanticKey, isNotEmpty, reason: entry.key);
        expect(claim.evidenceKeys, isNotEmpty, reason: entry.key);
        expect(claim.sourceAtoms, isNotEmpty, reason: entry.key);
        expect(
          claim.evidenceKeys.toSet(),
          claim.sourceAtoms
              .expand((atom) => atom.evidenceRefs)
              .map((evidence) => evidence.sourceRef)
              .toSet(),
          reason: '${entry.key}: exact provenance',
        );
        expect(
          claim.sourceAtoms.every(
            (atom) =>
                atom.houseNumber == entry.value &&
                ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
                  section.domain,
                  atom,
                ),
          ),
          isTrue,
          reason: '${entry.key}: ${claim.text}',
        );
      }
    }
  });

  test('all public claims preserve exact atom provenance', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );

    for (final section in reading.sections.where(
      (section) => !section.isMethodology,
    )) {
      for (final claim in section.claims) {
        expect(claim.sourceAtoms, isNotEmpty, reason: claim.semanticKey);
        expect(
          claim.evidenceKeys.toSet(),
          claim.sourceAtoms
              .expand((atom) => atom.evidenceRefs)
              .map((evidence) => evidence.sourceRef)
              .toSet(),
          reason: claim.semanticKey,
        );
        expect(
          claim.sourceAtoms.every(
            (atom) => ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
              claim.domain,
              atom,
            ),
          ),
          isTrue,
          reason: claim.semanticKey,
        );
      }
    }
  });

  test('section and top-theme atoms preserve exact field/value provenance', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
    final summaryTheme = reading.sections
        .singleWhere(
          (section) => section.domain == ThaiBirthProfileCoreDomain.summary,
        )
        .claims
        .expand((claim) => claim.sourceAtoms)
        .firstWhere(
          (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.identityTheme,
        );
    final topThemeAtoms = reading.sections
        .singleWhere((section) => section.isMethodology)
        .claims
        .singleWhere((claim) => claim.semanticKey == 'methodology:top-themes')
        .sourceAtoms;

    expect(
      summaryTheme.sourceRef,
      startsWith('ThaiMirrorResult.sections[core_self].supportingThemes['),
    );
    expect(summaryTheme.sourceRef, endsWith('.themeId'));
    expect(summaryTheme.rawValue, summaryTheme.themeId);
    expect(
      summaryTheme.evidenceRefs
          .singleWhere((evidence) => evidence.sourceRef.endsWith('.score'))
          .rawValue,
      '${summaryTheme.score}',
    );

    expect(topThemeAtoms, isNotEmpty);
    for (final atom in topThemeAtoms) {
      expect(atom.sourceRef, startsWith('ThaiMirrorResult.topThemes['));
      expect(atom.sourceRef, endsWith('.themeId'));
      expect(atom.rawValue, atom.themeId);
      expect(
        atom.evidenceRefs
            .singleWhere((evidence) => evidence.sourceRef.endsWith('.score'))
            .rawValue,
        '${atom.score}',
      );
      expect(
        atom.evidenceRefs.any(
          (evidence) =>
              evidence.sourceRef.endsWith('.score') &&
              evidence.rawValue == atom.themeId,
        ),
        isFalse,
      );
    }
  });

  test('methodology owns every field named by each explanation', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final disclosureClaims = reading.sections
        .where(
          (section) => section.domain == ThaiBirthProfileCoreDomain.methodology,
        )
        .expand((section) => section.claims)
        .toList(growable: false);
    Set<String> refs(String key) => disclosureClaims
        .singleWhere((claim) => claim.semanticKey == key)
        .evidenceKeys
        .toSet();

    expect(
      refs('methodology:astrological-date'),
      containsAll({
        'ThaiMirrorPipelineResult.birthData.thaiWeekdayNumber',
        'ThaiBetaAnalysis.normalizedSnapshot.thaiAstrologicalDate',
      }),
    );
    expect(
      refs('methodology:sunrise-boundary'),
      containsAll({
        'ThaiBetaAnalysis.normalizedSnapshot.birthTime',
        'ThaiBetaAnalysis.normalizedSnapshot.sunrise',
        'ThaiBetaAnalysis.normalizedSnapshot.usedPreviousDay',
        'ThaiBetaAnalysis.normalizedSnapshot.rawBirthDate',
      }),
    );
    expect(
      refs('methodology:lagna-inputs'),
      containsAll({
        'ThaiAstrologyProfile.lagnaKey',
        'ThaiBetaAnalysis.normalizedSnapshot.birthTime',
        'ThaiBetaAnalysis.normalizedSnapshot.latitude',
        'ThaiBetaAnalysis.normalizedSnapshot.longitude',
        'ThaiBetaAnalysis.normalizedSnapshot.timeZoneId',
      }),
    );
    for (final claim in disclosureClaims) {
      for (final atom in claim.sourceAtoms) {
        expect(
          atom.evidenceRefs.any((evidence) => evidence.rawValue == claim.text),
          isFalse,
          reason: claim.semanticKey,
        );
      }
    }
  });

  test('core paragraphs are not reused consumer-facing narrative fields', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
    final generated = reading.sections
        .where((section) => !section.isMethodology)
        .expand((section) => section.publicParagraphs)
        .toSet();
    final view = analysis.consumerViewState!;
    final legacy = <String>{
      view.hero.headline,
      view.signatureInsight.signature,
      for (final section in view.narrativeSections) ...[
        section.overview,
        section.pullQuote,
        section.tension,
        section.advice,
      ],
    }.where((text) => text.trim().isNotEmpty);

    expect(generated.intersection(legacy.toSet()), isEmpty);
  });

  test(
    'known rewording of one semantic claim is rejected as near-duplicate',
    () {
      const first = ThaiBirthProfileCoreParagraph(
        text: 'คุณมักรับงานมากเกินไปเพราะคิดว่าต้องเป็นผู้นำเสมอ',
        domain: ThaiBirthProfileCoreDomain.work,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'different-key-for-the-paraphrase',
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

  test('domain policy checks the source fact, not a plausible-looking key', () {
    const fakeMoneyAtom = ThaiBirthProfileCoreClaimAtom(
      kind: ThaiBirthProfileCoreAtomKind.identityTheme,
      domain: ThaiBirthProfileCoreDomain.money,
      sourceRef: 'mirror:money:investment_personality',
      rawValue: 'บุคลิกที่ชอบคิดเรื่องการลงทุน',
    );
    const validMoneyAtom = ThaiBirthProfileCoreClaimAtom(
      kind: ThaiBirthProfileCoreAtomKind.houseSign,
      domain: ThaiBirthProfileCoreDomain.money,
      sourceRef: 'HouseEngine.calculate.house[2].signKey',
      rawValue: 'taurus',
      houseNumber: 2,
    );
    const unsupportedWellbeingAtom = ThaiBirthProfileCoreClaimAtom(
      kind: ThaiBirthProfileCoreAtomKind.identityTheme,
      domain: ThaiBirthProfileCoreDomain.wellbeing,
      sourceRef: 'HouseEngine.calculate.house[6].routine',
      rawValue: 'คิดเป็นระบบและชอบกิจวัตรเดิม',
      houseNumber: 6,
    );

    expect(
      ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
        ThaiBirthProfileCoreDomain.money,
        fakeMoneyAtom,
      ),
      isFalse,
    );
    expect(
      ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
        ThaiBirthProfileCoreDomain.money,
        validMoneyAtom,
      ),
      isTrue,
    );
    expect(
      ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
        ThaiBirthProfileCoreDomain.wellbeing,
        unsupportedWellbeingAtom,
      ),
      isFalse,
    );
  });

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
        expect(synthesis.sourceAtoms, hasLength(2));
        expect(
          synthesis.sourceAtoms.every(
            (atom) => ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
              section.domain,
              atom,
            ),
          ),
          isTrue,
        );
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
  });

  test('strength and risk selection is deterministic and score-based', () {
    const themes = [
      ThaiMirrorThemeRef(
        themeId: 'risk_overcontrol',
        themeName: 'risk',
        score: 71,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
      ThaiMirrorThemeRef(
        themeId: 'risk_overthinking',
        themeName: 'risk',
        score: 88,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
      ThaiMirrorThemeRef(
        themeId: 'risk_overcommitment',
        themeName: 'risk',
        score: 88,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
    ];

    final selected = ThaiBirthProfileCoreReading.selectHighestPriorityTheme(
      themes.reversed,
      supportedThemeIds: const {
        'risk_overcontrol',
        'risk_overthinking',
        'risk_overcommitment',
      },
    );

    expect(selected?.themeId, 'risk_overcommitment');
  });

  test('closing uses one scored thematic context for strength risk action', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final closing = reading.sections.singleWhere(
      (section) => section.domain == ThaiBirthProfileCoreDomain.closing,
    );
    final atoms = closing.claims
        .expand((claim) => claim.sourceAtoms)
        .toList(growable: false);

    expect(closing.claims, hasLength(1));
    expect(
      closing.claims.single.text,
      contains('คำชี้หลักของพื้นดวงนี้คือให้ใช้'),
    );
    expect(
      closing.claims.single.text,
      contains('เมื่อใช้จุดแข็งนี้มากเกินไปอาจกลายเป็น'),
    );
    expect(
      closing.claims.single.text,
      contains('ทางที่เหมาะกว่าคือ'),
    );
    expect(atoms.map((atom) => atom.kind).toSet(), {
      ThaiBirthProfileCoreAtomKind.strengthTheme,
      ThaiBirthProfileCoreAtomKind.riskTheme,
      ThaiBirthProfileCoreAtomKind.actionTheme,
    });
    expect(atoms.map((atom) => atom.themeId).toSet(), hasLength(1));
    expect(atoms.map((atom) => atom.score).toSet(), hasLength(1));
    expect(atoms.map((atom) => atom.sourceRef).toSet(), hasLength(1));
  });

  test('closing context selection is deterministic and fails closed', () {
    const supported = [
      ThaiMirrorThemeRef(
        themeId: 'curious',
        themeName: 'curious',
        score: 90,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
      ThaiMirrorThemeRef(
        themeId: 'disciplined',
        themeName: 'disciplined',
        score: 90,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
    ];
    const unsupported = [
      ThaiMirrorThemeRef(
        themeId: 'unsupported_theme',
        themeName: 'unsupported',
        score: 100,
        confidence: ThaiThemeConfidenceLevel.high,
      ),
    ];

    expect(
      ThaiBirthProfileCoreReading.selectClosingContextTheme(
        supported.reversed,
      )?.themeId,
      'curious',
    );
    expect(
      ThaiBirthProfileCoreReading.selectClosingContextTheme(unsupported),
      isNull,
    );
  });

  test('full reading has no semantic duplicate paragraphs', () {
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      ThaiBetaNarrativeFixtures.fixtureA(),
    );
    final claims = reading.sections
        .expand((section) => section.claims)
        .toList(growable: false);

    for (var left = 0; left < claims.length; left++) {
      for (var right = left + 1; right < claims.length; right++) {
        expect(
          ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(
            claims[left],
            claims[right],
          ),
          isFalse,
          reason:
              '${claims[left].semanticKey} duplicates '
              '${claims[right].semanticKey}',
        );
      }
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

  testWidgets('unsupported no-time topics are disclosed after Timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: ThaiBetaNarrativeFixtures.fixtureB(),
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          screenshotModeOverride: true,
        ),
      ),
    );
    await tester.pump();

    final timeline = find.byKey(const Key('thai_consumer_life_timeline'));
    final omissions = find.byKey(const Key('thai_birth_profile_omissions'));
    expect(timeline, findsOneWidget);
    expect(omissions, findsOneWidget);
    expect(
      tester.getTopLeft(timeline).dy,
      lessThan(tester.getTopLeft(omissions).dy),
    );
    expect(
      find.text(ThaiBirthProfileCoreReadingCopy.omissionsTitle),
      findsOneWidget,
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

  test('PDF appends the same omissions as the final report section', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureB();
    final core = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);

    expect(core.omissions, isNotEmpty);
    expect(
      export.sections.last.title,
      ThaiBirthProfileCoreReadingCopy.omissionsTitle,
    );
    for (final omission in core.omissions) {
      expect(export.sections.last.paragraphs, contains(omission.publicText));
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
    expect(text, contains('โครงสร้างดวงหลัก'));
    expect(text, isNot(contains('ภาพรวมชีวิต')));
    expect(text, isNot(contains('ตัวตนและนิสัยลึก ๆ')));
    expect(text, isNot(contains('อย่าใช้ข้อความนี้แทน')));
  });
}
