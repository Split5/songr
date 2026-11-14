class LrcLine {
  const LrcLine({required this.text, this.start});

  final String text;
  final Duration? start;
}

class LrcDocument {
  const LrcDocument(this.lines);

  final List<LrcLine> lines;

  bool get isSynced => lines.any((line) => line.start != null);

  /// `[offset:+500]` shifts every line, positive values later, exactly like
  /// the offset control most lyric players expose. Ignoring it made lines
  /// written with an offset play consistently early or late.
  static final RegExp _offsetTag = RegExp(
    r'\[offset:\s*([+-]?\d+)\s*\]',
    caseSensitive: false,
  );

  factory LrcDocument.parse(String source) {
    final result = <LrcLine>[];
    final offsetMatch = _offsetTag.firstMatch(source);
    final offset = Duration(
      milliseconds: offsetMatch == null ? 0 : int.parse(offsetMatch.group(1)!),
    );
    final timestamp = RegExp(r'\[(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?\]');
    for (final raw in source.split(RegExp(r'\r?\n'))) {
      final matches = timestamp.allMatches(raw).toList(growable: false);
      final text = raw.replaceAll(timestamp, '').trim();
      if (matches.isEmpty) {
        // Ignore common LRC metadata while retaining ordinary unsynced lines.
        if (RegExp(r'^\[[a-zA-Z]+:').hasMatch(raw.trim())) continue;
        if (text.isNotEmpty) result.add(LrcLine(text: text));
        continue;
      }
      for (final match in matches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final fraction = match.group(3);
        final milliseconds = fraction == null
            ? 0
            : fraction.length == 1
            ? int.parse(fraction) * 100
            : fraction.length == 2
            ? int.parse(fraction) * 10
            : int.parse(fraction.substring(0, 3));
        result.add(
          LrcLine(
            text: text,
            start: _shift(
              Duration(
                minutes: minutes,
                seconds: seconds,
                milliseconds: milliseconds,
              ),
              offset,
            ),
          ),
        );
      }
    }
    if (result.any((line) => line.start != null)) {
      result.sort((a, b) {
        if (a.start == null) return 1;
        if (b.start == null) return -1;
        return a.start!.compareTo(b.start!);
      });
    }
    return LrcDocument(List.unmodifiable(result));
  }

  /// An offset can push a timestamp before the start of the song; the file
  /// then simply means "as early as possible".
  static Duration _shift(Duration start, Duration offset) {
    final shifted = start + offset;
    return shifted.isNegative ? Duration.zero : shifted;
  }

  int activeLine(Duration position) {
    var active = -1;
    for (var index = 0; index < lines.length; index++) {
      final start = lines[index].start;
      if (start == null || start > position) break;
      active = index;
    }
    return active;
  }
}
