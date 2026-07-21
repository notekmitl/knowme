import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/mirror_experience/mirror_copy.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_input.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_runtime.dart';
import 'package:knowme/features/mirror_experience/mirror_experience_service.dart';
import 'package:knowme/features/mirror_experience/mirror_view_models.dart';

/// P3 — the Mirror Experience consumes the **Fusion Runtime only**. These tests
/// pin that boundary, determinism, and the "explain life, not astrology" copy.
void main() {
  // Fixed inputs so `asOf` does not drift (defaults to now otherwise).
  final inputs = <MirrorExperienceInput>[
    MirrorExperienceInput(
      birthDate: DateTime(1989, 4, 15),
      asOf: DateTime(2026, 6, 28),
    ),
    MirrorExperienceInput(
      birthDate: DateTime(1995, 9, 26),
      asOf: DateTime(2026, 6, 28),
    ),
    MirrorExperienceInput(
      birthDate: DateTime(1972, 4, 5),
      asOf: DateTime(2026, 6, 28),
    ),
  ];

  // The service is built over the experience's fusion composition root.
  final service = MirrorExperienceService(MirrorExperienceRuntime.fusion);

  // No astrology/engine vocabulary may surface in user-facing copy.
  const forbidden = <String>[
    'planet',
    'saturn',
    'mars',
    'venus',
    'mercury',
    'jupiter',
    'moon',
    'sun',
    'rahu',
    'ketu',
    'astrology',
    'horoscope',
    'zodiac',
    'natal',
    'lagna',
    'runtime',
    'fusion',
    'thai',
  ];

  void assertClean(String text) {
    final lower = text.toLowerCase();
    for (final word in forbidden) {
      expect(lower.contains(word), isFalse,
          reason: 'Copy must not mention "$word": "$text"');
    }
  }

  test('single-provider fusion produces a current-life read', () {
    for (final input in inputs) {
      final insight = service.currentLife(input);
      expect(insight.headline, MirrorCopy.currentLifeHeadline);
      expect(insight.areas.length, lessThanOrEqualTo(4));
      expect(insight.clarity.value, inInclusiveRange(0, 100));
      assertClean(insight.headline);
      assertClean(insight.body);
      for (final a in insight.areas) {
        assertClean(a.title);
        assertClean(a.summary);
      }
    }
  });

  test('prediction and decision reads stay clean and bounded', () {
    for (final input in inputs) {
      final prediction = service.prediction(input);
      expect(prediction.headline, MirrorCopy.predictionHeadline);
      expect(prediction.clarity.value, inInclusiveRange(0, 100));
      assertClean(prediction.body);

      final decision = service.decision(input);
      expect(MirrorLean.values.contains(decision.lean), isTrue);
      expect(decision.clarity.value, inInclusiveRange(0, 100));
      assertClean(decision.headline);
      assertClean(decision.body);
      assertClean(decision.focus.title);
    }
  });

  test('reflection summarizes up to three key areas', () {
    for (final input in inputs) {
      final reflection = service.reflection(input);
      expect(reflection.headline, MirrorCopy.reflectionHeadline);
      expect(reflection.keyAreas.length, lessThanOrEqualTo(3));
      assertClean(reflection.body);
      assertClean(reflection.prompt);
    }
  });

  test('reads are deterministic for the same input', () {
    final input = inputs.first;

    final a = service.currentLife(input);
    final b = service.currentLife(input);
    expect(a.headline, b.headline);
    expect(a.body, b.body);
    expect(a.clarity.value, b.clarity.value);
    expect(a.areas.map((e) => '${e.key}:${e.tone}:${e.strength}'),
        b.areas.map((e) => '${e.key}:${e.tone}:${e.strength}'));

    final d1 = service.decision(input);
    final d2 = service.decision(input);
    expect(d1.lean, d2.lean);
    expect(d1.headline, d2.headline);
    expect(d1.focus.key, d2.focus.key);
  });

  test('lean is consistent with focus tone and clarity', () {
    for (final input in inputs) {
      final decision = service.decision(input);
      if (decision.focus.tone == MirrorTone.tender) {
        expect(decision.lean, MirrorLean.wait);
      } else if (decision.clarity.value >= 70) {
        expect(decision.lean, MirrorLean.goFor);
      } else {
        expect(decision.lean, MirrorLean.prepare);
      }
    }
  });
}
