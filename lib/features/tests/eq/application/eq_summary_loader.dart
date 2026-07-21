import '../data/eq_firestore_repository.dart';
import '../domain/eq_models.dart';
import '../domain/eq_summary_models.dart';
import '../domain/eq_test_type.dart';

/// Loads EQ mini results from `users/{uid}/results/eq_*` (read-only).
class EqSummaryLoader {
  EqSummaryLoader({EqFirestoreRepository? repository})
      : _repository = repository ?? EqFirestoreRepositoryImpl();

  final EqFirestoreRepository _repository;

  Future<bool> isUnlocked(String uid) async {
    final input = await loadInput(uid);
    return input.hasAllSix;
  }

  Future<EqSummaryInput> loadInput(String uid) async {
    final results = <EqTestType, EqResultSummary>{};
    for (final type in EqHomeModuleTypes.all) {
      final result = await _repository.loadLatestResult(uid, type.testId);
      if (result != null) {
        results[type] = result;
      }
    }
    return EqSummaryInput(resultsByType: results);
  }
}
