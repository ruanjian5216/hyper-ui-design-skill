import 'package:flutter/widgets.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/hyper_ui_theme_tokens.dart';
import '../theme/hyper_ui_theme.dart';
import 'hyper_button.dart';
import 'hyper_glass.dart';
import 'hyper_control_surface.dart';
import 'hyper_modal.dart';
import 'hyper_pressable.dart';
import 'hyper_tone.dart';

/// 无全局状态的玻璃轻提示。
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
    assert(
      type == 'neutral' ||
          type == 'primary' ||
          type == 'success' ||
          type == 'warning' ||
          type == 'error' ||
          type == 'info',
      'HyperToast.type must be neutral, primary, success, warning, error, or info.',
    );
    final tokens = HyperUiThemeTokens.of(context);
    final tone = switch (type) {
      'primary' => HyperUiTone.primary,
      'success' => HyperUiTone.success,
      'warning' => HyperUiTone.warning,
      'error' => HyperUiTone.error,
      'info' => HyperUiTone.info,
      'neutral' => HyperUiTone.neutral,
      _ => throw ArgumentError.value(type, 'type', 'Invalid toast type'),
    };
    final toneColor = color ?? tone.color(tokens);
    final theme = HyperUiTheme.of(context);
    late final OverlayEntry entry;
    var visible = true;
    void hide() {
      if (!visible) return;
      visible = false;
      entry.remove();
      entry.dispose();
    }

    entry = OverlayEntry(
      builder: (_) => HyperUiTheme(
        data: theme,
        child: Positioned(
          left: 16,
          right: 16,
          bottom: 96,
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 420),
              child: HyperGlass(
                radius: 18,
                type: 'prominent',
                color: Color.alphaBlend(
                  toneColor.withAlpha(10),
                  theme.surfaces.surfaceStrong,
                ),
                borderColor: toneColor.withAlpha(105),
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: toneColor.withAlpha(24),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(_iconFor(tone), color: toneColor, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message,
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
                    if (actionLabel != null && onAction != null)
                      HyperPressable(
                        onPressed: () {
                          hide();
                          onAction();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            actionLabel,
                            style: TextStyle(
                              color: toneColor,
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
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    Future<void>.delayed(duration, hide);
  }

  static IconData _iconFor(HyperUiTone tone) => switch (tone) {
    HyperUiTone.primary => LucideIcons.sparkles,
    HyperUiTone.success => LucideIcons.check,
    HyperUiTone.warning => LucideIcons.circleAlert,
    HyperUiTone.error => LucideIcons.x,
    HyperUiTone.info => LucideIcons.info,
    HyperUiTone.neutral => LucideIcons.bell,
  };
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
