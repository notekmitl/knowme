import '../../../foundation/models/profile_warning.dart';
import 'thai_chart_metadata.dart';
import 'thai_house.dart';
import 'thai_lagna.dart';

/// Deterministic aggregate output of Thai Chart Engine V2.
///
/// Structural chart truth only — no V1 snapshot or interpretation fields.
class ThaiChart {
  const ThaiChart({
    required this.metadata,
    required this.warnings,
    this.lagna,
    this.houses = const [],
    this.placements = const [],
    this.relationships = const [],
  });

  final ThaiChartMetadata metadata;
  final ThaiLagna? lagna;
  final List<ThaiHouse> houses;
  final List<ProfileWarning> warnings;

  /// Reserved for Phase C planet placements.
  final List<Object> placements;

  /// Reserved for Phase D relationship facts.
  final List<Object> relationships;
}
