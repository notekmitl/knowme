import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/application/home_load_timing.dart';

void main() {
  test('HomeLoadTiming records shell before total completion', () {
    final timing = HomeLoadTiming();
    timing.markShell();
    timing.markNarrative();
    timing.markEnrich();
    timing.markTotal();

    expect(timing.shellMs, isNotNull);
    expect(timing.totalMs, isNotNull);
    expect(timing.shellMs!, lessThanOrEqualTo(timing.totalMs!));
  });
}
