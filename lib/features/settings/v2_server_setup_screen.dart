import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/v2/v2_server_capabilities.dart';
import '../../app/v2/v2_support_links.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../l10n/app_localizations.dart';

class V2ServerSetupScreen extends StatelessWidget {
  const V2ServerSetupScreen({super.key, required this.capabilities});

  final V2ServerCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.serverSetupTitle),
        actions: [
          IconButton(
            tooltip: l.serverSetupCheckAgain,
            onPressed: capabilities.isChecking
                ? null
                : () => unawaited(capabilities.refresh(checkLyrics: true)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: capabilities,
        builder: (context, _) {
          final recommendations = _recommendations(l);
          final actions = recommendations.where((item) => !item.ready).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.lg,
              NaviSpacing.page,
              NaviSpacing.xl,
            ),
            children: [
              Text(
                l.serverSetupIntro,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: NaviSpacing.md),
              Text(
                capabilities.isChecking
                    ? l.serverSetupChecking
                    : actions == 0
                    ? l.serverSetupAllReady
                    : l.serverSetupActionsRecommended(actions),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: NaviColors.accent),
              ),
              const SizedBox(height: NaviSpacing.lg),
              for (final recommendation in recommendations) ...[
                _RecommendationCard(recommendation: recommendation),
                const SizedBox(height: NaviSpacing.sm),
              ],
              const SizedBox(height: NaviSpacing.md),
              FilledButton.tonal(
                style: Theme.of(context).filledButtonTheme.style,
                onPressed: capabilities.isChecking
                    ? null
                    : () => unawaited(capabilities.refresh(checkLyrics: true)),
                child: Text(
                  capabilities.isChecking
                      ? l.serverSetupChecking
                      : l.serverSetupCheckAgain,
                ),
              ),
              const SizedBox(height: NaviSpacing.xl),
              Text(
                l.serverSetupPluginNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  List<_SetupRecommendation> _recommendations(AppLocalizations l) => [
    _SetupRecommendation(
      icon: Icons.language_rounded,
      title: l.serverSetupRemoteTitle,
      body: capabilities.isLocalServer
          ? l.serverSetupRemoteLocal
          : l.serverSetupRemoteReady,
      ready: !capabilities.isLocalServer,
      uri: V2SupportLinks.remoteSetup,
    ),
    _SetupRecommendation(
      icon: Icons.auto_awesome_rounded,
      title: l.serverSetupSmartTitle,
      body: switch (capabilities.smartMixes) {
        ServerCapabilityState.available => l.serverSetupSmartReady,
        ServerCapabilityState.unavailable => l.serverSetupSmartMissing,
        ServerCapabilityState.checking => l.serverSetupChecking,
        ServerCapabilityState.unknown => l.serverSetupNotDetected,
      },
      ready: capabilities.smartMixes == ServerCapabilityState.available,
      checking: capabilities.isChecking,
      uri: V2SupportLinks.smartSetup,
    ),
    _SetupRecommendation(
      icon: Icons.lyrics_outlined,
      title: l.serverSetupLyricsTitle,
      body: switch (capabilities.lyrics) {
        ServerCapabilityState.available => l.serverSetupLyricsReady,
        ServerCapabilityState.unavailable => l.serverSetupLyricsMissing,
        ServerCapabilityState.checking => l.serverSetupChecking,
        ServerCapabilityState.unknown => l.serverSetupNotDetected,
      },
      ready: capabilities.lyrics == ServerCapabilityState.available,
      checking: capabilities.isChecking,
      uri: V2SupportLinks.lyricsSetup,
    ),
    _SetupRecommendation(
      icon: Icons.shield_outlined,
      title: l.serverSetupSecurityTitle,
      body: capabilities.isHttps
          ? l.serverSetupSecurityReady
          : l.serverSetupSecurityHttp,
      ready: capabilities.isHttps,
      uri: V2SupportLinks.securitySetup,
    ),
    _SetupRecommendation(
      icon: Icons.backup_outlined,
      title: l.serverSetupBackupTitle,
      body: l.serverSetupBackupBody,
      ready: true,
      informational: true,
      uri: V2SupportLinks.securitySetup,
    ),
  ];
}

class _SetupRecommendation {
  const _SetupRecommendation({
    required this.icon,
    required this.title,
    required this.body,
    required this.ready,
    required this.uri,
    this.checking = false,
    this.informational = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool ready;
  final bool checking;
  final bool informational;
  final Uri uri;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final _SetupRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = recommendation.informational
        ? l.serverSetupTip
        : recommendation.checking
        ? l.serverSetupChecking
        : recommendation.ready
        ? l.serverSetupReady
        : l.serverSetupActionRecommended;
    return NaviGlass(
      radius: NaviRadii.card,
      child: InkWell(
        borderRadius: BorderRadius.circular(NaviRadii.card),
        onTap: () => unawaited(_openGuide(context)),
        child: Padding(
          padding: const EdgeInsets.all(NaviSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                recommendation.icon,
                color: recommendation.ready
                    ? NaviColors.textSecondary
                    : NaviColors.accent,
              ),
              const SizedBox(width: NaviSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: NaviSpacing.sm),
                        Text(
                          status,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: recommendation.ready
                                    ? NaviColors.textSecondary
                                    : NaviColors.accent,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NaviSpacing.xs),
                    Text(
                      recommendation.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: NaviSpacing.sm),
                    Row(
                      children: [
                        Text(
                          l.serverSetupReadGuide,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(width: NaviSpacing.xxs),
                        const Icon(Icons.open_in_new_rounded, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGuide(BuildContext context) async {
    var opened = false;
    try {
      opened = await launchUrl(
        recommendation.uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }
}
