import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/hyper_ui_theme_tokens.dart';
import '../theme/hyper_ui_theme.dart';
import '../theme/hyper_ui_effects.dart';
import '../utils/hyper_overlay_motion.dart';
import 'hyper_button.dart';
import 'hyper_control_surface.dart';
import 'hyper_modal.dart';
import 'hyper_pressable.dart';
import 'hyper_tone.dart';

/// 无全局状态的玻璃轻提示；退出完成后移除 OverlayEntry。
abstract final class HyperToast {
  static void show(
    BuildContext context,
    String message, {
    String type = 'neutral',
    Color? color,
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (duration.isNegative) throw ArgumentError.value(duration, 'duration');
    final tone = switch (type) {
      'primary' => HyperUiTone.primary,
      'success' => HyperUiTone.success,
      'warning' => HyperUiTone.warning,
      'error' => HyperUiTone.error,
      'info' => HyperUiTone.info,
      'neutral' => HyperUiTone.neutral,
      _ => throw ArgumentError.value(type, 'type', 'Invalid toast type'),
    };
    final theme = HyperUiTheme.of(context);
    final toneColor = color ?? tone.color(theme.tokens);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => HyperUiTheme(
        data: theme,
        child: Positioned(
          left: 16,
          right: 16,
          bottom: 96,
          child: Align(
            alignment: Alignment.center,
            child: _HyperToastOverlay(
              message: message,
              tone: tone,
              color: toneColor,
              duration: duration,
              actionLabel: actionLabel,
              onAction: onAction,
              onRemoved: () {
                entry.remove();
                entry.dispose();
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _HyperToastOverlay extends StatefulWidget {
  const _HyperToastOverlay({
    required this.message,
    required this.tone,
    required this.color,
    required this.duration,
    required this.onRemoved,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final HyperUiTone tone;
  final Color color;
  final Duration duration;
  final VoidCallback onRemoved;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  State<_HyperToastOverlay> createState() => _HyperToastOverlayState();
}

class _HyperToastOverlayState extends State<_HyperToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 125),
  );
  Timer? _timer;
  bool _closing = false;
  @override
  void initState() {
    super.initState();
    if (widget.duration > Duration.zero) _timer = Timer(widget.duration, _hide);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 125);
    if (!_closing) _motion.forward();
  }

  void _hide() {
    if (_closing || !mounted) return;
    setState(() => _closing = true);
    _timer?.cancel();
    _motion.reverse().then((_) {
      if (mounted) widget.onRemoved();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HyperUiThemeTokens.of(context);
    final light = HyperUiTheme.of(context).brightness == Brightness.light;
    final icon = switch (widget.tone) {
      HyperUiTone.primary => LucideIcons.sparkles,
      HyperUiTone.success => LucideIcons.check,
      HyperUiTone.warning => LucideIcons.circleAlert,
      HyperUiTone.error => LucideIcons.x,
      HyperUiTone.info => LucideIcons.info,
      HyperUiTone.neutral => LucideIcons.bell,
    };
    return IgnorePointer(
      ignoring: _closing,
      child: buildHySurfaceTransition(
        animation: _motion,
        beginScale: 0.97,
        curve: HyperUiEffects.overlayCurve,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 420),
          child: HyperControlSurface(
            radius: 18,
            role: HyperControlSurfaceRole.panel,
            color: Color.alphaBlend(
              widget.color.withAlpha(10),
              Color.fromRGBO(255, 255, 255, light ? 0.6 : 0.272),
            ),
            border: Border.all(color: widget.color.withAlpha(105)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(24),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: widget.color, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onAction != null)
                    HyperPressable(
                      onPressed: () {
                        _hide();
                        widget.onAction!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

abstract final class HyperDialog {
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String confirmLabel = '确定',
    String cancelLabel = '取消',
    String type = 'default',
    bool showCancel = true,
    bool Function()? canConfirm,
  }) {
    if (type != 'default' && type != 'danger') {
      throw ArgumentError.value(type, 'type', 'Invalid dialog type');
    }
    // 表单先执行校验；返回 false 时保持当前弹层，供用户继续修改。
    void confirm(BuildContext dialogContext) {
      if (canConfirm?.call() == false) return;
      Navigator.pop(dialogContext, true);
    }

    return showHyperModal<bool>(
      context,
      builder: (dialogContext) => Padding(
        // 弹窗与屏幕边缘保持间距，宽屏时仍限制内容宽度。
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: HyperControlSurface(
            radius: 26,
            role: HyperControlSurfaceRole.dialog,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        // 弹窗可能晚于发起页面关闭，使用仍挂载的弹窗上下文。
                        color: HyperUiThemeTokens.of(dialogContext).foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (content != null ||
                        (message?.isNotEmpty ?? false)) ...<Widget>[
                      const SizedBox(height: 10),
                      content ?? Text(message!),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        if (showCancel)
                          HyperButton(
                            label: cancelLabel,
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                          ),
                        type == 'danger'
                            ? HyperButton(
                                colorStyle: 'danger',
                                type: 'filled',
                                label: confirmLabel,
                                onPressed: () => confirm(dialogContext),
                              )
                            : HyperButton(
                                label: confirmLabel,
                                onPressed: () => confirm(dialogContext),
                                colorStyle: 'primary',
                                type: 'filled',
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
