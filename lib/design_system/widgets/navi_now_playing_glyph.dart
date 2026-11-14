import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// Three thin bars that mark the song at the playhead. This is the one
/// ambient animation the design system allows because it communicates state:
/// the bars sway slowly while [playing] and freeze when paused or when the
/// system asks for reduced motion.
class NaviNowPlayingGlyph extends StatefulWidget {
  const NaviNowPlayingGlyph({
    super.key,
    required this.playing,
    this.size = 16,
    this.color = NaviColors.accent,
  });

  final bool playing;
  final double size;
  final Color color;

  /// One full sway; slow enough to never draw the eye.
  static const period = Duration(milliseconds: 900);

  @override
  State<NaviNowPlayingGlyph> createState() => _NaviNowPlayingGlyphState();
}

class _NaviNowPlayingGlyphState extends State<NaviNowPlayingGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: NaviNowPlayingGlyph.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant NaviNowPlayingGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _sync();
  }

  void _sync() {
    final animate = widget.playing && !NaviMotion.reduceMotion(context);
    if (animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _BarsPainter(
          phase: _controller.value,
          playing: widget.playing,
          color: widget.color,
        ),
      ),
    ),
  );
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.phase,
    required this.playing,
    required this.color,
  });

  final double phase;
  final bool playing;
  final Color color;

  static const _resting = [0.42, 0.7, 0.5];
  static const _offsets = [0.0, 0.33, 0.66];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.16;
    final gap = size.width / 3;
    for (var index = 0; index < 3; index++) {
      // Low amplitude: the bars breathe around their resting height rather
      // than bouncing between the extremes of an equalizer.
      final sway = playing
          ? math.sin((phase + _offsets[index]) * 2 * math.pi) * 0.16
          : 0.0;
      final height = size.height * (_resting[index] + sway).clamp(0.2, 0.95);
      final x = gap * index + gap / 2;
      final bottom = size.height - paint.strokeWidth / 2;
      canvas.drawLine(
        Offset(x, bottom),
        Offset(x, bottom - height + paint.strokeWidth / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.playing != playing ||
      oldDelegate.color != color;
}
