import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_chrome_style.dart';
import '../../design_system/widgets/navi_persistent_dock.dart';

enum V2Tab { home, favorites, playlists, library, search }

class V2TabSpec {
  const V2TabSpec({required this.destination, required this.rootBuilder});

  final NaviDockDestination destination;
  final WidgetBuilder rootBuilder;
}

/// Exposes tab activation without rebuilding or recreating any navigator.
/// Search uses the activation counter to focus its field both when selected
/// and when its already-selected tab is tapped again.
class V2TabActivity extends InheritedWidget {
  const V2TabActivity({
    super.key,
    required this.isActive,
    required this.activation,
    required super.child,
  });

  final bool isActive;
  final int activation;

  static V2TabActivity? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<V2TabActivity>();

  @override
  bool updateShouldNotify(V2TabActivity oldWidget) =>
      isActive != oldWidget.isActive || activation != oldWidget.activation;
}

/// Root shell for V2. Every tab owns a navigator, while the playback dock is a
/// sibling above them and therefore remains visible on all detail routes.
class V2Shell extends StatefulWidget {
  const V2Shell({
    super.key,
    required this.tabs,
    this.initialTab = V2Tab.home,
    this.nowPlaying,
    this.onOpenPlayer,
    this.onTogglePlayback,
    this.onSkipPrevious,
    this.onSkipNext,
    this.topBarTransparency = NaviChromeStyle.defaultTopBarTransparency,
    this.topBarBlurSigma = NaviChromeStyle.defaultTopBarBlurSigma,
  }) : assert(tabs.length == 5);

  final List<V2TabSpec> tabs;
  final V2Tab initialTab;
  final NaviMiniPlayerData? nowPlaying;
  final VoidCallback? onOpenPlayer;
  final VoidCallback? onTogglePlayback;
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onSkipNext;
  final double topBarTransparency;
  final double topBarBlurSigma;

  @override
  State<V2Shell> createState() => _V2ShellState();
}

class _V2ShellState extends State<V2Shell> {
  late int _selectedIndex = widget.initialTab.index;
  var _activation = 0;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    V2Tab.values.length,
    (index) => GlobalKey<NavigatorState>(debugLabel: V2Tab.values[index].name),
  );

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final dockContentHeight = widget.nowPlaying == null ? 68.0 : 132.0;
    final dockClearance = keyboardVisible ? 0.0 : dockContentHeight;
    return NaviChromeStyle(
      topBarTransparency: widget.topBarTransparency,
      topBarBlurSigma: widget.topBarBlurSigma,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _handleSystemBack();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPadding(
                key: const ValueKey('navi-content-area'),
                duration: NaviMotion.standard,
                curve: NaviMotion.curve,
                padding: EdgeInsets.only(bottom: dockClearance),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    for (var index = 0; index < widget.tabs.length; index++)
                      V2TabActivity(
                        isActive: index == _selectedIndex,
                        activation: index == _selectedIndex ? _activation : -1,
                        child: TickerMode(
                          enabled: index == _selectedIndex,
                          child: Navigator(
                            key: _navigatorKeys[index],
                            onGenerateRoute: (settings) =>
                                MaterialPageRoute<void>(
                                  settings: settings,
                                  builder: widget.tabs[index].rootBuilder,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  ignoring: keyboardVisible,
                  child: AnimatedSlide(
                    offset: keyboardVisible
                        ? const Offset(0, 1.2)
                        : Offset.zero,
                    duration: NaviMotion.standard,
                    curve: NaviMotion.curve,
                    child: AnimatedOpacity(
                      opacity: keyboardVisible ? 0 : 1,
                      duration: NaviMotion.micro,
                      child: NaviPersistentDock(
                        destinations: widget.tabs
                            .map((tab) => tab.destination)
                            .toList(growable: false),
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _selectTab,
                        nowPlaying: widget.nowPlaying,
                        onOpenPlayer: widget.onOpenPlayer,
                        onTogglePlayback: widget.onTogglePlayback,
                        onSkipPrevious: widget.onSkipPrevious,
                        onSkipNext: widget.onSkipNext,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      setState(() => _activation++);
      return;
    }
    setState(() {
      _selectedIndex = index;
      _activation++;
    });
  }

  Future<void> _handleSystemBack() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && await navigator.maybePop()) return;
    if (_selectedIndex != V2Tab.home.index && mounted) {
      setState(() => _selectedIndex = V2Tab.home.index);
    }
  }
}
