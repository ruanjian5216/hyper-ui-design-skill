import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import '../theme/hyper_ui_theme.dart';
import 'hyper_glass_source.dart';
import 'hyper_glass_painter.dart';
import 'hyper_glass_style.dart';
import 'hyper_switch_edge_painter.dart';

/// 固定组件玻璃，不提供全局材质档位；绘制与子组件布局独立。
enum HyperControlSurfaceRole {
  navigation,
  button,
  selection,
  thumb,
  switchThumb,
  dialog,
  compact,
  field,
  track,
  panel,
  drawer,
}

class HyperControlSurface extends StatefulWidget {
  const HyperControlSurface({
    super.key,
    required this.radius,
    required this.role,
    required this.child,
    this.progress = 0,
    this.color,
    this.sources,
    this.tintSource,
    this.tint,
    this.scaleSource,
    this.sourceScale = const Offset(1, 1),
    this.border,
  });
  final double radius, progress;
  final HyperControlSurfaceRole role;
  final Color? color, tint;
  final Widget child;
  final List<HyperGlassSourceController>? sources;
  final HyperGlassSourceController? tintSource, scaleSource;
  final Offset sourceScale;
  final Border? border;
  @override
  State<HyperControlSurface> createState() => _HyperControlSurfaceState();
}

class _HyperControlSurfaceState extends State<HyperControlSurface> {
  final _paintKey = GlobalKey();
  ui.FragmentShader? _shader;
  ui.FragmentShader? _ambientShader;
  HyperGlassPainter? _painter;
  HyperSwitchEdgePainter? _switchEdgePainter;
  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/flutter_hyper_ui/shaders/hyper_glass.frag',
      );
      if (mounted)
        setState(() {
          _shader = program.fragmentShader();
          _ambientShader = program.fragmentShader();
        });
    } catch (_) {
      /* 着色器加载失败时保留采样和表面，不阻断控件交互。 */
    }
  }

  @override
  void dispose() {
    _painter?.disposeSample();
    _switchEdgePainter?.disposeMask();
    _shader?.dispose();
    _ambientShader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = HyperUiTheme.of(context);
    final light = theme.brightness == Brightness.light;
    final role = widget.role;
    final pressed = widget.progress.clamp(0.0, 1.0);
    final interactive =
        role == HyperControlSurfaceRole.selection ||
        role == HyperControlSurfaceRole.thumb ||
        role == HyperControlSurfaceRole.switchThumb;
    final strength = interactive ? pressed : 1.0;
    final fixedStyle = switch (role) {
      HyperControlSurfaceRole.compact => HyperGlassStyle.compact,
      HyperControlSurfaceRole.field => HyperGlassStyle.field,
      HyperControlSurfaceRole.track => HyperGlassStyle.track,
      HyperControlSurfaceRole.panel => HyperGlassStyle.panel,
      HyperControlSurfaceRole.drawer => HyperGlassStyle.drawer,
      _ => null,
    };
    final controlStyle = role == HyperControlSurfaceRole.button
        ? HyperGlassStyle.button(pressed)
        : HyperGlassStyle.navigation;
    const white = Color.fromRGBO(255, 255, 255, 1),
        black = Color.fromRGBO(0, 0, 0, 1);
    final tint = light ? white : white.withValues(alpha: 0.34);
    final blur = switch (role) {
      HyperControlSurfaceRole.navigation ||
      HyperControlSurfaceRole.button => controlStyle.blur,
      HyperControlSurfaceRole.selection => 0.0,
      HyperControlSurfaceRole.thumb ||
      HyperControlSurfaceRole.switchThumb => 8 * (1 - pressed),
      HyperControlSurfaceRole.dialog => light ? 16.0 : 8.0,
      _ =>
        role == HyperControlSurfaceRole.drawer && !light
            ? 8.0
            : fixedStyle!.blur,
    };
    final edge = switch (role) {
      HyperControlSurfaceRole.navigation ||
      HyperControlSurfaceRole.button => controlStyle.edge,
      HyperControlSurfaceRole.dialog => 24.0 * strength,
      HyperControlSurfaceRole.switchThumb => 5.0 * strength,
      _ => (fixedStyle?.edge ?? 10.0) * strength,
    };
    final amount = switch (role) {
      HyperControlSurfaceRole.navigation ||
      HyperControlSurfaceRole.button => controlStyle.amount,
      HyperControlSurfaceRole.dialog => 48.0 * strength,
      HyperControlSurfaceRole.switchThumb => 10.0 * strength,
      _ => (fixedStyle?.amount ?? 14.0) * strength,
    };
    final fill = switch (role) {
      HyperControlSurfaceRole.navigation => (widget.color ?? tint).withValues(
        alpha: (widget.color ?? tint).a * 0.4,
      ),
      HyperControlSurfaceRole.button =>
        widget.color ?? tint.withValues(alpha: tint.a * 0.4),
      HyperControlSurfaceRole.selection => (light ? black : white).withValues(
        alpha: 0.1 * (1 - pressed),
      ),
      HyperControlSurfaceRole.switchThumb => (widget.color ?? white).withValues(
        alpha: (widget.color ?? white).a * (0.92 - 0.72 * pressed),
      ),
      HyperControlSurfaceRole.thumb => (widget.color ?? white).withValues(
        alpha: (widget.color ?? white).a * (1 - pressed),
      ),
      HyperControlSurfaceRole.dialog =>
        widget.color ?? tint.withValues(alpha: light ? 0.6 : 0.272),
      _ =>
        widget.color ??
            tint.withValues(
              alpha: role == HyperControlSurfaceRole.drawer
                  ? (light ? 0.85 : 0.28)
                  : role == HyperControlSurfaceRole.panel
                  ? (light ? 0.6 : 0.272)
                  : tint.a * 0.4,
            ),
    };
    final source = HyperGlassSourceScope.maybeOf(context);
    final sources = widget.sources ?? [if (source != null) source];
    _painter?.disposeSample();
    _painter = HyperGlassPainter(
      sources: sources,
      targetKey: _paintKey,
      shader: _shader,
      radius: widget.radius,
      blur: blur,
      edge: edge,
      amount: amount,
      dispersion: role == HyperControlSurfaceRole.switchThumb && pressed > 0
          ? 1
          : interactive
          ? pressed
          : 0,
      depth: role == HyperControlSurfaceRole.dialog ? 1 : 0,
      saturation: role == HyperControlSurfaceRole.dialog ? 1.5 : 1,
      brightness: role == HyperControlSurfaceRole.dialog && light ? 0.2 : 0,
      highlight: role == HyperControlSurfaceRole.switchThumb
          ? 0
          : role == HyperControlSurfaceRole.button
          ? controlStyle.highlight * 2
          : fixedStyle != null ? fixedStyle.highlight * 2 : strength,
      baseColor: theme.tokens.background,
      tintSource: widget.tintSource,
      tint: widget.tint,
      scaleSource: widget.scaleSource,
      sourceScale: widget.sourceScale,
      compactSampling: role == HyperControlSurfaceRole.switchThumb,
    );
    final shape = BorderRadius.circular(widget.radius);
    _switchEdgePainter?.disposeMask();
    _switchEdgePainter = role == HyperControlSurfaceRole.switchThumb
        ? HyperSwitchEdgePainter(
            radius: widget.radius,
            progress: pressed,
            density: MediaQuery.devicePixelRatioOf(context),
            shader: _ambientShader,
          )
        : null;
    final lift = role == HyperControlSurfaceRole.selection ? pressed : 1.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          if (lift > 0)
            BoxShadow(
              color: black.withValues(alpha: (light ? 0.08 : 0.18) * lift),
              offset: role == HyperControlSurfaceRole.switchThumb
                  ? const Offset(0, 4 / 6)
                  : Offset.zero,
              blurRadius:
                  fixedStyle?.shadow ??
                  (role == HyperControlSurfaceRole.button
                      ? controlStyle.shadow
                      : role == HyperControlSurfaceRole.dialog
                      ? 16
                      : role == HyperControlSurfaceRole.selection
                      ? 8
                      : interactive
                      ? 4
                      : 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: CustomPaint(
          key: _paintKey,
          painter: _painter,
          foregroundPainter: role == HyperControlSurfaceRole.switchThumb
              ? _switchEdgePainter
              : _ControlEdgePainter(
                  radius: widget.radius,
                  strength: role == HyperControlSurfaceRole.button
                      ? (widget.border == null ? controlStyle.highlight : 0)
                      : interactive
                      ? pressed
                      : fixedStyle != null && widget.border != null
                      ? 0
                      : fixedStyle?.highlight ?? 0.5,
                  navigation:
                      role == HyperControlSurfaceRole.navigation ||
                      role == HyperControlSurfaceRole.button ||
                      fixedStyle != null,
                  innerRadius: interactive
                      ? (role == HyperControlSurfaceRole.selection ? 8 : 4)
                      : 0,
                ),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: shape,
              border: widget.border,
            ),
            child: ColoredBox(color: fill, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _ControlEdgePainter extends CustomPainter {
  const _ControlEdgePainter({
    required this.radius,
    required this.strength,
    this.innerRadius = 0,
    this.navigation = false,
  });
  final double radius;
  final double strength;
  final double innerRadius;
  final bool navigation;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0 || size.isEmpty) return;
    // 导航轮廓与 Compose 一致：沿实际外缘画 0.5 描边，由父级圆角裁掉外半边。
    // 不以更粗的内缩亮边扩大单入口的视觉重量，布局与命中尺寸仍为原值。
    final rect = navigation
        ? Offset.zero & size
        : (Offset.zero & size).deflate(0.5);
    final edge = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (innerRadius > 0) {
      canvas.drawRRect(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Color.fromRGBO(0, 0, 0, 0.12 * strength)
          ..maskFilter = ui.MaskFilter.blur(
            ui.BlurStyle.normal,
            innerRadius * strength,
          ),
      );
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = navigation ? 0.5 : 0.75
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, (navigation ? 0.6 : 0.8) * strength),
          Color.fromRGBO(255, 255, 255, (navigation ? 0.04 : 0.08) * strength),
          Color.fromRGBO(255, 255, 255, (navigation ? 0.5 : 0.55) * strength),
        ],
        stops: navigation ? const [0, 0.5, 1] : const [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(edge, paint);
  }

  @override
  bool shouldRepaint(_ControlEdgePainter oldDelegate) =>
      radius != oldDelegate.radius ||
      navigation != oldDelegate.navigation ||
      strength != oldDelegate.strength ||
      innerRadius != oldDelegate.innerRadius;
}
