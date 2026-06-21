import 'package:knowme/features/home_cohesion/application/home_v2_loader.dart';
import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_runtime_loader.dart';

import '../presentation/home_screen_v3_models.dart';

/// Loads Home V3 emotional surface via existing V2 data pipeline.
class HomeV3Loader {
  HomeV3Loader({
    HomeV2Loader? loader,
    NarrativeRuntimeLoader? narrativeLoader,
  })  : _loader = loader ?? HomeV2Loader(),
        _narrativeLoader = narrativeLoader ?? NarrativeRuntimeLoader();

  final HomeV2Loader _loader;
  final NarrativeRuntimeLoader _narrativeLoader;

  Future<HomeScreenV3Data> load(String uid) async {
    final bundle = await _loader.loadBundle(uid);
    final narrative = await _narrativeLoader.loadForUser(
      uid,
      generatedAt: DateTime.now().toUtc(),
    );
    return HomeV3Assembler.fromSources(
      bundle,
      narrativeResult: narrative,
    );
  }
}
