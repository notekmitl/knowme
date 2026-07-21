/// Structured failure from KnowMe astrology HTTP APIs (BaZi / Western).
class AstrologyApiFailure implements Exception {
  const AstrologyApiFailure({
    required this.endpoint,
    required this.message,
    this.statusCode,
    this.responseBody,
    this.cause,
  });

  final String endpoint;
  final String message;
  final int? statusCode;
  final String? responseBody;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('AstrologyApiFailure($endpoint): $message');
    if (statusCode != null) {
      buffer.write(' [HTTP $statusCode]');
    }
    if (responseBody != null && responseBody!.trim().isNotEmpty) {
      final body = responseBody!.length > 300
          ? '${responseBody!.substring(0, 300)}...'
          : responseBody;
      buffer.write(' body=$body');
    }
    if (cause != null) {
      buffer.write(' cause=$cause');
    }
    return buffer.toString();
  }
}
