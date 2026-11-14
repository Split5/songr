import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';

/// Explicit empty, offline or error state: a quiet glyph, a title, an
/// optional hint and at most one action.
class NaviEmptyState extends StatelessWidget {
  const NaviEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(NaviSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: NaviColors.textTertiary),
          const SizedBox(height: NaviSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hint case final hint?) ...[
            const SizedBox(height: NaviSpacing.xs),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (actionLabel case final label?) ...[
            const SizedBox(height: NaviSpacing.md),
            FilledButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    ),
  );
}
