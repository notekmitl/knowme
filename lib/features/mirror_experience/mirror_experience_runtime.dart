import 'package:knowme/features/runtime/adapters/thai_runtime_adapter.dart';
import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';
import 'package:knowme/features/runtime/reasoning_runtime.dart';

/// P3 — the experience's **composition root** for reasoning.
///
/// This is the single place that names a provider. Everything else in the Mirror
/// Experience consumes only the [FusionRuntime] handed to it from here — never a
/// provider, never a system runtime. Today the platform hosts one provider
/// (Thai); when more are registered, the experience does not change.
abstract final class MirrorExperienceRuntime {
  static const FusionRuntime fusion =
      FusionRuntime(ReasoningRuntime([ThaiRuntimeAdapter()]));
}
