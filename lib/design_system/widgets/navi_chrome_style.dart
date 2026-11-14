import 'package:flutter/widgets.dart';

/// User-tunable transparency shared by every persistent navigation surface.
///
/// Values describe transparency rather than opacity: `1.0` removes the tint
/// completely. Blur is controlled independently, so a fully transparent bar
/// can also be completely sharp.
class NaviChromeStyle extends InheritedWidget {
  const NaviChromeStyle({
    super.key,
    required this.topBarTransparency,
    this.topBarBlurSigma = defaultTopBarBlurSigma,
    required super.child,
  });

  static const defaultTopBarTransparency = 0.78;
  static const defaultTopBarBlurSigma = 10.0;
  static const minTopBarTransparency = 0.0;
  static const maxTopBarTransparency = 1.0;
  static const minBarBlurSigma = 0.0;
  static const maxBarBlurSigma = 90.0;

  final double topBarTransparency;
  final double topBarBlurSigma;

  double get topBarOpacity => 1 - topBarTransparency;

  static NaviChromeStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NaviChromeStyle>();

  static double topBarTransparencyOf(BuildContext context) =>
      maybeOf(context)?.topBarTransparency ?? defaultTopBarTransparency;

  static double topBarBlurSigmaOf(BuildContext context) =>
      maybeOf(context)?.topBarBlurSigma ?? defaultTopBarBlurSigma;

  @override
  bool updateShouldNotify(NaviChromeStyle oldWidget) =>
      topBarTransparency != oldWidget.topBarTransparency ||
      topBarBlurSigma != oldWidget.topBarBlurSigma;
}
