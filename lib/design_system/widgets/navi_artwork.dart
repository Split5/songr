import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// One rounded artwork surface with the single neutral fallback the design
/// system allows: a raised graphite square carrying a tertiary glyph. Pass
/// the loaded image as [child]; the fallback paints whenever there is none.
///
/// [coverArt] is the server art id the caller already has. It is kept on the
/// widget so a builder can hand it straight through and so callers can key
/// or label the artwork by it; the fallback is selected by a missing [child].
class NaviArtwork extends StatelessWidget {
  const NaviArtwork({
    super.key,
    this.coverArt,
    this.child,
    required this.fallback,
    this.size,
    this.radius = NaviRadii.row,
  });

  final String? coverArt;
  final Widget? child;
  final IconData fallback;

  /// Side length of the square. When null the artwork takes the size its
  /// parent gives it (the fallback fills bounded parents and shrinks to its
  /// glyph in unbounded ones, so it is safe as a list-tile leading).
  final double? size;

  /// Corner radius; pass 0 when the caller clips the artwork itself.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    Widget content = child ?? _Fallback(icon: fallback, side: size);
    if (size != null) {
      content = SizedBox.square(dimension: size, child: content);
    }
    if (radius <= 0) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

/// The neutral fallback. The glyph scales with the square it fills (72 pt on
/// the 310 pt player artwork, ~60 pt on a 144 pt card, ~22 pt in a 52 pt row
/// leading) so a missing cover never reads as a tiny icon lost in a large
/// graphite surface.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon, this.side});

  final IconData icon;

  /// Known side length; when null it is measured from the parent's bounds.
  final double? side;

  @override
  Widget build(BuildContext context) {
    final side = this.side;
    if (side != null) return _paint(side);
    return LayoutBuilder(
      builder: (context, constraints) => _paint(_boundedSide(constraints)),
    );
  }

  Widget _paint(double? side) => ColoredBox(
    color: NaviColors.surfaceRaised,
    child: Center(
      child: Icon(
        icon,
        size: side == null ? null : (side * 0.42).clamp(14, 72),
        color: NaviColors.textTertiary,
      ),
    ),
  );
}

/// The side the fallback will fill, or null when the parent gives no bound
/// at all (then the theme's default glyph size applies).
double? _boundedSide(BoxConstraints constraints) {
  final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
  final height = constraints.hasBoundedHeight ? constraints.maxHeight : null;
  if (width == null) return height;
  if (height == null) return width;
  return math.min(width, height);
}
