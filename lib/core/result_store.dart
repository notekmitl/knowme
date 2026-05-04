class TestResult {
  final String testId;
  final Map<String, dynamic> data;

  TestResult({required this.testId, required this.data});
}

class ResultStore {
  final List<TestResult> results = [];

  void add(TestResult result) {
    results.removeWhere((r) => r.testId == result.testId);
    results.add(result);
  }
}
