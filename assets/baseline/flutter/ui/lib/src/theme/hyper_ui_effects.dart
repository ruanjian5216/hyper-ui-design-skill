import 'package:flutter/widgets.dart';

abstract final class HyperUiEffects {
  static const Duration pressInDuration = Duration(milliseconds: 85);
  static const Duration pressOutDuration = Duration(milliseconds: 180);
  static const Duration selectionDuration = Duration(milliseconds: 260);
  static const Duration overlayDuration = Duration(milliseconds: 280);
  static const Duration menuDuration = Duration(milliseconds: 180);
  static const Duration tooltipDuration = Duration(milliseconds: 125);
  static const Duration stateDuration = Duration(milliseconds: 160);
  static const Duration collapseDuration = Duration(milliseconds: 200);
  static const Duration modalDuration = Duration(milliseconds: 250);
  static const Duration reducedDuration = Duration(milliseconds: 100);

  static const Curve pressCurve = Cubic(0.23, 1, 0.32, 1);
  static const Curve selectionCurve = Cubic(0.77, 0, 0.175, 1);
  static const Curve overlayCurve = Cubic(0.23, 1, 0.32, 1);

  /// 颜色与透明度在减少动态效果时保留短过渡，位移由组件自行关闭。
  static Duration durationOf(BuildContext context, Duration duration) =>
      MediaQuery.maybeOf(context)?.disableAnimations == true
          ? reducedDuration
          : duration;

  /// 用于拖拽释放后的吸附。阻尼接近临界值，快速且不过度弹跳。
  static const SpringDescription settleSpring = SpringDescription(
    mass: 1,
    stiffness: 470,
    damping: 42,
  );
}
