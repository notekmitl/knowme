import '../repository/thai_lunar_repository.dart';
import 'thai_lunar_golden_cases.dart';

enum ThaiLunarValidationStatus { pass, fail, missing }

class ThaiLunarValidationResult {
  const ThaiLunarValidationResult({
    required this.caseId,
    required this.status,
    this.message,
  });

  final String caseId;
  final ThaiLunarValidationStatus status;
  final String? message;

  bool get isPass => status == ThaiLunarValidationStatus.pass;
}

/// Validates repository output against published golden cases.
abstract final class ThaiLunarValidator {
  static List<ThaiLunarValidationResult> validateGoldenCases(
    ThaiLunarRepository repository,
  ) {
    final results = <ThaiLunarValidationResult>[];

    for (final golden in ThaiLunarGoldenCases.all) {
      final record = repository.lookup(golden.lookupKey);

      if (record == null) {
        results.add(
          ThaiLunarValidationResult(
            caseId: golden.id,
            status: ThaiLunarValidationStatus.missing,
            message: 'No record for ${golden.lookupKey.canonical}',
          ),
        );
        continue;
      }

      final mismatches = <String>[];
      if (record.weekdayNumber != golden.weekdayNumber) {
        mismatches.add(
          'weekdayNumber: expected ${golden.weekdayNumber}, got ${record.weekdayNumber}',
        );
      }
      if (record.lunarMonthNumber != golden.lunarMonthNumber) {
        mismatches.add(
          'lunarMonthNumber: expected ${golden.lunarMonthNumber}, got ${record.lunarMonthNumber}',
        );
      }
      if (record.zodiacYearIndex != golden.zodiacYearIndex) {
        mismatches.add(
          'zodiacYearIndex: expected ${golden.zodiacYearIndex}, got ${record.zodiacYearIndex}',
        );
      }

      if (mismatches.isEmpty) {
        results.add(
          ThaiLunarValidationResult(
            caseId: golden.id,
            status: ThaiLunarValidationStatus.pass,
          ),
        );
      } else {
        results.add(
          ThaiLunarValidationResult(
            caseId: golden.id,
            status: ThaiLunarValidationStatus.fail,
            message: mismatches.join('; '),
          ),
        );
      }
    }

    return results;
  }

  static bool allGoldenCasesPass(ThaiLunarRepository repository) {
    return validateGoldenCases(repository).every((r) => r.isPass);
  }
}
