import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';
import 'navi_chrome_style.dart';
import 'navi_lift.dart';

export 'navi_lift.dart';

class NaviSliverHeader extends StatelessWidget {
  const NaviSliverHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.titleSpacing = NaviSpacing.page,
  });

  final Widget title;
  final List<Widget> actions;
  final double titleSpacing;

  @override
  Widget build(BuildContext context) {
    final transparency = NaviChromeStyle.topBarTransparencyOf(context);
    final blurSigma = NaviChromeStyle.topBarBlurSigmaOf(context);
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 44,
      titleSpacing: titleSpacing,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: SizedBox.expand(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: ColoredBox(
              key: const ValueKey('navi-header-translucent-surface'),
              color: NaviColors.canvas.withValues(alpha: 1 - transparency),
            ),
          ),
        ),
      ),
      title: DefaultTextStyle.merge(
        style:
            Theme.of(context).textTheme.displaySmall ??
            Theme.of(context).textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: title,
      ),
      actions: actions,
    );
  }
}

/// Lightweight, deterministic artwork used where the server has no image
/// (genres, stations and navigation groups). It is intentionally geometric
/// rather than a large symbolic icon, and never needs a network request.
class NaviAbstractArtwork extends StatelessWidget {
  const NaviAbstractArtwork({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _NaviAbstractPainter(seed),
    child: const SizedBox.expand(),
  );
}

class _NaviAbstractPainter extends CustomPainter {
  _NaviAbstractPainter(this.seed);

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed.hashCode);
    final shortest = math.min(size.width, size.height);
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 3; index++) {
      final y = size.height * (0.22 + index * 0.22);
      final amplitude = shortest * (0.03 + random.nextDouble() * 0.06);
      final path = Path()..moveTo(-8, y);
      for (var x = 0.0; x <= size.width + 8; x += 6) {
        path.lineTo(
          x,
          y + math.sin((x / size.width) * math.pi * (2 + index)) * amplitude,
        );
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NaviAbstractPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class NaviGlass extends StatelessWidget {
  const NaviGlass({
    super.key,
    required this.child,
    this.padding,
    this.radius = NaviRadii.glass,
    this.blur = 22,
    this.opaque = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final bool opaque;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: NaviColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: NaviColors.border),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    ),
  );
}

/// Opens a modal above a dimmed app. The sheet itself is opaque: information
/// stays legible even over busy album artwork.
Future<T?> showNaviModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  isScrollControlled: isScrollControlled,
  useSafeArea: true,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  showDragHandle: false,
  elevation: 0,
  backgroundColor: Colors.transparent,
  barrierColor: NaviColors.modalBarrier,
  builder: (sheetContext) {
    final keyboard = MediaQuery.viewInsetsOf(sheetContext).bottom;
    return AnimatedPadding(
      duration: NaviMotion.micro,
      curve: NaviMotion.curve,
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          NaviSpacing.xs,
          0,
          NaviSpacing.xs,
          NaviSpacing.xs,
        ),
        child: builder(sheetContext),
      ),
    );
  },
);

/// Opaque, flat modal surface. Only the sheet edge casts a shadow because the
/// sheet genuinely floats above the dimmed page.
class NaviModalSurface extends StatelessWidget {
  const NaviModalSurface({
    super.key,
    required this.child,
    this.radius = NaviRadii.dock,
    this.blur = 34,
  });

  final Widget child;
  final double radius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Semantics(
      container: true,
      scopesRoute: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        key: const ValueKey('navi-modal-surface'),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: NaviShadows.modal,
        ),
        child: Material(
          color: NaviColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(color: NaviColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

class NaviModalHandle extends StatelessWidget {
  const NaviModalHandle({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: NaviSpacing.sm, bottom: NaviSpacing.xs),
    child: Center(
      child: Container(
        key: const ValueKey('navi-modal-handle'),
        width: 38,
        height: 5,
        decoration: BoxDecoration(
          color: NaviColors.textTertiary,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ),
  );
}

/// Shared tactile wrapper for cards and controls. It deliberately uses
/// visual compression instead of system click feedback so interacting with the
/// music UI never changes or interrupts the audio experience.
///
/// The child is not clipped by default: cards routinely place text below a
/// self-clipped artwork, and a corner clip would cut the ends of those lines.
/// Pass [clip] only for a full-bleed child that cannot round its own corners.
/// [lift] is retained for call-site compatibility; the flat design no longer
/// adds depth while pressed.
class NaviPressable extends StatefulWidget {
  const NaviPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(NaviRadii.card)),
    this.pressedScale = 0.985,
    this.clip = false,
    this.lift = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final double pressedScale;

  /// Clips [child] to [borderRadius]. Off by default so text is never cut.
  final bool clip;

  /// Wraps [child] in a [NaviLift] that presses down while touched.
  final bool lift;

  @override
  State<NaviPressable> createState() => _NaviPressableState();
}

class _NaviPressableState extends State<NaviPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = NaviMotion.reduceMotion(context);
    Widget child = widget.child;
    if (widget.clip) {
      child = ClipRRect(borderRadius: widget.borderRadius, child: child);
    }
    if (widget.lift) {
      child = NaviLift(
        elevated: !_pressed,
        borderRadius: widget.borderRadius,
        child: child,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: reduceMotion ? Duration.zero : NaviMotion.micro,
        curve: NaviMotion.curve,
        child: child,
      ),
    );
  }
}

class NaviArtworkAtmosphere extends StatelessWidget {
  const NaviArtworkAtmosphere({
    super.key,
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Color primary;
  final Color secondary;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: NaviColors.canvas, child: child);
}
