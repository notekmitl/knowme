import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

import 'synthetic_human_attachment_style.dart';
import 'synthetic_human_variant.dart';

/// Full synthetic human profile for validation pipeline runs.
class SyntheticHumanProfile {
  const SyntheticHumanProfile({
    required this.profileId,
    required this.archetypeId,
    required this.archetypeName,
    required this.variant,
    required this.mbtiType,
    required this.mbtiDimensions,
    required this.bigFiveScores,
    required this.bigFiveBands,
    required this.eqAwarenessLevel,
    required this.eqRegulationLevel,
    required this.attachmentStyle,
    required this.thaiBirthData,
    required this.baziChart,
    required this.yearAnimalKey,
    required this.dayMasterLabel,
    required this.dominantElement,
  });

  final String profileId;
  final String archetypeId;
  final String archetypeName;
  final SyntheticHumanVariant variant;
  final String mbtiType;
  final Map<String, int> mbtiDimensions;
  final Map<String, int> bigFiveScores;
  final Map<String, String> bigFiveBands;
  final String eqAwarenessLevel;
  final String eqRegulationLevel;
  final SyntheticHumanAttachmentStyle attachmentStyle;
  final ThaiBirthData thaiBirthData;
  final BaziChartModel baziChart;
  final String yearAnimalKey;
  final String dayMasterLabel;
  final String dominantElement;

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'archetypeId': archetypeId,
      'archetypeName': archetypeName,
      'variant': variant.label,
      'mbtiType': mbtiType,
      'bigFiveScores': bigFiveScores,
      'bigFiveBands': bigFiveBands,
      'eqAwarenessLevel': eqAwarenessLevel,
      'eqRegulationLevel': eqRegulationLevel,
      'attachmentStyle': attachmentStyle.key,
      'yearAnimalKey': yearAnimalKey,
      'dayMasterLabel': dayMasterLabel,
      'dominantElement': dominantElement,
      'thaiBirthDate':
          thaiBirthData.localDateTime.toIso8601String().split('T').first,
    };
  }
}
