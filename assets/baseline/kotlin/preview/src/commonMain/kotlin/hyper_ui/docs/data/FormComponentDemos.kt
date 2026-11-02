/** 文件职责：在 hyper_ui 中负责提供 preview/src/commonMain/kotlin/hyper_ui/docs/data/FormComponentDemos 可复用界面组件及交互封装。 */
package hyper_ui.docs.data

import hyper_ui.docs.ui.CheckboxDemo
import hyper_ui.docs.ui.DatePickerDemo
import hyper_ui.docs.ui.CalendarDayDemo
import hyper_ui.docs.ui.CalendarMonthDemo
import hyper_ui.docs.ui.RadioDemo
import hyper_ui.docs.ui.SliderDemo
import hyper_ui.docs.ui.SwitchDemo
import hyper_ui.docs.ui.TextFieldDemo

private const val GROUP_FORM = "表单组件"

internal fun formComponentDemos(): List<ComponentDemo> = listOf(
    ComponentDemo(
        id = "calendar_day", group = GROUP_FORM, title = "HyperCalendarDay",
        description = "复用日期选择器外观的日期格，可展示辅助文字、角标及少量附属条目。",
        code = """HyperCalendarDay(day = 21, selected = true, onPressed = { selectDate() })""",
        variants = listOf(
            DemoVariant("状态", "selected / today / enabled", "圆形选中、今日描边与禁用"),
            DemoVariant("范围", "inRange", "亮暗独立语义底色，与月历只读绘制一致"),
            DemoVariant("附加信息", "subtitle / badge / items", "辅助文字、角标、条目与溢出数量"),
            DemoVariant("交互", "onPressed / onLongPressed / onItemsPressed", "日期、长按与条目区域点击")
        ),
        apiDocumentPaths = listOf("form/hyper-calendar-day.md"), content = { CalendarDayDemo() }
    ),
    ComponentDemo(
        id = "calendar_month", group = GROUP_FORM, title = "HyperCalendarMonth",
        description = "无卡片的受控六行月历，支持起始日、紧凑尺寸和只读合并绘制。",
        code = """HyperCalendarMonth(month = month, selectedDate = selected, onChanged = { selected = it })""",
        variants = listOf(
            DemoVariant("起始日", "weekStart", "星期一为 1，星期日为 7"),
            DemoVariant("尺寸", "size", "small/default/large"),
            DemoVariant("只读", "readOnly", "整月合并绘制，不创建逐日期点击和动画节点")
        ),
        apiDocumentPaths = listOf("form/hyper-calendar-month.md"), content = { CalendarMonthDemo() }
    ),
    ComponentDemo(
        id = "date_picker",
        group = GROUP_FORM,
        title = "HyperDatePicker",
        description = "与 Flutter 同样的底部玻璃面板、六行月历和月份/年份跳转；确定后提交单个日期。",
        code = """
            HyperDatePicker.date(
                visible = visible,
                onClose = { visible = false },
                onChanged = { selectedDate = it },
                initialDate = selectedDate ?: LocalDate.now()
            )
        """.trimIndent(),
        variants = listOf(
            DemoVariant("日期", "initialDate", "36dp 选中圆形、42dp 日期行；今日描边"),
            DemoVariant("月份与年份", "点击年月标题", "十二个月、前后一年和十年跳转"),
            DemoVariant("边界", "firstDate / lastDate", "范围外日期、月份与翻页按钮禁用"),
            DemoVariant("确认/取消", "onChanged / onClose", "确定后提交，遮罩或返回只取消")
        ),
        apiDocumentPaths = listOf("form/hyper-date-picker.md"),
        content = { DatePickerDemo() }
    ),
    ComponentDemo(
        id = "radio",
        group = GROUP_FORM,
        title = "HyperRadio",
        description = "互斥单选与禁用项；标签行统一承载点击，圆环不叠加独立触摸留白。",
        code = """
            HyperRadio(value = "system", groupValue = selectedMode,
                label = "跟随系统", onChanged = { selectedMode = it })
        """.trimIndent(),
        variants = listOf(
            DemoVariant("选中", "value == groupValue", "21dp 圆环，选中环宽 6dp、内部 subtle 表面"),
            DemoVariant("未选中", "value != groupValue", "21dp 圆环，普通轮廓 1.5dp"),
            DemoVariant("禁用", "onChanged = null", "标签行保留库默认高度，圆环只展示"),
            DemoVariant("展示", "label = null / onChanged = null", "21dp 圆环不分配独立触摸区"),
            DemoVariant("独立交互", "label = null / onChanged != null", "44dp 触摸区")
        ),
        apiDocumentPaths = listOf("form/hyper-radio.md"),
        content = { RadioDemo() }
    ),
    ComponentDemo(
        id = "checkbox",
        group = GROUP_FORM,
        title = "HyperCheckbox",
        description = "无卡片的受控复选标签行，覆盖三态、禁用与无标签纯控件。",
        code = """
            HyperCheckbox(
                value = checked,
                onChanged = { checked = it },
                label = "同步到所有设备"
            )
        """.trimIndent(),
        variants = listOf(
            DemoVariant("标签行", "label", "plain 行承载点击，21dp 方框不叠加 44dp 触摸区，无卡片外观"),
            DemoVariant("选中", "value = true", "主题实色与 Lucide check 图标"),
            DemoVariant("未选中", "value = false", "21dp 方框，普通轮廓 1.5dp"),
            DemoVariant("三态", "tristate = true", "false → true → null → false"),
            DemoVariant("禁用", "onChanged = null", "保留选中与未选中展示")
        ),
        apiDocumentPaths = listOf("form/hyper-checkbox.md"),
        content = { CheckboxDemo() }
    ),
    ComponentDemo(
        id = "text_field",
        group = GROUP_FORM,
        title = "HyperTextField",
        description = "分组呈现基础清空、密码显隐、金额前后缀和多行计数；尺寸、禁用、只读与错误状态可操作。",
        code = """
            HyperTextField(value, { value = it }, clearable = true,
                placeholder = { HyperText("请输入内容") })
            HyperTextField(password, { password = it }, type = "password", showPasswordToggle = true)
        """.trimIndent(),
        variants = listOf(
            DemoVariant("尺寸", "size", "14/16/18sp；圆角 20dp，padding 按档位联动"),
            DemoVariant("聚焦", "inputModifier / interactionSource", "即时 1.5dp 主题描边，无额外阴影"),
            DemoVariant("状态", "enabled / readOnly / isError", "禁用、只读与错误可切换"),
            DemoVariant("内置操作", "clearable / showPasswordToggle", "30dp 控件、18dp Lucide 图标"),
            DemoVariant("多行计数", "type / rows / maxLength / showWordLimit", "3 行输入与字符限制")
        ),
        apiDocumentPaths = listOf("form/hyper-text-field.md"),
        content = { TextFieldDemo() }
    ),
    ComponentDemo(
        id = "switch",
        group = GROUP_FORM,
        title = "HyperSwitch",
        description = "52×32dp/22dp 尺寸保持；Button 共用玻璃轨道、双轴扩张、速度形变、Ambient 与按住连续拖动。",
        code = """
            HyperSwitch(
                value = enabled,
                onChanged = { enabled = it }
            )
        """.trimIndent(),
        variants = listOf(
            DemoVariant("开启", "value = true", "主题轨道与滑块共用临界阻尼弹簧进度"),
            DemoVariant("关闭", "value = false", "中性轨道、细描边与固定尺寸滑块"),
            DemoVariant("按压", "按压进度", "只对滑块做 1.5 倍弹性扩张、速度形变与 Ambient，测量尺寸不变"),
            DemoVariant("横向拖动", "松手提交", "立即跟随拖动目标，0.5 阈值吸附；取消恢复受控值"),
            DemoVariant("禁用", "enabled = false", "分别展示禁用开启与禁用关闭")
        ),
        apiDocumentPaths = listOf("form/hyper-switch.md"),
        content = { SwitchDemo() }
    ),
    ComponentDemo(
        id = "slider",
        group = GROUP_FORM,
        title = "HyperSlider",
        description = "6dp 轨道与 20dp 圆形手柄，支持连续拖动、等距吸附、可选分段点和只读态，业务值由调用方持有。",
        code = """
            HyperSlider(
                value = speed,
                onChanged = { speed = it },
                min = 0f, max = 5f,
                divisions = 5,
                showSegmentMarkers = true
            )
        """.trimIndent(),
        variants = listOf(
            DemoVariant(
                "默认连续",
                "min = 0f, max = 100f, showValue = true",
                "44dp 触摸高度、6dp 轨道、20dp 玻璃手柄，按压高光与弹簧定位"
            ),
            DemoVariant("分段", "divisions = 5, showSegmentMarkers = true", "吸附并显示全部分段点"),
            DemoVariant("指定标记", "segmentValues", "只展示业务主刻度"),
            DemoVariant("只读", "readOnly = true", "保留正常配色但关闭交互"),
            DemoVariant("禁用", "enabled = false", "保留品牌轨道，手柄使用 muted 底色")
        ),
        apiDocumentPaths = listOf("form/hyper-slider.md"),
        content = { SliderDemo() }
    )
)
