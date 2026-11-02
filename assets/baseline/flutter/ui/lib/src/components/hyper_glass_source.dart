import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 内部背景录制器；只录制独立背景或轨道，绝不包含取样镜片。
class HyperGlassSourceController extends ChangeNotifier {
  ui.Image? image;
  RenderRepaintBoundary? boundary;
  double pixelRatio = 1;
  bool _pending = false;
  bool _dirty = false;
  bool _disposed = false;
  void captureAfterPaint() {
    if (_disposed) return;
    _dirty = true;
    if (_pending) return;
    _pending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _dirty = false;
      final target = boundary;
      try {
        if (_disposed ||
            target == null ||
            !target.attached ||
            target.size.isEmpty)
          return;
        final next = await target.toImage(pixelRatio: pixelRatio);
        if (_disposed || boundary != target) {
          next.dispose();
          return;
        }
        final previous = image;
        image = next;
        notifyListeners();
        previous?.dispose();
      } catch (_) {
        // 节点在帧尾卸载或尚未完成绘制时保留上次有效图像，下一次绘制重试。
      } finally {
        _pending = false;
        if (_dirty && !_disposed) {
          captureAfterPaint();
          SchedulerBinding.instance.scheduleFrame();
        }
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    image?.dispose();
    image = null;
    super.dispose();
  }
}

class HyperGlassSource extends SingleChildRenderObjectWidget {
  const HyperGlassSource({
    super.key,
    required this.controller,
    required super.child,
  });
  final HyperGlassSourceController controller;
  @override
  RenderObject createRenderObject(BuildContext context) => _GlassSourceBoundary(
    controller,
    MediaQuery.devicePixelRatioOf(context).clamp(1, 2),
  );
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _GlassSourceBoundary renderObject,
  ) {
    renderObject.controller = controller;
    controller.pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1, 2);
  }
}

class _GlassSourceBoundary extends RenderRepaintBoundary {
  _GlassSourceBoundary(this.controller, double ratio) {
    controller.pixelRatio = ratio;
  }
  HyperGlassSourceController controller;
  @override
  void paint(PaintingContext context, Offset offset) {
    controller.boundary = this;
    super.paint(context, offset);
    controller.captureAfterPaint();
  }

  @override
  void detach() {
    if (controller.boundary == this) controller.boundary = null;
    super.detach();
  }
}

class HyperGlassSourceScope extends InheritedWidget {
  const HyperGlassSourceScope({
    super.key,
    required this.source,
    required super.child,
  });
  final HyperGlassSourceController source;
  static HyperGlassSourceController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<HyperGlassSourceScope>()
      ?.source;
  @override
  bool updateShouldNotify(HyperGlassSourceScope oldWidget) =>
      source != oldWidget.source;
}

/// 背景与玻璃前景分开组合；不提供主题档位，不占用额外布局空间。
class HyperBackdrop extends StatefulWidget {
  const HyperBackdrop({
    super.key,
    required this.background,
    required this.child,
  });
  final Widget background;
  final Widget child;
  @override
  State<HyperBackdrop> createState() => _HyperBackdropState();
}

class _HyperBackdropState extends State<HyperBackdrop> {
  final _source = HyperGlassSourceController();
  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HyperGlassSourceScope(
    source: _source,
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: HyperGlassSource(
            controller: _source,
            child: widget.background,
          ),
        ),
        widget.child,
      ],
    ),
  );
}
