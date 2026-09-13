import 'package:flutter/services.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_exporter.dart';

abstract final class BaziCompatibilityPdfAssets {
  static Future<BaziCompatibilityPdfFonts> load() async {
    return BaziCompatibilityPdfFonts(
      thaiRegular: await _bytes(
        'assets/fonts/noto_sans_thai/NotoSansThai-Regular.ttf',
      ),
      thaiBold: await _bytes(
        'assets/fonts/noto_sans_thai/NotoSansThai-Bold.ttf',
      ),
      cjkRegular: await _bytes(
        'assets/fonts/noto_sans_sc/NotoSansSC-Regular.ttf',
      ),
    );
  }

  static Future<Uint8List> _bytes(String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
