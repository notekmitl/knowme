import '../foundation/models/thai_birth_data.dart';

/// One birth profile in the Thai Mirror internal QA dataset.
class ThaiMirrorQaProfile {
  const ThaiMirrorQaProfile({
    required this.id,
    required this.label,
    required this.birthData,
    this.notes = '',
  });

  final String id;
  final String label;
  final ThaiBirthData birthData;
  final String notes;

  String get birthDataSummary {
    final local = birthData.localDateTime;
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';

    if (!birthData.hasBirthTime) {
      return '$date · ไม่มีเวลาเกิด · ${birthData.latitude}, ${birthData.longitude}';
    }

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$date · $hour:$minute · ${birthData.latitude}, ${birthData.longitude}';
  }
}
