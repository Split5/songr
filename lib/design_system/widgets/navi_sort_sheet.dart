import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';
import 'navi_glass.dart';

/// Apple-style single-choice sheet: a title, one row per value and a
/// checkmark on the current one. Resolves with the picked value, or null when
/// dismissed.
Future<T?> showNaviSortSheet<T>({
  required BuildContext context,
  required String title,
  required T current,
  required List<T> values,
  required String Function(T value) labelOf,
}) => showNaviModalBottomSheet<T>(
  context: context,
  builder: (sheetContext) => NaviModalSurface(
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NaviModalHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.xs,
              NaviSpacing.page,
              NaviSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
          ),
          for (final value in values)
            ListTile(
              title: Text(labelOf(value)),
              trailing: value == current
                  ? const Icon(
                      Icons.check_rounded,
                      color: NaviColors.textPrimary,
                    )
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(value),
            ),
          const SizedBox(height: NaviSpacing.xs),
        ],
      ),
    ),
  ),
);
