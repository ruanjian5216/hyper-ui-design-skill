import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// 法线 Ambient 高光与内阴影分层；沿用参考的遮罩、模糊与合成顺序。
class HyperSwitchEdgePainter extends CustomPainter {
  HyperSwitchEdgePainter({
    required this.radius,
    required this.progress,
    required this.density,
    required this.shader,
  });
  final double radius, progress, density;
  final ui.FragmentShader? shader;
  ui.Image? _mask;

  void disposeMask() {
    _mask?.dispose();
    _mask = null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(shape);
    _ambient(canvas, size, shape);
    // 参考 InnerShadow 在 Ambient 之上：填充原轮廓，再清除向下偏移的轮廓，最后模糊。
    canvas.saveLayer(
      rect.inflate(8),
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: 4 * progress,
          sigmaY: 4 * progress,
        ),
    );
    canvas.drawRRect(
      shape,
      Paint()..color = Color.fromRGBO(0, 0, 0, 0.15 * progress),
    );
    canvas.drawRRect(
      shape.shift(Offset(0, 4 * progress)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
    canvas.restore();
  }

  void _ambient(Canvas canvas, Size size, RRect shape) {
    final width = (0.5 / 1.5 * density).ceil() * 2 / density;
    final padding = 1 / density;
    final rect = Offset.zero & size;
    if (shader == null) {
      canvas.drawRRect(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = Color.fromRGBO(255, 255, 255, 0.38 * progress)
          ..maskFilter = const ui.MaskFilter.blur(
            ui.BlurStyle.normal,
            0.25 / 1.5,
          ),
      );
      return;
    }
    final recorder = ui.PictureRecorder();
    final mask = Canvas(recorder)
      ..scale(2)
      ..translate(padding, padding);
    mask.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = const Color.fromRGBO(255, 255, 255, 0.38)
        ..maskFilter = const ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          0.25 / 1.5,
        ),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      ((size.width + 2 * padding) * 2).ceil(),
      ((size.height + 2 * padding) * 2).ceil(),
    );
    picture.dispose();
    final previous = _mask;
    _mask = image;
    final values = [
      size.width,
      size.height,
      padding,
      radius,
      radius,
      radius,
      radius,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ];
    for (var index = 0; index < values.length; index++) {
      shader!.setFloat(index, values[index]);
    }
    shader!.setImageSampler(0, image);
    canvas.saveLayer(
      rect.inflate(padding),
      Paint()..color = Color.fromRGBO(255, 255, 255, progress),
    );
    canvas.drawRect(rect, Paint()..shader = shader);
    canvas.restore();
    previous?.dispose();
  }

  @override
  bool shouldRepaint(HyperSwitchEdgePainter oldDelegate) =>
      radius != oldDelegate.radius ||
      progress != oldDelegate.progress ||
      density != oldDelegate.density ||
      shader != oldDelegate.shader;
}
