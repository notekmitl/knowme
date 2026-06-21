import '../../foundation/models/thai_birth_data.dart';

/// Synthetic gender label for population stratification (not used in pipeline).
enum ThaiMirrorPopulationGender {
  male,
  female;

  String get label {
    return switch (this) {
      ThaiMirrorPopulationGender.male => 'ชาย',
      ThaiMirrorPopulationGender.female => 'หญิง',
    };
  }
}

/// One synthetic profile in the Population QA dataset.
class ThaiMirrorPopulationProfile {
  const ThaiMirrorPopulationProfile({
    required this.id,
    required this.gender,
    required this.birthData,
    required this.cohortIndex,
  });

  final String id;
  final ThaiMirrorPopulationGender gender;
  final ThaiBirthData birthData;
  final int cohortIndex;

  bool get hasBirthTime => birthData.hasBirthTime;

  String get birthDataSummary {
    final local = birthData.localDateTime;
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final genderLabel = gender.label;

    if (!birthData.hasBirthTime) {
      return '$id · $genderLabel · $date · ไม่มีเวลาเกิด';
    }

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$id · $genderLabel · $date · $hour:$minute';
  }
}
