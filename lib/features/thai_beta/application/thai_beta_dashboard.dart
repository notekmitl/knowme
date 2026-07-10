import '../domain/thai_beta_record.dart';

/// A counted free-text theme (a frequent word across an open-text field).
class ThaiBetaTextTheme {
  const ThaiBetaTextTheme(this.term, this.count);
  final String term;
  final int count;
}

/// Deterministic, pure aggregates over a set of beta submissions for the
/// internal dashboard. No I/O — feed it the records loaded by [ThaiBetaStore].
class ThaiBetaDashboard {
  const ThaiBetaDashboard({
    required this.total,
    required this.averageRating,
    required this.ratingDistribution,
    required this.mostAccurateTopics,
    required this.mostCommonComplaints,
    required this.mostRequestedImprovements,
  });

  final int total;
  final double averageRating;

  /// Stars (1–5) → count. Always contains keys 1..5.
  final Map<int, int> ratingDistribution;

  final List<ThaiBetaTextTheme> mostAccurateTopics;
  final List<ThaiBetaTextTheme> mostCommonComplaints;
  final List<ThaiBetaTextTheme> mostRequestedImprovements;

  factory ThaiBetaDashboard.fromRecords(List<ThaiBetaRecord> records) {
    final distribution = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    var ratingSum = 0;
    var ratingCount = 0;
    for (final r in records) {
      final rating = r.rating;
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
        ratingSum += rating;
        ratingCount++;
      }
    }

    return ThaiBetaDashboard(
      total: records.length,
      averageRating: ratingCount == 0 ? 0 : ratingSum / ratingCount,
      ratingDistribution: distribution,
      mostAccurateTopics:
          _topTerms(records.map((r) => r.feedback.mostAccurate)),
      mostCommonComplaints:
          _topTerms(records.map((r) => r.feedback.leastAccurate)),
      mostRequestedImprovements:
          _topTerms(records.map((r) => r.feedback.wantMoreAnalysis)),
    );
  }

  static List<ThaiBetaTextTheme> _topTerms(Iterable<String> texts,
      {int top = 8}) {
    final counts = <String, int>{};
    for (final text in texts) {
      final seen = <String>{};
      for (final token in _tokenize(text)) {
        // Count each term once per submission (presence, not raw frequency).
        if (seen.add(token)) {
          counts[token] = (counts[token] ?? 0) + 1;
        }
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return entries
        .take(top)
        .map((e) => ThaiBetaTextTheme(e.key, e.value))
        .toList();
  }

  /// Splits text on whitespace/punctuation and drops very short tokens and a
  /// small Thai/English stopword set. Lightweight on purpose — this is an
  /// internal signal, not NLP.
  static Iterable<String> _tokenize(String text) {
    final lowered = text.toLowerCase();
    final rawTokens = lowered.split(RegExp(r'[\s,.;:!?()\[\]"”“\-/]+'));
    return rawTokens.where((t) {
      final term = t.trim();
      if (term.length < 2) return false;
      if (_stopwords.contains(term)) return false;
      return true;
    });
  }

  static const Set<String> _stopwords = {
    // English
    'the', 'and', 'for', 'are', 'was', 'but', 'not', 'you', 'your', 'with',
    'this', 'that', 'have', 'has', 'had', 'all', 'any', 'can', 'about', 'very',
    'really', 'just', 'too', 'because', 'they', 'them', 'from', 'more', 'most',
    // Thai (common particles/pronouns)
    'และ', 'ที่', 'เป็น', 'ของ', 'ได้', 'ให้', 'มาก', 'จะ', 'ก็', 'ใน',
    'กับ', 'แต่', 'นี้', 'นั้น', 'ว่า', 'คือ', 'มี', 'ไม่', 'ฉัน', 'ผม',
    'ดิฉัน', 'เรา', 'คุณ', 'ตัว', 'อยาก', 'ครับ', 'ค่ะ', 'นะ', 'เลย',
  };
}
