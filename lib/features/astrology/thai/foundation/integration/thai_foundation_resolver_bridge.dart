import '../../theme/models/thai_theme_resolver_input.dart';
import '../models/thai_astrology_profile.dart';

/// Maps [ThaiAstrologyProfile] to [ThaiThemeResolverInput] without modifying
/// the Theme Resolver / Engine / Presenter.
abstract final class ThaiFoundationResolverBridge {
  static ThaiThemeResolverInput toResolverInput(ThaiAstrologyProfile profile) {
    return ThaiThemeResolverInput(
      lagnaKey: profile.lagnaKey,
      lagnaLordKey: profile.lagnaLordKey,
      mahabhutaPositionKeys: profile.mahabhutaPositionKeys,
      myanmarKeys: profile.myanmarKeys,
    );
  }
}
