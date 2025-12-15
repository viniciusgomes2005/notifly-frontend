import 'package:flutter/material.dart';

class FormattedMessageText extends StatelessWidget {
  const FormattedMessageText({
    super.key,
    required this.text,
    required this.style,
    required this.isDark,
  });

  final String text;
  final TextStyle style;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = style;
    return SelectableText.rich(
      TextSpan(children: _InlineMdParser.parse(text, base, isDark: isDark)),
    );
  }
}

class _InlineMdParser {
  static List<InlineSpan> parse(
    String input,
    TextStyle base, {
    required bool isDark,
  }) {
    return _parseInternal(input, base, isDark);
  }

  static List<InlineSpan> _parseInternal(
    String s,
    TextStyle style,
    bool isDark,
  ) {
    final spans = <InlineSpan>[];
    final buf = StringBuffer();

    void flushBuf() {
      if (buf.isEmpty) return;
      spans.add(TextSpan(text: buf.toString(), style: style));
      buf.clear();
    }

    int i = 0;
    while (i < s.length) {
      // Escape simples: \* \` \~ \_ \[ \]
      if (s.codeUnitAt(i) == 92 /* '\' */ && i + 1 < s.length) {
        buf.write(s[i + 1]);
        i += 2;
        continue;
      }

      // Inline code: `...`
      if (_startsWithAt(s, i, '`')) {
        final end = s.indexOf('`', i + 1);
        if (end != -1) {
          flushBuf();
          final codeText = s.substring(i + 1, end);
          spans.add(_codeSpan(codeText, style, isDark));
          i = end + 1;
          continue;
        }
      }

      // Bold: **...**
      if (_startsWithAt(s, i, '**')) {
        final end = s.indexOf('**', i + 2);
        if (end != -1) {
          flushBuf();
          final inner = s.substring(i + 2, end);
          spans.add(
            TextSpan(
              style: style.copyWith(fontWeight: FontWeight.w700),
              children: _parseInternal(
                inner,
                style.copyWith(fontWeight: FontWeight.w700),
                isDark,
              ),
            ),
          );
          i = end + 2;
          continue;
        }
      }

      // Strikethrough: ~~...~~
      if (_startsWithAt(s, i, '~~')) {
        final end = s.indexOf('~~', i + 2);
        if (end != -1) {
          flushBuf();
          final inner = s.substring(i + 2, end);
          spans.add(
            TextSpan(
              style: style.copyWith(decoration: TextDecoration.lineThrough),
              children: _parseInternal(
                inner,
                style.copyWith(decoration: TextDecoration.lineThrough),
                isDark,
              ),
            ),
          );
          i = end + 2;
          continue;
        }
      }

      // Italic: *...*  (evita conflitar com **)
      if (_startsWithAt(s, i, '*') && !_startsWithAt(s, i, '**')) {
        final end = s.indexOf('*', i + 1);
        if (end != -1) {
          flushBuf();
          final inner = s.substring(i + 1, end);
          spans.add(
            TextSpan(
              style: style.copyWith(fontStyle: FontStyle.italic),
              children: _parseInternal(
                inner,
                style.copyWith(fontStyle: FontStyle.italic),
                isDark,
              ),
            ),
          );
          i = end + 1;
          continue;
        }
      }

      // Link: [texto](url)
      if (_startsWithAt(s, i, '[')) {
        final closeBracket = s.indexOf(']', i + 1);
        if (closeBracket != -1 &&
            closeBracket + 1 < s.length &&
            s[closeBracket + 1] == '(') {
          final closeParen = s.indexOf(')', closeBracket + 2);
          if (closeParen != -1) {
            flushBuf();
            final label = s.substring(i + 1, closeBracket);
            final url = s.substring(closeBracket + 2, closeParen);

            // Aqui eu só deixo com "cara de link".
            // Se você quiser abrir no clique, dá para plugar url_launcher depois.
            spans.add(
              TextSpan(
                text: label,
                style: style.copyWith(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

            // Opcional: mostrar a URL pequena ao lado (remova se não quiser)
            spans.add(
              TextSpan(
                text: ' ($url)',
                style: style.copyWith(
                  fontSize: (style.fontSize ?? 14) - 2,
                  color: (style.color ?? const Color(0xFF000000)).withOpacity(
                    0.75,
                  ),
                ),
              ),
            );

            i = closeParen + 1;
            continue;
          }
        }
      }

      // Normal char
      buf.write(s[i]);
      i++;
    }

    flushBuf();
    return spans;
  }

  static bool _startsWithAt(String s, int index, String token) {
    if (index + token.length > s.length) return false;
    return s.substring(index, index + token.length) == token;
  }

  static InlineSpan _codeSpan(String code, TextStyle base, bool isDark) {
    final bg = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final fg = base.color ?? (isDark ? Colors.white : Colors.black87);

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          code,
          style: base.copyWith(fontFamily: 'monospace', color: fg),
        ),
      ),
    );
  }
}
