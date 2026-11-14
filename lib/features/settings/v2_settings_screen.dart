import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/v2/v2_experience_preferences.dart';
import '../../app/v2/v2_playback_preferences.dart';
import '../../app/v2/v2_server_capabilities.dart';
import '../../app/v2/v2_server_settings.dart';
import '../../app/v2/v2_support_links.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_chrome_style.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/sync/library_sync_progress.dart';
import '../../state/download_provider.dart';
import 'library_sync_progress_view.dart';
import 'v2_connection_screen.dart';
import 'v2_server_setup_screen.dart';
import 'v2_support_screen.dart';

class V2SettingsScreen extends StatelessWidget {
  const V2SettingsScreen({
    super.key,
    required this.server,
    required this.playback,
    required this.experience,
    required this.downloads,
    this.capabilities,
    this.onSyncLibrary,
    this.librarySyncProgress,
  });

  final V2ServerSettings server;
  final V2PlaybackPreferences playback;
  final V2ExperiencePreferences experience;
  final DownloadProvider downloads;
  final V2ServerCapabilities? capabilities;
  final Future<bool> Function()? onSyncLibrary;
  final ValueListenable<LibrarySyncProgress?>? librarySyncProgress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final platform = Theme.of(context).platform;
    return Scaffold(
      appBar: AppBar(title: Text(l.tooltipSettings)),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          playback,
          experience,
          downloads,
          ?capabilities,
          ?librarySyncProgress,
        ]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(
            NaviSpacing.page,
            NaviSpacing.md,
            NaviSpacing.page,
            NaviSpacing.xl,
          ),
          children: [
            _SettingsGroup(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_rounded),
                  title: Text(l.settingsTitle),
                  subtitle: Text(server.url),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => V2ConnectionScreen(settings: server),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                if (onSyncLibrary != null) ...[
                  _LibrarySyncTile(
                    onSync: onSyncLibrary!,
                    progress: librarySyncProgress?.value,
                  ),
                  const Divider(height: 1, indent: 56),
                ],
                ListTile(
                  leading: const Icon(Icons.dashboard_customize_rounded),
                  title: Text(l.homeCustomizationTitle),
                  subtitle: Text(l.homeCustomizationSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _HomeCustomizationScreen(preferences: experience),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  key: const ValueKey('appearance-settings'),
                  leading: const Icon(Icons.blur_on_rounded),
                  title: Text(l.appearanceSettingsTitle),
                  subtitle: Text(l.appearanceSettingsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _AppearanceScreen(preferences: experience),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(l.recommendationsSettingsTitle),
                  subtitle: Text(l.recommendationsSettingsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _RecommendationsScreen(preferences: experience),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.settings_suggest_rounded),
                  title: Text(l.serverSetupTitle),
                  subtitle: Text(
                    capabilities?.isChecking == true
                        ? l.serverSetupChecking
                        : l.serverSetupSubtitle,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: capabilities == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => V2ServerSetupScreen(
                              capabilities: capabilities!,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.lg),
            _SettingsGroup(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.data_saver_on_rounded),
                  title: Text(l.dataSaver),
                  subtitle: Text(l.dataSaverSubtitle),
                  value: playback.dataSaverEnabled,
                  onChanged: (value) =>
                      unawaited(playback.setDataSaverEnabled(value)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.xs,
                NaviSpacing.lg,
                NaviSpacing.xs,
                NaviSpacing.xs,
              ),
              child: Text(
                l.offlineSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _SettingsGroup(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.wifi_rounded),
                  title: Text(l.offlineWifiOnly),
                  subtitle: Text(l.offlineWifiOnlySubtitle),
                  value: downloads.wifiOnlyEnabled,
                  onChanged: (value) =>
                      unawaited(downloads.setWifiOnlyEnabled(value)),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.favorite_rounded),
                  title: Text(l.offlineFavoritesTitle),
                  subtitle: Text(l.offlineFavoritesSubtitle),
                  value: downloads.favoritesOfflineEnabled,
                  onChanged: (value) =>
                      unawaited(downloads.setFavoritesOfflineEnabled(value)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.storage_rounded),
                  title: Text(l.offlineStorageCap),
                  subtitle: Text(
                    downloads.storageCapBytes == 0
                        ? l.offlineUsageUnlimited(_bytes(downloads.usedBytes))
                        : l.offlineUsage(
                            _bytes(downloads.usedBytes),
                            _bytes(downloads.storageCapBytes),
                          ),
                  ),
                  trailing: DropdownButton<int>(
                    value: _capOption(downloads.storageCapBytes),
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final gb in const [1, 2, 5, 10, 0])
                        DropdownMenuItem(
                          value: gb,
                          child: Text(
                            gb == 0 ? l.offlineStorageCapUnlimited : '$gb GB',
                          ),
                        ),
                    ],
                    onChanged: (gb) {
                      if (gb != null) {
                        unawaited(
                          downloads.setStorageCapBytes(gb * 1024 * 1024 * 1024),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.lg),
            _SettingsGroup(
              children: [
                if (V2SupportLinks.supportPageVisible) ...[
                  ListTile(
                    leading: const Icon(Icons.favorite_outline_rounded),
                    title: Text(l.supportDeveloperTitle),
                    subtitle: Text(l.supportDeveloperSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const V2SupportScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                ],
                const V2BugReportTile(),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.public_rounded),
                  title: Text(l.privacyPolicyTitle),
                  subtitle: Text(l.privacyPolicySubtitle),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openLink(context, V2SupportLinks.privacy),
                ),
                if (V2SupportLinks.refundLinkVisible &&
                    (platform == TargetPlatform.iOS ||
                        platform == TargetPlatform.macOS)) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l.requestRefundTitle),
                    subtitle: Text(l.requestRefundSubtitle),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => _openLink(context, V2SupportLinks.refunds),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }

  int _capOption(int bytes) {
    if (bytes == 0) return 0;
    final gb = bytes ~/ (1024 * 1024 * 1024);
    return const [1, 2, 5, 10].contains(gb) ? gb : 2;
  }

  String _bytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

class _LibrarySyncTile extends StatefulWidget {
  const _LibrarySyncTile({required this.onSync, this.progress});

  final Future<bool> Function() onSync;
  final LibrarySyncProgress? progress;

  @override
  State<_LibrarySyncTile> createState() => _LibrarySyncTileState();
}

class _LibrarySyncTileState extends State<_LibrarySyncTile> {
  bool _pending = false;
  bool get _loading => _pending || widget.progress != null;

  Future<void> _sync() async {
    if (_loading) return;
    setState(() => _pending = true);
    var success = false;
    try {
      success = await widget.onSync();
    } catch (_) {
      // Keep retry available if the caller fails before returning a result.
    }
    if (!mounted) return;
    setState(() => _pending = false);
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l.librarySyncComplete : l.librarySyncFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = widget.progress;
    return ListTile(
      key: const ValueKey('sync-full-library'),
      leading: const Icon(Icons.sync_rounded),
      title: Text(_loading ? l.librarySyncLoading : l.librarySyncTitle),
      subtitle: _loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LibrarySyncProgressView(progress: progress),
                const SizedBox(height: NaviSpacing.sm),
                Text(l.librarySyncCanLeave),
              ],
            )
          : Text(l.librarySyncSubtitle),
      trailing: _loading ? null : const Icon(Icons.refresh_rounded),
      onTap: _loading ? null : _sync,
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => NaviGlass(
    radius: NaviRadii.card,
    child: Column(children: children),
  );
}

class _HomeCustomizationScreen extends StatelessWidget {
  const _HomeCustomizationScreen({required this.preferences});

  final V2ExperiencePreferences preferences;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.homeCustomizationTitle)),
      body: ListenableBuilder(
        listenable: preferences,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: NaviSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.lg,
                NaviSpacing.page,
                NaviSpacing.sm,
              ),
              child: _SettingsGroup(
                children: [
                  SwitchListTile.adaptive(
                    key: const ValueKey('home-header-logo'),
                    secondary: const Icon(Icons.image_rounded),
                    title: Text(l.homeHeaderStyleTitle),
                    subtitle: Text(l.homeHeaderStyleSubtitle),
                    value: preferences.homeHeaderStyle == HomeHeaderStyle.logo,
                    onChanged: (value) => unawaited(
                      preferences.setHomeHeaderStyle(
                        value ? HomeHeaderStyle.logo : HomeHeaderStyle.wordmark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.lg,
                NaviSpacing.page,
                NaviSpacing.sm,
              ),
              child: Text(
                l.homeCarouselContentTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                0,
                NaviSpacing.page,
                NaviSpacing.lg,
              ),
              child: Text(
                l.homeCarouselContentHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.sm,
                NaviSpacing.page,
                NaviSpacing.xs,
              ),
              child: Text(
                l.homeSectionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                0,
                NaviSpacing.page,
                NaviSpacing.sm,
              ),
              child: Text(
                l.homeSectionsHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: preferences.homeSectionOrder.length,
              onReorderItem: (oldIndex, newIndex) =>
                  unawaited(preferences.reorderHomeSection(oldIndex, newIndex)),
              itemBuilder: (context, index) {
                final section = preferences.homeSectionOrder[index];
                final enabled = preferences.enabledHomeSections.contains(
                  section,
                );
                final content = preferences.homeContentFor(section);
                return ListTile(
                  key: ValueKey(section),
                  leading: Icon(_homeSectionIcon(section)),
                  title: Text(_homeSectionLabel(l, section)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (section == HomeSectionKind.quickPicks)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: NaviSpacing.sm,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      else
                        PopupMenuButton<HomeContentFocus>(
                          key: ValueKey('home-content-${section.name}'),
                          tooltip: l.homeCarouselContentTitle,
                          initialValue: content,
                          onSelected: (value) => unawaited(
                            preferences.setHomeSectionContent(section, value),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              key: const ValueKey('home-content-option-songs'),
                              value: HomeContentFocus.songs,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.music_note_rounded,
                                    size: 19,
                                  ),
                                  const SizedBox(width: NaviSpacing.sm),
                                  Text(l.homeFocusSongs),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              key: const ValueKey('home-content-option-albums'),
                              value: HomeContentFocus.albums,
                              child: Row(
                                children: [
                                  const Icon(Icons.album_rounded, size: 19),
                                  const SizedBox(width: NaviSpacing.sm),
                                  Text(l.homeFocusAlbums),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NaviSpacing.xs,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                NaviRadii.row,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  content == HomeContentFocus.songs
                                      ? Icons.music_note_rounded
                                      : Icons.album_rounded,
                                  size: 17,
                                ),
                                const SizedBox(width: NaviSpacing.xxs),
                                Text(
                                  content == HomeContentFocus.songs
                                      ? l.homeFocusSongs
                                      : l.homeFocusAlbums,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Switch.adaptive(
                        value: enabled,
                        onChanged: (value) => unawaited(
                          preferences.setHomeSectionEnabled(section, value),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(NaviSpacing.sm),
                          child: Icon(Icons.drag_handle_rounded),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _homeSectionLabel(AppLocalizations l, HomeSectionKind section) =>
      switch (section) {
        HomeSectionKind.recentlyPlayed => l.homeSectionRecentlyPlayed,
        HomeSectionKind.quickPicks => l.quickPicks,
        HomeSectionKind.recentlyAdded => l.homeSectionRecentlyAdded,
        HomeSectionKind.mostPlayed => l.homeSectionMostPlayed,
        HomeSectionKind.fromLibrary => l.sectionFromLibrary,
      };

  IconData _homeSectionIcon(HomeSectionKind section) => switch (section) {
    HomeSectionKind.recentlyPlayed => Icons.history_rounded,
    HomeSectionKind.quickPicks => Icons.auto_awesome_rounded,
    HomeSectionKind.recentlyAdded => Icons.fiber_new_rounded,
    HomeSectionKind.mostPlayed => Icons.trending_up_rounded,
    HomeSectionKind.fromLibrary => Icons.casino_rounded,
  };
}

/// Client-side tuning of the similarity results Navidrome returns through
/// `getSimilarSongs2` (answered by the AudioMuse plugin on the server). The
/// sliders never change what the server computes, only how the client samples
/// and diversifies the already-ranked candidates.
class _RecommendationsScreen extends StatelessWidget {
  const _RecommendationsScreen({required this.preferences});

  final V2ExperiencePreferences preferences;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recommendationsSettingsTitle),
        actions: [
          TextButton(
            onPressed: () =>
                unawaited(preferences.resetRecommendationProfile()),
            child: Text(l.resetFilters),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: preferences,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: NaviSpacing.xl),
          children: [
            _PreferenceSliderTile(
              icon: Icons.explore_rounded,
              title: l.recommendationVariationTitle,
              subtitle: l.recommendationVariationHelp,
              valueLabel:
                  '${(preferences.recommendationExploration * 100).round()}%',
              value: preferences.recommendationExploration,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: (value) =>
                  unawaited(preferences.setRecommendationExploration(value)),
            ),
            _PreferenceSliderTile(
              icon: Icons.groups_rounded,
              title: l.recommendationArtistVarietyTitle,
              subtitle: l.recommendationArtistVarietyHelp,
              valueLabel: l.recommendationSongsPerArtist(
                preferences.recommendationMaxSongsPerArtist,
              ),
              value: preferences.recommendationMaxSongsPerArtist.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) => unawaited(
                preferences.setRecommendationMaxSongsPerArtist(value.round()),
              ),
            ),
            _PreferenceSliderTile(
              icon: Icons.queue_music_rounded,
              title: l.recommendationInitialQueueTitle,
              subtitle: l.recommendationInitialQueueHelp,
              valueLabel: l.songsCount(
                preferences.recommendationInitialCandidateCount,
              ),
              value: preferences.recommendationInitialCandidateCount.toDouble(),
              min: 10,
              max: 30,
              divisions: 4,
              onChanged: (value) => unawaited(
                preferences.setRecommendationInitialCandidateCount(
                  value.round(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceScreen extends StatelessWidget {
  const _AppearanceScreen({required this.preferences});

  final V2ExperiencePreferences preferences;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appearanceSettingsTitle),
        actions: [
          TextButton(
            onPressed: () => unawaited(preferences.resetChromeTransparency()),
            child: Text(l.resetFilters),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: preferences,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: NaviSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.lg,
                NaviSpacing.page,
                NaviSpacing.xs,
              ),
              child: Text(
                l.topBarTransparencyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _PreferenceSliderTile(
              sliderKey: const ValueKey('top-bar-transparency-slider'),
              icon: Icons.opacity_rounded,
              title: l.transparencySettingTitle,
              subtitle: l.transparencySettingHelp,
              valueLabel: '${(preferences.topBarTransparency * 100).round()}%',
              value: preferences.topBarTransparency,
              min: NaviChromeStyle.minTopBarTransparency,
              max: NaviChromeStyle.maxTopBarTransparency,
              divisions:
                  ((NaviChromeStyle.maxTopBarTransparency -
                              NaviChromeStyle.minTopBarTransparency) *
                          100)
                      .round(),
              onChanged: (value) =>
                  unawaited(preferences.setTopBarTransparency(value)),
            ),
            _PreferenceSliderTile(
              sliderKey: const ValueKey('top-bar-blur-slider'),
              icon: Icons.blur_on_rounded,
              title: l.blurSettingTitle,
              subtitle: l.blurSettingHelp,
              valueLabel: '${preferences.topBarBlurSigma.round()}',
              value: preferences.topBarBlurSigma,
              min: NaviChromeStyle.minBarBlurSigma,
              max: NaviChromeStyle.maxBarBlurSigma,
              divisions:
                  (NaviChromeStyle.maxBarBlurSigma -
                          NaviChromeStyle.minBarBlurSigma)
                      .round(),
              onChanged: (value) =>
                  unawaited(preferences.setTopBarBlurSigma(value)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceSliderTile extends StatelessWidget {
  const _PreferenceSliderTile({
    this.sliderKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final Key? sliderKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.md,
      NaviSpacing.page,
      0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: NaviSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(valueLabel, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: NaviSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        Slider.adaptive(
          key: sliderKey,
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
