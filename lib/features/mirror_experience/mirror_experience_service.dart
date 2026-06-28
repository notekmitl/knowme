import 'package:knowme/features/runtime/fusion/fusion_context.dart';
import 'package:knowme/features/runtime/fusion/fusion_result.dart';
import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';
import 'package:knowme/features/runtime/reasoning_capability.dart';

import 'mirror_copy.dart';
import 'mirror_experience_input.dart';
import 'mirror_view_models.dart';

/// P3 — the only thing in the experience that touches reasoning.
///
/// It consumes the **Fusion Runtime only** (never a provider, never the Thai
/// runtime) and turns the structured `FusionResult` into plain-language view
/// models. By default it discovers the runtime from the global provider registry,
/// so it has no compile-time dependency on any system.
class MirrorExperienceService {
  const MirrorExperienceService(this.runtime);

  /// Discovers the fusion runtime from the registered providers.
  factory MirrorExperienceService.discover() =>
      MirrorExperienceService(FusionRuntime.discover());

  final FusionRuntime runtime;

  /// Maximum life areas shown on a card.
  static const int _maxAreas = 4;

  MirrorInsight currentLife(MirrorExperienceInput input) {
    final result = runtime.fuse(_context(ReasoningCapability.evaluate, input));
    final areas = _areas(result);
    return MirrorInsight(
      headline: MirrorCopy.currentLifeHeadline,
      body: MirrorCopy.insightBody(areas.isEmpty ? null : areas.first),
      areas: areas,
      clarity: _clarity(result),
    );
  }

  MirrorPrediction prediction(MirrorExperienceInput input) {
    final result = runtime.fuse(_context(ReasoningCapability.predict, input));
    final areas = _areas(result);
    return MirrorPrediction(
      headline: MirrorCopy.predictionHeadline,
      body: MirrorCopy.predictionBody(areas.isEmpty ? null : areas.first),
      areas: areas,
      clarity: _clarity(result),
    );
  }

  MirrorDecision decision(MirrorExperienceInput input) {
    final result = runtime.fuse(_context(ReasoningCapability.decide, input));
    final areas = _areas(result);
    final focus = areas.isEmpty ? _neutralArea() : areas.first;
    final lean = _lean(focus, result);
    return MirrorDecision(
      headline: MirrorCopy.leanHeadline(lean),
      body: MirrorCopy.decisionBody(
        MirrorDecisionLeanInput(lean: lean, focusTitle: focus.title),
      ),
      focus: focus,
      lean: lean,
      clarity: _clarity(result),
    );
  }

  MirrorReflectionData reflection(MirrorExperienceInput input) {
    final result = runtime.fuse(_context(ReasoningCapability.evaluate, input));
    final areas = _areas(result);
    return MirrorReflectionData(
      headline: MirrorCopy.reflectionHeadline,
      body: MirrorCopy.reflectionBody(areas.isEmpty ? null : areas.first),
      keyAreas: areas.take(3).toList(),
      prompt: MirrorCopy.reflectionPrompt,
    );
  }

  // --- Internals -----------------------------------------------------------

  FusionContext _context(
    ReasoningCapability capability,
    MirrorExperienceInput input,
  ) =>
      FusionContext(
        capability: capability,
        birthDate: input.birthDate,
        asOf: input.asOf,
      );

  List<MirrorLifeArea> _areas(FusionResult result) {
    final netByDomain = <String, int>{
      for (final e in result.mergedEvidence) e.domain: e.netMagnitude,
    };
    final out = <MirrorLifeArea>[];
    for (final priority in result.priorities.take(_maxAreas)) {
      final net = netByDomain[priority.domain] ?? 0;
      final tone = _tone(net);
      out.add(MirrorLifeArea(
        key: priority.domain,
        title: MirrorCopy.areaTitle(priority.domain),
        tone: tone,
        strength: net.abs(),
        summary: MirrorCopy.toneSummary(tone),
        highlighted: priority.agreed || priority.rank == 1,
      ));
    }
    return out;
  }

  MirrorTone _tone(int net) {
    if (net > 0) return MirrorTone.strong;
    if (net < 0) return MirrorTone.tender;
    return MirrorTone.steady;
  }

  MirrorClarity _clarity(FusionResult result) => MirrorClarity(
        value: result.confidence.value,
        label: MirrorCopy.clarityLabel(result.confidence.band),
      );

  MirrorLean _lean(MirrorLifeArea focus, FusionResult result) {
    if (focus.tone == MirrorTone.tender) return MirrorLean.wait;
    if (result.confidence.value >= 70) return MirrorLean.goFor;
    return MirrorLean.prepare;
  }

  MirrorLifeArea _neutralArea() => const MirrorLifeArea(
        key: '',
        title: 'Life',
        tone: MirrorTone.steady,
        strength: 0,
        summary: 'Holding steady — no big swings.',
        highlighted: false,
      );
}
