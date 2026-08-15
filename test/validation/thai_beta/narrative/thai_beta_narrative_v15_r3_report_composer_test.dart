import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  final fixtures = <String, ThaiBetaInput>{
    'owner-known-0035': _owner(known: true, minute: 35),
    'owner-unknown': _owner(known: false),
    'regression-known-0003': _owner(known: true, minute: 3),
    'comparison-known-bangkok': ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1991, 11, 18),
      birthHour: 14,
      birthMinute: 20,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
    'comparison-known-khon-kaen': ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1974, 2, 27),
      birthHour: 6,
      birthMinute: 45,
      province: 'ขอนแก่น',
      provinceKey: 'khon_kaen',
    ),
  };

  test('R4 replaces the rejected R3 hook and keeps clean consumer prose', () {
    for (final entry in fixtures.entries) {
      final analysis = _run(entry.value);
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
      ).fullPlainText;
      expect(view.hero.headline, isNot(startsWith('ลายเซ็นของคำอ่าน:')));
      expect(view.hero.summary, contains('คำถาม'), reason: entry.key);
      expect(text, contains(view.hero.headline), reason: entry.key);
      expect(text, contains('คำถาม'), reason: entry.key);
      expect(view.futurePrediction!.windows, hasLength(3), reason: entry.key);
      expect(
        view.futurePrediction!.windows.every(
          (window) => window.domains.length == 4,
        ),
        isTrue,
        reason: entry.key,
      );
      for (final banned in const [
        'น้ำหนักเด่น',
        'น้ำหนักปานกลาง',
        'น้ำหนักเบา',
        'คาบเกี่ยวรอยต่อ',
        'คุณถูกผลักให้',
        'ร่างกายและใจถูกใช้จนสุดแรง',
        'คุณต้องแบกงานหลายเรื่อง',
      ]) {
        expect(text, isNot(contains(banned)), reason: '${entry.key}: $banned');
      }
      final bodies = view.futurePrediction!.windows
          .expand((window) => window.domains)
          .map((domain) => _normalize(domain.body))
          .toList(growable: false);
      expect(bodies.toSet(), hasLength(bodies.length), reason: entry.key);
    }
  });

  test('R6 assigns decision, checkpoint, and outcome to separate horizons', () {
    for (final entry in fixtures.entries) {
      final windows = ThaiBetaNarrativeComposer.narrativeView(
        _run(entry.value),
      ).futurePrediction!.windows;
      expect(
        windows[0].domains.every(
          (domain) => domain.material?.horizon == ForecastHorizon.current,
        ),
        isTrue,
        reason: entry.key,
      );
      expect(
        windows[1].domains.every(
          (domain) => domain.material?.horizon == ForecastHorizon.next12Months,
        ),
        isTrue,
        reason: entry.key,
      );
      expect(
        windows[2].domains.every(
          (domain) =>
              domain.material?.horizon == ForecastHorizon.nextLifePeriod,
        ),
        isTrue,
        reason: entry.key,
      );
      expect(windows[0].summary, contains('ต้องตัดสินใจ'));
      expect(
        windows[1].summary,
        anyOf(contains('จุดกระตุ้น'), contains('สัญญาณ')),
      );
      expect(windows[2].summary, contains('ผลระยะยาว'));
    }
  });

  test(
    'R4 materially different fixtures keep strong-body exact reuse below R3',
    () {
      final strongBodies = <String>[];
      // The 00:03 regression fixture intentionally remains a documented twin of
      // the owner Known fixture when its evidence projection is identical. The
      // product gate measures materially different fixtures, so that pair is
      // excluded rather than hidden through a blanket evidence exemption.
      for (final entry in fixtures.entries.where(
        (entry) => entry.key != 'regression-known-0003',
      )) {
        final input = entry.value;
        final domains = ThaiBetaNarrativeComposer.narrativeView(
          _run(input),
        ).futurePrediction!.windows.expand((window) => window.domains);
        strongBodies.addAll(
          domains
              .where((domain) => domain.material!.band == ForecastBand.strong)
              .map((domain) => _normalize(domain.body)),
        );
      }
      final frequency = <String, int>{};
      for (final body in strongBodies) {
        frequency.update(body, (count) => count + 1, ifAbsent: () => 1);
      }
      final reused = frequency.entries
          .where((entry) => entry.value > 1)
          .fold<int>(0, (sum, entry) => sum + entry.value);
      final rate = strongBodies.isEmpty ? 0 : reused / strongBodies.length;
      expect(
        rate,
        lessThan(0.38461538461538464),
        reason: '$reused/${strongBodies.length}',
      );
    },
  );
}

ThaiBetaInput _owner({required bool known, int minute = 0}) => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: known ? 0 : null,
  birthMinute: known ? minute : 0,
  birthTimeUnknown: !known,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);

ThaiBetaAnalysis _run(ThaiBetaInput input) =>
    ThaiBetaAnalysisRunner.run(input, startedAt: DateTime(2026, 8, 7));

String _normalize(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\-–—:;,.!?()•]'), '')
    .toLowerCase();
