import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/v2/v2_diagnostics.dart';
import '../../app/v2/v2_support_links.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../l10n/app_localizations.dart';

class V2SupportScreen extends StatefulWidget {
  const V2SupportScreen({super.key});

  @override
  State<V2SupportScreen> createState() => _V2SupportScreenState();
}

class _V2SupportScreenState extends State<V2SupportScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPackageInfo());
  }

  Future<void> _loadPackageInfo() async {
    try {
      final value = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _packageInfo = value);
    } catch (_) {
      // Version details are optional in support UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.supportDeveloperTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          NaviSpacing.lg,
          NaviSpacing.page,
          NaviSpacing.xl,
        ),
        children: [
          Center(
            child: Image.asset(
              'assets/branding/musik-app-icon.png',
              width: 104,
              height: 104,
              semanticLabel: l.appTitle,
            ),
          ),
          const SizedBox(height: NaviSpacing.lg),
          Text(
            l.supportDeveloperHeadline,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NaviSpacing.sm),
          Text(
            l.supportDeveloperBody,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NaviSpacing.xl),
          _SupportGroup(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_outline_rounded),
                title: Text(l.supportShareTitle),
                subtitle: Text(l.supportShareSubtitle),
                trailing: const Icon(Icons.ios_share_rounded),
                onTap: _shareApp,
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded),
                title: Text(l.supportEmailTitle),
                subtitle: Text(V2SupportLinks.supportEmail),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _openEmail(
                  subject: l.supportMailSubject,
                  body: l.supportMailBody,
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.public_rounded),
                title: Text(l.websiteLabel),
                subtitle: const Text('simonbystrom.se'),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _open(V2SupportLinks.website),
              ),
            ],
          ),
          const SizedBox(height: NaviSpacing.lg),
          if (_packageInfo case final info?)
            Text(
              '${l.appTitle} ${info.version} (${info.buildNumber})',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Future<void> _shareApp() async {
    final l = AppLocalizations.of(context);
    try {
      await SharePlus.instance.share(
        ShareParams(text: '${l.supportShareText}\n${V2SupportLinks.appPage}'),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).shareAppFailed)),
        );
      }
    }
  }

  Future<void> _openEmail({required String subject, required String body}) =>
      _open(V2SupportLinks.mail(subject: subject, body: body));

  Future<void> _open(Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }
}

class V2BugReportTile extends StatefulWidget {
  const V2BugReportTile({super.key});

  @override
  State<V2BugReportTile> createState() => _V2BugReportTileState();
}

class _V2BugReportTileState extends State<V2BugReportTile> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.bug_report_outlined),
      title: Text(l.bugReportTitle),
      subtitle: Text(l.bugReportSubtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => showNaviModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _BugReportSheet(),
      ),
    );
  }
}

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();

  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  static const _maxAttachmentBytes = 40 * 1024 * 1024;
  static const _allowedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.heif',
    '.mp4',
    '.mov',
  };

  final _description = TextEditingController();
  final _picker = ImagePicker();
  XFile? _attachment;
  bool _sending = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final attachment = _attachment;
    return NaviModalSurface(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          NaviSpacing.page,
          0,
          NaviSpacing.page,
          MediaQuery.paddingOf(context).bottom + NaviSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NaviModalHandle(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.bugReportSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l.close,
                  onPressed: _sending
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.md),
            Text(
              l.bugReportDescriptionLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: NaviSpacing.xs),
            TextField(
              key: const ValueKey('bug-report-description'),
              controller: _description,
              minLines: 5,
              maxLines: 9,
              maxLength: 4000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l.bugReportDescriptionHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: NaviSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: NaviColors.textSecondary,
                ),
                const SizedBox(width: NaviSpacing.xs),
                Expanded(
                  child: Text(
                    l.bugReportDiagnosticsNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.lg),
            if (attachment != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _isVideo(attachment)
                      ? Icons.video_file_outlined
                      : Icons.image_outlined,
                ),
                title: Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: l.bugReportRemoveAttachment,
                  onPressed: _sending
                      ? null
                      : () => setState(() => _attachment = null),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
              ),
              const SizedBox(height: NaviSpacing.sm),
            ],
            Wrap(
              spacing: NaviSpacing.xs,
              runSpacing: NaviSpacing.xs,
              children: [
                OutlinedButton.icon(
                  onPressed: _sending ? null : () => _pick(false),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l.bugReportAttachImage),
                ),
                OutlinedButton.icon(
                  onPressed: _sending ? null : () => _pick(true),
                  icon: const Icon(Icons.videocam_outlined),
                  label: Text(l.bugReportAttachVideo),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.xs),
            Text(
              l.bugReportAttachmentHelp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: NaviSpacing.lg),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_sending ? l.bugReportSending : l.bugReportSend),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(bool video) async {
    final l = AppLocalizations.of(context);
    try {
      final file = video
          ? await _picker.pickVideo(
              source: ImageSource.gallery,
              maxDuration: const Duration(minutes: 1),
            )
          : await _picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 2400,
              imageQuality: 88,
              requestFullMetadata: false,
            );
      if (file == null || !mounted) return;

      final extension = _extensionOf(file.name);
      final mime = file.mimeType?.toLowerCase() ?? '';
      final knownMime = mime.startsWith('image/') || mime.startsWith('video/');
      if (!_allowedExtensions.contains(extension) && !knownMime) {
        _showMessage(l.bugReportAttachmentUnsupported);
        return;
      }
      if (await file.length() > _maxAttachmentBytes) {
        if (mounted) _showMessage(l.bugReportAttachmentTooLarge);
        return;
      }
      if (mounted) setState(() => _attachment = file);
    } catch (_) {
      if (mounted) _showMessage(l.bugReportAttachmentPickFailed);
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final description = _description.text.trim();
    if (description.isEmpty) {
      _showMessage(l.bugReportEmptyDescription);
      return;
    }

    setState(() => _sending = true);
    try {
      final attachment = _attachment;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      final report = await V2Diagnostics.buildReport(description: description);
      final result = await SharePlus.instance.share(
        ShareParams(
          title: l.bugReportSheetTitle,
          subject: l.bugReportMailSubject,
          text: report,
          files: [
            XFile.fromData(
              Uint8List.fromList(utf8.encode(report)),
              mimeType: 'text/plain',
            ),
            ?attachment,
          ],
          fileNameOverrides: [
            'soengr-diagnostics.txt',
            if (attachment != null) attachment.name,
          ],
          sharePositionOrigin: origin,
        ),
      );
      if (!mounted || result.status == ShareResultStatus.dismissed) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l.bugReportOpened)));
    } catch (_) {
      if (mounted) _showMessage(l.bugReportShareFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot).toLowerCase();
  }

  bool _isVideo(XFile file) =>
      file.mimeType?.startsWith('video/') ??
      const {'.mp4', '.mov'}.contains(_extensionOf(file.name));
}

class _SupportGroup extends StatelessWidget {
  const _SupportGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => NaviGlass(
    radius: NaviRadii.card,
    child: Column(children: children),
  );
}
