import 'package:flutter/widgets.dart';

import '../theme/hyper_ui_effects.dart';
import 'hyper_control_surface.dart';

/// Button 配色、禁用态与共用玻璃样式的适配；只持有瞬时按压状态，不决定业务行为。
class HyperButtonSurface extends StatefulWidget {
  const HyperButtonSurface({
    super.key,
    required this.child,
    required this.radius,
    required this.enabled,
    required this.interactive,
    required this.color,
    required this.border,
  });
  final Widget child;
  final double radius;
  final bool enabled, interactive;
  final Color? color;
  final Border? border;

  @override
  State<HyperButtonSurface> createState() => _HyperButtonSurfaceState();
}

class _HyperButtonSurfaceState extends State<HyperButtonSurface> {
  int? _pointer;
  bool _pressed = false;

  @override
  void didUpdateWidget(HyperButtonSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactive) {
      _pressed = false;
      _pointer = null;
    }
  }

  void _release(int pointer) {
    if (_pointer != pointer) return;
    setState(() {
      _pointer = null;
      _pressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(widget.radius);
    if (!widget.enabled)
      return DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color,
          border: widget.border,
          borderRadius: shape,
        ),
        child: ClipRRect(borderRadius: shape, child: widget.child),
      );
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: (event) {
        if (!widget.interactive || _pointer != null) return;
        setState(() {
          _pointer = event.pointer;
          _pressed = true;
        });
      },
      onPointerMove: (event) {
        if (_pointer != event.pointer) return;
        final box = context.findRenderObject();
        if (box is RenderBox &&
            !(Offset.zero & box.size).contains(event.localPosition))
          _release(event.pointer);
      },
      onPointerUp: (event) => _release(event.pointer),
      onPointerCancel: (event) => _release(event.pointer),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _pressed ? 1 : 0),
        duration: reduced
            ? Duration.zero
            : _pressed
            ? HyperUiEffects.pressInDuration
            : HyperUiEffects.pressOutDuration,
        curve: HyperUiEffects.pressCurve,
        child: widget.child,
        builder: (context, progress, child) => Transform.scale(
          scale: reduced ? 1 : 1 - 0.025 * progress,
          child: Opacity(
            opacity: 1 - 0.08 * progress,
            child: HyperControlSurface(
              radius: widget.radius,
              role: HyperControlSurfaceRole.button,
              progress: progress,
              color: widget.color,
              border: widget.border,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
