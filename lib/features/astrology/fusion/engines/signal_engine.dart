import '../domain/entities/fusion_agreement.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../domain/entities/fusion_tension.dart';
import '../registry/signal_registry.dart';

/// Converts agreements and tensions into user-facing [FusionSignal] values.
abstract final class SignalEngine {
  static List<FusionSignal> build({
    required List<FusionAgreement> agreements,
    required List<FusionTension> tensions,
  }) {
    final buckets = <FusionSignalType, _SignalBucket>{};

    for (final agreement in agreements) {
      for (final themeId in agreement.sourceThemeIds) {
        final type = FusionSignalRegistry.signalForTheme(themeId);
        if (type == null) continue;

        buckets
            .putIfAbsent(type, () => _SignalBucket(type))
            .absorbAgreement(agreement, themeId);
      }
    }

    for (final tension in tensions) {
      if (tension.perspectives.length < 2) continue;

      final transformBucket = buckets.putIfAbsent(
        FusionSignalType.transformation,
        () => _SignalBucket(FusionSignalType.transformation),
      );

      for (final perspective in tension.perspectives) {
        transformBucket.addTheme(perspective.themeId, [perspective.lensId]);
        transformBucket.supportLevel = FusionSupportLevel.low;

        final type = FusionSignalRegistry.signalForTheme(perspective.themeId);
        if (type == null || type == FusionSignalType.transformation) continue;

        buckets
            .putIfAbsent(type, () => _SignalBucket(type))
            .addTheme(perspective.themeId, [perspective.lensId]);
      }
    }

    final signals = buckets.values.map((bucket) => bucket.toSignal()).toList()
      ..sort((a, b) {
        final supportCompare =
            b.supportLevel.rank.compareTo(a.supportLevel.rank);
        if (supportCompare != 0) return supportCompare;
        return a.type.name.compareTo(b.type.name);
      });

    return signals;
  }
}

final class _SignalBucket {
  _SignalBucket(this.type);

  final FusionSignalType type;
  final Set<String> sourceThemes = {};
  final Set<String> supportingLenses = {};
  FusionSupportLevel supportLevel = FusionSupportLevel.low;

  void absorbAgreement(FusionAgreement agreement, String themeId) {
    addTheme(themeId, agreement.supportingLenses);
    supportLevel = maxFusionSupportLevel(supportLevel, agreement.supportLevel);
  }

  void addTheme(String themeId, Iterable<String> lenses) {
    sourceThemes.add(themeId.trim().toLowerCase());
    supportingLenses.addAll(lenses);
  }

  FusionSignal toSignal() {
    final themes = sourceThemes.toList()..sort();
    final lenses = supportingLenses.toList()..sort();

    return FusionSignal(
      type: type,
      sourceThemes: themes,
      supportingLenses: lenses,
      supportLevel: supportLevel,
    );
  }
}
