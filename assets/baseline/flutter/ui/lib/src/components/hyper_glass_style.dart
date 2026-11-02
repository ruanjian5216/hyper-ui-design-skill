import 'package:flutter/foundation.dart';

/// 小型交互表面的内部玻璃参数；与 Kotlin 同一套单位和按压曲线，无全局材质档位。
@immutable
class HyperGlassStyle {
  const HyperGlassStyle(
    this.blur,
    this.edge,
    this.amount,
    this.shadow,
    this.highlight,
  );
  final double blur, edge, amount, shadow, highlight;

  static const compact = HyperGlassStyle(2, 3, 4, 1, 0.35);
  static const field = HyperGlassStyle(8, 8, 12, 0, 0.5);
  static const track = HyperGlassStyle(2, 2, 3, 0, 0.25);
  static const panel = HyperGlassStyle(8, 12, 18, 8, 0.5);
  static const drawer = HyperGlassStyle(16, 0, 0, 0, 0);
  static const navigation = HyperGlassStyle(8, 24, 24, 8, 0.5);

  static HyperGlassStyle button(double progress) => HyperGlassStyle(
    8 - 2 * progress,
    12 + 2 * progress,
    16 + 2 * progress,
    6 - 1.5 * progress,
    0.5 + 0.5 * progress,
  );
}
