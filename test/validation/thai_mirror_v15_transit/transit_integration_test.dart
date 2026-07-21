import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';
import 'package:knowme/features/astrology/thai/core/transit/enhanced_reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/transit/enhanced_reasoning_runtime.dart';
import 'package:knowme/features/astrology/thai/core/transit/transit_event.dart';

const _runtime = ThaiReasoningRuntime();
const _enhanced = EnhancedReasoningRuntime();

final _birthDates = <DateTime>[
  DateTime(1988, 3, 14),
  DateTime(1990, 7, 17),
  DateTime(1995, 1, 4),
  DateTime(1979, 11, 8),
  DateTime(2001, 5, 18),
  DateTime(1966, 9, 24),
  DateTime(2010, 2, 7),
  DateTime(1948, 12, 30),
];

// Seven consecutive days → all weekday rulers exercised.
final _asOfDates = <DateTime>[
  for (var i = 0; i < 7; i++) DateTime(2026, 6, 22).add(Duration(days: i)),
];

ReasoningRequest _req(DateTime birth, DateTime asOf) =>
    ReasoningRequest(birthDate: birth, asOf: asOf);

void main() {
  group('V15 — transit stability', () {
    test('transiting planet is the day-of-week ruler; two events; reuses bond',
        () {
      for (final b in _birthDates) {
        for (final asOf in _asOfDates) {
          final r = _enhanced.decide(_req(b, asOf));
          final t = r.transit;

          final dayRuler = LifePlanets.rulerForWeekday(asOf.weekday);
          expect(t.window.ruler, dayRuler);
          expect(t.events.length, 2);
          expect(t.events.map((e) => e.kind).toList(), [
            TransitEventKind.dayVersusNatal,
            TransitEventKind.dayVersusPeriod,
          ]);

          for (final e in t.events) {
            expect(e.signal.transiting, dayRuler);
            // signal reuses the shared relationship engine (no duplicate scoring)
            final expected =
                PlanetRelationshipEngine.assess(dayRuler, e.signal.target);
            expect(e.signal.score, expected.score);
            expect(e.signal.bond, expected.bond);
          }

          // impact net equals the summed influence magnitudes (pre-clamp range).
          final sum =
              t.influences.fold<int>(0, (s, i) => s + i.magnitude);
          expect(t.impact.net, sum.clamp(-100, 100));
          expect(t.evidence.length, 2);
        }
      }
    });

    test('transit depends only on day ruler, natal and current planet', () {
      // Same birth + same weekday (7 days apart) → identical transit signals.
      for (final b in _birthDates) {
        final a = _enhanced.decide(_req(b, DateTime(2026, 6, 22)));
        final c = _enhanced.decide(_req(b, DateTime(2026, 6, 29)));
        expect(a.transit.window.ruler, c.transit.window.ruler);
        expect(
          a.transit.evidence.map((e) => '${e.sourceName}:${e.magnitude}'),
          c.transit.evidence.map((e) => '${e.sourceName}:${e.magnitude}'),
        );
      }
    });
  });

  group('V15 — runtime compatibility (base untouched; transit is additive)', () {
    test('enhanced.base equals the runtime called directly, across all APIs', () {
      for (final b in _birthDates) {
        final asOf = _asOfDates.first;
        final intent = const QuestionIntent(
          kind: QuestionIntentKind.shouldI,
          topic: QuestionTopic.career,
        );
        final req = ReasoningRequest(
          birthDate: b,
          asOf: asOf,
          question: intent,
          scenarioFocus: null,
        );

        _expectSameBase(_enhanced.evaluate(req), _runtime.evaluate(req));
        _expectSameBase(_enhanced.predict(req), _runtime.predict(req));
        _expectSameBase(_enhanced.decide(req), _runtime.decide(req));
        _expectSameBase(_enhanced.question(req), _runtime.question(req));
        _expectSameBase(_enhanced.answer(req), _runtime.answer(req));
      }
    });

    test('confidence is exactly the base confidence (transit adds no verdict)',
        () {
      for (final b in _birthDates) {
        for (final asOf in _asOfDates) {
          final r = _enhanced.decide(_req(b, asOf));
          expect(r.confidence, r.base.confidence);
        }
      }
    });
  });

  group('V15 — evidence merge', () {
    test('merged = runtime evidence then transit evidence; base preserved', () {
      for (final b in _birthDates) {
        for (final asOf in _asOfDates) {
          final r = _enhanced.decide(_req(b, asOf));

          expect(r.runtimeEvidence.length, r.base.evidence.length);
          expect(r.transitEvidence.length, r.transit.evidence.length);
          expect(
            r.mergedEvidence.length,
            r.base.evidence.length + r.transit.evidence.length,
          );

          // runtime atoms preserved unchanged and tagged as runtime origin
          for (var i = 0; i < r.base.evidence.length; i++) {
            final src = r.base.evidence[i];
            final merged = r.runtimeEvidence[i];
            expect(merged.origin, EnhancedEvidenceOrigin.runtime);
            expect(merged.layer, src.layer.name);
            expect(merged.sourceName, src.sourceName);
            expect(merged.magnitude, src.magnitude);
          }

          // transit atoms tagged as transit origin under the 'transit' layer
          for (final e in r.transitEvidence) {
            expect(e.origin, EnhancedEvidenceOrigin.transit);
            expect(e.layer, 'transit');
          }
          expect(
            r.mergedEvidence.where((e) => e.origin == EnhancedEvidenceOrigin.transit),
            isNotEmpty,
          );
        }
      }
    });
  });

  group('V15 — determinism', () {
    test('identical request → identical enhanced response', () {
      for (final b in _birthDates) {
        for (final asOf in _asOfDates) {
          expect(_sig(_enhanced.decide(_req(b, asOf))),
              _sig(_enhanced.decide(_req(b, asOf))));
        }
      }
    });
  });
}

void _expectSameBase(EnhancedReasoningResponse enhanced, dynamic direct) {
  expect(enhanced.base.depth, direct.depth);
  expect(enhanced.base.confidence, direct.confidence);
  expect(enhanced.base.evidence.length, direct.evidence.length);
  for (var i = 0; i < enhanced.base.evidence.length; i++) {
    final a = enhanced.base.evidence[i];
    final c = direct.evidence[i];
    expect(a.layer, c.layer);
    expect(a.sourceName, c.sourceName);
    expect(a.magnitude, c.magnitude);
  }
}

String _sig(EnhancedReasoningResponse r) => [
      r.confidence,
      r.transit.window.ruler.name,
      r.transit.impact.net,
      r.transit.impact.band.name,
      r.transit.events
          .map((e) =>
              '${e.kind.name}/${e.signal.transiting.name}/${e.signal.target.name}/${e.signal.score}')
          .join(','),
      r.mergedEvidence
          .map((e) => '${e.origin.name}:${e.layer}:${e.sourceName}:${e.magnitude}')
          .join('|'),
    ].join('#');
