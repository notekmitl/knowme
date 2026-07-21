import '../datasets/thai_lunar_embedded_dataset.dart';
import '../datasets/thai_lunar_verified_entries.dart';
import '../models/thai_lunar_dataset_manifest.dart';
import '../models/thai_lunar_lookup_key.dart';
import '../models/thai_lunar_record.dart';

/// Read-only access to Thai lunar lookup data.
abstract interface class ThaiLunarRepository {
  ThaiLunarDatasetManifest get manifest;

  /// Returns a record for [key], or null if not in current coverage.
  ThaiLunarRecord? lookup(ThaiLunarLookupKey key);

  /// All entries currently loaded (for validation / audit).
  Iterable<ThaiLunarRecord> get allEntries;
}

/// Default repository — verified golden cases only (Infrastructure V1).
class InMemoryThaiLunarRepository implements ThaiLunarRepository {
  InMemoryThaiLunarRepository({
    Map<String, ThaiLunarRecord>? entriesByCanonicalKey,
  }) : _entries = entriesByCanonicalKey ?? ThaiLunarVerifiedEntries.asCanonicalMap();

  final Map<String, ThaiLunarRecord> _entries;

  static final ThaiLunarDatasetManifest _manifest = ThaiLunarDatasetManifest(
    infrastructureVersion: 'v1',
    schemaVersion: 1,
    entryCount: ThaiLunarVerifiedEntries.all.length,
    coverageStatus: ThaiLunarCoverageStatus.goldenCasesOnly,
    primaryDataSource: null,
    notes: [
      'Only GC-04 and GC-05 verified entries loaded',
      'Full 1900-2100 coverage pending licensed dataset (V1.2)',
      ThaiLunarEmbeddedDataset.populateStatus,
    ],
  );

  @override
  ThaiLunarDatasetManifest get manifest => _manifest;

  @override
  ThaiLunarRecord? lookup(ThaiLunarLookupKey key) {
    return _entries[key.canonical];
  }

  @override
  Iterable<ThaiLunarRecord> get allEntries => _entries.values;
}
