import 'package:flutter_test/flutter_test.dart';

import 'analysis/consumer_ux_validation_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runs consumer UX validation and writes report', () async {
    await ConsumerUxValidationRunner.runAndWrite();
  });
}
