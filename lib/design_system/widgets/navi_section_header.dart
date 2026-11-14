import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// Shelf or list heading at the page inset. Pass [onTap] for a "see all"
/// affordance; the chevron appears and the whole header becomes tappable.
class NaviSectionHeader extends StatelessWidget {
  const NaviSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.md,
      NaviSpacing.page,
      NaviSpacing.sm,
    ),
  });

  final String title;
  final Widget? action;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ?action,
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: NaviSpacing.xxs),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: NaviColors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return header;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: header,
      ),
    );
  }
}
