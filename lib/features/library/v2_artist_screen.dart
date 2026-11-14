import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../domain/library/catalog_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'v2_library_screens.dart' show CatalogArtworkBuilder, NaviAlbumCard;

/// A dedicated artist page: identity header, play/shuffle controls, a
/// "most played" quick-picks shelf and the artist's albums sorted by year.
/// The page is built from the local catalogue so it works offline and always
/// matches the songs Navidrome serves through the Subsonic API.
class V2ArtistScreen extends StatefulWidget {
  const V2ArtistScreen({
    super.key,
    required this.artist,
    required this.catalog,
    required this.onAlbumTap,
    required this.onSongTap,
    required this.onPlay,
    required this.onShuffle,
    this.artworkBuilder,
    this.onSongMenu,
    this.nowPlaying,
    this.playing,
    this.onRefresh,
  });

  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final ArtistSummary artist;
  final CatalogRepository catalog;
  final ValueChanged<Album> onAlbumTap;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<List<Song>> onPlay;
  final ValueChanged<List<Song>> onShuffle;
  final CatalogArtworkBuilder? artworkBuilder;
  final ValueChanged<Song>? onSongMenu;
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2ArtistScreen> createState() => _V2ArtistScreenState();
}

class _V2ArtistScreenState extends State<V2ArtistScreen> {
  List<Album> _albums = const [];
  List<Song> _songs = const [];
  List<Song> _popular = const [];
  bool _loading = true;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.catalog.songsForArtist(widget.artist),
        widget.catalog.albumsForArtist(widget.artist),
      ]);
      if (!mounted || generation != _generation) return;
      final songs = List<Song>.of(results[0] as List<Song>);
      final albums = List<Album>.of(results[1] as List<Album>);
      albums.sort((a, b) {
        final year = b.year.compareTo(a.year);
        if (year != 0) return year;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      final popular = List<Song>.of(songs)
        ..sort((a, b) {
          final plays = b.playCount.compareTo(a.playCount);
          if (plays != 0) return plays;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
      setState(() {
        _songs = List.unmodifiable(songs);
        _albums = List.unmodifiable(albums);
        _popular = List.unmodifiable(popular.take(8));
        _loading = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await widget.onRefresh?.call();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: NaviArtworkAtmosphere(
        primary: NaviColors.atmospherePlum,
        secondary: NaviColors.atmosphereWine,
        child: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              NaviSliverHeader(title: Text(widget.artist.name)),
              SliverToBoxAdapter(child: _artistHero(l)),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l.couldNotLoadLibrary('$_error'))),
                )
              else ...[
                if (_popular.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _sectionHeader(l.sectionMostPlayedSongs),
                  ),
                  SliverToBoxAdapter(child: _quickPicks()),
                ],
                if (_albums.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _sectionHeader(l.navAlbums)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      NaviSpacing.page,
                      0,
                      NaviSpacing.page,
                      NaviSpacing.lg,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: NaviSpacing.sm,
                            mainAxisSpacing: NaviSpacing.md,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: _albums.length,
                      itemBuilder: (context, index) =>
                          _albumCard(context, _albums[index]),
                    ),
                  ),
                ],
                if (_songs.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _sectionHeader(l.navSongs)),
                  SliverList.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      final openMenu = widget.onSongMenu == null
                          ? null
                          : () => widget.onSongMenu!(song);
                      return NaviSongRow(
                        song: song,
                        dense: true,
                        artwork: widget.artworkBuilder?.call(
                          context,
                          song.coverArt,
                          Icons.music_note_rounded,
                        ),
                        nowPlayingListenable: widget.nowPlaying,
                        playingListenable: widget.playing,
                        starred: song.starred,
                        subtitle: song.album,
                        onTap: () => widget.onSongTap(song),
                        onMenu: openMenu,
                        menuButtonKey: ValueKey('artist-song-menu-${song.id}'),
                      );
                    },
                  ),
                ] else if (_albums.isEmpty && _popular.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l.nothingToShowYet)),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 92)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _artistHero(AppLocalizations l) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.xs,
      NaviSpacing.page,
      NaviSpacing.lg,
    ),
    child: Column(
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: 132,
            child:
                widget.artworkBuilder?.call(
                  context,
                  widget.artist.coverArt,
                  Icons.person_rounded,
                ) ??
                NaviArtwork(
                  coverArt: widget.artist.coverArt,
                  fallback: Icons.person_rounded,
                ),
          ),
        ),
        const SizedBox(height: NaviSpacing.md),
        Text(
          widget.artist.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: NaviSpacing.xs),
        Text(
          '${l.albumsCount(_albums.length)} · ${l.songsCount(_songs.length)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: NaviColors.textSecondary),
        ),
        const SizedBox(height: NaviSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _songs.isEmpty ? null : () => widget.onPlay(_songs),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.play),
            ),
            const SizedBox(width: NaviSpacing.sm),
            FilledButton.tonalIcon(
              style: NaviTheme.tonalButtonStyle,
              onPressed: _songs.isEmpty ? null : () => widget.onShuffle(_songs),
              icon: const Icon(Icons.shuffle_rounded),
              label: Text(l.shuffle),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.xs,
      NaviSpacing.page,
      NaviSpacing.sm,
    ),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _quickPicks() => SizedBox(
    height: 164,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: _popular.length,
      separatorBuilder: (_, _) => const SizedBox(width: NaviSpacing.sm),
      itemBuilder: (context, index) {
        final song = _popular[index];
        return SizedBox(
          width: 118,
          child: NaviPressable(
            borderRadius: BorderRadius.circular(NaviRadii.card),
            lift: true,
            onTap: () => widget.onSongTap(song),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(NaviRadii.card),
                    child: SizedBox.expand(
                      child:
                          widget.artworkBuilder?.call(
                            context,
                            song.coverArt,
                            Icons.music_note_rounded,
                          ) ??
                          NaviArtwork(
                            coverArt: song.coverArt,
                            fallback: Icons.music_note_rounded,
                            radius: NaviRadii.card,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: NaviSpacing.xs),
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _albumCard(BuildContext context, Album album) => NaviAlbumCard(
    album: album,
    artworkBuilder: widget.artworkBuilder,
    onTap: () => widget.onAlbumTap(album),
  );
}
