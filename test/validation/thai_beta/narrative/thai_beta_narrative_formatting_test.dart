import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_formatting.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  group('Formatting', () {
    test('normalizer fixes age, bullet, dash, and parenthesis spacing', () {
      expect(
        ThaiBetaNarrativeFormatting.normalize('อายุ42–62'),
        'อายุ 42–62',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('ดาวศุกร์• ความสุข'),
        'ดาวศุกร์ • ความสุข',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('อยากรู้—'),
        'อยากรู้ —',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('ดี(ผ่านมุ่งมั่น)'),
        'ดี (ผ่านมุ่งมั่น)',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('ปกติลองจับตา'),
        'ปกติ ลองจับตา',
      );
    });

    test('normalizer expands capture groups instead of literal dollar-one', () {
      expect(
        ThaiBetaNarrativeFormatting.normalize('hello , world'),
        'hello, world',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('test . end'),
        'test. end',
      );
      expect(ThaiBetaNarrativeFormatting.normalize('word ,'), 'word,');
    });

    test('normalizer preserves valid Thai compound words', () {
      expect(
        ThaiBetaNarrativeFormatting.normalize('ตั้งแต่เริ่มงาน'),
        'ตั้งแต่เริ่มงาน',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('อยากทดลองวิธีใหม่'),
        'อยากทดลองวิธีใหม่',
      );
      expect(
        ThaiBetaNarrativeFormatting.normalize('ด้านนี้ลองดูอีกครั้ง'),
        'ด้านนี้ ลองดูอีกครั้ง',
      );
    });

    test('forbidden patterns absent from composed export text', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final text = doc.fullPlainText;
      expect(ThaiBetaNarrativeFormatting.findForbidden(text), isEmpty);
      expect(text.contains('**'), isFalse);
      expect(RegExp(r'อายุ\d').hasMatch(text), isFalse);
      expect(RegExp(r'[ก-๙]•').hasMatch(text), isFalse);
      expect(RegExp(r'[ก-๙A-Za-z]—').hasMatch(text), isFalse);
      expect(RegExp(r'[ก-๙]\(').hasMatch(text), isFalse);
    });

    test('composed dashboard export has domain spacing', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      for (final item in view.lifeDashboard) {
        expect(RegExp(r'[ก-๙]•').hasMatch(item.currentState), isFalse);
        expect(RegExp(r'[ก-๙A-Za-z]—').hasMatch(item.currentState), isFalse);
      }
    });
  });
}
