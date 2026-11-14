import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';
import '../navi_theme.dart';
import 'navi_lift.dart';

/// The primary pair on a collection: a white Play pill and a graphite
/// Shuffle pill. Both rest on a [NaviLift] and press down while touched —
/// one of the few places depth is allowed because it signals pressability.
class NaviPlayShufflePills extends StatelessWidget {
  const NaviPlayShufflePills({
    super.key,
    required this.onPlay,
    required this.onShuffle,
    required this.playLabel,
    required this.shuffleLabel,
    this.extra,
  });

  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final String playLabel;
  final String shuffleLabel;

  /// Optional third control rendered after the pair.
  final Widget? extra;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _LiftedPill(
        enabled: onPlay != null,
        child: FilledButton.icon(
          onPressed: onPlay,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(playLabel),
        ),
      ),
      const SizedBox(width: NaviSpacing.sm),
      _LiftedPill(
        enabled: onShuffle != null,
        child: FilledButton.tonalIcon(
          style: NaviTheme.tonalButtonStyle,
          onPressed: onShuffle,
          icon: const Icon(Icons.shuffle_rounded),
          label: Text(shuffleLabel),
        ),
      ),
      if (extra case final extra?) ...[
        const SizedBox(width: NaviSpacing.sm),
        extra,
      ],
    ],
  );
}

/// Lift around a real button. A [Listener] observes the pointer without
/// entering the gesture arena, so the button keeps its own tap handling
/// while the shadow presses down under the finger.
class _LiftedPill extends StatefulWidget {
  const _LiftedPill({required this.child, required this.enabled});

  final Widget child;
  final bool enabled;

  @override
  State<_LiftedPill> createState() => _LiftedPillState();
}

class _LiftedPillState extends State<_LiftedPill> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: NaviLift(
        elevated: !_pressed,
        borderRadius: const BorderRadius.all(Radius.circular(23)),
        child: widget.child,
      ),
    );
  }
}
