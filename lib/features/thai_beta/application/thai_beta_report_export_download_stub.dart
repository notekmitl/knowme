import 'dart:typed_data';

/// Non-web: no browser download; caller should use print/share fallback.
Future<bool> downloadBytesAsFile({
  required Uint8List bytes,
  required String filename,
  String mimeType = 'application/pdf',
}) async {
  return false;
}
