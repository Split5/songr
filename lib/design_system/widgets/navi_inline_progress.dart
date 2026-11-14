import 'package:flutter/cupertino.dart';

import '../navi_design_tokens.dart';

/// Small indeterminate spinner for in-flow loading (a list tail, a section
/// refreshing). Replaces thin linear bars, which read as page progress.
class NaviInlineProgress extends StatelessWidget {
  const NaviInlineProgress({
    super.key,
    this.padding = const EdgeInsets.all(NaviSpacing.md),
    this.radius = 9,
  });

  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Center(
      child: CupertinoActivityIndicator(
        radius: radius,
        color: NaviColors.textSecondary,
      ),
    ),
  );
}
