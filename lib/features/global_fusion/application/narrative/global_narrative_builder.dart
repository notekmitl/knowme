import '../../domain/global_agreement.dart';
import '../../domain/global_agreement_strength.dart';
import '../../domain/global_confidence.dart';
import '../../domain/global_core_themes.dart';
import '../../domain/global_fusion_snapshot.dart';
import '../../domain/global_lens_id.dart';
import '../../domain/global_reflection_unit.dart';
import '../../domain/global_tension.dart';
import '../../domain/global_theme_activation.dart';
import 'global_narrative_registry.dart';

/// Builds deterministic human reflections from Global Fusion synthesis (GF-F3).
abstract final class GlobalNarrativeBuilder {
  static List<GlobalReflectionUnit> build({
    required List<GlobalThemeActivation> themes,
    required List<GlobalAgreement> agreements,
    required List<GlobalTension> tensions,
    required GlobalConfidence confidence,
  }) {
    if (themes.isEmpty && agreements.isEmpty && tensions.isEmpty) {
      return const [];
    }

    final units = <GlobalReflectionUnit>[];

    for (final activation in themes) {
      final unit = _themeUnit(activation, confidence);
      if (unit != null) units.add(unit);
    }

    for (final agreement in agreements) {
      units.add(_agreementUnit(agreement));
    }

    for (final tension in tensions) {
      units.add(_tensionUnit(tension, confidence));
    }

    return List.unmodifiable(units);
  }

  static List<GlobalReflectionUnit> fromSnapshot(GlobalFusionSnapshot snapshot) {
    return build(
      themes: snapshot.normalizedThemes,
      agreements: snapshot.agreements,
      tensions: snapshot.tensions,
      confidence: snapshot.confidence,
    );
  }

  static GlobalReflectionUnit? _themeUnit(
    GlobalThemeActivation activation,
    GlobalConfidence confidence,
  ) {
    final theme = GlobalThemeRegistry.get(activation.globalThemeId);
    if (theme == null) return null;

    return GlobalReflectionUnit(
      category: theme.category,
      themeId: theme.id,
      reflection: GlobalNarrativeRegistry.themeReflection(theme.id),
      evidenceSummary: _themeEvidenceSummary(activation),
      confidenceBand: confidence.band,
    );
  }

  static GlobalReflectionUnit _agreementUnit(GlobalAgreement agreement) {
    final theme = GlobalThemeRegistry.get(agreement.themeId)!;

    return GlobalReflectionUnit(
      category: theme.category,
      themeId: agreement.themeId,
      reflection: GlobalNarrativeRegistry.agreementReflection(agreement.themeId),
      evidenceSummary: _agreementEvidenceSummary(agreement),
      confidenceBand: GlobalNarrativeRegistry.agreementStrengthBand(
        agreement.strength,
      ),
    );
  }

  static GlobalReflectionUnit _tensionUnit(
    GlobalTension tension,
    GlobalConfidence confidence,
  ) {
    final primary = GlobalThemeRegistry.get(tension.primaryThemeId)!;

    return GlobalReflectionUnit(
      category: primary.category,
      themeId: tension.primaryThemeId,
      reflection: GlobalNarrativeRegistry.tensionReflection(
        tension.primaryThemeId,
        tension.secondaryThemeId,
      ),
      evidenceSummary: _tensionEvidenceSummary(tension),
      confidenceBand: confidence.band,
    );
  }

  static String _themeEvidenceSummary(GlobalThemeActivation activation) {
    final mirrors = _mirrorLabels(activation);
    final count = activation.evidence.length;
    return 'ธีม ${activation.globalThemeId} จาก ${mirrors.join(' และ ')} '
        '($count หลักฐาน)';
  }

  static String _agreementEvidenceSummary(GlobalAgreement agreement) {
    final mirrors = agreement.supportingMirrors.map(_mirrorLabel).join(' และ ');
    return 'ข้อตกลงข้ามมิเรอร์บนธีม ${agreement.themeId} '
        'จาก $mirrors (${agreement.supportingEvidenceCount} หลักฐาน, '
        'ความแข็งแรง ${agreement.strength.id})';
  }

  static String _tensionEvidenceSummary(GlobalTension tension) {
    final mirrors = tension.supportingMirrors.map(_mirrorLabel).join(' ↔ ');
    return 'ความต่างระหว่าง ${tension.primaryThemeId} กับ '
        '${tension.secondaryThemeId} จาก $mirrors';
  }

  static List<String> _mirrorLabels(GlobalThemeActivation activation) {
    return activation.evidence
        .map((e) => e.sourceMirror)
        .toSet()
        .map(_mirrorLabel)
        .toList()
      ..sort();
  }

  static String _mirrorLabel(GlobalLensId mirror) {
    return switch (mirror) {
      GlobalLensId.astrologyMirror => 'มิเรอร์ดวงดาว',
      GlobalLensId.personalityMirror => 'มิเรอร์บุคลิกภาพ',
    };
  }
}
