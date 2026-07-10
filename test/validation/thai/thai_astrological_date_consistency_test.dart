import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_reasoning_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_profile_enrichment.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';

/// Critical Consistency Fix — Thai Astrological Date.
///
/// Birth Sunday 00:30, sunrise ~05:48 (born before sunrise) → the Thai
/// astrological day is the PREVIOUS day, Saturday. Every layer that depends on
/// the Thai day must therefore start from **Saturday** (เสาร์ = Saturn ruler),
/// never from the civil Sunday.
void main() {
  // 2024-06-09 is a Sunday; the previous day (2024-06-08) is a Saturday.
  // 00:30 is before sunrise on any day, so this is deterministically a
  // before-sunrise birth regardless of the exact sunrise minute (~05:48).
  final sundayCivil = DateTime(2024, 6, 9, 0, 30);
  // Pin "now" so age-dependent fields are deterministic (start planet is not
  // age-dependent, but this keeps the whole pipeline stable in CI).
  final asOf = DateTime(2024, 6, 9, 12, 0);

  late ThaiBirthData birthData;

  setUp(() {
    final raw = RawBirthInput(
      birthDate: DateTime(sundayCivil.year, sundayCivil.month, sundayCivil.day),
      birthHour: sundayCivil.hour,
      birthMinute: sundayCivil.minute,
      province: 'bangkok',
      placeLabel: 'กรุงเทพมหานคร',
      timeZoneId: 'Asia/Bangkok',
    );
    final result = BirthNormalizer.normalize(raw);
    expect(result.isValid, isTrue);
    birthData = ThaiEngineAdapter.fromNormalized(result.birth!);
  });

  group('Birth Sunday 00:30 → Thai day Saturday across every layer', () {
    test('Normalization resolves the astrological date to Saturday', () {
      expect(sundayCivil.weekday, DateTime.sunday);
      // The single normalized source.
      expect(birthData.astrologicalDate.weekday, DateTime.saturday);
      // อาทิตย์=1 … เสาร์=7.
      expect(birthData.thaiWeekdayNumber, 7);
      // Civil date (must never drive the Thai day) would say Sunday.
      expect(birthData.dateOnly.weekday, DateTime.sunday);
    });

    test('Foundation (Mirror enrichment) uses the astrological weekday', () {
      final enriched = ThaiMirrorProfileEnrichment.enrich(
        profile: ThaiFoundationEngine.generate(birthData),
        birthData: birthData,
      );
      // Saturday (weekday 7) → the seventh เลข 7 ตัว key, not Sunday's.
      expect(enriched.dominantMyanmarKey, ThaiContentKeys.myanmarSeven7);
    });

    test('Life Timeline starts from Saturday (Saturn)', () {
      final timeline = LifePeriodEngine.fromBirthData(birthData, asOf: asOf);
      expect(timeline.startPlanet, LifePlanet.saturn);

      // Contrast: feeding the civil date would (wrongly) start from Sunday/Sun.
      final civil = LifePeriodEngine.fromBirthDate(birthData.dateOnly, asOf: asOf);
      expect(civil.startPlanet, LifePlanet.sun);
    });

    test('Timeline Intelligence natal ruler is Saturday (Saturn)', () {
      final intel =
          LifeTimelineIntelligenceEngine.fromBirthData(birthData, asOf: asOf);
      expect(intel.timeline.startPlanet, LifePlanet.saturn);
      expect(intel.natal.birthRuler, LifePlanet.saturn);
    });

    test('Prediction reasons over the Saturday timeline', () {
      final prediction = PredictionIntelligenceEngine.fromBirthDate(
        birthData.astrologicalDate,
        asOf: asOf,
      );
      expect(
        prediction.context.intelligence.timeline.startPlanet,
        LifePlanet.saturn,
      );
    });

    test('Decision reasons over the Saturday timeline', () {
      final decision = DecisionIntelligenceEngine.fromBirthDate(
        birthData.astrologicalDate,
        asOf: asOf,
      );
      expect(
        decision.context.intelligence.timeline.startPlanet,
        LifePlanet.saturn,
      );
    });

    test('Question reasons over the Saturday timeline', () {
      final decision = DecisionIntelligenceEngine.fromBirthDate(
        birthData.astrologicalDate,
        asOf: asOf,
      );
      const intent = QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.career,
      );
      // Question recomputes nothing — it routes into the Decision above, which
      // is rooted in the Saturday timeline.
      final question = QuestionReasoningEngine.fromDecision(decision, intent);
      expect(question.scenario.scenario.name, isNotEmpty);
      expect(
        decision.context.intelligence.timeline.startPlanet,
        LifePlanet.saturn,
      );
    });

    test('Unified Runtime exposes the Saturday timeline', () {
      final response = const ThaiReasoningRuntime().evaluate(
        ReasoningRequest(birthDate: birthData.astrologicalDate, asOf: asOf),
      );
      expect(response.timeline.source.timeline.startPlanet, LifePlanet.saturn);
    });

    test('Consumer (Thai Mirror pipeline) starts from Saturday', () {
      final pipeline = ThaiMirrorPipeline.generate(birthData);
      expect(pipeline.isSuccess, isTrue);
      expect(pipeline.lifePeriods!.startPlanet, LifePlanet.saturn);
    });
  });
}
