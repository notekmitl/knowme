import 'dart:convert';
import 'package:http/http.dart' as http;

class AscendantApiService {
  /// ⭐ ใช้ API ฟรีตัวอย่าง (สามารถเปลี่ยนได้)
  /// ตอนนี้ใช้ dummy endpoint ก่อน
  /// คุณสามารถเปลี่ยนเป็น backend ของคุณเองภายหลัง

  Future<dynamic> getAscendant({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      /// แยกวันเวลา
      final year = birthDateTime.year;
      final month = birthDateTime.month;
      final day = birthDateTime.day;
      final hour = birthDateTime.hour;
      final minute = birthDateTime.minute;

      /// ⭐ ตัวอย่าง API endpoint
      final url = Uri.parse(
        "https://api.example.com/ascendant"
        "?year=$year"
        "&month=$month"
        "&day=$day"
        "&hour=$hour"
        "&minute=$minute"
        "&lat=$latitude"
        "&lng=$longitude",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// คาดว่า API จะส่ง:
        /// { "ascendant": "Aries" }

        return data["ascendant"];
      } else {
        return null;
      }
    } catch (e) {
      print("Ascendant API error: $e");
      return null;
    }
  }
}
