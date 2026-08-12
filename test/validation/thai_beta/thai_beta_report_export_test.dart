import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_current_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_polish.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_safety.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_export_print_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_qa_sample_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_report_export_button.dart';

ThaiBetaAnalysis _runAnalysis({
  required DateTime birthDate,
  String firstName = 'Export',
  String lastName = 'Test',
}) {
  return ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      birthHour: 10,
      birthMinute: 30,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
  );
}

ThaiMirrorLifeTimelineState _timeline(ThaiBetaAnalysis analysis) {
  return analysis.consumerViewState!.lifeTimeline!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;
  late ThaiBetaAnalysis qaSampleAnalysis;

  setUpAll(() {
    analysis = _runAnalysis(birthDate: DateTime(1972, 4, 4));
    qaSampleAnalysis = ThaiBetaQaSampleCapturePage.sampleAnalysis();
  });

  tearDown(() {
    ThaiBetaScreenshotMode.resetForTest();
    ThaiBetaCurrentAnalysis.resetForTest();
  });

  group('ThaiBetaReportExportSafety', () {
    test('detects forbidden tokens', () {
      expect(ThaiBetaReportExportSafety.containsForbidden('ดวงขึ้น'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('ดวงตก'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('Taksa'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('ทักษา'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('Khumsap'), isTrue);
      expect(
        ThaiBetaReportExportSafety.containsForbidden('คุ้มทรัพย์'),
        isTrue,
      );
      expect(ThaiBetaReportExportSafety.containsForbidden('remedy'), isTrue);
      expect(
        ThaiBetaReportExportSafety.containsForbidden('ontology:foo'),
        isTrue,
      );
      expect(
        ThaiBetaReportExportSafety.containsForbidden('unit.remedy.1'),
        isTrue,
      );
      expect(
        ThaiBetaReportExportSafety.containsForbidden('คุณมีบุคลิกที่น่าสนใจ'),
        isFalse,
      );
    });

    test('scrub removes forbidden fragments', () {
      final scrubbed = ThaiBetaReportExportSafety.scrub(
        'ข้อความปกติ. มีดวงขึ้นปน. อีกประโยค',
      );
      expect(scrubbed.contains('ดวงขึ้น'), isFalse);
      expect(scrubbed.contains('ข้อความปกติ'), isTrue);
    });
  });

  group('ThaiBetaReportExportDocument', () {
    test('builds from existing analysis view state', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(doc.sections, isNotEmpty);
      expect(doc.title, contains('KnowMe'));
      final text = doc.fullPlainText;
      expect(text, isNotEmpty);
      // Core Reading is the shared web/PDF presentation source.
      expect(text, contains(ThaiBirthProfileCoreReading.reportTitle));
      expect(text, contains(ThaiBirthProfileCoreReadingCopy.summaryTitle));
      expect(text, contains('วิธีนับวันทางโหราศาสตร์ไทย'));
      expect(
        text,
        contains(ThaiBirthProfileCoreReadingCopy.chartStructureTitle),
      );
    });

    test('deduplicates identical public evidence summaries', () {
      const badges = [
        ThaiPublicEvidenceBadgeBetaViewModel(
          sectionId: 'profile',
          badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
          cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
          sourceLevel:
              ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
          eligible: true,
        ),
        ThaiPublicEvidenceBadgeBetaViewModel(
          sectionId: 'timeline',
          badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
          cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
          sourceLevel:
              ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
          eligible: true,
        ),
      ];
      final doc = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
        badges: badges,
      );

      expect(
        'มีที่มาจากตำราอ้างอิง'.allMatches(doc.fullPlainText),
        hasLength(1),
      );
      expect(
        ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel.allMatches(
          doc.fullPlainText,
        ),
        isEmpty,
      );
      expect(
        ThaiPublicEvidenceBadgeCopy.cautionCopy.allMatches(doc.fullPlainText),
        hasLength(1),
      );
    });

    test('export text has no forbidden content', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      expect(ThaiBetaReportExportSafety.containsForbidden(text), isFalse);
      expect(text.contains('ดวงขึ้น'), isFalse);
      expect(text.contains('ดวงตก'), isFalse);
      expect(text.toLowerCase().contains('taksa'), isFalse);
      expect(text.toLowerCase().contains('khumsap'), isFalse);
      expect(text.toLowerCase().contains('remedy'), isFalse);
      expect(text.toLowerCase().contains('ontology'), isFalse);
      expect(RegExp(r'\bunit\.[a-zA-Z0-9_.-]+').hasMatch(text), isFalse);
    });

    test('does not invent new prediction copy beyond view state', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      // V1.3.2: birth confidence remains silent when complete. Core Reading
      // replaces the legacy hero as the PDF opening without inventing
      // prediction copy.
      expect(view.birthDataConfidence.isComplete, isTrue);
      expect(view.birthDataConfidence.title, isEmpty);
      expect(
        doc.fullPlainText,
        contains(ThaiBirthProfileCoreReading.reportTitle),
      );
      expect(doc.fullPlainText, contains('รายงานนี้ดูจากอะไร'));
      expect(doc.fullPlainText, isNot(contains('ข้อมูลวันเกิดครบถ้วน')));
    });

    test('unknown-time web and PDF omit assumed clock and sunrise claims', () {
      final unknown = ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Unknown',
          lastName: 'Time',
          birthDate: DateTime(1972, 4, 5),
          birthTimeUnknown: true,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: DateTime(2026, 7, 21),
      );
      final webText = ThaiBirthProfileCoreReading.fromAnalysis(
        unknown,
      ).sections.expand((section) => section.publicParagraphs).join('\n');
      final pdfText = ThaiBetaReportExportDocument.fromAnalysis(
        unknown,
      ).fullPlainText;
      final prediction = ThaiBetaNarrativeComposer.narrativeView(
        unknown,
      ).futurePrediction!;

      for (final text in [webText, pdfText]) {
        expect(text, isNot(contains('ก่อนพระอาทิตย์ขึ้น')));
        expect(text, isNot(contains('หลังพระอาทิตย์ขึ้น')));
        expect(text, isNot(contains('เวลาเกิดอยู่')));
        expect(text, isNot(contains('12:00')));
      }
      expect(unknown.input.toMap()['birthHour'], isNull);
      expect(unknown.input.toMap()['birthMinute'], isNull);
      for (final domain in prediction.windows.expand(
        (window) => window.domains,
      )) {
        expect(domain.uncertaintyDisclosure, contains('ไม่มีหลักฐานลัคนา'));
        expect(domain.preparationAction, isNot(contains('ไม่มีหลักฐานลัคนา')));
      }
      expect('ข้อจำกัดของคำอ่าน:'.allMatches(pdfText), hasLength(1));
    });

    test('Thai Beta omits repeated past and future domain claims', () {
      final source = analysis.consumerViewState!.lifeTimeline!;
      final curated = ThaiBetaNarrativeComposer.narrativeView(
        analysis,
      ).lifeTimeline!;
      final sourceCount = source.periods
          .where((period) => !period.isCurrent)
          .expand((period) => period.lifeDomains)
          .length;
      final curatedEntries = <String>[];
      for (final period in curated.periods.where(
        (period) => !period.isCurrent,
      )) {
        final bucket = period.isPast ? 'past' : 'future';
        for (final domain in period.lifeDomains) {
          final body = domain.body
              .replaceAll('ใน${period.phaseName}', 'ในช่วงชีวิตนี้')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
              .toLowerCase();
          curatedEntries.add('$bucket|${domain.title}|$body');
        }
      }

      expect(curatedEntries.toSet(), hasLength(curatedEntries.length));
      expect(curatedEntries.length, lessThan(sourceCount));
      expect(
        curated.periods
            .where((period) {
              final start = int.parse(period.ageLabel.split('–').first);
              return !period.isCurrent && start < 69;
            })
            .every((period) => period.lifeDomains.length <= 4),
        isTrue,
      );
      expect(
        curated.periods
            .where((period) {
              final start = int.parse(period.ageLabel.split('–').first);
              return start >= 69;
            })
            .every((period) => period.lifeDomains.isEmpty),
        isTrue,
      );
      expect(
        curated.periods
            .where((period) => !period.isCurrent)
            .expand((period) => period.lifeDomains)
            .where(
              (domain) => domain.evidenceKeys.contains(
                'ThaiMirrorLifePeriodState.whatChanges',
              ),
            ),
        isEmpty,
      );
      expect(
        curated.periods.singleWhere((period) => period.isCurrent).lifeDomains,
        orderedEquals(
          source.periods.singleWhere((period) => period.isCurrent).lifeDomains,
        ),
      );

      final exportText = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
      ).fullPlainText;
      expect(exportText, isNot(contains('บริบทเฉพาะของช่วงนี้คือ')));
    });

    test('PDF polish removes duplicate neighbour prefixes and zero timing', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      expect(ThaiBetaReportExportPolish.findForbidden(text), isEmpty);
    });

    test('export prefers full insight bodies over UI ellipsis truncations', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      // No mid-card truncated ellipsis leftovers from UI maxChars cuts.
      expect(RegExp(r'[ก-๙A-Za-z]…').hasMatch(text), isFalse);
    });

    test(
      'exports concise past and distinct future prose from shared state',
      () {
        final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
        final text = doc.fullPlainText;
        final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
        final timeline = view.lifeTimeline!;
        final prediction = view.futurePrediction!;

        final past = timeline.periods.firstWhere((period) => period.isPast);
        expect(text, contains(past.summary));
        expect(text, isNot(contains(past.lifeDomains.first.body)));
        expect(text, contains(prediction.detailedSectionIntro));
        for (final domain
            in prediction.windows.skip(1).expand((window) => window.domains)) {
          expect(text, contains(domain.body));
          expect(text, isNot(contains('ภาพที่เห็น: ${domain.claim}')));
        }
      },
    );
  });

  group('Real PDF exporter path regression', () {
    test('disclaimer cards use full-width geometry and contain their body', () {
      const legacy = <String, Object>{
        'column': 'intrinsic',
        'width': 'content',
        'bodyInsideBorder': false,
      };
      final current =
          ThaiBetaReportPdfExporter.debugDisclaimerGeometryForTest();

      bool violates(Map<String, Object> geometry) =>
          geometry['column'] != 'flex' ||
          geometry['width'] != 'page' ||
          geometry['bodyInsideBorder'] != true;

      expect(violates(legacy), isTrue, reason: 'negative legacy fixture');
      expect(violates(current), isFalse);
      expect(current, {
        'column': 'flex',
        'width': 'page',
        'bodyInsideBorder': true,
      });
    });

    test('V1.3 Unknown omission failure stays atomic with visible orientation', () {
      const section = ThaiBetaReportExportSection(
        title: 'หัวข้อที่ไม่ได้แสดง',
        kind: ThaiBetaReportExportSectionKind.disclaimer,
        paragraphs: [
          'ระบบตัดหัวข้อต่อไปนี้ออกแทนการเติมคำทำนายที่ไม่มีข้อมูลรองรับ',
          'สรุปตัวคุณแบบตรง ๆ — ไม่มีเวลาเกิด จึงไม่ใช้ลัคนาสรุปบุคลิก',
          'การงานจากลัคนาและเรือนการงาน — ไม่มีเวลาเกิด จึงคำนวณไม่ได้',
          'การเงินจากลัคนาและเรือนการเงิน — ไม่มีเวลาเกิด จึงคำนวณไม่ได้',
          'ความรักและความสัมพันธ์จากลัคนาและเรือนคู่ครอง — ไม่มีเวลาเกิด จึงคำนวณไม่ได้',
          'สุขภาพและพลังชีวิตจากลัคนาและเรือนสุขภาพ — ไม่มีเวลาเกิด จึงคำนวณไม่ได้',
          'คำชี้หลักจากพื้นดวง — ไม่พบชุดจุดแข็ง ความเสี่ยง และแนวทางที่อ้างอิงได้ครบ',
        ],
      );
      final chunks = ThaiBetaReportPdfExporter.debugDisclaimerChunksForTest(
        section,
      );
      expect(chunks, hasLength(1));
      expect(chunks.single, hasLength(7));
      expect(chunks.single, contains(section.paragraphs.last));
    });

    test('Poppler raster keeps ink inside printable margins', () async {
      final renderer = _findPdftoppm();
      expect(
        renderer,
        isNotNull,
        reason: 'pdftoppm is required for the real-raster clipping gate',
      );
      final temp = Directory.systemTemp.createTempSync(
        'knowme-pdf-raster-regression-',
      );
      try {
        for (final fixture in <String, ThaiBetaAnalysis>{
          'known': analysis,
          'unknown': ThaiBetaAnalysisRunner.run(
            ThaiBetaInput(
              firstName: 'Raster',
              lastName: 'Unknown',
              birthDate: DateTime(1982, 6, 6),
              birthTimeUnknown: true,
              province: 'เชียงใหม่',
              provinceKey: 'chiang_mai',
            ),
          ),
        }.entries) {
          final document = ThaiBetaReportExportDocument.fromAnalysis(
            fixture.value,
          );
          final rendered = await ThaiBetaReportPdfExporter.build(document);
          final pdf = File('${temp.path}/${fixture.key}.pdf')
            ..writeAsBytesSync(rendered.bytes);
          final prefix = '${temp.path}/${fixture.key}';
          final result = await Process.run(renderer!, [
            '-r',
            '120',
            pdf.path,
            prefix,
          ]);
          expect(
            result.exitCode,
            0,
            reason: 'pdftoppm failed: ${result.stderr}',
          );
          final pages =
              temp
                  .listSync()
                  .whereType<File>()
                  .where(
                    (file) =>
                        file.uri.pathSegments.last.startsWith(
                          '${fixture.key}-',
                        ) &&
                        file.path.endsWith('.ppm'),
                  )
                  .toList()
                ..sort((a, b) => a.path.compareTo(b.path));
          expect(pages, isNotEmpty);
          expect(
            pages.length,
            lessThanOrEqualTo(fixture.key == 'known' ? 32 : 30),
            reason:
                '${fixture.key} PDF regressed to forced one-block-per-page '
                'pagination (${pages.length} pages)',
          );
          for (final page in pages) {
            expect(
              _hasInkInForbiddenMargin(page.readAsBytesSync()),
              isFalse,
              reason:
                  '${fixture.key}/${page.uri.pathSegments.last} '
                  'contains raster ink outside the printable margin',
            );
          }
        }
      } finally {
        temp.deleteSync(recursive: true);
      }
    });

    test(
      'pagination units keep period, domain, and first paragraph together',
      () {
        const section = ThaiBetaReportExportSection(
          title: 'ช่วงทดสอบ 1982-06-05',
          kind: ThaiBetaReportExportSectionKind.timeline,
          paragraphs: [
            'บริบทของช่วง',
            'การงาน',
            'แนวโน้มงานที่มีหลักฐานรองรับ',
            'การเงิน',
            'แนวโน้มเงินที่มีหลักฐานรองรับ',
            'ความรัก',
            'แนวโน้มความสัมพันธ์ที่มีหลักฐานรองรับ',
            'สุขภาพ',
            'แนวโน้มสุขภาวะที่มีหลักฐานรองรับ',
          ],
        );

        final units = ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
          section,
        );
        expect(units, hasLength(5));
        expect(units.first, contains('ช่วงทดสอบ 1982-06-05'));
        expect(units.first, contains('บริบทของช่วง'));
        expect(units.first, isNot(contains('การงาน')));
        expect(units[1], startsWith('การงาน\n'));
        expect(units[2], startsWith('การเงิน\n'));
        expect(units[3], startsWith('ความรัก\n'));
        expect(units[4], startsWith('สุขภาพ\n'));
        for (final unit in units) {
          expect(unit, isNot(matches(RegExp(r'1982-06-0\s*\n\s*5'))));
          expect(unit, isNot(contains('(ต่อ)')));
        }
      },
    );

    test(
      'V1.1 pages 6-8 regression: parent continuation is not emitted per domain',
      () {
        for (final title in const [
          'แนวโน้ม 12 เดือนข้างหน้า',
          'ช่วงชีวิตถัดไป',
        ]) {
          final section = ThaiBetaReportExportSection(
            title: title,
            paragraphs: const [
              'บทนำของช่วง',
              'การงาน',
              'เนื้อหางานที่จบเป็นหนึ่งความคิด',
              'การเงิน',
              'เนื้อหาเงินที่จบเป็นหนึ่งความคิด',
              'ความรัก',
              'เนื้อหาความสัมพันธ์ที่จบเป็นหนึ่งความคิด',
              'สุขภาพ',
              'เนื้อหาสุขภาพที่จบเป็นหนึ่งความคิด',
            ],
          );
          final units = ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
            section,
          );
          expect(units.where((unit) => unit.contains(title)), hasLength(1));
          expect(units.where((unit) => unit.contains('$title (ต่อ)')), isEmpty);
        }
      },
    );

    test('reading-basis continuation is explicit for both evidence modes', () {
      const known = ThaiBetaReportExportSection(
        title: 'รายงานนี้ดูจากอะไร',
        paragraphs: ['ก', 'ข', 'ค', 'ง', 'จ', 'ฉ'],
      );
      const unknown = ThaiBetaReportExportSection(
        title: 'รายงานนี้ดูจากอะไร',
        paragraphs: ['ก', 'ข', 'ไม่มีเวลาเกิด', 'ง'],
      );

      expect(
        ThaiBetaReportPdfExporter.debugReadingBasisContinuationForTest(known),
        (paragraphIndex: 5, heading: 'โครงสร้างดวงหลัก — ต่อ'),
      );
      expect(
        ThaiBetaReportPdfExporter.debugReadingBasisContinuationForTest(unknown),
        (paragraphIndex: 3, heading: 'รายงานนี้ดูจากอะไร — ต่อ'),
      );
    });

    test('ISO date tokens are detected generically for atomic layout', () {
      expect(
        ThaiBetaReportPdfExporter.debugIsoDateTokensForTest(
          'วันที่ 1982-06-05 และ 2001-12-31 ใช้เป็นฐาน',
        ),
        ['1982-06-05', '2001-12-31'],
      );
      expect(
        ThaiBetaReportPdfExporter.debugIsoDateTokensForTest('รุ่น 1982-06'),
        isEmpty,
      );
    });

    test('fortune owns a semantic block after health in every mode', () {
      const section = ThaiBetaReportExportSection(
        title: 'ช่วงทดสอบ',
        kind: ThaiBetaReportExportSectionKind.timeline,
        paragraphs: ['สุขภาพ', 'ข้อความสุขภาพ', 'โชคลาภ', 'ข้อความโชคลาภ'],
      );

      final units = ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
        section,
      );
      expect(units, hasLength(2));
      expect(units[0], contains('สุขภาพ\nข้อความสุขภาพ'));
      expect(units[0], isNot(contains('โชคลาภ')));
      expect(units[1], contains('โชคลาภ\nข้อความโชคลาภ'));
      expect(units[1], isNot(contains('สุขภาพ')));
    });

    test(
      'download-button path polishes polluted document before PDF text',
      () async {
        const polluted = ThaiBetaReportExportDocument(
          title: 'KnowMe — รายงานโหราไทย',
          subtitle: 'probe',
          filenameStem: 'knowme-thai-report',
          sections: [
            ThaiBetaReportExportSection(
              title: 'เส้นทางชีวิต',
              kind: ThaiBetaReportExportSectionKind.timeline,
              paragraphs: [
                'อิทธิพลดาวพฤหัสบดี • การเติบโต',
                'การเติบโต',
                'อิทธิพลดาวพุธ • การเรียนรู้',
                'การเรียนรู้',
                'อิทธิพลดาวเสาร์ • ความมั่นคง',
                'ความมั่นคง',
                'ช่วงก่อนหน้า: ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
                'ช่วงถัดไป: ช่วงถัดไป: ช่วงพลิกผัน (55–66)',
                'เหลืออีกประมาณ 0 ปีก่อนเปลี่ยนช่วง',
                'อีกประมาณ 0 เดือนจะเริ่มก้าวสู่จังหวะใหม่',
                'ดี(ผ่านรู้สึก…)',
                'ผ่านคิดละเอ…',
                'เนื้อหาที่ต้องเหลืออยู่',
              ],
            ),
          ],
        );

        // Same exporter entry used by ThaiBetaReportExportButton._exportPdf.
        final rendered = await ThaiBetaReportPdfExporter.build(polluted);
        expect(rendered.bytes, isNotEmpty);
        expect(rendered.plainText, contains('เนื้อหาที่ต้องเหลืออยู่'));
        expect(
          ThaiBetaReportExportPolish.findForbidden(rendered.plainText),
          isEmpty,
        );
        expect(rendered.plainText.contains('ผ่านรู้สึก…'), isFalse);
        expect(rendered.plainText.contains('ผ่านคิดละเอ…'), isFalse);
        expect(rendered.plainText.contains('ดี(ผ่าน'), isFalse);
        expect(rendered.plainText.contains('• การเติบโต\nการเติบโต'), isFalse);
        expect(
          rendered.plainText.contains('ช่วงก่อนหน้า: ช่วงก่อนหน้า'),
          isFalse,
        );
        expect(
          RegExp(r'(?<![0-9])0\s*ปี').hasMatch(rendered.plainText),
          isFalse,
        );
      },
    );

    test(
      'real analysis download path PDF text has no forbidden regressions',
      () async {
        final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
        final rendered = await ThaiBetaReportPdfExporter.build(document);
        expect(rendered.bytes.length, greaterThan(1000));
        expect(
          ThaiBetaReportExportPolish.findForbidden(rendered.plainText),
          isEmpty,
        );
        expect(
          ThaiBetaReportExportSafety.containsForbidden(rendered.plainText),
          isFalse,
        );
        for (final forbidden in [
          'หากความล้าสะสม ข้อความนี้ไม่ใช่คำวินิจฉัยทางการแพทย์เกิดซ้ำ',
          'เตรียมรับมือเรื่องความล้าสะสม ข้อความนี้ไม่ใช่คำวินิจฉัยทางการแพทย์',
          'กดดูรายละเอียด',
          'เนื้อหาจากรายงานที่มีอยู่แล้ว ไม่สร้างคำทำนายใหม่',
          'โดยไม่นำชื่อหมวดภายใน',
        ]) {
          expect(rendered.plainText, isNot(contains(forbidden)));
        }
      },
    );
  });

  group('Real user analysis wiring', () {
    late ThaiBetaAnalysis realUserAnalysis;

    setUpAll(() {
      realUserAnalysis = _runAnalysis(
        birthDate: DateTime(1982, 6, 15),
        firstName: 'Real',
        lastName: 'User',
      );
    });

    test('export uses current ThaiBetaAnalysis from session', () {
      ThaiBetaCurrentAnalysis.set(realUserAnalysis);
      expect(ThaiBetaCurrentAnalysis.current, same(realUserAnalysis));

      final doc = ThaiBetaReportExportDocument.fromAnalysis(
        ThaiBetaCurrentAnalysis.current!,
      );
      expect(
        doc.fullPlainText,
        contains(_timeline(realUserAnalysis).currentStage.planetLine),
      );
    });

    test('export never uses sampleQaBirthData birth year', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final text = doc.fullPlainText;
      final sampleAge = _timeline(qaSampleAnalysis).currentStage.currentAge;
      final realAge = _timeline(realUserAnalysis).currentStage.currentAge;

      expect(realAge, isNot(equals(sampleAge)));
      expect(
        text,
        anyOf(contains('อายุ $realAge'), contains('วัย $realAge ปี')),
      );
      expect(
        text,
        isNot(
          anyOf(contains('อายุ $sampleAge'), contains('วัย $sampleAge ปี')),
        ),
      );
    });

    test('PDF age matches report age', () async {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final rendered = await ThaiBetaReportPdfExporter.build(doc);
      final reportAge = _timeline(realUserAnalysis).currentStage.currentAge;

      expect(
        rendered.plainText,
        anyOf(contains('อายุ $reportAge'), contains('วัย $reportAge ปี')),
      );
    });

    test('PDF current period matches report', () async {
      final stage = _timeline(realUserAnalysis).currentStage;
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final rendered = await ThaiBetaReportPdfExporter.build(doc);

      expect(rendered.plainText, contains(stage.phaseName));
      expect(rendered.plainText, contains(stage.eyebrow));
    });

    test('PDF timeline matches report timeline sections', () async {
      final timeline = _timeline(realUserAnalysis);
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final rendered = await ThaiBetaReportPdfExporter.build(doc);

      expect(rendered.plainText, contains('แผนที่ชีวิต'));
      expect(rendered.plainText, contains(timeline.currentStage.planetLine));
      for (final period in timeline.periods.take(2)) {
        expect(rendered.plainText, contains(period.phaseName));
      }
    });

    test('real PDF has no Markdown markers', () async {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final rendered = await ThaiBetaReportPdfExporter.build(doc);
      expect(rendered.plainText.contains('**'), isFalse);
    });

    test('real PDF passes safety exclusions', () async {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(realUserAnalysis);
      final rendered = await ThaiBetaReportPdfExporter.build(doc);
      expect(
        ThaiBetaReportExportSafety.containsForbidden(rendered.plainText),
        isFalse,
      );
      expect(
        ThaiBetaReportExportPolish.findForbidden(rendered.plainText),
        isEmpty,
      );
    });
  });

  group('Capture route without analysis', () {
    testWidgets('never uses QA sample — shows empty state', (tester) async {
      ThaiBetaCurrentAnalysis.resetForTest();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: true,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const ThaiBetaCapturePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('thai_beta_capture_no_report')),
        findsOneWidget,
      );
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsOneWidget);
      expect(
        find.byKey(const Key('thai_beta_capture_back_to_create')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsNothing,
      );
      expect(find.text('Thai Beta Capture Mode Active'), findsNothing);

      final sampleAge = _timeline(qaSampleAnalysis).currentStage.currentAge;
      expect(find.textContaining('อายุ $sampleAge'), findsNothing);
    });

    testWidgets('uses stored current analysis for export', (tester) async {
      final userAnalysis = _runAnalysis(birthDate: DateTime(1982, 6, 15));
      ThaiBetaCurrentAnalysis.set(userAnalysis);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: true,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const ThaiBetaCapturePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
      expect(find.text('Thai Beta Capture Mode Active'), findsOneWidget);
      final userAge = _timeline(userAnalysis).currentStage.currentAge;
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              ((widget.data?.contains('อายุ $userAge') ?? false) ||
                  (widget.data?.contains('วัย $userAge ปี') ?? false)),
        ),
        findsWidgets,
      );
    });
  });

  group('Stale analysis export guard', () {
    ThaiBetaInput sampleInput({
      String firstName = 'Stale',
      String lastName = 'Guard',
      DateTime? birthDate,
    }) {
      return ThaiBetaInput(
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate ?? DateTime(1982, 6, 15),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      );
    }

    test('successful analysis can export', () {
      final success = _runAnalysis(birthDate: DateTime(1982, 6, 15));
      expect(success.isSuccess, isTrue);

      ThaiBetaCurrentAnalysis.clear();
      ThaiBetaCurrentAnalysis.set(success);

      expect(ThaiBetaCurrentAnalysis.current, same(success));
      final doc = ThaiBetaReportExportDocument.fromAnalysis(
        ThaiBetaCurrentAnalysis.current!,
      );
      expect(
        doc.fullPlainText,
        contains(_timeline(success).currentStage.planetLine),
      );
    });

    test('starting a new analysis clears previous export state', () {
      final previous = _runAnalysis(birthDate: DateTime(1982, 6, 15));
      ThaiBetaCurrentAnalysis.set(previous);
      expect(ThaiBetaCurrentAnalysis.current, isNotNull);

      // Mirrors ThaiBetaInputPage._submit: clear before running the new attempt.
      ThaiBetaCurrentAnalysis.clear();
      expect(ThaiBetaCurrentAnalysis.current, isNull);
    });

    test('failed latest analysis cannot export stale previous result', () {
      final previous = _runAnalysis(birthDate: DateTime(1982, 6, 15));
      ThaiBetaCurrentAnalysis.set(previous);
      expect(ThaiBetaCurrentAnalysis.current, same(previous));

      ThaiBetaCurrentAnalysis.clear();
      final failed = ThaiBetaAnalysis.failedForTest(input: sampleInput());
      expect(failed.isSuccess, isFalse);
      ThaiBetaCurrentAnalysis.set(failed);

      expect(ThaiBetaCurrentAnalysis.current, isNull);
    });

    testWidgets('capture route after failed analysis shows no-report state', (
      tester,
    ) async {
      final previous = _runAnalysis(birthDate: DateTime(1982, 6, 15));
      ThaiBetaCurrentAnalysis.set(previous);

      ThaiBetaCurrentAnalysis.clear();
      ThaiBetaCurrentAnalysis.set(
        ThaiBetaAnalysis.failedForTest(input: sampleInput()),
      );

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: true,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const ThaiBetaCapturePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('thai_beta_capture_no_report')),
        findsOneWidget,
      );
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsOneWidget);
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsNothing,
      );

      final previousAge = _timeline(previous).currentStage.currentAge;
      expect(find.textContaining('อายุ $previousAge'), findsNothing);
      final sampleAge = _timeline(qaSampleAnalysis).currentStage.currentAge;
      expect(find.textContaining('อายุ $sampleAge'), findsNothing);
    });

    testWidgets('QA sample route remains separate and clearly labeled', (
      tester,
    ) async {
      ThaiBetaCurrentAnalysis.resetForTest();

      await tester.pumpWidget(
        const MaterialApp(home: ThaiBetaQaSampleCapturePage()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('QA Sample Report — ไม่ใช่ข้อมูลของผู้ใช้'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsNothing);
      // Real-user capture empty-state must not appear on the QA route.
      expect(
        find.byKey(const Key('thai_beta_capture_no_report')),
        findsNothing,
      );
    });
  });

  group('QA sample capture route', () {
    testWidgets('shows QA label and sample report', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ThaiBetaQaSampleCapturePage()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('QA Sample Report — ไม่ใช่ข้อมูลของผู้ใช้'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
    });
  });

  group('ThaiBetaReportExportPolish', () {
    test('neighbourLabel does not double prefix', () {
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงก่อนหน้า: ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
    });

    test('polishTimingCopy rewrites zero remaining years', () {
      final polished = ThaiBetaReportExportPolish.polishTimingCopy(
        'ตอนนี้คุณอายุ 54 ปี กำลังอยู่ในช่วงเก็บเกี่ยว '
        'และจะอยู่ในจังหวะนี้ไปอีกประมาณ 0 ปี',
      );
      expect(RegExp(r'(?<![0-9])0\s*ปี').hasMatch(polished), isFalse);
      expect(polished.contains('กำลังอยู่ช่วงปลายของจังหวะนี้'), isTrue);
      // Must not destroy legitimate ages like 10/20/54.
      expect(
        ThaiBetaReportExportPolish.polishTimingCopy('อายุ 10 ปีในวัยเด็ก'),
        'อายุ 10 ปีในวัยเด็ก',
      );
    });

    test(
      'normalizeSpacing adds space before parentheses and Thai punctuation',
      () {
        expect(
          ThaiBetaReportExportPolish.normalizeSpacing('ดี(ผ่านช่วงนี้)'),
          'ดี (ผ่านช่วงนี้)',
        );
        expect(
          ThaiBetaReportExportPolish.normalizeSpacing('อยากรู้·คำถาม'),
          'อยากรู้ · คำถาม',
        );
        expect(
          ThaiBetaReportExportPolish.normalizeSpacing('อายุ36–54'),
          'อายุ 36–54',
        );
        expect(
          ThaiBetaReportExportPolish.normalizeSpacing('ดาวพฤหัสบดี•การเติบโต'),
          'ดาวพฤหัสบดี • การเติบโต',
        );
      },
    );

    test('polishLine strips Markdown bold markers', () {
      expect(
        ThaiBetaReportExportPolish.polishLine('**หัวข้อ** เนื้อหา'),
        'หัวข้อ เนื้อหา',
      );
    });

    test(
      'dedupeParagraphs drops title echo, keyword echo, truncated UI lines',
      () {
        final lines = ThaiBetaReportExportPolish.dedupeParagraphs('การเติบโต', [
          'การเติบโต',
          'อิทธิพลดาวพฤหัสบดี • การเติบโต',
          'การเติบโต',
          'คำสำคัญ: การเติบโต',
          'เนื้อหาเต็ม',
          'เนื้อหาเต็ม',
          'ผ่านรู้สึก…',
          'ดี(ผ่านคิดละเอ…)',
        ]);
        expect(lines, ['อิทธิพลดาวพฤหัสบดี • การเติบโต', 'เนื้อหาเต็ม']);
      },
    );
  });

  group('Export button visibility', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      required bool screenshotMode,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: screenshotMode,
            child: child ?? const SizedBox.shrink(),
          ),
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            screenshotModeOverride: screenshotMode,
            showCaptureModeBanner: screenshotMode,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('export button appears only in screenshot/capture mode', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: true);
      expect(
        find.byKey(const Key('thai_beta_report_export_bar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_print_button')),
        findsOneWidget,
      );
      expect(find.text('ดาวน์โหลดรายงานเต็ม'), findsOneWidget);
      expect(find.text('เปิดหน้าพิมพ์ / Save as PDF'), findsOneWidget);
    });

    testWidgets('export button visible on capture page with stored analysis', (
      tester,
    ) async {
      ThaiBetaCurrentAnalysis.set(analysis);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: true,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const ThaiBetaCapturePage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Thai Beta Capture Mode Active'), findsOneWidget);
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
      expect(find.text('ดาวน์โหลดรายงานเต็ม'), findsOneWidget);
    });

    testWidgets('export button not gated by evidence badge flag off', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            screenshotModeOverride: true,
            showCaptureModeBanner: true,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.off,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsOneWidget,
      );
    });

    testWidgets('export button hidden in normal beta report mode', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: false);
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('thai_beta_report_export_bar')),
        findsNothing,
      );
    });

    testWidgets('ThaiMirrorResultPage alone has no export button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiMirrorResultPage(
            consumerState: analysis.consumerViewState!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaReportExportButton), findsNothing);
      expect(
        find.byKey(const Key('thai_beta_report_export_button')),
        findsNothing,
      );
    });
  });

  group('Print fallback page', () {
    testWidgets('renders export document without progress/feedback chrome', (
      tester,
    ) async {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      await tester.pumpWidget(
        MaterialApp(home: ThaiBetaExportPrintPage(document: doc)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('thai_beta_export_print_page')),
        findsOneWidget,
      );
      expect(find.text('อ่านผล'), findsNothing);
      expect(find.text('ให้ความคิดเห็นต่อผลวิเคราะห์'), findsNothing);
      expect(find.textContaining('KnowMe'), findsWidgets);
    });
  });
}

String? _findPdftoppm() {
  final configured = Platform.environment['KNOWME_PDFTOPPM'];
  if (configured != null && File(configured).existsSync()) return configured;
  if (Platform.isWindows) {
    final profile = Platform.environment['USERPROFILE'];
    if (profile != null) {
      final runtimes = Directory('$profile/.cache/codex-runtimes');
      if (runtimes.existsSync()) {
        for (final entity in runtimes.listSync(recursive: true)) {
          if (entity is File &&
              entity.path.endsWith(
                r'\dependencies\native\poppler\Library\bin\pdftoppm.exe',
              )) {
            return entity.path;
          }
        }
      }
    }
  }
  return null;
}

bool _hasInkInForbiddenMargin(List<int> bytes) {
  var offset = 0;
  String token() {
    while (offset < bytes.length &&
        (bytes[offset] == 9 ||
            bytes[offset] == 10 ||
            bytes[offset] == 13 ||
            bytes[offset] == 32)) {
      offset++;
    }
    final start = offset;
    while (offset < bytes.length &&
        bytes[offset] != 9 &&
        bytes[offset] != 10 &&
        bytes[offset] != 13 &&
        bytes[offset] != 32) {
      offset++;
    }
    return String.fromCharCodes(bytes.sublist(start, offset));
  }

  expect(token(), 'P6');
  final width = int.parse(token());
  final height = int.parse(token());
  final maxValue = int.parse(token());
  expect(maxValue, 255);
  while (offset < bytes.length &&
      (bytes[offset] == 9 ||
          bytes[offset] == 10 ||
          bytes[offset] == 13 ||
          bytes[offset] == 32)) {
    offset++;
  }
  const safeMargin = 55;
  const inkThreshold = 225;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = offset + ((y * width + x) * 3);
      final isInk =
          bytes[pixel] < inkThreshold ||
          bytes[pixel + 1] < inkThreshold ||
          bytes[pixel + 2] < inkThreshold;
      if (isInk &&
          (x < safeMargin ||
              x >= width - safeMargin ||
              y < safeMargin ||
              y >= height - safeMargin)) {
        return true;
      }
    }
  }
  return false;
}
