import 'package:flutter_hyper_ui/hyper_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ButtonsExample extends StatefulWidget {
  const ButtonsExample({super.key});

  @override
  State<ButtonsExample> createState() => _ButtonsExampleState();
}

class _ButtonsExampleState extends State<ButtonsExample> {
  bool _processing = true;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 文字按钮默认按内容收缩。
        Wrap(
          spacing: HyperUiSpacing.xs,
          runSpacing: HyperUiSpacing.xs,
          children: [
            // 默认档文字由按钮提供字号、字重与颜色。
            HyperButton(
              onPressed: () => setState(() => _processing = !_processing),
              content: const HyperText('默认按钮'),
            ),
            HyperButton(
              label: '处理中',
              loading: _processing,
              onPressed: () => setState(() => _processing = true),
            ),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.md),
        // 带图标的按钮：图标 + 文字。
        Wrap(
          spacing: HyperUiSpacing.xs,
          runSpacing: HyperUiSpacing.xs,
          children: [
            HyperButton(
              colorStyle: 'primary',
              type: 'filled',
              label: 'Primary',
              onPressed: _noop,
            ),
            HyperButton(
              colorStyle: 'success',
              type: 'filled',
              label: 'Success',
              onPressed: _noop,
            ),
            HyperButton(
              colorStyle: 'info',
              type: 'filled',
              label: 'Info',
              onPressed: _noop,
            ),
            HyperButton(
              colorStyle: 'warning',
              type: 'filled',
              label: 'Warning',
              onPressed: _noop,
            ),
            HyperButton(
              label: '导出',
              icon: LucideIcons.share2,
              onPressed: _noop,
            ),
            HyperButton(
              colorStyle: 'danger',
              type: 'filled',
              label: 'Danger',
              icon: LucideIcons.trash,
              onPressed: _noop,
            ),
            HyperButton(
              label: '带图标胶囊',
              icon: LucideIcons.settings,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.md),
        // icon 只控制显示形态，colorStyle 控制配色。
        Wrap(
          spacing: HyperUiSpacing.xs,
          runSpacing: HyperUiSpacing.xs,
          children: [
            HyperButton(
              type: 'icon',
              content: const HyperIcon(LucideIcons.plus),
              onPressed: _noop,
              tooltip: '新建',
            ),
            HyperButton(
              type: 'icon',
              icon: LucideIcons.refreshCw,
              onPressed: _noop,
              tooltip: '刷新',
            ),
            HyperButton(
              type: 'icon',
              icon: LucideIcons.share2,
              onPressed: _noop,
              tooltip: '分享',
            ),
            HyperButton(
              colorStyle: 'danger',
              type: 'icon',
              icon: LucideIcons.trash,
              onPressed: _noop,
              tooltip: '删除',
            ),
            HyperButton(
              type: 'icon',
              icon: LucideIcons.refreshCw,
              loading: true,
              onPressed: _noop,
              tooltip: '加载中',
            ),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.md),
        const HyperButton(label: '不可用'),
        const SizedBox(height: HyperUiSpacing.md),
        Wrap(
          spacing: HyperUiSpacing.xs,
          runSpacing: HyperUiSpacing.xs,
          children: [
            for (final colorStyle in <String?>[
              null,
              'primary',
              'success',
              'info',
              'warning',
              'danger',
            ])
              HyperButton(
                type: 'filled',
                colorStyle: colorStyle,
                label: colorStyle ?? 'Default',
                loading: true,
                onPressed: _noop,
              ),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.md),
        Wrap(
          spacing: HyperUiSpacing.xs,
          runSpacing: HyperUiSpacing.xs,
          children: [
            HyperButton(colorStyle: 'success', label: '默认玻璃', onPressed: _noop),
            HyperButton(
              type: 'filled',
              colorStyle: 'success',
              label: '填充',
              onPressed: _noop,
            ),
            HyperButton(
              type: 'icon',
              colorStyle: 'success',
              icon: LucideIcons.check,
              onPressed: _noop,
            ),
            HyperButton(
              type: 'filled',
              colorStyle: 'danger',
              color: context.hyperUi.primary,
              label: '自定义颜色优先',
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.md),
        // 通栏按钮：显式 expanded 铺满父级宽度。
        HyperButton(
          label: '通栏按钮（expanded: true）',
          expanded: true,
          onPressed: _noop,
          colorStyle: 'primary',
          type: 'filled',
        ),
      ],
    );
    // 与 Kotlin 文档同一完整背景与滚动视口：顶部 52，内容 padding 16，正文组间距不变。
    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}

void _noop() {}
