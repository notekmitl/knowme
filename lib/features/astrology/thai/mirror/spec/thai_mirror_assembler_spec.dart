import '../../foundation/integration/thai_foundation_resolver_bridge.dart';
import '../../foundation/models/thai_astrology_profile.dart';
import '../../theme/thai_theme_engine.dart';
import '../../theme/thai_theme_presenter.dart';
import '../../theme/thai_theme_resolver.dart';
import '../models/thai_mirror_input.dart';
import '../models/thai_mirror_result.dart';

/// Specification for structural Mirror assembly — **implementation in V1.1**.
///
/// Documents the deterministic pipeline without modifying Theme layers.
abstract final class ThaiMirrorAssemblerSpec {
  /// End-to-end pipeline from profile to mirror input.
  static ThaiMirrorInput inputFromProfile(ThaiAstrologyProfile profile) {
    final resolverInput = ThaiFoundationResolverBridge.toResolverInput(profile);
    final signals = ThaiThemeResolver.resolve(resolverInput);
    final results = ThaiThemeEngine.process(signals);
    final presented = ThaiThemePresenter.present(results);

    return ThaiMirrorInput(
      profile: profile,
      presentedThemes: presented,
    );
  }

  /// Assembly rules (deterministic).
  static const rules = <String>[
    'Top themes: global sort by score desc, take topThemeLimit (default 5).',
    'Section themes: filter presented themes by ThemeRegistry category.',
    'Section order: fixed per ThaiMirrorSectionId enum (fusion order).',
    'Evidence: flatten ThaiThemeEvidence from supporting themes, dedupe by contentKey.',
    'Lens source: map ThaiContentType → ThaiMirrorLensSource (ramahabhuta excluded).',
    'Summaries: null in V1 structural phase.',
    'Warnings from profile propagate to ThaiMirrorProfileContext.',
  ];

  /// Expected output type from future [ThaiMirrorAssembler.assemble].
  static const outputType = ThaiMirrorResult;
}

/// Future structural assembler — not implemented in specification-only V1.
abstract class ThaiMirrorAssembler {
  ThaiMirrorResult assemble(ThaiMirrorInput input);
}
