import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'thai_mirror_golden_path.dart';

void main() {
  test('keeps the accepted Linux golden path unchanged', () {
    expect(
      thaiMirrorGoldenPath(
        'screenshots/profile_a_hero.png',
        operatingSystem: 'linux',
      ),
      'screenshots/profile_a_hero.png',
    );
  });

  test('inserts the exact Windows baseline directory', () {
    expect(
      thaiMirrorGoldenPath(
        'screenshots/profile_a_hero.png',
        operatingSystem: 'windows',
      ),
      'screenshots/windows/profile_a_hero.png',
    );
  });

  test('supports a golden filename without a parent directory', () {
    expect(
      thaiMirrorGoldenPath('report.png', operatingSystem: 'windows'),
      'windows/report.png',
    );
  });

  test(
    'every Windows Thai Mirror golden matches a Linux filename and size',
    () {
      final groups = <({String directory, int expectedCount})>[
        (directory: 'test/goldens', expectedCount: 1),
        (
          directory: 'test/validation/thai_mirror_consumer_ux/screenshots',
          expectedCount: 29,
        ),
        (
          directory: 'test/validation/thai_mirror_qa_harness/screenshots',
          expectedCount: 144,
        ),
      ];

      var total = 0;
      for (final group in groups) {
        final directory = Directory(group.directory);
        final windowsDirectory = Directory('${group.directory}/windows');
        final windowsFiles =
            windowsDirectory
                .listSync()
                .whereType<File>()
                .where((file) => file.path.toLowerCase().endsWith('.png'))
                .toList()
              ..sort((left, right) => left.path.compareTo(right.path));

        expect(
          windowsFiles,
          hasLength(group.expectedCount),
          reason: '${group.directory} must retain its complete Windows set',
        );
        total += windowsFiles.length;

        for (final windowsFile in windowsFiles) {
          final fileName = windowsFile.uri.pathSegments.last;
          final linuxFile = File('${directory.path}/$fileName');
          expect(
            linuxFile.existsSync(),
            isTrue,
            reason: '$fileName must map to an accepted Linux baseline',
          );
          expect(
            _pngSize(windowsFile),
            _pngSize(linuxFile),
            reason: '$fileName may differ only in platform rasterization',
          );
        }
      }

      expect(total, 174);
    },
  );
}

({int width, int height}) _pngSize(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(24), reason: file.path);
  final data = ByteData.sublistView(bytes, 16, 24);
  return (
    width: data.getUint32(0, Endian.big),
    height: data.getUint32(4, Endian.big),
  );
}
