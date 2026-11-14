import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// Loading placeholder that fades in once and then holds still — no shimmer
/// loop, in line with the motion rules.
class NaviSkeleton extends StatelessWidget {
  const NaviSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius = NaviRadii.row,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = NaviMotion.reduceMotion(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? 0.72 : 0.35, end: 0.72),
      duration: reduceMotion ? Duration.zero : NaviMotion.page,
      curve: NaviMotion.curve,
      builder: (context, opacity, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: NaviColors.surfaceRaised.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
