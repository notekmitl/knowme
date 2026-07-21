import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';

/// V10.5 — Prediction presentation (composer) validation.
///
/// The composer must: be deterministic, keep the copy boundary (no planet names
/// or astrology jargon in the headline-facing copy — only in the expandable
/// evidence), avoid duplicated copy, and degrade gracefully at the final period.
final _asOf = DateTime(2026, 6, 1);

final _birthDates = <DateTime>[
  DateTime(1988, 3, 14),
  DateTime(1990, 7, 17),
  DateTime(1995, 1, 4),
  DateTime(1979, 11, 8),
  DateTime(2001, 5, 18),
  DateTime(1966, 9, 24),
];

// Every Thai planet name starts with "ดาว"; astrology surface terms to keep out
// of the user-facing headline copy.
const _astrologyTokens = <String>['ดาว', 'ธาตุ', 'ราศี', 'ลัคนา'];
const _fateTokens = <String>['พรหมลิขิต', 'ดวงกำหนด', 'เกิดมาเพื่อ', 'โชคชะต'];

PredictionSectionModel? _compose(DateTime birth, {int seed = 7}) {
  final intel =
      LifeTimelineIntelligenceEngine.fromBirthDate(birth, asOf: _asOf);
  final prediction = PredictionIntelligenceEngine.fromIntelligence(intel);
  return PredictionComposer.compose(intelligence: prediction, seed: seed);
}

void main() {
  group('V10.5 — structure', () {
    test('a mid-life chart produces up to three ordered windows', () {
      for (final birth in _birthDates) {
        final model = _compose(birth);
        expect(model, isNotNull);
        expect(model!.windows, isNotEmpty);
        expect(model.windows.length, lessThanOrEqualTo(3));
        expect(model.windows.first.windowLabel, 'ช่วงนี้');
        expect(model.sectionTitle, isNotEmpty);
        expect(model.sectionIntro, isNotEmpty);
        expect(model.closingAdvice, isNotEmpty);
      }
    });

    test('final period degrades gracefully (no next-life-period card)', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.thursday,
        currentAge: 118,
      );
      final intel = LifeTimelineIntelligenceEngine.fromTimeline(timeline);
      final prediction =
          PredictionIntelligenceEngine.fromIntelligence(intel);
      final model =
          PredictionComposer.compose(intelligence: prediction, seed: 7);
      expect(model, isNotNull);
      // current + next-12-months remain; next life period is absent.
      expect(model!.windows.length, 2);
      expect(
        model.windows.map((w) => w.windowLabel),
        isNot(contains('ช่วงชีวิตถัดไป')),
      );
    });

    test('every card carries all six required slots', () {
      for (final card in _compose(_birthDates.first)!.windows) {
        expect(card.summary, isNotEmpty);
        expect(card.topOpportunity, isNotEmpty);
        expect(card.topRisk, isNotEmpty);
        expect(card.confidenceLabel, isNotEmpty);
        expect(card.confidenceLevel, inInclusiveRange(1, 3));
        expect(card.why, isNotEmpty);
        expect(card.whyNow, isNotEmpty);
        expect(card.whatToWatch, isNotEmpty);
      }
    });
  });

  group('V10.5 — determinism', () {
    test('same intelligence + seed → identical copy', () {
      for (final birth in _birthDates) {
        final a = _compose(birth)!;
        final b = _compose(birth)!;
        expect(a.windows.length, b.windows.length);
        for (var i = 0; i < a.windows.length; i++) {
          final wa = a.windows[i];
          final wb = b.windows[i];
          expect(wa.summary, wb.summary);
          expect(wa.topOpportunity, wb.topOpportunity);
          expect(wa.topRisk, wb.topRisk);
          expect(wa.why, wb.why);
          expect(wa.whyNow, wb.whyNow);
          expect(wa.whatToWatch, wb.whatToWatch);
          expect(wa.evidenceDetail, wb.evidenceDetail);
          expect(wa.confidenceLevel, wb.confidenceLevel);
        }
      }
    });
  });

  group('V10.5 — copy boundary', () {
    test('headline copy has no planet names / astrology jargon', () {
      for (final birth in _birthDates) {
        for (final card in _compose(birth)!.windows) {
          final headlineFields = <String>[
            card.windowLabel,
            card.timeframeLabel,
            card.summary,
            card.topOpportunity,
            card.topRisk,
            card.confidenceLabel,
            card.why,
            card.whyNow,
            card.whatToWatch,
          ];
          for (final field in headlineFields) {
            for (final token in _astrologyTokens) {
              expect(field.contains(token), isFalse,
                  reason: 'astrology token "$token" leaked into "$field"');
            }
          }
        }
      }
    });

    test('planet evidence is confined to the expandable detail', () {
      for (final birth in _birthDates) {
        for (final card in _compose(birth)!.windows) {
          // the planet name ("ดาว…") may only appear in the evidence detail
          expect(card.evidenceDetail.contains('ดาว'), isTrue,
              reason: 'evidence detail should cite the planet');
        }
      }
    });

    test('no fate / determinism wording anywhere', () {
      for (final birth in _birthDates) {
        final model = _compose(birth)!;
        final all = <String>[
          model.sectionTitle,
          model.sectionIntro,
          model.transitionLine,
          model.closingAdvice,
          for (final c in model.windows) ...[
            c.summary,
            c.topOpportunity,
            c.topRisk,
            c.why,
            c.whyNow,
            c.whatToWatch,
            c.evidenceDetail,
          ],
        ];
        for (final text in all) {
          for (final token in _fateTokens) {
            expect(text.contains(token), isFalse,
                reason: 'fate token "$token" in "$text"');
          }
        }
      }
    });
  });

  group('V10.5 — no duplicated copy', () {
    test('window summaries are distinct', () {
      for (final birth in _birthDates) {
        final summaries = _compose(birth)!.windows.map((w) => w.summary);
        expect(summaries.toSet().length, summaries.length);
      }
    });

    test('no two window cards are byte-identical', () {
      for (final birth in _birthDates) {
        final signatures = _compose(birth)!.windows.map((w) =>
            '${w.summary}|${w.topOpportunity}|${w.topRisk}|${w.why}|'
            '${w.whyNow}|${w.whatToWatch}');
        expect(signatures.toSet().length, signatures.length);
      }
    });

    test('confidence is non-increasing from near to far horizons', () {
      for (final birth in _birthDates) {
        final levels =
            _compose(birth)!.windows.map((w) => w.confidenceLevel).toList();
        for (var i = 1; i < levels.length; i++) {
          expect(levels[i - 1], greaterThanOrEqualTo(levels[i]));
        }
      }
    });
  });
}
