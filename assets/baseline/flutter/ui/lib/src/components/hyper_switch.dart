import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import '../theme/hyper_surface_theme.dart';
import '../theme/hyper_ui_theme.dart';
import 'hyper_control_surface.dart';
import 'hyper_glass_source.dart';
import 'hyper_list_tile.dart';
import 'hyper_switch_motion.dart';

/// 受控开关；布局保持 52×32，镜片的弹性只改变绘制。
class HyperSwitch extends StatefulWidget {
  const HyperSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
  });
  final bool value, enabled;
  final ValueChanged<bool>? onChanged;
  final String? label;
  @override
  State<HyperSwitch> createState() => _HyperSwitchState();
}

class _HyperSwitchState extends State<HyperSwitch> {
  bool _rowPressed = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onChanged != null;
    final control = _HyperSwitchControl(
      value: widget.value,
      onChanged: active ? widget.onChanged : null,
      rowPressed: active && _rowPressed,
    );
    if (widget.label == null) return control;
    return Listener(
      onPointerDown: active ? (_) => setState(() => _rowPressed = true) : null,
      onPointerUp: (_) => setState(() => _rowPressed = false),
      onPointerCancel: (_) => setState(() => _rowPressed = false),
      child: HyperListTile(
        type: 'plain',
        title: widget.label!,
        trailing: control,
        enabled: active,
        showChevron: false,
        onPressed: active ? () => widget.onChanged!(!widget.value) : null,
      ),
    );
  }
}

class _HyperSwitchControl extends StatefulWidget {
  const _HyperSwitchControl({
    required this.value,
    required this.onChanged,
    required this.rowPressed,
  });
  final bool value, rowPressed;
  final ValueChanged<bool>? onChanged;
  @override
  State<_HyperSwitchControl> createState() => _HyperSwitchControlState();
}

class _HyperSwitchControlState extends State<_HyperSwitchControl> {
  final _trackSource = HyperGlassSourceController();
  bool _pressed = false;
  double? _dragTarget;
  double _downX = 0, _initial = 0;
  int? _pointer;

  @override
  void didUpdateWidget(_HyperSwitchControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged == null) {
      _pressed = false;
      _dragTarget = null;
      _pointer = null;
    }
  }

  void _release() => setState(() {
    _pressed = false;
    _pointer = null;
  });
  void _cancel() => setState(() {
    _pressed = false;
    _pointer = null;
    _dragTarget = null;
  });
  @override
  void dispose() {
    _trackSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.onChanged != null;
    final theme = HyperUiTheme.of(context);
    final light = theme.brightness == Brightness.light;
    final glass = HyperSurfaceTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final checked = theme.tokens.primary.withValues(alpha: light ? 0.74 : 0.64);
    final unchecked = Color.fromRGBO(255, 255, 255, light ? 0.46 : 0.12);
    final source = HyperGlassSourceScope.maybeOf(context);
    void toggle() => widget.onChanged?.call(!widget.value);
    return Semantics(
      toggled: widget.value,
      enabled: active,
      onTap: active ? toggle : null,
      child: Listener(
        onPointerDown: active
            ? (event) {
                if (_pointer != null) return;
                setState(() {
                  _pointer = event.pointer;
                  _pressed = true;
                  _downX = event.localPosition.dx;
                  _initial = widget.value ? 1 : 0;
                });
              }
            : null,
        onPointerUp: (event) {
          if (_pointer == event.pointer) _release();
        },
        onPointerCancel: (event) {
          if (_pointer == event.pointer) _cancel();
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            gestureSettings: const DeviceGestureSettings(touchSlop: 0),
          ),
          child: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: active ? toggle : null,
            onTapCancel: () {
              if (_dragTarget == null) setState(() => _pressed = false);
            },
            onHorizontalDragStart: active
                ? (_) => setState(() {
                    _dragTarget = _initial;
                    _pressed = true;
                  })
                : null,
            onHorizontalDragUpdate: active
                ? (details) => setState(() {
                    _dragTarget =
                        (_initial +
                                (details.localPosition.dx - _downX) /
                                    20 *
                                    (rtl ? -1 : 1))
                            .clamp(0, 1);
                  })
                : null,
            onHorizontalDragEnd: active
                ? (_) {
                    final selected = (_dragTarget ?? _initial) >= 0.5;
                    _cancel();
                    widget.onChanged?.call(selected);
                  }
                : null,
            onHorizontalDragCancel: _cancel,
            child: HyperSwitchMotion(
              target: active
                  ? _dragTarget ?? (widget.value ? 1 : 0)
                  : (widget.value ? 1 : 0),
              pressed: _pressed || widget.rowPressed,
              enabled: active,
              builder: (context, motion) {
                final fraction = motion.position.clamp(0.0, 1.0);
                final track = Color.lerp(
                  unchecked,
                  active ? checked : checked.withAlpha(90),
                  fraction,
                )!;
                return SizedBox(
                  width: 52,
                  height: 32,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: HyperGlassSource(
                          controller: _trackSource,
                          child: HyperControlSurface(
                            radius: 16,
                            role: HyperControlSurfaceRole.button,
                            color: track,
                            sources: [if (source != null) source],
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 5 + 20 * motion.position,
                        top: 5,
                        width: 22,
                        height: 22,
                        child: Transform(
                          transform: Matrix4.diagonal3Values(
                            motion.scaleX,
                            motion.scaleY,
                            1,
                          ),
                          alignment: Alignment.center,
                          child: active
                              ? HyperControlSurface(
                                  radius: 11,
                                  role: HyperControlSurfaceRole.switchThumb,
                                  progress: motion.progress,
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  sources: [
                                    if (source != null) source,
                                    _trackSource,
                                  ],
                                  scaleSource: _trackSource,
                                  sourceScale: Offset(
                                    2 / 3 + motion.progress / 12,
                                    0.75 * motion.progress,
                                  ),
                                  child: const SizedBox.expand(),
                                )
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      1,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: glass.shadow.withValues(
                                          alpha: glass.shadow.a * 0.5,
                                        ),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
