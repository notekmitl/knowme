import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_loader.dart';
import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_runtime_loader.dart';

import '../presentation/home_screen_v3_models.dart';
import 'home_load_timing.dart';

typedef HomeShellReadyCallback = void Function(
  HomeScreenV3Data shell,
  HomeV2SourceBundle bundle,
);

/// Loads Home V3 emotional surface via existing V2 data pipeline.
class HomeV3Loader {
  HomeV3Loader({
    HomeV2Loader? loader,
    NarrativeRuntimeLoader? narrativeLoader,
  })  : _loader = loader ?? HomeV2Loader(),
        _narrativeLoader = narrativeLoader ?? NarrativeRuntimeLoader();

  final HomeV2Loader _loader;
  final NarrativeRuntimeLoader _narrativeLoader;

  /// Full load — shell + enrich + narrative (legacy single await).
  Future<HomeScreenV3Data> load(String uid) async {
    final timing = HomeLoadTiming();
    final data = await loadProgressive(uid, timing: timing);
    timing.markTotal();
    return data;
  }

  /// Fast shell first, then narrative + enrich in background.
  Future<HomeScreenV3Data> loadProgressive(
    String uid, {
    HomeShellReadyCallback? onShellReady,
    HomeLoadTiming? timing,
  }) async {
    if (uid.isEmpty) {
      return HomeScreenV3Data.empty();
    }

    final bundleFast =
        await _loader.loadBundle(uid, includeHeavyDerivations: false);
    timing?.markShell();
    final shell = HomeV3Assembler.fromSources(bundleFast);
    onShellReady?.call(shell, bundleFast);

    final narrativeFuture = _narrativeLoader.loadForUser(
      uid,
      generatedAt: DateTime.now().toUtc(),
    );
    final enrichFuture = Future(() => _loader.enrichBundle(bundleFast));

    final results = await Future.wait([narrativeFuture, enrichFuture]);
    final narrative = results[0] as NarrativeResult?;
    final bundleFull = results[1] as HomeV2SourceBundle;
    timing?.markNarrative();
    timing?.markEnrich();

    return HomeV3Assembler.fromSources(
      bundleFull,
      narrativeResult: narrative,
    );
  }

  /// Shell only — for tests and first paint measurement.
  Future<HomeScreenV3Data> loadShell(String uid) async {
    if (uid.isEmpty) return HomeScreenV3Data.empty();
    final bundle =
        await _loader.loadBundle(uid, includeHeavyDerivations: false);
    return HomeV3Assembler.fromSources(bundle);
  }
}
