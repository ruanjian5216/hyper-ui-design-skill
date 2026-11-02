import 'package:flutter/widgets.dart';

import 'hyper_surface_theme.dart';
import 'hyper_ui_theme_tokens.dart';

/// Hyper UI's own visual configuration.
@immutable
class HyperUiThemeData {
  const HyperUiThemeData({
    required this.brightness,
    required this.tokens,
    this.fontFamily,
  });

  final Brightness brightness;
  final HyperUiThemeTokens tokens;
  final String? fontFamily;

  HyperSurfaceTheme get surfaces => brightness == Brightness.dark
      ? HyperSurfaceTheme.dark()
      : HyperSurfaceTheme.light();

  TextStyle get textStyle => TextStyle(
    color: tokens.foreground,
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    decoration: TextDecoration.none,
  );

  HyperUiThemeData copyWith({
    Brightness? brightness,
    HyperUiThemeTokens? tokens,
    String? fontFamily,
  }) => HyperUiThemeData(
    brightness: brightness ?? this.brightness,
    tokens: tokens ?? this.tokens,
    fontFamily: fontFamily ?? this.fontFamily,
  );
}

/// Provides Hyper colors, typography, and solid surfaces to descendants.
class HyperUiTheme extends StatelessWidget {
  const HyperUiTheme({super.key, required this.data, required this.child});

  final HyperUiThemeData data;
  final Widget child;

  /// A ready-to-use app host. Supply [brightness] only when overriding the system.
  static Widget app({
    required Widget home,
    String title = 'Hyper UI',
    Brightness? brightness,
    Color? primary,
    String? fontFamily,
    TransitionBuilder? builder,
  }) => _HyperApp(
    home: home,
    title: title,
    brightness: brightness,
    primary: primary,
    fontFamily: fontFamily,
    builder: builder,
  );

  static HyperUiThemeData light({Color? primary, String? fontFamily}) =>
      HyperUiThemeData(
        brightness: Brightness.light,
        tokens: HyperUiThemeTokens.light(primary: primary),
        fontFamily: fontFamily,
      );

  static HyperUiThemeData dark({Color? primary, String? fontFamily}) =>
      HyperUiThemeData(
        brightness: Brightness.dark,
        tokens: HyperUiThemeTokens.dark(primary: primary),
        fontFamily: fontFamily,
      );

  static HyperUiThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HyperUiThemeScope>()?.data ??
      light();

  @override
  Widget build(BuildContext context) => _HyperUiThemeScope(
    data: data,
    child: _HyperTextDefaults(data: data, child: child),
  );
}

class _HyperUiThemeScope extends InheritedWidget {
  const _HyperUiThemeScope({required this.data, required super.child});

  final HyperUiThemeData data;

  @override
  bool updateShouldNotify(_HyperUiThemeScope oldWidget) =>
      data != oldWidget.data;
}

/// 给独立路由和浮层提供明确的文字与图标基线，避免 Flutter 调试回退样式。
class _HyperTextDefaults extends StatelessWidget {
  const _HyperTextDefaults({required this.data, required this.child});

  final HyperUiThemeData data;
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
    style: data.textStyle,
    child: IconTheme(
      data: IconThemeData(color: data.tokens.foreground, size: 24),
      child: child,
    ),
  );
}

class _HyperApp extends StatefulWidget {
  const _HyperApp({
    required this.home,
    required this.title,
    this.brightness,
    this.primary,
    this.fontFamily,
    this.builder,
  });

  final Widget home;
  final String title;
  final Brightness? brightness;
  final Color? primary;
  final String? fontFamily;
  final TransitionBuilder? builder;

  @override
  State<_HyperApp> createState() => _HyperAppState();
}

class _HyperAppState extends State<_HyperApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    if (widget.brightness == null) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBrightness =
        widget.brightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final theme = resolvedBrightness == Brightness.dark
        ? HyperUiTheme.dark(
            primary: widget.primary,
            fontFamily: widget.fontFamily,
          )
        : HyperUiTheme.light(
            primary: widget.primary,
            fontFamily: widget.fontFamily,
          );
    return HyperUiTheme(
      data: theme,
      child: WidgetsApp(
        title: widget.title,
        debugShowCheckedModeBanner: false,
        color: theme.tokens.background,
        textStyle: theme.textStyle,
        pageRouteBuilder: <T>(settings, page) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              page(context),
        ),
        builder: widget.builder,
        home: widget.home,
      ),
    );
  }
}
