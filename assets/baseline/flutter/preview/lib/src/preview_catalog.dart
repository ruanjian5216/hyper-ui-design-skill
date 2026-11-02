import 'examples/component_tab_bar_examples.dart' deferred as example_tab_bar;
import 'package:flutter/widgets.dart';
import 'examples/component_theme_mode_dialog_example.dart'
    deferred as example_theme_mode_dialog;
import 'examples/component_safe_area_example.dart'
    deferred as example_component_safe_area;

import 'examples/actions_example.dart' deferred as example_actions_example;
import 'examples/buttons_example.dart' deferred as example_buttons_example;
import 'examples/calendar_examples.dart' deferred as example_calendar_examples;
import 'examples/cards_example.dart' deferred as example_cards_example;
import 'examples/component_action_examples.dart'
    deferred as example_component_action_examples;
import 'examples/component_carousel_example.dart'
    deferred as example_component_carousel_example;
import 'examples/component_composite_examples.dart'
    deferred as example_component_composite_examples;
import 'examples/component_loading_example.dart'
    deferred as example_component_loading;
import 'examples/component_feedback_examples.dart'
    deferred as example_component_feedback_examples;
import 'examples/component_update_dialog_example.dart'
    deferred as example_component_update_dialog_example;
import 'examples/component_foundation_examples.dart'
    deferred as example_component_foundation_examples;
import 'examples/component_form_field_example.dart'
    deferred as example_component_form_field_example;
import 'examples/component_form_examples.dart'
    deferred as example_component_form_examples;
import 'examples/component_layout_examples.dart'
    deferred as example_component_layout_examples;
import 'examples/component_navigation_examples.dart'
    deferred as example_component_navigation_examples;
import 'examples/component_nav_bar_example.dart'
    deferred as example_component_nav_bar_example;
import 'examples/component_scroll_gradient_example.dart'
    deferred as example_component_scroll_gradient_example;
import 'examples/component_number_stepper_example.dart'
    deferred as example_component_number_stepper_example;
import 'examples/component_pagination_example.dart'
    deferred as example_component_pagination_example;
import 'examples/component_surface_examples.dart'
    deferred as example_component_surface_examples;
import 'examples/component_tooltip_example.dart'
    deferred as example_component_tooltip_example;
import 'examples/data_example.dart' deferred as example_data_example;
import 'examples/drawer_example.dart' deferred as example_drawer_example;
import 'examples/feedback_example.dart' deferred as example_feedback_example;
import 'examples/component_library_example.dart'
    deferred as example_component_library_example;
import 'examples/inputs_example.dart' deferred as example_inputs_example;
import 'examples/navigation_example.dart'
    deferred as example_navigation_example;
import 'examples/overview_example.dart' deferred as example_overview_example;
import 'examples/upload_example.dart' deferred as example_upload_example;
import 'examples/complete_examples.dart' deferred as example_complete_examples;
import 'examples/home_hero_example.dart' deferred as example_home_hero_example;
import 'examples/interactive_examples.dart'
    deferred as example_interactive_examples;

typedef PreviewBuilder = Widget Function(BuildContext context);

/// 目录元数据立即可用；示例构造器必须在对应 loadLibrary 完成后调用。
class PreviewItem {
  final String id;
  final String title;
  final String description;
  // 同一个示例文件中的多个组件共享 Dart 的延迟加载结果。
  final Future<void> Function() loadLibrary;
  final PreviewBuilder builder;

  /// 页面示例直接占满宿主视口，由示例自身管理滚动。
  final bool fullScreen;

  const PreviewItem({
    required this.id,
    required this.title,
    required this.description,
    required this.loadLibrary,
    required this.builder,
    this.fullScreen = false,
  });
}

PreviewItem _componentPreview(
  String id,
  String title,
  String description,
  Future<void> Function() loadLibrary,
  PreviewBuilder builder,
) => PreviewItem(
  id: id,
  title: title,
  description: description,
  loadLibrary: loadLibrary,
  builder: builder,
);

class PreviewCatalog {
  const PreviewCatalog._();

  static const defaultId = 'component-library';

  static final List<PreviewItem> items = [
    PreviewItem(
      id: 'component-library',
      title: 'Hyper UI 组件库',
      description: '通用导航、表单、菜单、反馈与加载组件。',
      loadLibrary: () => example_component_library_example.loadLibrary(),
      builder: (_) =>
          example_component_library_example.ComponentLibraryExample(),
    ),
    PreviewItem(
      id: 'home-hero',
      fullScreen: true,
      title: '首页真机',
      description: '首页英雄区的真实组件拼合。',
      loadLibrary: () => example_home_hero_example.loadLibrary(),
      builder: (_) => example_home_hero_example.HomeHeroExample(),
    ),
    PreviewItem(
      id: 'drawer',
      title: 'Drawer 抽屉',
      description: '侧边导航、筛选与返回结果。',
      loadLibrary: () => example_drawer_example.loadLibrary(),
      builder: (_) => example_drawer_example.DrawerExample(),
    ),
    PreviewItem(
      id: 'actions',
      title: '按钮与卡片',
      description: '动作层级、状态与内容容器。',
      loadLibrary: () => example_actions_example.loadLibrary(),
      builder: (_) => example_actions_example.ActionsExample(),
    ),
    PreviewItem(
      id: 'atoms',
      title: '基础原子',
      description: '文字、图标、图片、头像与角标。',
      loadLibrary: () => example_complete_examples.loadLibrary(),
      builder: (_) => example_complete_examples.AtomsExample(),
    ),
    PreviewItem(
      id: 'layout',
      title: '布局容器',
      description: '玻璃卡片、网格、流式布局与骨架。',
      loadLibrary: () => example_complete_examples.loadLibrary(),
      builder: (_) => example_complete_examples.LayoutExample(),
    ),
    PreviewItem(
      id: 'forms',
      title: '完整表单',
      description: '输入、选择、日期与上传。',
      loadLibrary: () => example_complete_examples.loadLibrary(),
      builder: (_) => example_complete_examples.FormsExample(),
    ),
    PreviewItem(
      id: 'upload',
      title: '文件上传',
      description: '选择、进度、取消、失败和重试状态。',
      loadLibrary: () => example_upload_example.loadLibrary(),
      builder: (_) => example_upload_example.UploadExample(),
    ),
    PreviewItem(
      id: 'overlays',
      title: '反馈弹层',
      description: '轻提示、弹窗、菜单与加载。',
      loadLibrary: () => example_interactive_examples.loadLibrary(),
      builder: (_) => example_interactive_examples.OverlayExample(),
    ),
    PreviewItem(
      id: 'full-navigation',
      title: '导航与列表',
      description: '悬浮导航、页面联动与步骤状态。',
      loadLibrary: () => example_complete_examples.loadLibrary(),
      builder: (_) => example_complete_examples.FullNavigationExample(),
    ),
    PreviewItem(
      id: 'business',
      title: '业务组件',
      description: '设置菜单、搜索与时间轴。',
      loadLibrary: () => example_interactive_examples.loadLibrary(),
      builder: (_) => example_interactive_examples.BusinessExample(),
    ),
    PreviewItem(
      id: 'overview',
      title: '组件概览',
      description: 'Hyper UI 的基础控件组合。',
      loadLibrary: () => example_overview_example.loadLibrary(),
      builder: (_) => example_overview_example.OverviewExample(),
    ),
    PreviewItem(
      id: 'buttons', fullScreen: true,
      title: 'Button 按钮',
      description: '用于明确动作、弱动作与危险动作。',
      loadLibrary: () => example_buttons_example.loadLibrary(),
      builder: (_) => example_buttons_example.ButtonsExample(),
    ),
    PreviewItem(
      id: 'cards',
      title: 'Card 卡片',
      description: '用于承载列表项、状态摘要与操作区。',
      loadLibrary: () => example_cards_example.loadLibrary(),
      builder: (_) => example_cards_example.CardsExample(),
    ),
    PreviewItem(
      id: 'inputs',
      title: 'Input 输入',
      description: '输入框与分段选择的基础状态。',
      loadLibrary: () => example_inputs_example.loadLibrary(),
      builder: (_) => example_inputs_example.InputsExample(),
    ),
    PreviewItem(
      id: 'data',
      title: 'Data 数据展示',
      description: '列表项、标签与进度条。',
      loadLibrary: () => example_data_example.loadLibrary(),
      builder: (_) => example_data_example.DataExample(),
    ),
    PreviewItem(
      id: 'feedback',
      title: 'Feedback 反馈',
      description: '空状态与语义徽标。',
      loadLibrary: () => example_feedback_example.loadLibrary(),
      builder: (_) => example_feedback_example.FeedbackExample(),
    ),
    PreviewItem(
      id: 'navigation',
      title: 'Navigation 导航',
      description: '顶部栏与可点击列表项。',
      loadLibrary: () => example_navigation_example.loadLibrary(),
      builder: (_) => example_navigation_example.NavigationExample(),
    ),
    PreviewItem(
      id: 'component-button', fullScreen: true,
      title: 'HyperButton',
      description: '38 高的共用玻璃按钮；按压反馈与加载拦截以 Kotlin 文档示例为准。',
      loadLibrary: () => example_buttons_example.loadLibrary(),
      builder: (_) => example_buttons_example.ButtonsExample(),
    ),
    PreviewItem(
      id: 'component-card',
      title: 'HyperCard',
      description: '单一卡片的内容结构。',
      loadLibrary: () => example_component_surface_examples.loadLibrary(),
      builder: (_) => example_component_surface_examples.CardComponentExample(),
    ),
    PreviewItem(
      id: 'component-skeleton',
      title: 'HyperSkeleton',
      description: '加载占位状态。',
      loadLibrary: () => example_component_feedback_examples.loadLibrary(),
      builder: (_) =>
          example_component_feedback_examples.SkeletonComponentExample(),
    ),
    PreviewItem(
      id: 'component-text-field',
      title: 'HyperTextField',
      description: '输入、辅助与错误状态。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) =>
          example_component_form_examples.TextFieldComponentExample(),
    ),
    PreviewItem(
      id: 'component-tabs',
      title: 'HyperTabs',
      description: '受控分段选择。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) => example_component_form_examples.TabsComponentExample(),
    ),
    PreviewItem(
      id: 'component-dropdown',
      title: 'HyperDropdown',
      description: '锚定式下拉选择。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) =>
          example_component_form_examples.DropdownComponentExample(),
    ),
    PreviewItem(
      id: 'component-checkbox',
      title: 'HyperCheckbox',
      description: '受控复选状态。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) =>
          example_component_form_examples.CheckboxComponentExample(),
    ),
    PreviewItem(
      id: 'component-radio',
      title: 'HyperRadio',
      description: '互斥单选与禁用项；标签行不叠加圆环触摸留白。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) => example_component_form_examples.RadioComponentExample(),
    ),
    PreviewItem(
      id: 'component-theme-dialog',
      title: 'HyperThemeDialog',
      description: '36dp 紧凑三选项，选择后关闭。',
      loadLibrary: () => example_theme_mode_dialog.loadLibrary(),
      builder: (_) => example_theme_mode_dialog.ThemeModeDialogComponentExample(),
    ),
    PreviewItem(
      id: 'component-switch',
      title: 'HyperSwitch',
      description: '参考 Toggle 的弹性、Ambient 与横向拖动；保留开启、关闭及禁用。',
      fullScreen: true,
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) => example_component_form_examples.SwitchComponentExample(),
    ),
    PreviewItem(
      id: 'component-slider',
      title: 'HyperSlider',
      description: '连续拖动与离散数值。',
      loadLibrary: () => example_component_form_examples.loadLibrary(),
      builder: (_) => example_component_form_examples.SliderComponentExample(),
    ),
    _componentPreview(
      'component-number-stepper',
      'HyperNumberStepper',
      '紧凑整数增减与边界状态。',
      () => example_component_number_stepper_example.loadLibrary(),
      (_) =>
          example_component_number_stepper_example.NumberStepperComponentExample(),
    ),
    _componentPreview(
      'component-form-field',
      'HyperFormField',
      '字段标题、辅助与错误状态。',
      () => example_component_form_field_example.loadLibrary(),
      (_) => example_component_form_field_example.FormFieldComponentExample(),
    ),
    PreviewItem(
      id: 'component-uploader',
      title: 'HyperUploader',
      description: '上传进度、取消与重试。',
      loadLibrary: () => example_upload_example.loadLibrary(),
      builder: (_) => example_upload_example.UploadExample(),
    ),
    PreviewItem(
      id: 'component-toast',
      title: 'HyperToast',
      description: '语义轻提示与操作。',
      loadLibrary: () => example_component_feedback_examples.loadLibrary(),
      builder: (_) =>
          example_component_feedback_examples.ToastComponentExample(),
    ),
    PreviewItem(
      id: 'component-drawer',
      title: 'HyperDrawer',
      description: '抽屉打开、关闭与返回值。',
      loadLibrary: () => example_component_feedback_examples.loadLibrary(),
      builder: (_) =>
          example_component_feedback_examples.DrawerComponentExample(),
    ),
    PreviewItem(
      id: 'component-scroll-gradient',
      fullScreen: true,
      title: 'HyperScrollGradient',
      description: '滚动渐显的主题渐变，不采样正文。',
      loadLibrary: () => example_component_scroll_gradient_example.loadLibrary(),
      builder: (_) => example_component_scroll_gradient_example.ScrollGradientComponentExample(),
    ),
    PreviewItem(
      id: 'component-nav-bar',
      fullScreen: true,
      title: 'HyperNavBar',
      description: 'standard 显示操作行，simple 仅适配状态栏和挖孔；两种形态共用滚动渐变。',
      loadLibrary: () => example_component_nav_bar_example.loadLibrary(),
      builder: (_) =>
          example_component_nav_bar_example.NavBarComponentExample(),
    ),
    PreviewItem(
      id: 'component-safe-area',
      title: 'HyperSafeArea',
      description: '方向、系统区与嵌套单次消费。',
      loadLibrary: () => example_component_safe_area.loadLibrary(),
      builder: (_) => example_component_safe_area.SafeAreaComponentExample(),
    ),
    PreviewItem(
      id: 'component-tab-bar', fullScreen: true,
      title: 'HyperTabBar 交互预览',
      description: '与 Kotlin 文档示例一致；栏内最多五项，栏外一个 48 独立入口；轮廓与高光遵循 Kotlin，保留原选中块高度。',
      loadLibrary: () => example_tab_bar.loadLibrary(),
      builder: (_) => example_tab_bar.TabBarComponentExample(),
    ),
    PreviewItem(
      id: 'component-tab-bar-docked', fullScreen: true,
      title: '非悬浮动作栏：重复点击与禁用项',
      description: '与 Kotlin 文档示例一致；栏内最多五项，栏外一个 48 独立入口；轮廓与高光遵循 Kotlin，保留原选中块高度。',
      loadLibrary: () => example_tab_bar.loadLibrary(),
      builder: (_) => example_tab_bar.DockedTabBarComponentExample(),
    ),
    PreviewItem(
      id: 'component-tab-bar-single', fullScreen: true,
      title: '单动作与角标',
      description: '与 Kotlin 文档示例一致；栏内最多五项，栏外一个 48 独立入口；轮廓与高光遵循 Kotlin，保留原选中块高度。',
      loadLibrary: () => example_tab_bar.loadLibrary(),
      builder: (_) => example_tab_bar.SingleTabBarComponentExample(),
    ),
    PreviewItem(
      id: 'component-tab-bar-trailing', fullScreen: true,
      title: '56dp 主导航与 48dp 独立操作居中并排',
      description: '与 Kotlin 文档示例一致；栏内最多五项，栏外一个 48 独立入口；轮廓与高光遵循 Kotlin，保留原选中块高度。',
      loadLibrary: () => example_tab_bar.loadLibrary(),
      builder: (_) => example_tab_bar.TrailingTabBarComponentExample(),
    ),
    PreviewItem(
      id: 'component-list-tile',
      title: 'HyperListTile',
      description: '列表项的常见状态，水平留白由预览宿主统一提供。',
      loadLibrary: () => example_component_navigation_examples.loadLibrary(),
      builder: (_) =>
          example_component_navigation_examples.ListTileComponentExample(),
    ),
    PreviewItem(
      id: 'component-menu-group',
      title: 'HyperMenuGroup',
      description: '设置页式分组菜单，标题和行不叠加水平缩进。',
      loadLibrary: () => example_component_navigation_examples.loadLibrary(),
      builder: (_) =>
          example_component_navigation_examples.MenuGroupComponentExample(),
    ),
    PreviewItem(
      id: 'component-slide-menu',
      title: 'HyperSlideMenu',
      description: '双向拖拽快捷操作。',
      loadLibrary: () => example_component_navigation_examples.loadLibrary(),
      builder: (_) =>
          example_component_navigation_examples.SlideMenuComponentExample(),
    ),
    _componentPreview(
      'component-text',
      'HyperText',
      '六种语义文字层级。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.TextComponentExample(),
    ),
    _componentPreview(
      'component-icon',
      'HyperIcon',
      '常用图标与语义标签。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.IconComponentExample(),
    ),
    _componentPreview(
      'component-image',
      'HyperImage',
      '图片加载与缩放预览。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.ImageComponentExample(),
    ),
    _componentPreview(
      'component-avatar',
      'HyperAvatar',
      '头像形态与尺寸。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.AvatarComponentExample(),
    ),
    _componentPreview(
      'component-badge',
      'HyperBadge',
      '紧凑语义状态徽标。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.BadgeComponentExample(),
    ),
    _componentPreview(
      'component-ui-tone',
      'HyperUiTone',
      '跨组件语义状态。',
      () => example_component_foundation_examples.loadLibrary(),
      (_) => example_component_foundation_examples.ToneComponentExample(),
    ),
    _componentPreview(
      'component-pressable',
      'HyperPressable',
      '即时按压反馈。',
      () => example_component_action_examples.loadLibrary(),
      (_) => example_component_action_examples.PressableComponentExample(),
    ),
    _componentPreview(
      'component-divider',
      'HyperDivider',
      '横纵与虚实分割线。',
      () => example_component_layout_examples.loadLibrary(),
      (_) => example_component_layout_examples.DividerComponentExample(),
    ),
    _componentPreview(
      'component-empty-state',
      'HyperEmptyState',
      '空状态与恢复操作。',
      () => example_component_layout_examples.loadLibrary(),
      (_) => example_component_layout_examples.EmptyStateComponentExample(),
    ),
    _componentPreview(
      'component-page-content-sliver',
      'HyperPageContentSliver',
      '统一页面边距与宽屏居中限宽。',
      () => example_component_layout_examples.loadLibrary(),
      (_) => example_component_layout_examples.PageContentComponentExample(),
    ),
    _componentPreview(
      'component-select',
      'HyperSelect',
      '底部弹层选择。',
      () => example_component_form_examples.loadLibrary(),
      (_) => example_component_form_examples.SelectComponentExample(),
    ),
    _componentPreview(
      'component-picker',
      'HyperPicker',
      '滚轮选择器。',
      () => example_component_form_examples.loadLibrary(),
      (_) => example_component_form_examples.PickerComponentExample(),
    ),
    _componentPreview(
      'component-calendar-day',
      'HyperCalendarDay',
      '日期格、角标与附属条目。',
      () => example_calendar_examples.loadLibrary(),
      (_) => example_calendar_examples.CalendarDayComponentExample(),
    ),
    _componentPreview(
      'component-calendar-month',
      'HyperCalendarMonth',
      '内嵌、紧凑与只读月历。',
      () => example_calendar_examples.loadLibrary(),
      (_) => example_calendar_examples.CalendarMonthComponentExample(),
    ),
    _componentPreview(
      'component-date-picker',
      'HyperDatePicker',
      '月历选择日期与区间。',
      () => example_component_form_examples.loadLibrary(),
      (_) => example_component_form_examples.DatePickerComponentExample(),
    ),
    _componentPreview(
      'component-file-picker',
      'HyperFilePicker',
      '文件能力注入边界。',
      () => example_component_form_examples.loadLibrary(),
      (_) => example_component_form_examples.FilePickerComponentExample(),
    ),
    _componentPreview(
      'component-dialog',
      'HyperDialog',
      '玻璃确认对话框。',
      () => example_component_feedback_examples.loadLibrary(),
      (_) => example_component_feedback_examples.DialogComponentExample(),
    ),
    _componentPreview(
      'component-loading',
      'HyperLoading',
      '默认随机与十款原生动画，固定 2× 节奏。',
      () => example_component_loading.loadLibrary(),
      (_) => example_component_loading.LoadingComponentExample(),
    ),
    _componentPreview(
      'component-update-dialog',
      'HyperUpdateDialog',
      '检查更新、版本日志、下载、安装与失败重试。',
      () => example_component_update_dialog_example.loadLibrary(),
      (_) =>
          example_component_update_dialog_example.UpdateDialogComponentExample(),
    ),
    _componentPreview(
      'component-update-status',
      'HyperUpdateStatus / HyperUpdateRelease',
      '更新状态与版本信息模型。',
      () => example_component_update_dialog_example.loadLibrary(),
      (_) =>
          example_component_update_dialog_example.UpdateDialogComponentExample(),
    ),
    _componentPreview(
      'component-update-download-progress',
      'HyperUpdateDownloadProgress',
      '字节下载量、百分比、速度和未知总大小。',
      () => example_component_update_dialog_example.loadLibrary(),
      (_) =>
          example_component_update_dialog_example.UpdateDialogComponentExample(),
    ),
    _componentPreview(
      'component-action-sheet',
      'HyperActionSheet',
      '底部操作菜单。',
      () => example_component_feedback_examples.loadLibrary(),
      (_) => example_component_feedback_examples.ActionSheetComponentExample(),
    ),
    _componentPreview(
      'component-popover',
      'HyperPopover',
      '锚定补充说明。',
      () => example_component_feedback_examples.loadLibrary(),
      (_) => example_component_feedback_examples.PopoverComponentExample(),
    ),
    _componentPreview(
      'component-tooltip',
      'HyperTooltip',
      '自绘玻璃提示。',
      () => example_component_tooltip_example.loadLibrary(),
      (_) => example_component_tooltip_example.TooltipComponentExample(),
    ),
    _componentPreview(
      'component-popup-menu',
      'HyperPopupMenu',
      '泛型弹出菜单。',
      () => example_component_feedback_examples.loadLibrary(),
      (_) => example_component_feedback_examples.PopupMenuComponentExample(),
    ),
    _componentPreview(
      'component-notice-bar',
      'HyperNoticeBar',
      '可关闭滚动公告。',
      () => example_component_feedback_examples.loadLibrary(),
      (_) => example_component_feedback_examples.NoticeBarComponentExample(),
    ),
    _componentPreview(
      'component-filter-bar',
      'HyperFilterBar',
      '浅底细线的紧凑分类按钮，淡主题色选中态。',
      () => example_component_navigation_examples.loadLibrary(),
      (_) => example_component_navigation_examples.FilterBarComponentExample(),
    ),
    _componentPreview(
      'component-carousel',
      'HyperCarousel',
      '滑动轮播与页码状态。',
      () => example_component_carousel_example.loadLibrary(),
      (_) => example_component_carousel_example.CarouselComponentExample(),
    ),
    _componentPreview(
      'component-page-indicator',
      'HyperPageIndicator',
      '独立页码指示器。',
      () => example_component_carousel_example.loadLibrary(),
      (_) => example_component_carousel_example.PageIndicatorComponentExample(),
    ),
    _componentPreview(
      'component-steps',
      'HyperSteps',
      '步骤状态。',
      () => example_component_navigation_examples.loadLibrary(),
      (_) => example_component_navigation_examples.StepsComponentExample(),
    ),
    _componentPreview(
      'component-progress',
      'HyperProgress',
      '线性与环形进度。',
      () => example_component_navigation_examples.loadLibrary(),
      (_) => example_component_navigation_examples.ProgressComponentExample(),
    ),
    _componentPreview(
      'component-pagination',
      'HyperPagination',
      '可直接跳页的受控分页。',
      () => example_component_pagination_example.loadLibrary(),
      (_) => example_component_pagination_example.PaginationComponentExample(),
    ),
    _componentPreview(
      'component-collapse',
      'HyperCollapse',
      '折叠内容。',
      () => example_component_composite_examples.loadLibrary(),
      (_) => example_component_composite_examples.CollapseComponentExample(),
    ),
    _componentPreview(
      'component-timeline',
      'HyperTimeline',
      '流程事件时间轴。',
      () => example_component_composite_examples.loadLibrary(),
      (_) => example_component_composite_examples.TimelineComponentExample(),
    ),
  ];

  static bool contains(String id) => items.any((item) => item.id == id);

  static PreviewItem byId(String id) {
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('未注册的预览组件：$id'),
    );
  }
}
