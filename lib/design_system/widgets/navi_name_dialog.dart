import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// One text-field dialog used for naming things (a playlist, a saved filter,
/// a queue snapshot). Resolves with the trimmed name, or null when cancelled
/// or left empty.
Future<String?> showNaviNameDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String confirmLabel,
  String? initial,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _NaviNameDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      initial: initial,
    ),
  );
  final trimmed = name?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Owns the text controller so it outlives the route's exit animation.
class _NaviNameDialog extends StatefulWidget {
  const _NaviNameDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    this.initial,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String? initial;

  @override
  State<_NaviNameDialog> createState() => _NaviNameDialogState();
}

class _NaviNameDialogState extends State<_NaviNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (value) => Navigator.of(context).pop(value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context).cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: Text(widget.confirmLabel),
      ),
    ],
  );
}
