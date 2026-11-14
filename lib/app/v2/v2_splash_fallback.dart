import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_widgets.dart';

/// The app's launch state: one small mark with indeterminate progress on the
/// same black canvas as the blank native splash.
class V2SplashFallback extends StatelessWidget {
  const V2SplashFallback({super.key});

  static const markAsset = 'assets/branding/splash-mark.png';

  @override
  Widget build(BuildContext context) {
    final markWidth = MediaQuery.sizeOf(context).width * 0.3;
    return ColoredBox(
      color: NaviColors.canvas,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Image.asset(
              V2SplashFallback.markAsset,
              width: markWidth,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.sizeOf(context).height / 2 + markWidth / 2,
            child: const NaviInlineProgress(),
          ),
        ],
      ),
    );
  }
}
