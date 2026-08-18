import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'thai_beta_cross_runtime_manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'writes exact deterministic 300-profile and canonical manifest',
    () async {
      final runLabel = Platform.environment['KNOWME_CROSS_RUNTIME_RUN'] ?? 'vm';
      final manifest = await buildCrossRuntimeManifest(runLabel: runLabel);
      final summary = manifest['summary']! as Map<String, Object?>;
      expect(summary['executed'], 300);
      expect(summary['known'], 225);
      expect(summary['unknown'], 75);
      expect(summary['unknownOmissionPass'], 75);
      expect(summary['uniqueReports'], 300);
      expect(summary['uniqueNarratives'], 300);
      final canonical = manifest['canonical']! as List<Map<String, Object?>>;
      expect(canonical, hasLength(5));
      for (final fixture in canonical) {
        expect(
          fixture['frozenAcceptedExact'],
          isTrue,
          reason: '${fixture['fixture']} frozen',
        );
        expect(
          fixture['frozenWebPdfExact'],
          isTrue,
          reason: '${fixture['fixture']} frozen PDF',
        );
        expect(
          fixture['liveWebPdfExact'],
          isTrue,
          reason: '${fixture['fixture']} live PDF',
        );
        expect(
          fixture['liveRepeatExact'],
          isTrue,
          reason: '${fixture['fixture']} repeat',
        );
        expect(
          fixture['unknownFailClosed'],
          isTrue,
          reason: '${fixture['fixture']} omission',
        );
      }
      final output = Platform.environment['KNOWME_CROSS_RUNTIME_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        File(output)
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(
            '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
            flush: true,
          );
      }
      // Raw logs retain a compact identity without printing the full manifest.
      // ignore: avoid_print
      print(
        jsonEncode({
          'runtime': manifest['runtime'],
          'runLabel': runLabel,
          'summary': summary,
          'canonical': canonical,
        }),
      );
    },
    timeout: const Timeout(Duration(minutes: 30)),
  );
}
