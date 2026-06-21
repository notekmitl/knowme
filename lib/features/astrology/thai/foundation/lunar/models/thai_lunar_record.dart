import '../../calendar/thai_lunar_date.dart';
import 'thai_lunar_lookup_key.dart';

/// Provenance of a [ThaiLunarRecord].
enum ThaiLunarRecordProvenance {
  /// Domain-expert / published golden case with citation.
  verifiedGoldenCase,

  /// Future: row from embedded ปฏิทิน 100/150 ปี dataset asset.
  embeddedDataset,

  /// Future: computed from licensed calendar algorithm.
  generated,
}

/// Single Gregorian → Thai lunar mapping entry.
///
/// This is the infrastructure source-of-truth record. Chart layers consume
/// [toChartDate] which maps to the slimmer [ThaiLunarDate] contract.
class ThaiLunarRecord {
  const ThaiLunarRecord({
    required this.lookupKey,
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
    required this.provenance,
    required this.sourceId,
    required this.sourceReference,
  });

  final ThaiLunarLookupKey lookupKey;

  /// Thai weekday อาทิตย์=1 … เสาร์=7 (from ปฏิทิน 100/150 ปี, not Dart weekday).
  final int weekdayNumber;

  /// Lunar month 1–12 (ธันวา=1 per พรหมชาติ).
  final int lunarMonthNumber;

  /// Zodiac year 1–12 (ชวด=1 … กุน=12) after ขึ้น 1 ค่ำ เดือน 5 boundary.
  final int zodiacYearIndex;

  final ThaiLunarRecordProvenance provenance;
  final String sourceId;
  final String sourceReference;

  ThaiLunarDate toChartDate() {
    return ThaiLunarDate(
      weekdayNumber: weekdayNumber,
      lunarMonthNumber: lunarMonthNumber,
      zodiacYearIndex: zodiacYearIndex,
      source: _mapSource(provenance),
    );
  }

  static ThaiLunarDateSource _mapSource(ThaiLunarRecordProvenance provenance) {
    return switch (provenance) {
      ThaiLunarRecordProvenance.verifiedGoldenCase =>
        ThaiLunarDateSource.verifiedLookup,
      ThaiLunarRecordProvenance.embeddedDataset =>
        ThaiLunarDateSource.embeddedDataset,
      ThaiLunarRecordProvenance.generated => ThaiLunarDateSource.generated,
    };
  }
}
