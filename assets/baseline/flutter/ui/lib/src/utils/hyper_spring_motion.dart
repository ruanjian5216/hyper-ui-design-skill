import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// 与 Compose 共用临界阻尼弹簧；只驱动视觉值，不提交业务状态。
class HyperSpringMotion extends StatefulWidget {
  const HyperSpringMotion({
    super.key,
    required this.value,
    required this.builder,
    this.immediate = false,
  });

  final double value;
  final bool immediate;
  final Widget Function(BuildContext, double) builder;

  @override
  State<HyperSpringMotion> createState() => _HyperSpringMotionState();
}

class _HyperSpringMotionState extends State<HyperSpringMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.value,
  );
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 1000,
    damping: 63.2455532,
  );

  @override
  void didUpdateWidget(HyperSpringMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value &&
        widget.immediate == oldWidget.immediate)
      return;
    if (widget.immediate || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.value;
    } else {
      _controller.animateWith(
        SpringSimulation(
          _spring,
          _controller.value,
          widget.value,
          _controller.velocity,
          tolerance: const Tolerance(distance: 0.001, velocity: 0.001),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => widget.builder(context, _controller.value),
  );
}
