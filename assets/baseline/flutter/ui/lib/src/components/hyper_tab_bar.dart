import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../theme/hyper_ui_theme_tokens.dart';
import 'hyper_badge.dart';
import 'hyper_safe_area.dart';
import 'hyper_pressable.dart';
import 'hyper_control_surface.dart';
import 'hyper_glass_source.dart';
import 'hyper_tab_bar_motion.dart';

/// 底栏中的导航项；页面与图标含义由调用方决定。
class HyperTabItem {
  const HyperTabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// 悬浮或全宽贴底导航；空选中值用于可重复点击的动作入口。
class HyperTabBar extends StatefulWidget {
  const HyperTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.type = 'multiple',
    this.badgeCount = 0,
    this.safeArea = true,
    this.floating = true,
    this.itemEnabled,
    EdgeInsetsGeometry? margin,
    this.color,
  }) : assert(type == 'multiple' || type == 'single'),
       assert(
         type == 'single'
             ? items.length == 1
             : items.length >= 2 && items.length <= 5,
       ),
       assert(
         selectedIndex == null ||
             (selectedIndex >= 0 && selectedIndex < items.length),
       ),
       assert(floating || type == 'multiple'),
       margin =
           margin ??
           (!floating || type == 'single'
               ? EdgeInsets.zero
               : const EdgeInsets.fromLTRB(
                   12,
                   8,
                   12,
                   HyperSafeAreaDefaults.minimumBottomSpacing,
                 ));

  /// 单独动作入口的固定直径，不与多项按钮组等高。
  static const double singleDiameter = 48;

  /// 悬浮和贴底多项按钮组的默认内容高度，组件内可随字体扩展。
  static const double height = 56;
  final List<HyperTabItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onChanged;
  final String type;
  final int badgeCount;
  final bool safeArea;
  final bool floating;
  final bool Function(HyperTabItem)? itemEnabled;
  final Color? color;
  final EdgeInsetsGeometry margin;

  @override
  State<HyperTabBar> createState() => _HyperTabBarState();
}

class _HyperTabBarState extends State<HyperTabBar> {
  final _panelSource = HyperGlassSourceController();
  final _labelsSource = HyperGlassSourceController();
  @override
  void dispose() {
    _panelSource.dispose();
    _labelsSource.dispose();
    super.dispose();
  }

  double get _inset => widget.floating ? 4 : 0;
  double? _dragPosition;
  bool _pressed = false;
  int? _pointer;
  double _pointerTravel = 0;

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;
  int _visual(int logical) =>
      _rtl ? widget.items.length - logical - 1 : logical;
  int _logical(int visual) => _rtl ? widget.items.length - visual - 1 : visual;

  void _select(int index) {
    if (index == widget.selectedIndex || !_enabled(index)) return;
    HapticFeedback.selectionClick();
    widget.onChanged(index);
  }

  bool _enabled(int index) =>
      widget.itemEnabled?.call(widget.items[index]) ?? true;

  void _drag(double x, double width) {
    final position =
        ((x - _inset) / (width - 2 * _inset) * widget.items.length - 0.5).clamp(
          0.0,
          widget.items.length - 1.0,
        );
    if (_enabled(_logical(position.round())) && _dragPosition != position) {
      setState(() => _dragPosition = position);
    }
  }

  void _releasePointer(int pointer) {
    if (_pointer != pointer) return;
    setState(() {
      _pointer = null;
      _pressed = false;
    });
  }

  @override
  void didUpdateWidget(covariant HyperTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.floating != widget.floating ||
        (oldWidget.selectedIndex == null) != (widget.selectedIndex == null)) {
      _dragPosition = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length > 5) {
      throw ArgumentError.value(
        widget.items.length,
        'items.length',
        'TabBar 最多支持 5 项',
      );
    }
    final tokens = HyperUiThemeTokens.of(context);
    final activeColor = widget.color ?? tokens.primary;
    // 单动作固定为 48 圆形入口；只有多项按钮组按标签字体扩展默认高度。
    final textHeight = MediaQuery.textScalerOf(context).scale(12) * 1.08;
    final barHeight = widget.type == 'single'
        ? HyperTabBar.singleDiameter
        : math.max(HyperTabBar.height, textHeight + 36);
    final selectionHeight = barHeight - 8;
    Widget bar;
    if (widget.type == 'single') {
      bar = HyperBadge(
        type: 'count',
        count: widget.badgeCount,
        child: Opacity(
          opacity: _enabled(0) ? 1 : 0.4,
          child: HyperPressable(
            enabled: _enabled(0),
            borderRadius: BorderRadius.circular(barHeight / 2),
            onPressed: () => widget.onChanged(0),
            child: HyperControlSurface(
              radius: barHeight / 2,
              role: HyperControlSurfaceRole.navigation,
              child: SizedBox.square(
                dimension: barHeight,
                child: Icon(
                  widget.items.single.icon,
                  size: 22,
                  color: activeColor,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      var itemWidth = 76.0;
      for (final item in widget.items) {
        final label = TextPainter(
          text: TextSpan(
            text: item.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        itemWidth = math.max(itemWidth, label.width + 32);
        label.dispose();
      }
      bar = SizedBox(
        width: widget.floating
            ? itemWidth * widget.items.length + 2 * _inset
            : double.infinity,
        height: barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (!width.isFinite ||
                width <= 2 * _inset + widget.items.length * 2) {
              return const SizedBox.shrink();
            }
            final cellWidth = (width - 2 * _inset) / widget.items.length;
            final selected =
                _dragPosition ??
                (widget.selectedIndex == null
                    ? null
                    : _visual(widget.selectedIndex!).toDouble());
            final selectionMode = widget.selectedIndex != null;
            return Listener(
              onPointerDown: (event) {
                final index = ((event.localPosition.dx - _inset) / cellWidth)
                    .floor()
                    .clamp(0, widget.items.length - 1);
                if (_pointer != null || !_enabled(_logical(index))) return;
                setState(() {
                  _pointer = event.pointer;
                  _pressed = true;
                  _pointerTravel = 0;
                });
              },
              onPointerMove: (event) {
                if (_pointer == event.pointer) {
                  setState(() => _pointerTravel += event.delta.dx);
                }
              },
              onPointerUp: (event) => _releasePointer(event.pointer),
              onPointerCancel: (event) => _releasePointer(event.pointer),
              child: RepaintBoundary(
                child: GestureDetector(
                  onHorizontalDragStart: selectionMode
                      ? (details) => _drag(details.localPosition.dx, width)
                      : null,
                  onHorizontalDragUpdate: selectionMode
                      ? (details) => _drag(details.localPosition.dx, width)
                      : null,
                  onHorizontalDragCancel: selectionMode
                      ? () => setState(() => _dragPosition = null)
                      : null,
                  onHorizontalDragEnd: selectionMode
                      ? (_) {
                          final index = _dragPosition?.round();
                          setState(() => _dragPosition = null);
                          if (index != null) _select(_logical(index));
                        }
                      : null,
                  child: HyperTabBarMotion(
                    target: selected ?? 0,
                    count: widget.items.length,
                    pressed: _pressed,
                    travel: _pointerTravel,
                    builder: (context, motion) {
                      final panelOffset = widget.floating
                          ? motion.panelOffset(width)
                          : 0.0;
                      final panelScale = widget.floating
                          ? 1 + 16 / width * motion.progress
                          : 1.0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(panelOffset, 0),
                              child: Transform.scale(
                                scale: panelScale,
                                child: Stack(
                                  children: [
                                    // 背景与标签分别录制，镜片只合成一次标签，避免弹性缩放时重影。
                                    Positioned.fill(
                                      child: HyperGlassSource(
                                        controller: _panelSource,
                                        child: _TabBarSurface(
                                          floating: widget.floating,
                                          height: barHeight,
                                          child: CustomPaint(
                                            painter: HyperTabBarHighlight(
                                              motion.progress,
                                              motion.position,
                                              widget.items.length,
                                              _inset,
                                            ),
                                            child: const SizedBox.expand(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      left: _inset,
                                      right: _inset,
                                      child: HyperGlassSource(
                                        controller: _labelsSource,
                                        child: Row(
                                          textDirection: TextDirection.ltr,
                                          children: [
                                            for (
                                              var index = 0;
                                              index < widget.items.length;
                                              index++
                                            )
                                              Expanded(
                                                child: Opacity(
                                                  opacity:
                                                      _enabled(_logical(index))
                                                      ? 1
                                                      : 0.4,
                                                  child: HyperPressable(
                                                    enabled: _enabled(
                                                      _logical(index),
                                                    ),
                                                    pressedScale: 1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          barHeight / 2,
                                                        ),
                                                    onPressed: () => _select(
                                                      _logical(index),
                                                    ),
                                                    child: _TabLabel(
                                                      item:
                                                          widget.items[_logical(
                                                            index,
                                                          )],
                                                      selected:
                                                          index ==
                                                          selected?.round(),
                                                      color:
                                                          index ==
                                                              selected?.round()
                                                          ? activeColor
                                                          : tokens.foreground,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 连续预览位置，释放后由同一弹簧回到受控选中值。
                          if (selected != null)
                            Positioned(
                              left: _inset + motion.position * cellWidth + 1,
                              top: (barHeight - selectionHeight) / 2,
                              width: cellWidth - 2,
                              height: selectionHeight,
                              child: IgnorePointer(
                                child: Transform.translate(
                                  offset: Offset(panelOffset, 0),
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.diagonal3Values(
                                      motion.scaleX,
                                      motion.scaleY,
                                      1,
                                    ),
                                    child: HyperControlSurface(
                                      radius: selectionHeight / 2,
                                      role: HyperControlSurfaceRole.selection,
                                      progress: motion.progress,
                                      sources: [_panelSource, _labelsSource],
                                      tintSource: _labelsSource,
                                      tint: activeColor,
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    bar = Padding(padding: widget.margin, child: bar);
    bar = widget.safeArea ? SafeArea(top: false, child: bar) : bar;
    // 贴底背景包含底部安全区，业务宿主不再补底板或重复 SafeArea。
    return widget.floating
        ? bar
        : ColoredBox(color: tokens.background, child: bar);
  }
}

/// 仅悬浮形态绘制玻璃胶囊，贴底形态直接使用外层页面表面。
class _TabBarSurface extends StatelessWidget {
  const _TabBarSurface({
    required this.floating,
    required this.height,
    required this.child,
  });
  final bool floating;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => floating
      ? HyperControlSurface(
          radius: height / 2,
          role: HyperControlSurfaceRole.navigation,
          child: child,
        )
      : child;
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.item,
    required this.selected,
    required this.color,
  });
  final HyperTabItem item;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(item.icon, color: color, size: 23),
      const SizedBox(height: 1),
      Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          height: 1.08,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}
