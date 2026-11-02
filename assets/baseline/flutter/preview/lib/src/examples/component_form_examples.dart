import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_hyper_ui/hyper_ui.dart';

// doc-region TextFieldComponentExample
class TextFieldComponentExample extends StatelessWidget {
  const TextFieldComponentExample({super.key});

  // 基础输入可连续操作：打开键盘、系统返回收起、再次点同一位置。
  // 字段标题写在输入框外部：输入组件本身不携带标题与说明。
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('基础输入'),
        const HyperTextField(placeholder: '请输入内容'),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('可清空'),
        const HyperTextField(
          type: 'search',
          clearable: true,
          initialValue: '示例内容',
          placeholder: '输入后右侧显示清空按钮',
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('密码显隐'),
        const HyperTextField(
          type: 'password',
          showPasswordToggle: true,
          placeholder: '请输入密码',
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('前缀与后缀插槽'),
        const HyperTextField(
          placeholder: '搜索组件',
          prefix: Icon(LucideIcons.search),
          suffix: Icon(LucideIcons.slidersHorizontal),
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('多行输入'),
        const HyperTextField(type: 'textarea', rows: 3, placeholder: '请输入多行内容'),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('字数统计'),
        const HyperTextField(
          maxLength: 50,
          showWordLimit: true,
          placeholder: '最多输入 50 个字符',
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('禁用与只读'),
        const HyperTextField(enabled: false, initialValue: '禁用状态'),
        const SizedBox(height: HyperUiSpacing.sm),
        const HyperTextField(readOnly: true, initialValue: '只读状态'),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('错误态'),
        const HyperTextField(initialValue: '错误内容', errorText: '内容格式不正确'),
      ],
    );
  }
}
// end-doc-region TextFieldComponentExample

// doc-region TabsComponentExample
class TabsComponentExample extends StatefulWidget {
  const TabsComponentExample({super.key});

  @override
  State<TabsComponentExample> createState() => _TabsComponentExampleState();
}

class _TabsComponentExampleState extends State<TabsComponentExample> {
  int _value = 0;
  int _scope = 0;
  int _view = 0;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('受控切换 · 连续点击观察选中底板移动'),
        HyperTabs<String>(
          selectedIndex: _value,
          onChanged: (value) => setState(() => _value = value),
          tabs: const [
            HyperTabsItem(value: 'day', label: '日'),
            HyperTabsItem(value: 'week', label: '周'),
            HyperTabsItem(value: 'month', label: '月'),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.sm),
        HyperText('当前值：${['日', '周', '月'][_value]}'),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('非等宽布局'),
        HyperTabs<String>(
          equalWidth: false,
          selectedIndex: _scope,
          onChanged: (value) => setState(() => _scope = value),
          tabs: const [
            HyperTabsItem(value: 'all', label: '全部'),
            HyperTabsItem(value: 'todo', label: '待办'),
            HyperTabsItem(value: 'done', label: '已完成'),
            HyperTabsItem(value: 'draft', label: '草稿箱'),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('图标与禁用项'),
        HyperTabs<String>(
          selectedIndex: _view,
          onChanged: (value) => setState(() => _view = value),
          tabs: const [
            HyperTabsItem(value: 'list', label: '列表', icon: LucideIcons.list),
            HyperTabsItem(
              value: 'chart',
              label: '图表',
              icon: LucideIcons.trendingUp,
            ),
            HyperTabsItem(
              value: 'board',
              label: '看板（未开放）',
              icon: LucideIcons.layoutDashboard,
              enabled: false,
            ),
          ],
        ),
      ],
    );
  }
}
// end-doc-region TabsComponentExample

// doc-region DropdownComponentExample
class DropdownComponentExample extends StatefulWidget {
  const DropdownComponentExample({super.key});

  @override
  State<DropdownComponentExample> createState() =>
      _DropdownComponentExampleState();
}

class _DropdownComponentExampleState extends State<DropdownComponentExample> {
  String? _value = 'recent';
  String? _owner;
  int _pageSize = 20;
  String? _longValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        HyperDropdown<String>(
          label: '排序方式 · 展开与收起动画',
          value: _value,
          onChanged: (value) => setState(() => _value = value),
          options: const [
            HyperOption(value: 'recent', label: '最近更新'),
            HyperOption(value: 'name', label: '按名称'),
            HyperOption(value: 'created', label: '创建时间'),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.xl),

        HyperDropdown<String>(
          label: '负责人',
          placeholder: '选择负责人',
          value: _owner,
          onChanged: (value) => setState(() => _owner = value),
          options: const [
            HyperOption(value: 'ada', label: 'Ada'),
            HyperOption(value: 'bob', label: 'Bob'),
            HyperOption(value: 'eve', label: 'Eve（已停用）', enabled: false),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.xl),

        HyperDropdown<int>(
          width: 220,
          label: '每页数量',
          value: _pageSize,
          menuMaxHeight: 160,
          onChanged: (value) => setState(() => _pageSize = value),
          options: const [
            HyperOption(value: 10, label: '每页 10 条'),
            HyperOption(value: 20, label: '每页 20 条'),
            HyperOption(value: 50, label: '每页 50 条'),
            HyperOption(value: 100, label: '每页 100 条'),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.xl),
        HyperDropdown<String>(
          label: '长选项',
          value: _longValue,
          onChanged: (value) => setState(() => _longValue = value),
          options: const [
            HyperOption(value: 'lastPlayed', label: '按最近播放时间排序并保留原始文件名称'),
            HyperOption(value: 'name', label: '按名称'),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.xl),
        HyperDropdown<String>(
          label: '空选项',
          options: const [],
          onChanged: (_) {},
        ),
        const SizedBox(height: HyperUiSpacing.xl),
        const HyperDropdown<String>(
          label: '禁用',
          enabled: false,
          value: 'recent',
          options: [HyperOption(value: 'recent', label: '最近更新')],
        ),
      ],
    );
  }
}
// end-doc-region DropdownComponentExample

// doc-region CheckboxComponentExample
class CheckboxComponentExample extends StatefulWidget {
  const CheckboxComponentExample({super.key});

  @override
  State<CheckboxComponentExample> createState() =>
      _CheckboxComponentExampleState();
}

class _CheckboxComponentExampleState extends State<CheckboxComponentExample> {
  bool? _value = true;
  bool? _partial;
  bool _plain = false;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('受控复选'),
        // 直接展示组件默认标签行，不添加卡片包装。
        HyperCheckbox(
          value: _value,
          label: '同步到所有设备',
          onChanged: (value) => setState(() => _value = value),
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('三态（全选 / 部分 / 空）'),
        HyperCheckbox(
          tristate: true,
          value: _partial,
          label: '已选择 2 / 4 项',
          onChanged: (value) => setState(() => _partial = value),
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('禁用状态'),
        const HyperCheckbox(value: false, label: '禁用 · 未选中'),
        const SizedBox(height: HyperUiSpacing.sm),
        const HyperCheckbox(value: true, label: '禁用 · 已选中'),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('纯控件（无标签）'),
        Row(
          children: [
            HyperCheckbox(
              value: _plain,
              onChanged: (value) => setState(() => _plain = value ?? false),
            ),
            const SizedBox(width: HyperUiSpacing.md),
            const HyperCheckbox(value: true),
            const SizedBox(width: HyperUiSpacing.md),
            const HyperCheckbox(value: false, tristate: true),
          ],
        ),
      ],
    );
  }
}
// end-doc-region CheckboxComponentExample

// doc-region RadioComponentExample
class RadioComponentExample extends StatefulWidget {
  const RadioComponentExample({super.key});

  @override
  State<RadioComponentExample> createState() => _RadioComponentExampleState();
}

class _RadioComponentExampleState extends State<RadioComponentExample> {
  String _value = 'system';

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  @override
  Widget build(BuildContext context) {
    const labels = <String, String>{
      'system': '跟随系统',
      'light': '浅色',
      'dark': '深色',
      'amoled': '纯黑（Pro）',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('互斥单选'),
        // 标签行统一处理点击，圆环不叠加独立触摸留白或额外行间距。
        for (final entry in labels.entries)
          HyperRadio<String>(
            value: entry.key,
            groupValue: _value,
            label: entry.value,
            // Pro 档位仅作展示：onChanged 为 null 即禁用。
            onChanged: entry.key == 'amoled'
                ? null
                : (value) => setState(() => _value = value),
          ),
        const SizedBox(height: HyperUiSpacing.sm),
        HyperText('当前值：$_value'),
        const SizedBox(height: HyperUiSpacing.lg),
        _label('纯控件（无标签）'),
        Row(
          children: [
            HyperRadio<String>(
              value: 'system',
              groupValue: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
            const SizedBox(width: HyperUiSpacing.sm),
            const HyperRadio<String>(value: 'preview', groupValue: 'preview'),
            const SizedBox(width: HyperUiSpacing.sm),
            const HyperRadio<String>(
              value: 'disabled',
              groupValue: null,
              enabled: false,
            ),
          ],
        ),
      ],
    );
  }
}
// end-doc-region RadioComponentExample

// doc-region SwitchComponentExample
class SwitchComponentExample extends StatefulWidget {
  const SwitchComponentExample({super.key});

  @override
  State<SwitchComponentExample> createState() => _SwitchComponentExampleState();
}

class _SwitchComponentExampleState extends State<SwitchComponentExample> {
  // 正式 Switch 支持长按扩张、Ambient 与横向拖动；标签行和纯控件由示例持有值。
  bool _enabled = true;
  bool _plain = false;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 12,
        color: HyperUiThemeTokens.of(context).mutedForeground,
      ),
      child: HyperText(text),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('受控开关'),
        HyperSwitch(
          value: _enabled,
          label: '接收消息通知',
          onChanged: (value) => setState(() => _enabled = value),
        ),
        const SizedBox(height: 24),

        _label('禁用状态'),
        const HyperSwitch(value: true, label: '禁用 · 开启'),
        const SizedBox(height: 14),
        const HyperSwitch(value: false, label: '禁用 · 关闭'),
        const SizedBox(height: 24),

        _label('纯控件（无标签）'),
        Row(
          children: [
            HyperSwitch(
              value: _plain,
              onChanged: (value) => setState(() => _plain = value),
            ),
            const SizedBox(width: HyperUiSpacing.md),
            const HyperSwitch(value: true),
          ],
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
// end-doc-region SwitchComponentExample

// doc-region SliderComponentExample
class SliderComponentExample extends StatefulWidget {
  const SliderComponentExample({super.key});

  @override
  State<SliderComponentExample> createState() => _SliderComponentExampleState();
}

class _SliderComponentExampleState extends State<SliderComponentExample> {
  // 点击弹簧定位、按压高光和拖动提交均复用正式滑块。
  double _continuous = 42;
  double _discrete = 3;
  double _age = 26;
  String? _committedAge;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('连续取值'),
        HyperSlider(
          value: _continuous,
          onChanged: (value) => setState(() => _continuous = value),
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('离散分段（divisions: 5）'),
        HyperSlider(
          value: _discrete,
          max: 5,
          divisions: 5,
          onChanged: (value) => setState(() => _discrete = value),
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('自定义范围与提交回调'),
        HyperSlider(
          value: _age,
          min: 18,
          max: 60,
          showValue: false,
          onChanged: (value) => setState(() => _age = value),
          // onChangeEnd 在拖动结束时触发，适合提交最终值。
          onChangeEnd: (value) =>
              setState(() => _committedAge = '已提交：${value.toInt()} 岁'),
        ),
        const SizedBox(height: HyperUiSpacing.sm),
        HyperText(
          '当前：${_age.toInt()} 岁${_committedAge == null ? '' : ' · $_committedAge'}',
        ),
      ],
    );
  }
}
// end-doc-region SliderComponentExample

// doc-region SelectComponentExample
class SelectComponentExample extends StatefulWidget {
  const SelectComponentExample({super.key});

  @override
  State<SelectComponentExample> createState() => _SelectComponentExampleState();
}

class _SelectComponentExampleState extends State<SelectComponentExample> {
  String? _single = 'test';
  List<String> _multi = const ['design', 'develop'];
  String? _team;

  @override
  Widget build(BuildContext context) {
    const options = <HyperOption<String>>[
      HyperOption(value: 'design', label: '设计'),
      HyperOption(value: 'develop', label: '开发'),
      HyperOption(value: 'test', label: '测试'),
      HyperOption(value: 'archive', label: '已归档', enabled: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        HyperSelect<String>(
          label: '交付状态',
          value: _single,
          onChanged: (value) => setState(() => _single = value),
          options: options,
        ),
        const SizedBox(height: HyperUiSpacing.xl),

        HyperSelect<String>(
          type: 'multiple',
          label: '协作角色',
          values: _multi,
          onMultipleChanged: (values) => setState(() => _multi = values),
          options: options,
        ),
        const SizedBox(height: HyperUiSpacing.xl),

        HyperSelect<String>(
          label: '所在团队',
          placeholder: '请选择所在团队',
          value: _team,
          onChanged: (value) => setState(() => _team = value),
          options: const [
            HyperOption(value: 'app', label: '应用组'),
            HyperOption(value: 'web', label: '平台组'),
          ],
        ),
      ],
    );
  }
}
// end-doc-region SelectComponentExample

// doc-region PickerComponentExample
class PickerComponentExample extends StatefulWidget {
  const PickerComponentExample({super.key});

  @override
  State<PickerComponentExample> createState() => _PickerComponentExampleState();
}

class _PickerComponentExampleState extends State<PickerComponentExample> {
  String _value = '尚未选择';
  String _city = '上海';

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  Future<void> _pick() async {
    final value = await HyperPicker.show<String>(
      context,
      title: '选择交付周期',
      options: const [
        HyperOption(value: '今天', label: '今天'),
        HyperOption(value: '本周', label: '本周'),
        HyperOption(value: '下周', label: '下周'),
      ],
    );
    if (mounted && value != null) setState(() => _value = value);
  }

  Future<void> _pickCity() async {
    final value = await HyperPicker.show<String>(
      context,
      title: '常用城市',
      // initialIndex 让滚轮停在指定项。
      initialIndex: 2,
      options: const [
        HyperOption(value: '北京', label: '北京'),
        HyperOption(value: '广州', label: '广州'),
        HyperOption(value: '上海', label: '上海'),
        HyperOption(value: '深圳', label: '深圳'),
      ],
    );
    if (mounted && value != null) setState(() => _city = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('基础滚轮选择'),
        Row(
          children: [
            HyperButton(label: '选择交付周期', onPressed: _pick),
            const SizedBox(width: 14),
            HyperBadge(label: _value),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('指定初始项（initialIndex: 2）'),
        Row(
          children: [
            HyperButton(label: '选择城市', onPressed: _pickCity),
            const SizedBox(width: 14),
            HyperBadge(label: _city),
          ],
        ),
      ],
    );
  }
}
// end-doc-region PickerComponentExample

// doc-region DatePickerComponentExample
class DatePickerComponentExample extends StatefulWidget {
  const DatePickerComponentExample({super.key});

  @override
  State<DatePickerComponentExample> createState() =>
      _DatePickerComponentExampleState();
}

class _DatePickerComponentExampleState
    extends State<DatePickerComponentExample> {
  DateTime? _date;
  HyperTimeOfDay? _time;
  HyperDateRange? _range;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: HyperUiSpacing.xs),
    child: HyperText(text),
  );

  Future<void> _pickDate() async {
    final value = await HyperDatePicker.date(context, initialDate: _date);
    if (mounted && value != null) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await HyperDatePicker.time(context, initialTime: _time);
    if (mounted && value != null) setState(() => _time = value);
  }

  Future<void> _pickRange() async {
    final value = await HyperDatePicker.range(context, initialRange: _range);
    if (mounted && value != null) setState(() => _range = value);
  }

  String _format(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('月历选择日期 · 玻璃面板'),
        Row(
          children: [
            HyperButton(
              label: '选择日期',
              icon: LucideIcons.calendar,
              onPressed: _pickDate,
            ),
            const SizedBox(width: 14),
            HyperBadge(label: _date == null ? '未选择' : _format(_date!)),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('时间选择'),
        Row(
          children: [
            HyperButton(
              label: '选择时间',
              icon: LucideIcons.clock,
              onPressed: _pickTime,
            ),
            const SizedBox(width: 14),
            HyperBadge(label: _time == null ? '未选择' : _time!.format()),
          ],
        ),
        const SizedBox(height: HyperUiSpacing.lg),

        _label('月历选择日期区间'),
        Row(
          children: [
            HyperButton(
              label: '选择区间',
              icon: LucideIcons.calendarDays,
              onPressed: _pickRange,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: HyperBadge(
                label: _range == null
                    ? '未选择'
                    : '${_format(_range!.start)} ~ ${_format(_range!.end)}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
// end-doc-region DatePickerComponentExample

// doc-region FilePickerComponentExample
class FilePickerComponentExample extends StatelessWidget {
  const FilePickerComponentExample({super.key});

  @override
  Widget build(BuildContext context) => const HyperCard(
    title: '能力由业务层注入',
    leading: Icon(LucideIcons.puzzle),
    child: Text('HyperFilePicker 负责选择文件，HyperFileUpload 负责上传；组件库不绑定平台插件或网络实现。'),
  );
}
// end-doc-region FilePickerComponentExample
