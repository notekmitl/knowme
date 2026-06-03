import 'package:knowme/services/mbti/mbti_function_stack.dart';

/// Picks up to two MBTI types whose canonical stacks best match the user's top four.
List<String> stackHintsForTopFour(List<String> userTopFour) {
  if (userTopFour.isEmpty) return const [];

  final ranked = mbtiFunctionStacks.entries.map((entry) {
    final score = _overlapScore(userTopFour, entry.value);
    return MapEntry(entry.key, score);
  }).toList()
    ..sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      if (byScore != 0) return byScore;
      return a.key.compareTo(b.key);
    });

  return ranked
      .where((e) => e.value > 0)
      .take(2)
      .map((e) => e.key)
      .toList();
}

int _overlapScore(List<String> userTopFour, List<String> stack) {
  var score = 0;
  for (var i = 0; i < userTopFour.length && i < 4; i++) {
    final pos = stack.indexOf(userTopFour[i]);
    if (pos < 0) continue;
    score += 4 - pos;
  }
  return score;
}
