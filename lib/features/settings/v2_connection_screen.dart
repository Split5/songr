import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/v2/v2_server_settings.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../l10n/app_localizations.dart';

class V2ConnectionScreen extends StatefulWidget {
  const V2ConnectionScreen({super.key, required this.settings});

  final V2ServerSettings settings;

  @override
  State<V2ConnectionScreen> createState() => _V2ConnectionScreenState();
}

class _V2ConnectionScreenState extends State<V2ConnectionScreen> {
  late final TextEditingController _url = TextEditingController(
    text: widget.settings.url,
  );
  late final TextEditingController _username = TextEditingController(
    text: widget.settings.username,
  );
  final TextEditingController _password = TextEditingController();
  bool _saving = false;
  bool _obscure = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _url.addListener(_urlChanged);
  }

  void _urlChanged() => setState(() {});

  bool get _usesInsecureHttp {
    final uri = Uri.tryParse(_url.text.trim());
    return uri?.scheme.toLowerCase() == 'http';
  }

  @override
  void dispose() {
    _url.removeListener(_urlChanged);
    _url.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
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
              'assets/branding/splash-mark.png',
              width: 96,
              height: 96,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: NaviSpacing.md),
          Text(
            l.appTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: NaviSpacing.xxs),
          Text(
            l.connectToServer,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: NaviColors.textSecondary),
          ),
          const SizedBox(height: NaviSpacing.xl),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l.serverUrl),
          ),
          if (_usesInsecureHttp) ...[
            const SizedBox(height: NaviSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: NaviColors.accent,
                ),
                const SizedBox(width: NaviSpacing.xs),
                Expanded(
                  child: Text(
                    l.serverHttpWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: NaviColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: NaviSpacing.md),
          TextField(
            controller: _username,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l.username),
          ),
          const SizedBox(height: NaviSpacing.md),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => unawaited(_save()),
            decoration: InputDecoration(
              labelText: l.password,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: NaviSpacing.md),
            Text(
              l.couldNotConnect('$_error'),
              style: const TextStyle(color: NaviColors.destructive),
            ),
          ],
          const SizedBox(height: NaviSpacing.lg),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : const Icon(Icons.cloud_done_rounded),
              label: Text(l.connectAndSave),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final password = _password.text.isEmpty
        ? widget.settings.password
        : _password.text;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.settings.saveAndVerify(
        url: _url.text.trim(),
        username: _username.text.trim(),
        password: password,
      );
      if (mounted) Navigator.of(context).maybePop();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
