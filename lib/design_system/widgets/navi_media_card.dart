import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';
import 'navi_glass.dart';
import 'navi_now_playing_glyph.dart';

/// Shelf card: square artwork above a title, a subtitle and an optional
/// caption. Only the artwork is clipped, so the text below keeps its full
/// line and the card's bottom corners stay hit-testable. When [nowPlaying]
/// the artwork rests on a [NaviLift] and carries a small glyph badge — the
/// only depth a card is allowed, because it communicates state.
class NaviMediaCard extends StatelessWidget {
  const NaviMediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.caption,
    required this.artwork,
    this.nowPlaying = false,
    this.playing = false,
    this.captionColor,
    this.onTap,
    this.onLongPress,
    this.width = 144,
  });

  final String title;
  final String subtitle;
  final String? caption;
  final Widget artwork;
  final bool nowPlaying;
  final bool playing;

  /// Colour for [caption]; defaults to tertiary text.
  final Color? captionColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;

  static const _artworkGap = NaviSpacing.sm;
  static const _lineGap = NaviSpacing.xxs;

  /// Height a shelf must reserve for one card at the current text scale.
  static double heightFor(
    BuildContext context, {
    bool withCaption = false,
    double width = 144,
  }) {
    final theme = Theme.of(context).textTheme;
    var height =
        width +
        _artworkGap +
        _lineHeight(context, theme.titleSmall) +
        _lineGap +
        _lineHeight(context, theme.bodySmall);
    if (withCaption) {
      height += _lineGap + _lineHeight(context, theme.labelSmall);
    }
    return height;
  }

  static double _lineHeight(BuildContext context, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: style),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(NaviRadii.artwork);
    Widget art = ClipRRect(
      borderRadius: radius,
      child: SizedBox.square(dimension: width, child: artwork),
    );
    if (nowPlaying) {
      art = NaviLift(
        elevated: false,
        borderRadius: radius,
        child: Stack(
          children: [
            art,
            Positioned(
              right: NaviSpacing.xs,
              bottom: NaviSpacing.xs,
              child: DecoratedBox(
                key: const ValueKey('navi-media-card-now-playing'),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: NaviNowPlayingGlyph(playing: playing, size: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: width,
      child: NaviPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            art,
            const SizedBox(height: _artworkGap),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.titleSmall?.copyWith(
                color: nowPlaying ? NaviColors.accent : null,
              ),
            ),
            const SizedBox(height: _lineGap),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodySmall,
            ),
            if (caption case final caption?) ...[
              const SizedBox(height: _lineGap),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.labelSmall?.copyWith(
                  color: captionColor ?? NaviColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
