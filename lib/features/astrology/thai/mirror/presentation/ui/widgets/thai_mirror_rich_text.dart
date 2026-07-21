import 'package:flutter/material.dart';

/// Renders body copy with lightweight inline emphasis.
///
/// Supports `**bold**` markers, which are shown as a heavier weight in an
/// accent colour to guide the reader's attention. Everything else renders as
/// normal paragraph text. Presentation-only — no copy meaning is altered.
class ThaiMirrorRichText extends StatelessWidget {
  const ThaiMirrorRichText(
    this.text, {
    super.key,
    required this.baseStyle,
    this.emphasisColor,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle baseStyle;
  final Color? emphasisColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final accent = emphasisColor ?? Theme.of(context).colorScheme.primary;
    return Text.rich(
      TextSpan(children: _spans(text, baseStyle, accent)),
      textAlign: textAlign,
    );
  }

  static List<InlineSpan> _spans(
    String text,
    TextStyle baseStyle,
    Color accent,
  ) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var index = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      );
      index = match.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }
    if (spans.isEmpty) spans.add(TextSpan(text: text));
    return [TextSpan(style: baseStyle, children: spans)];
  }
}
