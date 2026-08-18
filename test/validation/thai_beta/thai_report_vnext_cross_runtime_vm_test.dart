import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/thai_report_vnext_cross_runtime_manifest.dart';

void main() {
  test('writes deterministic VM shared-report manifest', () {
    final first = encodeThaiReportVnextCrossRuntimeManifest();
    final second = encodeThaiReportVnextCrossRuntimeManifest();
    expect(second, first);
    final output = Platform.environment['KNOWME_REPORT_VNEXT_VM_MANIFEST'];
    if (output != null && output.isNotEmpty) {
      File(output).writeAsStringSync(first, flush: true);
    }
  });
}
