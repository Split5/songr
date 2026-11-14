import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../navi_design_tokens.dart';
import 'navi_artwork.dart';
import 'navi_now_playing_glyph.dart';

/// Builds the artwork for [song]. Screens receive one from the composition
/// root so rows never know where images come from.
typedef SongArtworkBuilder = Widget Function(BuildContext context, Song song);

/// The one song row every list surface shares: artwork or track number,
/// title over artist, an optional trailing token (usually the length), a
/// long-press and a trailing … button that both open the same song menu.
///
/// The song at the playhead is marked with an accent title and the
/// [NaviNowPlayingGlyph]; when [nowPlayingListenable] is given only the
/// leading and title parts listen for that change, so a long list never
/// rebuilds wholesale when the track advances.
class NaviSongRow extends StatefulWidget {
  const NaviSongRow({
    super.key,
    required this.song,
    this.artwork,
    this.leadingText,
    this.nowPlaying = false,
    this.playing = false,
    this.nowPlayingListenable,
    this.playingListenable,
    this.starred = false,
    this.subtitle,
    this.caption,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.onMenu,
    this.showMenuButton = true,
    this.dense = false,
    this.padding,
    this.menuButtonKey,
  });

  final Song song;

  /// Loaded artwork; the neutral [NaviArtwork] fallback paints when null and
  /// no [leadingText] is given.
  final Widget? artwork;

  /// Replaces the artwork with a short label (a track number).
  final String? leadingText;

  /// Static now-playing state, used when no listenable is supplied.
  final bool nowPlaying;
  final bool playing;

  /// Live id of the song at the playhead; the row compares it to [song].
  final ValueListenable<String?>? nowPlayingListenable;
  final ValueListenable<bool>? playingListenable;

  final bool starred;

  /// Second line; defaults to the primary artist.
  final String? subtitle;

  /// Optional third line (for example an audio-quality label).
  final Widget? caption;

  /// Small trailing token such as the length.
  final String? trailingText;

  /// Custom trailing widget placed before the menu button.
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final bool showMenuButton;
  final bool dense;
  final EdgeInsetsGeometry? padding;

  /// Key for the … button so feature tests can find it.
  final Key? menuButtonKey;

  static const minHeight = 44.0;

  @override
  State<NaviSongRow> createState() => _NaviSongRowState();
}

class _NaviSongRowState extends State<NaviSongRow> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final interactive = widget.onTap != null || widget.onMenu != null;
    final artworkSize = widget.dense ? 40.0 : 48.0;
    final subtitle = widget.subtitle ?? primaryArtistName(widget.song.artist);
    final row = Row(
      children: [
        _Live(
          row: widget,
          builder: (context, nowPlaying, playing) => _Leading(
            row: widget,
            nowPlaying: nowPlaying,
            playing: playing,
            size: artworkSize,
          ),
        ),
        const SizedBox(width: NaviSpacing.sm),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Live(
                row: widget,
                builder: (context, nowPlaying, _) => Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: nowPlaying ? NaviColors.accent : null,
                        ),
                      ),
                    ),
                    if (widget.starred)
                      const Padding(
                        padding: EdgeInsets.only(left: NaviSpacing.xs),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: NaviColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (widget.caption case final caption?) ...[
                const SizedBox(height: 2),
                caption,
              ],
            ],
          ),
        ),
        if (widget.trailingText case final trailingText?) ...[
          const SizedBox(width: NaviSpacing.xs),
          Text(trailingText, style: theme.textTheme.labelMedium),
        ],
        ?widget.trailing,
        if (widget.onMenu != null && widget.showMenuButton)
          IconButton(
            key: widget.menuButtonKey,
            tooltip: l.showMore,
            visualDensity: VisualDensity.compact,
            onPressed: widget.onMenu,
            icon: const Icon(Icons.more_horiz_rounded, size: 20),
          )
        else
          const SizedBox(width: NaviSpacing.xs),
      ],
    );
    return Semantics(
      button: interactive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: interactive ? (_) => _setPressed(true) : null,
        onTapUp: interactive ? (_) => _setPressed(false) : null,
        onTapCancel: interactive ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        onLongPress: widget.onMenu,
        child: AnimatedContainer(
          duration: NaviMotion.reduceMotion(context)
              ? Duration.zero
              : NaviMotion.micro,
          curve: NaviMotion.curve,
          color: _pressed
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          padding:
              widget.padding ??
              const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.xs,
                NaviSpacing.xs,
                NaviSpacing.xs,
              ),
          constraints: const BoxConstraints(minHeight: NaviSongRow.minHeight),
          child: row,
        ),
      ),
    );
  }
}

typedef _LiveBuilder =
    Widget Function(BuildContext context, bool nowPlaying, bool playing);

/// Resolves the now-playing state from the listenables when present, so only
/// the wrapped part of the row rebuilds on a track or pause change.
class _Live extends StatelessWidget {
  const _Live({required this.row, required this.builder});

  final NaviSongRow row;
  final _LiveBuilder builder;

  @override
  Widget build(BuildContext context) {
    final current = row.nowPlayingListenable;
    if (current == null) return builder(context, row.nowPlaying, row.playing);
    return ValueListenableBuilder<String?>(
      valueListenable: current,
      builder: (context, currentId, _) {
        final nowPlaying = currentId != null && currentId == row.song.id;
        if (!nowPlaying) return builder(context, false, false);
        final playing = row.playingListenable;
        if (playing == null) return builder(context, true, row.playing);
        return ValueListenableBuilder<bool>(
          valueListenable: playing,
          builder: (context, value, _) => builder(context, true, value),
        );
      },
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.row,
    required this.nowPlaying,
    required this.playing,
    required this.size,
  });

  final NaviSongRow row;
  final bool nowPlaying;
  final bool playing;
  final double size;

  @override
  Widget build(BuildContext context) {
    final leadingText = row.leadingText;
    final glyphLabel = AppLocalizations.of(context).nowPlayingLabel;
    if (leadingText != null) {
      return SizedBox(
        width: 28,
        child: Center(
          child: nowPlaying
              ? Semantics(
                  label: glyphLabel,
                  child: NaviNowPlayingGlyph(playing: playing),
                )
              : Text(
                  leadingText,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
        ),
      );
    }
    final artwork = NaviArtwork(
      coverArt: row.song.coverArt,
      fallback: Icons.music_note_rounded,
      size: size,
      radius: row.dense ? 8 : 10,
      child: row.artwork,
    );
    if (!nowPlaying) return artwork;
    return Stack(
      alignment: Alignment.center,
      children: [
        artwork,
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(row.dense ? 8 : 10),
            ),
          ),
        ),
        Semantics(
          label: glyphLabel,
          child: NaviNowPlayingGlyph(playing: playing, size: size * 0.4),
        ),
      ],
    );
  }
}
