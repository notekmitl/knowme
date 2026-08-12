import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_claim_ledger.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  test('claim ledger rejects a second primary home and audits callbacks', () {
    final ledger = ThaiBetaReportClaimLedger();
    expect(
      ledger.assign(
        ThaiBetaReportClaimAllocation(
          canonicalId: 'forecast:career',
          evidenceKeys: {'career-score'},
          role: 'active-pressure',
          section: 'present',
          domain: 'career',
          horizon: 'current',
        ),
      ),
      isTrue,
    );
    expect(
      ledger.assign(
        ThaiBetaReportClaimAllocation(
          canonicalId: 'forecast:career',
          evidenceKeys: {'career-score'},
          role: 'change-trigger',
          section: 'near-future',
          domain: 'career',
          horizon: 'next12Months',
        ),
      ),
      isFalse,
    );
    expect(
      ledger.callbackAddsInformation(
        canonicalId: 'forecast:career',
        newInformationKey: 'trigger:new-role',
      ),
      isTrue,
    );
    expect(
      ledger.callbackAddsInformation(
        canonicalId: 'forecast:career',
        newInformationKey: 'trigger:new-role',
      ),
      isFalse,
    );
  });

  for (final knownTime in [true, false]) {
    test(
      'V1.5 assigns each forecast domain once (${knownTime ? 'Known' : 'Unknown'})',
      () {
        final analysis = ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Acceptance',
            lastName: 'Fixture',
            birthDate: DateTime(1982, 6, 6),
            birthHour: knownTime ? 0 : null,
            birthMinute: knownTime ? 3 : 0,
            birthTimeUnknown: !knownTime,
            province: 'เชียงใหม่',
            provinceKey: 'chiang_mai',
          ),
          startedAt: DateTime(2026, 8, 7),
        );
        final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
        final domains = view.futurePrediction!.windows
            .expand((window) => window.domains)
            .map((domain) => domain.material!.domain)
            .toList();
        expect(domains.toSet().length, 4);
        expect(domains.length, 4);
        expect(
          view.futurePrediction!.windows
              .where((window) => window.domains.isNotEmpty)
              .length,
          3,
        );

        final text = ThaiBetaReportExportDocument.fromAnalysis(
          analysis,
        ).fullPlainText;
        for (final phrase in [
          'วินัย ความต่อเนื่อง และการสร้างฐานทีละขั้น',
          'การแบกภาระนานเกินไปโดยไม่ปรับวิธี',
          'การวางระบบที่ทำซ้ำได้',
        ]) {
          expect(phrase.allMatches(text).length, lessThanOrEqualTo(1));
        }
      },
    );
  }
}
