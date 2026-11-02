import 'package:flutter/widgets.dart';

import '../theme/hyper_ui_effects.dart';

/// 为触控组件提供统一的即时按压反馈。
///
/// 按下时立即响应，松开与取消时从当前展示状态恢复。组件只处理交互状态，
/// 不决定颜色或业务行为，因此可安全复用于按钮、菜单行与卡片。
class HyperPressable extends StatefulWidget {
  const HyperPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPressed,
    this.enabled = true,
    this.pressedScale = 0.975,
    this.pressedOpacity = 0.92,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// 长按操作与普通点击共用控件的可用状态和按压反馈。
  final VoidCallback? onLongPressed;
  final bool enabled;
  final double pressedScale;
  final double pressedOpacity;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<HyperPressable> createState() => _HyperPressableState();
}

class _HyperPressableState extends State<HyperPressable> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPressed != null);

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(HyperPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 业务可能在按住期间禁用按钮，及时恢复视觉状态。
    if (!_interactive) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion
        ? HyperUiEffects.reducedDuration
        : (_pressed
              ? HyperUiEffects.pressInDuration
              : HyperUiEffects.pressOutDuration);

    return MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _interactive ? (_) => _setPressed(true) : null,
        onTapUp: _interactive ? (_) => _setPressed(false) : null,
        onTapCancel: _interactive ? () => _setPressed(false) : null,
        onTap: _interactive ? widget.onPressed : null,
        onLongPressStart: _interactive && widget.onLongPressed != null
            ? (_) => _setPressed(true)
            : null,
        onLongPress: _interactive ? widget.onLongPressed : null,
        onLongPressEnd: _interactive && widget.onLongPressed != null
            ? (_) => _setPressed(false)
            : null,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? widget.pressedScale : 1,
          duration: reduceMotion ? Duration.zero : duration,
          curve: HyperUiEffects.pressCurve,
          child: AnimatedOpacity(
            opacity: _pressed ? widget.pressedOpacity : 1,
            duration: duration,
            curve: HyperUiEffects.pressCurve,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
