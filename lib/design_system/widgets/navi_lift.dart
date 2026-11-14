import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// Press-state scale kept behind the original API. The true-black direction
/// has no resting shadows; visual separation comes from tone and rules.
class NaviLift extends StatelessWidget {
  const NaviLift({
    super.key,
    required this.child,
    this.elevated = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(NaviRadii.card)),
    this.restingScale = 1,
    this.duration = NaviMotion.standard,
  }) : assert(restingScale > 0 && restingScale <= 1);

  final Widget child;
  final bool elevated;
  final BorderRadius borderRadius;

  /// Scale applied while resting. 1 keeps geometry stable; 0.985 is the
  /// strongest compression the design system allows.
  final double restingScale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = NaviMotion.reduceMotion(context)
        ? Duration.zero
        : duration;
    return AnimatedScale(
      scale: elevated ? 1 : restingScale,
      duration: effectiveDuration,
      curve: NaviMotion.curve,
      child: AnimatedContainer(
        duration: effectiveDuration,
        curve: NaviMotion.curve,
        decoration: BoxDecoration(borderRadius: borderRadius),
        child: child,
      ),
    );
  }
}
