import 'package:flutter/widgets.dart';
import 'hyper_glass_source.dart';

import '../theme/hyper_ui_theme.dart';
import '../theme/hyper_ui_effects.dart';
import '../utils/hyper_overlay_motion.dart';

/// Hosts a Hyper surface in a route and keeps the caller's theme available.
Future<T?> showHyperModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Alignment alignment = Alignment.center,
  bool dismissible = true,
  Color? scrim,
}) async {
  final theme = HyperUiTheme.of(context);
  final glassSource = HyperGlassSourceScope.maybeOf(context);
  final barrier = scrim ?? theme.surfaces.scrim;
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  final route = RawDialogRoute<T>(
    barrierDismissible: false,
    barrierColor: const Color(0x00000000),
    transitionDuration: reduceMotion
        ? HyperUiEffects.reducedDuration
        : HyperUiEffects.modalDuration,
    pageBuilder: (routeContext, animation, secondaryAnimation) => HyperUiTheme(
      data: theme,
      child: Stack(
        children: <Widget>[
          // 遮罩保持全视口；系统栏与键盘的避让只属于面板，不包裹这一层。
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: dismissible ? () => Navigator.pop(routeContext) : null,
              child: FadeTransition(
                opacity: animation,
                child: ColoredBox(color: barrier),
              ),
            ),
          ),
          Align(
            alignment: alignment,
            child: buildHySurfaceTransition(
              animation: animation,
              curve: HyperUiEffects.overlayCurve,
              // 底部选择器沿竖直方向进退，对话框保持居中轻缩放。
              beginScale: alignment.y == 0 ? 0.96 : 1,
              offset: Offset(0, alignment.y * 24),
              child: glassSource == null
                  ? Builder(builder: builder)
                  : HyperGlassSourceScope(
                      source: glassSource,
                      child: Builder(builder: builder),
                    ),
            ),
          ),
        ],
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => IgnorePointer(
            // 退出中的路由仍参与绘制，但不再接受点击或操作底下的路由。
            ignoring:
                animation.status == AnimationStatus.reverse ||
                animation.status == AnimationStatus.dismissed,
            child: child,
          ),
        ),
  );
  final result = await Navigator.of(context, rootNavigator: true).push(route);
  // 返回结果与退出动画是两个阶段；调用方继续导航前，先释放旧弹层。
  await route.completed;
  return result;
}
