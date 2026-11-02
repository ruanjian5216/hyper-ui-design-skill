import 'dart:math' as math;
import 'package:flutter/physics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Switch 的五条弹簧通道；仅驱动绘制，不决定业务值。
class HyperSwitchMotion extends StatefulWidget {
  const HyperSwitchMotion({
    super.key,
    required this.target,
    required this.pressed,
    required this.enabled,
    required this.builder,
  });
  final double target;
  final bool pressed, enabled;
  final Widget Function(BuildContext, HyperSwitchMotionFrame) builder;
  @override
  State<HyperSwitchMotion> createState() => _HyperSwitchMotionState();
}

class HyperSwitchMotionFrame {
  const HyperSwitchMotionFrame(
    this.position,
    this.progress,
    this.scaleX,
    this.scaleY,
  );
  final double position, progress, scaleX, scaleY;
}

class _HyperSwitchMotionState extends State<HyperSwitchMotion>
    with TickerProviderStateMixin {
  late final _position = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  )..addListener(_tick);
  late final _press = AnimationController.unbounded(vsync: this);
  late final _scaleX = AnimationController.unbounded(vsync: this, value: 1);
  late final _scaleY = AnimationController.unbounded(vsync: this, value: 1);
  late final _velocity = AnimationController.unbounded(vsync: this);
  bool _active = false, _reduced = false;
  double _velocityTarget = 0;
  var _tracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  void _spring(
    AnimationController controller,
    double target,
    double ratio,
    double stiffness, {
    double threshold = 0.001,
  }) {
    if (_reduced || !widget.enabled) {
      controller.value = target;
      return;
    }
    controller.animateWith(
      SpringSimulation(
        SpringDescription(
          mass: 1,
          stiffness: stiffness,
          damping: 2 * ratio * math.sqrt(stiffness),
        ),
        controller.value,
        target,
        controller.velocity,
        tolerance: Tolerance(distance: threshold, velocity: threshold),
      ),
    );
  }

  void _syncPress() {
    final active =
        widget.enabled &&
        !_reduced &&
        (widget.pressed || (_position.value - widget.target).abs() >= 0.025);
    if (active == _active) return;
    _active = active;
    if (active) _tracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    _spring(_press, active ? 1 : 0, 1, 1000);
    _spring(_scaleX, active ? 1.5 : 1, 0.6, 250);
    _spring(_scaleY, active ? 1.5 : 1, 0.7, 250);
  }

  void _tick() {
    _syncPress();
    _tracker.addPosition(
      Duration(microseconds: DateTime.now().microsecondsSinceEpoch),
      Offset(_position.value, 0),
    );
    final target = _active ? _tracker.getVelocity().pixelsPerSecond.dx : 0.0;
    if ((target - _velocityTarget).abs() >= 0.01) {
      _velocityTarget = target;
      _spring(_velocity, target, 0.5, 300, threshold: 0.01);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) _position.value = widget.target;
    _syncPress();
  }

  @override
  void didUpdateWidget(HyperSwitchMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target ||
        widget.enabled != oldWidget.enabled)
      _spring(_position, widget.target, 1, 1000);
    _syncPress();
  }

  @override
  void dispose() {
    for (final controller in [_position, _press, _scaleX, _scaleY, _velocity]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      _position,
      _press,
      _scaleX,
      _scaleY,
      _velocity,
    ]),
    builder: (context, _) => widget.builder(
      context,
      !widget.enabled || _reduced
          ? HyperSwitchMotionFrame(widget.target, 0, 1, 1)
          : HyperSwitchMotionFrame(
              _position.value,
              _press.value.clamp(0, 1),
              _scaleX.value /
                  (1 - (_velocity.value / 50 * 0.75).clamp(-0.2, 0.2)),
              _scaleY.value *
                  (1 - (_velocity.value / 50 * 0.25).clamp(-0.2, 0.2)),
            ),
    ),
  );
}
