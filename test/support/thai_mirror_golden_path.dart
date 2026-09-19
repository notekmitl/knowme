import 'dart:io';

/// Keeps exact-pixel Thai Mirror baselines separate where the Flutter engine
/// delegates glyph rasterization differently on Windows and Linux.
///
/// Linux retains the accepted baseline path. Windows inserts a `windows`
/// directory beside it. Both platforms still use Flutter's strict comparator;
/// no tolerance, threshold, or skip is introduced.
String thaiMirrorGoldenPath(String path, {String? operatingSystem}) {
  final platform = operatingSystem ?? Platform.operatingSystem;
  if (platform != 'windows') return path;

  final separator = path.lastIndexOf('/');
  if (separator < 0) return 'windows/$path';
  return '${path.substring(0, separator)}/windows/'
      '${path.substring(separator + 1)}';
}
