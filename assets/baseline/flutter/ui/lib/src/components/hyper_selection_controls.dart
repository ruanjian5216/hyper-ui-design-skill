import 'package:flutter_hyper_ui/src/theme/hyper_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/hyper_surface_theme.dart';
import '../theme/hyper_ui_effects.dart';
import '../theme/hyper_ui_theme_tokens.dart';
import 'hyper_list_tile.dart';
import 'hyper_pressable.dart';
import 'hyper_control_surface.dart';
import 'hyper_glass_source.dart';
import '../utils/hyper_spring_motion.dart';

class HyperCheckbox extends StatelessWidget {
  const HyperCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.tristate = false,
  }) : assert(tristate || value != null);

  final bool enabled;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final tokens = HyperUiThemeTokens.of(context);
    final glass = HyperSurfaceTheme.of(context);
    final selected = value == true || (tristate && value == null);
    final duration = HyperUiEffects.durationOf(
      context,
      HyperUiEffects.stateDuration,
    );
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final box = AnimatedContainer(
      duration: duration,
      curve: HyperUiEffects.selectionCurve,
      width: 21,
      height: 21,
      decoration: BoxDecoration(
        color: selected ? tokens.primary : glass.surfaceSubtle,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected ? tokens.primary : tokens.input,
          width: 1.5,
        ),
      ),
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: duration,
        curve: HyperUiEffects.pressCurve,
        child: AnimatedScale(
          scale: !selected && !reduceMotion ? 0.8 : 1,
          duration: reduceMotion ? Duration.zero : duration,
          curve: HyperUiEffects.pressCurve,
          child: Icon(
            tristate && value == null ? LucideIcons.minus : LucideIcons.check,
            size: 15,
            color: tokens.primaryForeground,
          ),
        ),
      ),
    );
    void toggle() {
      if (tristate) {
        onChanged?.call(
          value == true
              ? null
              : value == false
              ? true
              : false,
        );
      } else {
        onChanged?.call(!(value ?? false));
      }
    }

    if (label == null) {
      return HyperPressable(
        onPressed: !enabled || onChanged == null ? null : toggle,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.square(dimension: 44, child: Center(child: box)),
      );
    }
    return HyperListTile(
      type: 'plain',
      title: label!,
      trailing: box,
      enabled: enabled && onChanged != null,
      showChevron: false,
      onPressed: !enabled || onChanged == null ? null : toggle,
    );
  }
}

class HyperRadio<T> extends StatelessWidget {
  const HyperRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
    this.label,
  });

  final bool enabled;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = HyperUiThemeTokens.of(context);
    final glass = HyperSurfaceTheme.of(context);
    final selected = value == groupValue;
    // 标签行承载点击；只展示的圆环不再占用独立触摸区。
    final standaloneInteractive = label == null && onChanged != null;
    final radio = HyperPressable(
      onPressed: !enabled || !standaloneInteractive
          ? null
          : () => onChanged!(value),
      child: SizedBox.square(
        dimension: standaloneInteractive ? 44 : 21,
        child: Center(
          child: AnimatedContainer(
            duration: HyperUiEffects.durationOf(
              context,
              HyperUiEffects.stateDuration,
            ),
            curve: HyperUiEffects.selectionCurve,
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glass.surfaceSubtle,
              border: Border.all(
                color: selected ? tokens.primary : tokens.input,
                width: selected ? 6 : 1.5,
              ),
            ),
          ),
        ),
      ),
    );
    if (label == null) return radio;
    return HyperListTile(
      type: 'plain',
      title: label!,
      trailing: radio,
      enabled: enabled && onChanged != null,
      showChevron: false,
      onPressed: !enabled || onChanged == null ? null : () => onChanged!(value),
    );
  }
}

class HyperSwitch extends StatefulWidget {
  const HyperSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
  });

  final bool enabled;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  State<HyperSwitch> createState() => _HyperSwitchState();
}

class _HyperSwitchState extends State<HyperSwitch> {
  bool _rowPressed = false;

  @override
  Widget build(BuildContext context) {
    final HyperSwitch(:value, :onChanged, :enabled, :label) = widget;
    final active = enabled && onChanged != null;
    final control = _HyperSwitchControl(
      value: value,
      onChanged: enabled ? onChanged : null,
      rowPressed: active && _rowPressed,
    );
    if (label == null) return control;
    return Listener(
      onPointerDown: active ? (_) => setState(() => _rowPressed = true) : null,
      onPointerUp: (_) => setState(() => _rowPressed = false),
      onPointerCancel: (_) => setState(() => _rowPressed = false),
      child: HyperListTile(
        type: 'plain',
        title: label,
        trailing: control,
        enabled: enabled && onChanged != null,
        showChevron: false,
        onPressed: !enabled || onChanged == null
            ? null
            : () => onChanged(!value),
      ),
    );
  }
}

/// 自绘开关轨道，保证关闭态在不同玻璃背景上仍有清晰层次。
class _HyperSwitchControl extends StatefulWidget {
  const _HyperSwitchControl({
    required this.value,
    this.onChanged,
    required this.rowPressed,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool rowPressed;

  @override
  State<_HyperSwitchControl> createState() => _HyperSwitchControlState();
}

class _HyperSwitchControlState extends State<_HyperSwitchControl> {
  final _trackSource = HyperGlassSourceController();
  @override
  void dispose() {
    _trackSource.dispose();
    super.dispose();
  }

  bool _pointerPressed = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final onChanged = widget.onChanged;
    final tokens = HyperUiThemeTokens.of(context);
    final glass = HyperSurfaceTheme.of(context);
    final enabled = onChanged != null;
    final uncheckedTrack = Color.alphaBlend(
      glass.controlTrack,
      enabled ? glass.surfaceStrong : glass.surfaceSubtle,
    );
    final checkedTrack = enabled
        ? tokens.primary
        : tokens.primary.withAlpha(90);
    final uncheckedThumb = const Color.fromRGBO(255, 255, 255, 1);
    final outlineColor = value
        ? HyperPalette.transparent
        : Color.alphaBlend(glass.edgeShade, glass.edgeHighlight);

    return Listener(
      onPointerDown: enabled
          ? (_) => setState(() => _pointerPressed = true)
          : null,
      onPointerUp: (_) => setState(() => _pointerPressed = false),
      onPointerCancel: (_) => setState(() => _pointerPressed = false),
      child: HyperPressable(
        onPressed: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(18),
        child: HyperSpringMotion(
          value: value ? 1 : 0,
          builder: (context, position) {
            final fraction = position.clamp(0.0, 1.0);
            final trackColor = Color.lerp(
              uncheckedTrack,
              checkedTrack,
              fraction,
            )!;
            final thumbColor = Color.lerp(
              uncheckedThumb,
              tokens.primaryForeground,
              fraction,
            )!;
            return SizedBox(
              width: 52,
              height: 32,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: HyperGlassSource(
                      controller: _trackSource,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outlineColor),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(fraction * 2 - 1, 0),
                      child: enabled
                          ? SizedBox.square(
                              dimension: 24,
                              // 保留原来的 24×22 约束盒；内部可见圆形仍为 22，不扩大轨道或滑块。
                              child: Center(
                                child: SizedBox.square(
                                  dimension: 22,
                                  child: HyperSpringMotion(
                                    value:
                                        enabled &&
                                            (_pointerPressed ||
                                                widget.rowPressed)
                                        ? 1
                                        : 0,
                                    builder: (context, progress) =>
                                        HyperControlSurface(
                                          radius: 11,
                                          role: HyperControlSurfaceRole
                                              .switchThumb,
                                          progress: progress,
                                          color: thumbColor,
                                          sources: [
                                            if (HyperGlassSourceScope.maybeOf(
                                                  context,
                                                )
                                                case final source?)
                                              source,
                                            _trackSource,
                                          ],
                                          scaleSource: _trackSource,
                                          sourceScale: Offset(
                                            2 / 3 + progress / 12,
                                            0.75 * progress,
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                  ),
                                ),
                              ),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: thumbColor,
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: glass.shadow.withValues(
                                      alpha:
                                          glass.shadow.a * (enabled ? 1 : 0.5),
                                    ),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const SizedBox.square(dimension: 24),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class HyperSlider extends StatefulWidget {
  const HyperSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.showValue = true,
    this.readOnly = false,
  }) : assert(max > min),
       assert(divisions == null || divisions > 0);

  final bool enabled;
  final bool readOnly;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool showValue;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  @override
  State<HyperSlider> createState() => _HyperSliderState();
}

class _HyperSliderState extends State<HyperSlider> {
  final _trackSource = HyperGlassSourceController();
  @override
  void dispose() {
    _trackSource.dispose();
    super.dispose();
  }

  bool _pressed = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final HyperSlider(
      :value,
      :min,
      :max,
      :divisions,
      :showValue,
      :readOnly,
      :enabled,
      :onChanged,
      :onChangeStart,
      :onChangeEnd,
    ) = widget;
    final tokens = HyperUiThemeTokens.of(context);
    final glass = HyperSurfaceTheme.of(context);
    final currentValue = value.isFinite
        ? value.clamp(min, max).toDouble()
        : min;
    var interactionValue = currentValue;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final amount = ((currentValue - min) / (max - min)).toDouble();
    double nextValue(double localX, double width) {
      final fraction =
          ((rtl ? width - localX : localX) / (width > 0 ? width : 1)).clamp(
            0.0,
            1.0,
          );
      var next = min + fraction * (max - min);
      if (divisions != null && divisions > 0) {
        next =
            min +
            ((next - min) / (max - min) * divisions).round() *
                (max - min) /
                divisions;
      }
      return next;
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Listener(
              onPointerDown: !enabled || readOnly || onChanged == null
                  ? null
                  : (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: !enabled || readOnly || onChanged == null
                    ? null
                    : (details) {
                        onChangeStart?.call(currentValue);
                        final next = nextValue(
                          details.localPosition.dx,
                          constraints.maxWidth,
                        );
                        interactionValue = next;
                        onChanged(next);
                        onChangeEnd?.call(next);
                      },
                onHorizontalDragStart: !enabled || readOnly || onChanged == null
                    ? null
                    : (_) {
                        setState(() => _dragging = true);
                        onChangeStart?.call(currentValue);
                      },
                onHorizontalDragUpdate:
                    !enabled || readOnly || onChanged == null
                    ? null
                    : (details) {
                        interactionValue = nextValue(
                          details.localPosition.dx,
                          constraints.maxWidth,
                        );
                        onChanged(interactionValue);
                      },
                onHorizontalDragEnd: !enabled || readOnly || onChanged == null
                    ? null
                    : (_) {
                        setState(() => _dragging = false);
                        onChangeEnd?.call(interactionValue);
                      },
                onHorizontalDragCancel:
                    !enabled || readOnly || onChanged == null
                    ? null
                    : () {
                        setState(() {
                          _dragging = false;
                          _pressed = false;
                        });
                      },
                child: HyperSpringMotion(
                  value: amount,
                  immediate: _dragging,
                  builder: (context, position) => SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: rtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      children: <Widget>[
                        HyperGlassSource(
                          controller: _trackSource,
                          child: SizedBox(
                            height: 6,
                            child: Stack(
                              alignment: rtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: glass.controlTrack,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                Container(
                                  width: constraints.maxWidth * position,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: tokens.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left:
                              (constraints.maxWidth *
                                          (rtl ? 1 - position : position) -
                                      10)
                                  .clamp(
                                    0.0,
                                    constraints.maxWidth > 20
                                        ? constraints.maxWidth - 20
                                        : 0.0,
                                  ),
                          child: HyperSpringMotion(
                            value: _pressed ? 1 : 0,
                            builder: (context, progress) => enabled
                                ? HyperControlSurface(
                                    radius: 10,
                                    role: HyperControlSurfaceRole.thumb,
                                    progress: progress,
                                    sources: [
                                      if (HyperGlassSourceScope.maybeOf(context)
                                          case final source?)
                                        source,
                                      _trackSource,
                                    ],
                                    child: const SizedBox(
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                : Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: tokens.muted,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showValue)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(value.toStringAsFixed(0)),
          ),
      ],
    );
  }
}
