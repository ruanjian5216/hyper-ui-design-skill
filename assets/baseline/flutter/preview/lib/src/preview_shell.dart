import 'package:flutter_hyper_ui/hyper_ui_preview_core.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'preview_catalog.dart';
import 'preview_deferred_content.dart';
import 'preview_glass_background.dart';

class PreviewShell extends StatelessWidget {
  final String componentId;
  final bool embedded;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onComponentReady;
  final ValueChanged<String>? onComponentError;

  const PreviewShell({
    super.key,
    required this.componentId,
    required this.embedded,
    this.onToggleTheme,
    this.onComponentReady,
    this.onComponentError,
  });

  @override
  Widget build(BuildContext context) {
    final item = PreviewCatalog.byId(componentId);

    if (embedded) {
      return _EmbeddedPreview(
        key: ValueKey(item.id),
        item: item,
        onReady: onComponentReady,
        onError: onComponentError,
      );
    }

    return _StandalonePreview(
      initialSelected: item,
      onToggleTheme: onToggleTheme,
      onComponentReady: onComponentReady,
      onComponentError: onComponentError,
    );
  }
}

class _EmbeddedPreview extends StatelessWidget {
  final PreviewItem item;
  final VoidCallback? onReady;
  final ValueChanged<String>? onError;

  const _EmbeddedPreview({
    super.key,
    required this.item,
    this.onReady,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewContent(item: item, onReady: onReady, onError: onError);
  }
}

/// 页面示例拥有完整视口；普通组件示例继续使用外层滚动和内容边距。
class _PreviewContent extends StatelessWidget {
  const _PreviewContent({required this.item, this.onReady, this.onError});

  final PreviewItem item;
  final VoidCallback? onReady;
  final ValueChanged<String>? onError;

  @override
  Widget build(BuildContext context) {
    final content = PreviewDeferredContent(
      key: ValueKey(item.id),
      item: item,
      onReady: onReady,
      onError: onError,
    );
    final viewport = item.fullScreen ? content : SingleChildScrollView(
      padding: const EdgeInsets.all(HyperUiSpacing.pagePadding),
      child: content,
    );
    final glassScene = item.id.startsWith('component-tab-bar') || const {'buttons','component-button','component-slider','component-switch','component-dialog'}.contains(item.id);
    return glassScene ? PreviewGlassBackground(child:viewport) : viewport;
  }
}

class _StandalonePreview extends StatefulWidget {
  final PreviewItem initialSelected;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onComponentReady;
  final ValueChanged<String>? onComponentError;

  const _StandalonePreview({
    required this.initialSelected,
    this.onToggleTheme,
    this.onComponentReady,
    this.onComponentError,
  });

  @override
  State<_StandalonePreview> createState() => _StandalonePreviewState();
}

class _StandalonePreviewState extends State<_StandalonePreview> {
  late String _selectedId = widget.initialSelected.id;

  PreviewItem get _selected => PreviewCatalog.byId(_selectedId);

  @override
  Widget build(BuildContext context) {
    final tokens = HyperUiThemeTokens.of(context);
    final selected = _selected;

    return ColoredBox(
      color: tokens.background,
      child: SafeArea(
        child: Column(
          children: [
            HyperNavBar(
              title: const Text(
                'Flutter Hyper UI Preview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                selected.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              safeArea: false,
              actions: [
                HyperButton(
                  type: 'icon',
                  icon: LucideIcons.sun,
                  tooltip: '切换明暗主题',
                  onPressed: widget.onToggleTheme,
                ),
              ],
            ),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: HyperUiSpacing.pagePadding,
                  vertical: HyperUiSpacing.xs,
                ),
                itemCount: PreviewCatalog.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: HyperUiSpacing.xs),
                itemBuilder: (context, index) {
                  final item = PreviewCatalog.items[index];
                  return HyperBadge(
                    type: 'tag',
                    label: item.title,
                    selected: item.id == selected.id,
                    onPressed: () => setState(() => _selectedId = item.id),
                  );
                },
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: _PreviewContent(
                    item: selected,
                    onReady: widget.onComponentReady,
                    onError: widget.onComponentError,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
