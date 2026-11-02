import 'package:flutter/widgets.dart';

import 'hyper_ui_theme.dart';

/// 库内实色表面、边缘、阴影与交互色。
@immutable
class HyperSurfaceTheme {
  const HyperSurfaceTheme._({
    required this.surface,
    required this.surfaceStrong,
    required this.surfaceSubtle,
    required this.edgeHighlight,
    required this.edgeShade,
    required this.shadow,
    required this.controlTrack,
    required this.selection,
    required this.pressed,
    required this.scrim,
  });

  /// 标准玻璃表面，用于卡片和常规容器。
  final Color surface;

  /// 高不透明度玻璃表面，用于抽屉、弹层等强调层级。
  final Color surfaceStrong;

  /// 轻量玻璃表面，用于输入框和小型控件。
  final Color surfaceSubtle;

  /// 模拟玻璃迎光边缘的高光色。
  final Color edgeHighlight;

  /// 为浅色玻璃提供轮廓、为深色玻璃提供分隔的边缘色。
  final Color edgeShade;

  /// 浮动表面的环境阴影色。
  final Color shadow;

  /// 未选中控件轨道、骨架和低强调背景色。
  final Color controlTrack;

  /// 胶囊、菜单和分段控件的选中背景色。
  final Color selection;

  /// 触控按下、悬停和聚焦状态的反馈色。
  final Color pressed;

  /// 模态抽屉、对话框和加载层使用的背景遮罩色。
  final Color scrim;

  /// 内容卡片通过柔和的环境阴影与接触阴影分层，低于浮层高度。
  List<BoxShadow> get cardShadows => <BoxShadow>[
    BoxShadow(
      color: shadow.withValues(alpha: shadow.a * 0.75),
      blurRadius: 18,
      spreadRadius: -4,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: shadow.a * 0.4),
      blurRadius: 4,
      spreadRadius: -1,
      offset: const Offset(0, 1),
    ),
  ];

  List<BoxShadow> get surfaceShadows => <BoxShadow>[
    BoxShadow(
      color: shadow,
      blurRadius: 28,
      spreadRadius: -6,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: shadow.a * 0.42),
      blurRadius: 8,
      spreadRadius: -3,
      offset: const Offset(0, 3),
    ),
  ];

  factory HyperSurfaceTheme.light() => const HyperSurfaceTheme._(
    surface: Color.fromRGBO(255, 255, 255, 1),
    surfaceStrong: Color.fromRGBO(255, 255, 255, 1),
    surfaceSubtle: Color.fromRGBO(255, 255, 255, 1),
    edgeHighlight: Color.fromRGBO(17, 18, 22, 24 / 255),
    edgeShade: Color.fromRGBO(0, 0, 0, 0),
    shadow: Color.fromRGBO(17, 26, 40, 20 / 255),
    controlTrack: Color.fromRGBO(0, 0, 0, 22 / 255),
    selection: Color.fromRGBO(0, 0, 0, 31 / 255),
    pressed: Color.fromRGBO(0, 0, 0, 20 / 255),
    scrim: Color.fromRGBO(8, 11, 18, 82 / 255),
  );

  factory HyperSurfaceTheme.dark() => const HyperSurfaceTheme._(
    surface: Color.fromRGBO(27, 31, 39, 1),
    surfaceStrong: Color.fromRGBO(27, 31, 39, 1),
    surfaceSubtle: Color.fromRGBO(27, 31, 39, 1),
    edgeHighlight: Color.fromRGBO(52, 59, 71, 1),
    edgeShade: Color.fromRGBO(0, 0, 0, 0),
    shadow: Color.fromRGBO(0, 0, 0, 82 / 255),
    controlTrack: Color.fromRGBO(255, 255, 255, 36 / 255),
    selection: Color.fromRGBO(255, 255, 255, 31 / 255),
    pressed: Color.fromRGBO(255, 255, 255, 31 / 255),
    scrim: Color.fromRGBO(0, 0, 0, 153 / 255),
  );

  static HyperSurfaceTheme of(BuildContext context) =>
      HyperUiTheme.of(context).surfaces;
}
