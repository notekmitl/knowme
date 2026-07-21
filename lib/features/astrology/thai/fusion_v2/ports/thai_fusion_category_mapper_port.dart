import '../../theme_v2/enums/thai_theme_category.dart';
import '../enums/thai_fusion_category_id.dart';

/// Maps frozen theme categories to fusion category ids.
abstract final class ThaiFusionCategoryMapperPort {
  static ThaiFusionCategoryId fusionCategory(ThaiThemeCategory category) {
    return switch (category) {
      ThaiThemeCategory.coreSelf => ThaiFusionCategoryId.coreSelf,
      ThaiThemeCategory.thinkingStyle => ThaiFusionCategoryId.thinkingStyle,
      ThaiThemeCategory.emotionalWorld => ThaiFusionCategoryId.emotionalWorld,
      ThaiThemeCategory.relationships => ThaiFusionCategoryId.relationships,
      ThaiThemeCategory.workAmbition => ThaiFusionCategoryId.workAmbition,
      ThaiThemeCategory.strengths => ThaiFusionCategoryId.strengths,
      ThaiThemeCategory.growthAreas => ThaiFusionCategoryId.growthAreas,
      ThaiThemeCategory.growthPath => ThaiFusionCategoryId.growthPath,
    };
  }

  static ThaiThemeCategory themeCategory(ThaiFusionCategoryId categoryId) {
    return switch (categoryId) {
      ThaiFusionCategoryId.coreSelf => ThaiThemeCategory.coreSelf,
      ThaiFusionCategoryId.thinkingStyle => ThaiThemeCategory.thinkingStyle,
      ThaiFusionCategoryId.emotionalWorld => ThaiThemeCategory.emotionalWorld,
      ThaiFusionCategoryId.relationships => ThaiThemeCategory.relationships,
      ThaiFusionCategoryId.workAmbition => ThaiThemeCategory.workAmbition,
      ThaiFusionCategoryId.strengths => ThaiThemeCategory.strengths,
      ThaiFusionCategoryId.growthAreas => ThaiThemeCategory.growthAreas,
      ThaiFusionCategoryId.growthPath => ThaiThemeCategory.growthPath,
    };
  }
}
