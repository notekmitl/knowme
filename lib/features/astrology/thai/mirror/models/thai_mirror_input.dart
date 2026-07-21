import '../../foundation/models/thai_astrology_profile.dart';
import '../../theme/models/thai_presented_theme.dart';

/// Deterministic input to Thai Mirror assembly (V1).
///
/// Produced by the existing pipeline:
/// Profile → Resolver → Engine → Presenter → Mirror Input.
class ThaiMirrorInput {
  const ThaiMirrorInput({
    required this.profile,
    required this.presentedThemes,
    this.locale = 'th',
    this.topThemeLimit = ThaiMirrorInput.defaultTopThemeLimit,
  });

  static const defaultTopThemeLimit = 5;

  final ThaiAstrologyProfile profile;
  final List<ThaiPresentedTheme> presentedThemes;

  /// BCP-47 locale hint for future narrative generation.
  final String locale;

  /// Max themes in the cross-cutting top-themes view.
  final int topThemeLimit;
}
