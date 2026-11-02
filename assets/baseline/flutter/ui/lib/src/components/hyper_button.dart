import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'hyper_progress_painters.dart';

import '../theme/hyper_surface_theme.dart';
import '../theme/hyper_ui_spacing.dart';
import '../theme/hyper_ui_theme.dart';
import '../theme/hyper_ui_theme_tokens.dart';
import 'hyper_pressable.dart';
import 'hyper_button_surface.dart';
import 'hyper_tooltip.dart';

/// Self-drawn button with a small default API and an optional content slot.
class HyperButton extends StatelessWidget {
  const HyperButton({
    super.key,
    this.type,
    this.colorStyle,
    this.label,
    this.content,
    this.onPressed,

    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.loading = false,
    this.expanded = false,
    this.tooltip,
    this.color,
    this.backgroundColor,
  }) : assert(
         type == null || type == 'filled' || type == 'icon',
         'HyperButton.type must be null, filled, or icon.',
       ),
       assert(
         colorStyle == null ||
             colorStyle == 'primary' ||
             colorStyle == 'success' ||
             colorStyle == 'info' ||
             colorStyle == 'warning' ||
             colorStyle == 'danger',
         'HyperButton.colorStyle must be null, primary, success, info, warning, or danger.',
       ),
       assert(
         label == null || content == null,
         'HyperButton.label and content cannot be used together.',
       ),
       assert(
         type != 'icon' || label == null,
         'HyperButton icon type uses icon, content, or loading instead of label.',
       );

  final String? label;
  final Widget? content;
  final VoidCallback? onPressed;
  final String? type;
  final String? colorStyle;

  final IconData? icon;
  final IconData? trailingIcon;
  final bool enabled;
  final bool loading;
  final bool expanded;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (label != null && content != null) {
      throw ArgumentError(
        'HyperButton.label and content cannot be used together.',
      );
    }
    if (type == 'icon' && label != null) {
      throw ArgumentError(
        'HyperButton icon type uses icon, content, or loading instead of label.',
      );
    }
    final variant = switch (type) {
      null => _ButtonVariant.standard,
      'filled' => _ButtonVariant.filled,
      'icon' => _ButtonVariant.icon,
      _ => throw ArgumentError.value(type, 'type', 'Invalid button type'),
    };
    final tokens = HyperUiThemeTokens.of(context);
    final glass = HyperSurfaceTheme.of(context);
    final disabled = !enabled || onPressed == null;
    final blocked = disabled || loading;
    final metrics = _HyperButtonMetrics.standard;
    final hasLabel = label != null && label!.isNotEmpty;
    final isIconOnly =
        type == 'icon' ||
        (!hasLabel && content == null && (icon != null || loading));
    assert(
      (hasLabel ? 1 : 0) +
              (content != null ? 1 : 0) +
              (icon != null ? 1 : 0) +
              (loading ? 1 : 0) >
          0,
      'HyperButton needs label, content, icon, or loading.',
    );

    final visual = _HyperButtonVisual.resolve(
      tokens: tokens,
      glass: glass,
      variant: variant,
      disabled: disabled,
      color: color,
      colorStyle: colorStyle,
    );
    final foreground = visual.foreground;
    final background = backgroundColor ?? visual.background;
    final isSquare = isIconOnly;
    final borderRadius = BorderRadius.circular(metrics.height / 2);
    final effectiveIconSize = isIconOnly
        ? metrics.iconOnlyIconSize
        : metrics.labelIconSize;

    final buttonBody = Container(
      height: metrics.height,
      padding: EdgeInsets.symmetric(
        horizontal: isIconOnly ? 0 : metrics.horizontal,
      ),
      child: Align(
        alignment: Alignment.center,
        // widthFactor: 1 让宽度跟随内容收缩（等价 inline-block），
        // 避免 Container 的 Align 在受限宽度下填满父级；通栏由外层 SizedBox 收紧。
        widthFactor: 1,
        child: IconTheme(
          data: IconThemeData(color: foreground, size: effectiveIconSize),
          child: isIconOnly
              ? _buildIconOnly(foreground, effectiveIconSize)
              : DefaultTextStyle(
                  style: TextStyle(
                    color: foreground,
                    fontFamily: HyperUiTheme.of(context).fontFamily,
                    fontSize: metrics.fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0.05,
                    decoration: TextDecoration.none,
                  ),
                  // 圆形（宽高相等）按钮内空间有限，文字按比例缩小而非溢出。
                  child: isSquare
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildContent(foreground),
                        )
                      : _buildContent(foreground),
                ),
        ),
      ),
    );

    Widget child = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isSquare ? metrics.height : metrics.minWidth,
        minHeight: metrics.height,
      ),
      child: SizedBox(
        // 默认按内容收缩（inline-block）；仅 expanded 时铺满。
        width: isSquare ? metrics.height : (expanded ? double.infinity : null),
        child: HyperButtonSurface(
          enabled: !disabled,
          interactive: !blocked,
          radius: metrics.height / 2,
          color: disabled
              ? background
              : backgroundColor ??
                    (variant == _ButtonVariant.filled
                        ? background.withValues(alpha: background.a * 0.9)
                        : null),
          border: visual.border == null
              ? null
              : Border.all(color: visual.border!, width: disabled ? 1 : 0.5),
          child: HyperPressable(
            onPressed: blocked ? null : onPressed,
            enabled: !blocked,
            pressedScale: 1,
            pressedOpacity: 1,
            borderRadius: borderRadius,
            child: buttonBody,
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      child = HyperTooltip(message: tooltip!, child: child);
    }
    return child;
  }

  /// 图标按钮内容：加载态显示转圈，否则居中显示图标。
  Widget _buildIconOnly(Color foreground, double iconSize) {
    if (loading) {
      return SizedBox.square(
        dimension: math.max(12.0, iconSize - 2),
        child: HyperSpinner(strokeWidth: 2, color: foreground),
      );
    }
    return content ?? Icon(icon!);
  }

  Widget _buildContent(Color foreground) {
    final labelContent =
        content ?? Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (loading) ...<Widget>[
          SizedBox.square(
            dimension: 16,
            child: HyperSpinner(strokeWidth: 2, color: foreground),
          ),
          const SizedBox(width: HyperUiSpacing.xs),
        ] else if (icon != null) ...<Widget>[
          Icon(icon),
          const SizedBox(width: HyperUiSpacing.xs),
        ],
        if (expanded) Flexible(child: labelContent) else labelContent,
        if (trailingIcon != null) ...<Widget>[
          const SizedBox(width: HyperUiSpacing.xs),
          Icon(trailingIcon),
        ],
      ],
    );
  }
}

class _HyperButtonMetrics {
  const _HyperButtonMetrics({
    required this.height,
    required this.minWidth,
    required this.horizontal,
    required this.fontSize,
    required this.iconOnlyIconSize,
    required this.labelIconSize,
  });

  final double height;
  final double minWidth;
  final double horizontal;
  final double fontSize;
  final double iconOnlyIconSize;

  /// 带文字时前置/后置图标的默认尺寸，随字号联动。
  final double labelIconSize;

  static const standard = _HyperButtonMetrics(
    height: 38,
    minWidth: 68,
    horizontal: 14,
    fontSize: 13,
    iconOnlyIconSize: 20,
    labelIconSize: 17,
  );
}

class _HyperButtonVisual {
  const _HyperButtonVisual({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;

  static _HyperButtonVisual resolve({
    required HyperUiThemeTokens tokens,
    required HyperSurfaceTheme glass,
    required _ButtonVariant variant,
    required bool disabled,
    required Color? color,
    required String? colorStyle,
  }) {
    final preset = switch (colorStyle) {
      null => glass.surfaceStrong,
      'primary' => tokens.primary,
      'success' => tokens.success,
      'info' => tokens.info,
      'warning' => tokens.warning,
      'danger' => tokens.error,
      _ => throw ArgumentError.value(
        colorStyle,
        'colorStyle',
        'Invalid button color style',
      ),
    };
    // color 覆盖预设配色，type 只决定显示形态。
    final base = color ?? preset;
    final hasTone = color != null || colorStyle != null;
    if (disabled) {
      return _HyperButtonVisual(
        background: glass.controlTrack,
        foreground: tokens.mutedForeground.withAlpha(150),
        // 禁用态保留弱化轮廓，色相与启用态一致（edgeShade 在浅色下仅 7% 黑，轮廓不可见）。
        border: tokens.border.withAlpha(110),
      );
    }

    if (variant == _ButtonVariant.filled) {
      return _HyperButtonVisual(
        background: base,
        foreground: !hasTone || base.computeLuminance() > 0.5
            ? tokens.foreground
            : tokens.primaryForeground,
        border: null,
      );
    }

    return switch (variant) {
      _ButtonVariant.standard => _HyperButtonVisual(
        background: glass.surfaceSubtle,
        foreground: hasTone ? base : tokens.foreground,
        // 默认按钮的中性玻璃外缘由共用绘制器提供，语义配色仅补单层色调轮廓。
        border: hasTone ? base.withValues(alpha: 0.35) : null,
      ),
      _ButtonVariant.icon => _HyperButtonVisual(
        background: glass.surface,
        foreground: hasTone ? base : tokens.foreground,
        border: hasTone ? base.withValues(alpha: 0.35) : null,
      ),
      _ => throw StateError('Unexpected button variant'),
    };
  }
}

enum _ButtonVariant { standard, filled, icon }
