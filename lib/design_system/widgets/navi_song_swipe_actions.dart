import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../navi_design_tokens.dart';

class NaviSwipeUndo {
  const NaviSwipeUndo({required this.message, this.undo});

  final String message;
  final Future<void> Function()? undo;
}

class NaviSwipeAction {
  const NaviSwipeAction({
    required this.icon,
    required this.label,
    required this.onInvoke,
    this.color = NaviColors.accentViolet,
  });

  final IconData icon;
  final String label;
  final Future<NaviSwipeUndo?> Function() onInvoke;
  final Color color;
}

/// Stable song-row swipe behavior built on Flutter's own gesture arbitration.
/// The row is never dismissed: right executes one reversible quick action,
/// while left opens the same song menu as the row's long-press ([onMore]).
class NaviSongSwipeActions extends StatelessWidget {
  const NaviSongSwipeActions({
    super.key,
    required this.dismissibleKey,
    required this.child,
    this.quickAction,
    this.onMore,
  });

  final Key dismissibleKey;
  final Widget child;
  final NaviSwipeAction? quickAction;

  /// Opens the shared song menu; the same callback the row's … button uses.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    if (quickAction == null && onMore == null) return child;
    return Dismissible(
      key: dismissibleKey,
      direction: quickAction != null && onMore != null
          ? DismissDirection.horizontal
          : quickAction != null
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.42,
        DismissDirection.endToStart: 0.34,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final action = quickAction;
          if (action != null) await _invoke(context, action);
        } else {
          onMore?.call();
        }
        return false;
      },
      background: _SwipeBackdrop(
        alignment: Alignment.centerLeft,
        color: quickAction?.color ?? NaviColors.accent,
        icon: quickAction?.icon ?? Icons.playlist_add_rounded,
        label: quickAction?.label ?? '',
      ),
      secondaryBackground: _SwipeBackdrop(
        alignment: Alignment.centerRight,
        color: NaviColors.accentViolet,
        icon: Icons.more_horiz_rounded,
        label: AppLocalizations.of(context).swipeActionsHint,
      ),
      child: child,
    );
  }

  Future<void> _invoke(BuildContext context, NaviSwipeAction action) async {
    final result = await action.onInvoke();
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.message),
        action: result.undo == null
            ? null
            : SnackBarAction(
                label: AppLocalizations.of(context).undo,
                onPressed: () => unawaited(result.undo!()),
              ),
      ),
    );
  }
}

class _SwipeBackdrop extends StatelessWidget {
  const _SwipeBackdrop({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color.withValues(alpha: 0.22),
    child: Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alignment == Alignment.centerRight) ...[
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: NaviSpacing.xs),
            ],
            Icon(icon, color: color),
            if (alignment == Alignment.centerLeft) ...[
              const SizedBox(width: NaviSpacing.xs),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ],
        ),
      ),
    ),
  );
}
