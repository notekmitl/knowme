/// Placeholder for future embedded ปฏิทิน 100/150 ปี asset dataset.
///
/// **NOT POPULATED in Infrastructure V1** — no fake data.
/// Acquisition plan: `docs/THAI_LUNAR_DATASET_ACQUISITION_V1.md`
/// JSON Schema: [thai_lunar_dataset_schema_v1.json]
///
/// Planned format (V1.2+):
/// ```json
/// {
///   "schemaVersion": 1,
///   "source": "ปฏิทิน 100 ปี (licensed export)",
///   "coverage": { "start": "1900-01-01", "end": "2100-12-31" },
///   "entries": [
///     {
///       "key": "1972-04-04 02:00",
///       "weekdayNumber": 2,
///       "lunarMonthNumber": 5,
///       "zodiacYearIndex": 1,
///       "waxingDay": 5,
///       "phase": "waning"
///     }
///   ]
/// }
/// ```
abstract final class ThaiLunarEmbeddedDataset {
  static const assetPath = 'assets/thai_astrology/lunar/thai_lunar_1900_2100.json';

  static const populateStatus =
      'PENDING — requires licensed ปฏิทิน 100/150 ปี data export';
}
