import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'navi_design_tokens.dart';

/// Material 3 wiring for the true-black listening-room look: flat surfaces,
/// white type, inverted primary controls and one playback-only accent.
abstract final class NaviTheme {
  /// Graphite pill for secondary actions. Flutter applies
  /// [FilledButtonThemeData] to `FilledButton` and `FilledButton.tonal`
  /// alike, so every `FilledButton.tonal` in the app passes this style.
  static ButtonStyle get tonalButtonStyle => FilledButton.styleFrom(
    backgroundColor: NaviColors.surfaceRaised,
    foregroundColor: NaviColors.textPrimary,
    disabledBackgroundColor: NaviColors.surface,
    disabledForegroundColor: NaviColors.textTertiary,
    shape: const StadiumBorder(),
    minimumSize: const Size(48, 46),
    padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.md),
  );

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: NaviColors.textPrimary,
      onPrimary: NaviColors.canvas,
      primaryContainer: NaviColors.surfaceRaised,
      onPrimaryContainer: NaviColors.textPrimary,
      secondary: NaviColors.accent,
      onSecondary: NaviColors.canvas,
      secondaryContainer: NaviColors.surfaceRaised,
      onSecondaryContainer: NaviColors.textPrimary,
      tertiary: NaviColors.textSecondary,
      surface: NaviColors.canvas,
      onSurface: NaviColors.textPrimary,
      onSurfaceVariant: NaviColors.textSecondary,
      surfaceContainerLowest: NaviColors.canvas,
      surfaceContainerLow: Color(0xFF151517),
      surfaceContainer: NaviColors.surface,
      surfaceContainerHigh: Color(0xFF242426),
      surfaceContainerHighest: NaviColors.surfaceRaised,
      surfaceTint: Colors.transparent,
      outline: NaviColors.controlBorder,
      outlineVariant: NaviColors.separator,
      inverseSurface: NaviColors.textPrimary,
      onInverseSurface: NaviColors.canvas,
      error: NaviColors.destructive,
      onError: NaviColors.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: NaviColors.canvas,
      canvasColor: NaviColors.canvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: NaviColors.separator,
      dividerTheme: const DividerThemeData(
        color: NaviColors.separator,
        thickness: 1,
      ),
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: NaviColors.textPrimary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NaviColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: NaviColors.textPrimary),
        titleTextStyle: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 30,
          height: 1.08,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 24,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        // headlineSmall, titleSmall, bodySmall and labelSmall keep their
        // Material size, weight and colour; only the tracking is Apple-like.
        headlineSmall: TextStyle(letterSpacing: -0.2),
        titleLarge: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 20,
          height: 1.15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 16,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleSmall: TextStyle(letterSpacing: 0),
        bodyLarge: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 16,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: NaviColors.textSecondary,
          fontSize: 14,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(letterSpacing: 0),
        labelLarge: TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          color: NaviColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(letterSpacing: 0),
      ),
      cardTheme: const CardThemeData(
        color: NaviColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(NaviRadii.card)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: NaviColors.surface,
        hintStyle: TextStyle(color: NaviColors.textTertiary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(NaviRadii.row)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(NaviRadii.row)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(NaviRadii.row)),
          borderSide: BorderSide(color: NaviColors.textSecondary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NaviColors.surface,
        selectedColor: NaviColors.surfaceRaised,
        disabledColor: NaviColors.surface,
        side: const BorderSide(color: NaviColors.separator),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NaviRadii.row),
        ),
        labelStyle: const TextStyle(
          color: NaviColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        secondaryLabelStyle: const TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        checkmarkColor: NaviColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: NaviColors.textPrimary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
        thumbColor: NaviColors.textPrimary,
        overlayColor: Colors.white.withValues(alpha: 0.1),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 17),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NaviColors.textPrimary,
          foregroundColor: NaviColors.canvas,
          disabledBackgroundColor: NaviColors.surfaceRaised,
          disabledForegroundColor: NaviColors.textTertiary,
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 46),
          padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.md),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NaviColors.textPrimary,
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 46),
          side: const BorderSide(color: Color(0x24FFFFFF)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: NaviColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: NaviColors.surfaceRaised,
        contentTextStyle: const TextStyle(
          color: NaviColors.textPrimary,
          fontSize: 14,
        ),
        actionTextColor: NaviColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NaviRadii.row),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NaviColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NaviRadii.card),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: NaviColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NaviRadii.row),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NaviColors.textPrimary,
        linearTrackColor: Color(0x1AFFFFFF),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NaviColors.canvas
              : NaviColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NaviColors.textPrimary
              : NaviColors.surfaceRaised,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(
          NaviColors.controlBorder,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: NaviColors.textPrimary,
        selectionColor: NaviColors.textPrimary.withValues(alpha: 0.24),
        selectionHandleColor: NaviColors.textPrimary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: NaviColors.textSecondary,
        textColor: NaviColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: NaviColors.textPrimary, size: 22),
    );
  }
}
