import 'package:flutter_test/flutter_test.dart';

import 'thai_beta_canonical_text_contract.dart';

void main() {
  group('canonicalizeLineEndings', () {
    test('preserves LF', () {
      expect(canonicalizeLineEndings('หนึ่ง\nสอง'), 'หนึ่ง\nสอง');
    });

    test('canonicalizes CRLF', () {
      expect(canonicalizeLineEndings('หนึ่ง\r\nสอง'), 'หนึ่ง\nสอง');
    });

    test('canonicalizes standalone CR', () {
      expect(canonicalizeLineEndings('หนึ่ง\rสอง'), 'หนึ่ง\nสอง');
    });

    test('canonicalizes mixed line endings only', () {
      expect(
        canonicalizeLineEndings('หนึ่ง\r\nสอง\rสาม\nสี่'),
        'หนึ่ง\nสอง\nสาม\nสี่',
      );
    });

    test('preserves blank lines and trailing newline', () {
      expect(canonicalizeLineEndings('หนึ่ง\r\n\r\nสอง\r\n'), 'หนึ่ง\n\nสอง\n');
    });

    test('preserves leading and trailing spaces on every line', () {
      expect(canonicalizeLineEndings('  หนึ่ง  \r\n สอง '), '  หนึ่ง  \n สอง ');
    });

    test('preserves Thai Unicode code points', () {
      const thai = 'ลัคนากุมภ์ 19°19′ — ไม่ทราบเวลาเกิด';
      expect(canonicalizeLineEndings(thai), thai);
    });
  });

  group('canonicalTextMatchesExactly', () {
    test('accepts line-ending-only differences', () {
      expect(
        canonicalTextMatchesExactly(
          pipelineText: 'หนึ่ง\nสอง\n',
          rawFixtureText: 'หนึ่ง\r\nสอง\r\n',
        ),
        isTrue,
      );
    });

    test('rejects pipeline carriage returns', () {
      expect(
        canonicalTextMatchesExactly(
          pipelineText: 'หนึ่ง\r\nสอง',
          rawFixtureText: 'หนึ่ง\r\nสอง',
        ),
        isFalse,
      );
    });

    test('rejects wording mismatch', () {
      expect(
        canonicalTextMatchesExactly(
          pipelineText: 'ความหมายเดิม\n',
          rawFixtureText: 'เปลี่ยนถ้อยคำ\r\n',
        ),
        isFalse,
      );
    });

    test('rejects punctuation mismatch', () {
      expect(
        canonicalTextMatchesExactly(
          pipelineText: 'ประโยคหนึ่ง.\n',
          rawFixtureText: 'ประโยคหนึ่ง!\r\n',
        ),
        isFalse,
      );
    });
  });
}
