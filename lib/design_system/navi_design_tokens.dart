import 'package:flutter/material.dart';

/// True-black listening-room palette. Album artwork carries the colour; the
/// warm VU-meter accent only marks playback and other live state.
abstract final class NaviColors {
  static const canvas = Color(0xFF000000);
  static const surface = Color(0xFF111111);
  static const surfaceRaised = Color(0xFF2A2A2A);
  static const glass = surface;
  static const glassOpaque = surface;
  static const glassBorder = border;
  static const modalGlassTop = surfaceRaised;
  static const modalGlassBottom = surface;
  static const modalGlassBorder = border;
  static const modalBarrier = Color(0xB3000000);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB4B4B4);
  static const textTertiary = Color(0xFF949494);
  static const accent = Color(0xFFE9A23B);
  static const accentWarm = accent;
  static const accentViolet = accent;
  static const atmosphereWine = canvas;
  static const atmospherePlum = canvas;
  static const destructive = Color(0xFFE5484D);
  static const success = accent;
  static const separator = Color(0xFF1A1A1A);
  static const border = Color(0xFF1A1A1A);
  static const controlBorder = Color(0xFF444444);
}

/// Depth is reserved for genuinely floating content. Resting tiles use tone
/// steps and one-pixel rules instead.
abstract final class NaviShadows {
  static const elevated = <BoxShadow>[];
  static const resting = <BoxShadow>[];

  static const modal = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 28,
      offset: Offset(0, 14),
      blurStyle: BlurStyle.outer,
    ),
  ];
}

abstract final class NaviSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const page = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 44.0;
}

abstract final class NaviRadii {
  static const row = 8.0;
  static const card = 16.0;
  static const artwork = 16.0;
  static const glass = 16.0;
  static const dock = 0.0;
  static const control = 999.0;
}

/// State motion only: short, direct and quiet.
abstract final class NaviMotion {
  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 180);
  static const page = Duration(milliseconds: 240);
  static const artworkFlip = Duration(milliseconds: 320);
  static const ambient = Duration(seconds: 18);

  static const curve = Curves.easeOutCubic;

  /// True when the system asks for reduced motion; callers collapse
  /// durations to zero and replace scale/3D transitions with fades.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
