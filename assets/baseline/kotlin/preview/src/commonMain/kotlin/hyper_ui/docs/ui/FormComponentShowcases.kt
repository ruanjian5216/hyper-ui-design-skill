/** 文件职责：在 hyper_ui 中负责提供 preview/src/commonMain/kotlin/hyper_ui/docs/ui/FormComponentShowcases 可复用界面组件及交互封装。 */
package hyper_ui.docs.ui

import com.composables.icons.lucide.Lucide
import com.composables.icons.lucide.Calendar
import hyper_ui.*
import hyper_ui.LocalHyperContentColor
import hyper_ui.docs.theme.LocalDocsColorScheme

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.compositeOver
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import hyper_ui.HyperCheckbox
import hyper_ui.HyperRadio
import hyper_ui.HyperTabs
import hyper_ui.HyperTabsDefaults
import hyper_ui.HyperSlider
import hyper_ui.HyperSliderDefaults
import hyper_ui.HyperSwitch
import hyper_ui.HyperTextField

@Composable
fun DatePickerDemo() {
    var visible by remember { mutableStateOf(false) }
    var date by remember { mutableStateOf<HyperCalendarDate?>(null) }
    // Preview 模拟本机日期；Android 公开入口会读取 LocalDate.now()。
    val today = HyperCalendarDate(2026, 10, 19)
    Column {
        HyperText("月历选择日期 · 玻璃面板", modifier = Modifier.padding(bottom = 8.dp))
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            HyperButton(onPressed = { visible = true }) {
                HyperIcon(Lucide.Calendar, null)
                HyperText("选择日期")
            }
            val tone = HyperColors.secondaryText
            HyperText(
                date?.let { "${it.year}-${it.month.toString().padStart(2, '0')}-${it.day.toString().padStart(2, '0')}" } ?: "未选择",
                modifier = Modifier.background(tone.copy(alpha = 31 / 255f).compositeOver(HyperTheme.surfaces.surfaceSubtle), RoundedCornerShape(50))
                    .padding(horizontal = 8.dp, vertical = 4.dp),
                fontSize = 12.sp, lineHeight = 14.4.sp, fontWeight = FontWeight.SemiBold, color = tone,
            )
        }
    }
    HyperDatePickerSheet(
        visible = visible,
        onClose = { visible = false },
        onChanged = { date = it },
        initialDate = date ?: today,
        firstDate = HyperCalendarDate(1900, 1, 1),
        lastDate = HyperCalendarDate(2100, 12, 31),
        today = today,
    )
}

@Composable
fun RadioDemo() {
    var mode by remember { mutableStateOf("system") }
    val labels = remember {
        linkedMapOf("system" to "跟随系统", "light" to "浅色", "dark" to "深色", "amoled" to "纯黑（Pro）")
    }

    // 与 Flutter 参考一致，直接展示库默认单选行，不额外叠加行间距。
    Column {
        HyperText("互斥单选", modifier = Modifier.padding(bottom = 8.dp))
        labels.forEach { (value, label) ->
            HyperRadio(
                value = value, groupValue = mode, label = label,
                onChanged = if (value == "amoled") null else { { selectedMode -> mode = selectedMode } }
            )
        }
        Spacer(Modifier.height(12.dp))
        HyperText("当前值：$mode")
        Spacer(Modifier.height(20.dp))
        HyperText("纯控件（无标签）", modifier = Modifier.padding(bottom = 8.dp))
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            HyperRadio(value = "system", groupValue = mode, onChanged = { mode = it })
            HyperRadio(value = "preview", groupValue = "preview")
            HyperRadio(value = "disabled", groupValue = null, enabled = false)
        }
    }
}

@Composable
fun TabsDemo() {
    val periods = remember { listOf("日", "周", "月", "年") }
    var selectedPeriod by remember { mutableStateOf("年") }
    var equalWidth by remember { mutableStateOf(true) }
    val modes = remember { listOf("轻量", "标准", "停用") }
    var selectedMode by remember { mutableStateOf("标准") }

    Column(
        modifier = Modifier.widthIn(max = 520.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        HyperButton({ equalWidth = !equalWidth }) {
            HyperText(if (equalWidth) "等宽分段" else "内容宽度分段")
        }
        HyperTabs(
            equalWidth = equalWidth,
            tabs = periods,
            selectedIndex = periods.indexOf(selectedPeriod),
            onChanged = { selectedPeriod = periods[it] }
        ) { period ->
            HyperText(
                text = period,
                fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
                fontSize = 13.sp,
                lineHeight = 18.sp
            )
        }
        HyperText(
            text = "当前周期：$selectedPeriod",
            color = LocalDocsColorScheme.current.onSurfaceVariant,
            fontSize = 13.sp
        )

        HyperTabs(
            tabs = modes,
            selectedIndex = modes.indexOf(selectedMode),
            onChanged = { selectedMode = modes[it] },
            itemEnabled = { it != "停用" },
            colors = HyperTabsDefaults.colors(
                selectedItemColor = Color(0.03f, 0.76f, 0.38f, 1f),
                selectedContentColor = Color(1f, 1f, 1f, 1f)
            )
        ) { mode ->
            HyperText(
                text = mode,
                fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
                fontSize = 13.sp,
                lineHeight = 18.sp
            )
        }
    }
}

@Composable
fun CheckboxDemo() {
    var checked by remember { mutableStateOf<Boolean?>(true) }
    var triState by remember { mutableStateOf<Boolean?>(null) }
    var standalone by remember { mutableStateOf(false) }
    // 直接展示库默认标签行，与 Flutter 相同，不额外包卡片或自定义点击行。
    Column {
        HyperText("受控复选", modifier = Modifier.padding(bottom = 8.dp))
        HyperCheckbox(checked, { checked = it }, label = "同步到所有设备")
        Spacer(Modifier.height(20.dp))
        HyperText("三态（全选 / 部分 / 空）", modifier = Modifier.padding(bottom = 8.dp))
        HyperCheckbox(triState, { triState = it }, tristate = true, label = "已选择 2 / 4 项")
        Spacer(Modifier.height(20.dp))
        HyperText("禁用状态", modifier = Modifier.padding(bottom = 8.dp))
        HyperCheckbox(false, label = "禁用 · 未选中")
        Spacer(Modifier.height(12.dp))
        HyperCheckbox(true, label = "禁用 · 已选中")
        Spacer(Modifier.height(20.dp))
        HyperText("纯控件（无标签）", modifier = Modifier.padding(bottom = 8.dp))
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            HyperCheckbox(standalone, { standalone = it == true })
            HyperCheckbox(true)
            HyperCheckbox(false, tristate = true)
        }
    }
}

@Composable
fun TextFieldDemo() {
    var value by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("password") }
    var amount by remember { mutableStateOf("128") }
    var note by remember { mutableStateOf("") }
    var enabled by remember { mutableStateOf(true) }
    var error by remember { mutableStateOf(false) }
    var readOnly by remember { mutableStateOf(false) }
    val focusRequester = remember { FocusRequester() }
    Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        PreviewToggle("允许输入", enabled) { enabled = it }
        PreviewToggle("错误状态", error) { error = it }
        PreviewToggle("只读", readOnly) { readOnly = it }
        PreviewSectionLabel("基础输入与清空")
        HyperTextField(value, { value = it }, clearable = true, enabled = enabled, isError = error, readOnly = readOnly,
            inputModifier = Modifier.focusRequester(focusRequester),
            placeholder = { HyperText("请输入内容") })
        PreviewSectionLabel("密码显隐")
        HyperTextField(password, { password = it }, type = "password", showPasswordToggle = true,
            placeholder = { HyperText("请输入密码") })
        PreviewSectionLabel("前后缀插槽")
        HyperTextField(amount, { amount = it }, type = "number", clearable = true,
            label = { HyperText("金额") }, prefix = { HyperText("¥") }, suffix = { HyperText("元") })
        PreviewSectionLabel("多行与字数限制")
        HyperTextField(note, { note = it }, type = "textarea", rows = 3, maxLength = 80, showWordLimit = true,
            label = { HyperText("多行输入") }, placeholder = { HyperText("请输入多行内容") })
        HyperButton({ focusRequester.requestFocus() }, colorStyle = "primary", type = "filled") { HyperText("查看聚焦") }
    }
}

@Composable
fun SwitchDemo() {
    // 标签点击与纯控件拖动都使用正式 Switch；长按可查看扩张、高光，取消不提交。
    var notifications by remember { mutableStateOf(true) }
    var standalone by remember { mutableStateOf(false) }
    Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(24.dp)) {
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            HyperText("受控开关", color = LocalDocsColorScheme.current.onSurfaceVariant, fontSize = 12.sp)
            HyperSwitch(value = notifications, onChanged = { notifications = it }, label = "接收消息通知")
        }
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            HyperText("禁用状态", color = LocalDocsColorScheme.current.onSurfaceVariant, fontSize = 12.sp)
            HyperSwitch(value = true, label = "禁用 · 开启")
            HyperSwitch(value = false, label = "禁用 · 关闭")
        }
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            HyperText("纯控件（无标签）", color = LocalDocsColorScheme.current.onSurfaceVariant, fontSize = 12.sp)
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                HyperSwitch(value = standalone, onChanged = { standalone = it })
                HyperSwitch(value = true)
            }
        }
    }
}

@Composable
fun SliderDemo() {
    // 按压高光反馈、分段吸附与只读／禁用继续使用正式组件，不另做预览动画。
    var continuousValue by remember { mutableStateOf(42f) }
    var steppedValue by remember { mutableStateOf(2f) }
    var showSegmentMarkers by remember { mutableStateOf(true) }

    Column(
        modifier = Modifier.widthIn(max = 520.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        HyperText(text = "紧凑连续进度 ${continuousValue.toInt()}%")
        HyperSlider(
            value = continuousValue,
            onChanged = { continuousValue = it },
            modifier = Modifier.fillMaxWidth(),
            showSegmentMarkers = false,
            showValue = true
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            HyperText(text = "分段进度 ${steppedValue.toInt()}/5")
            HyperButton(onPressed = { showSegmentMarkers = !showSegmentMarkers }, colorStyle = "primary", type = "filled") {
                HyperText(if (showSegmentMarkers) "隐藏分段点" else "显示分段点")
            }
        }
        HyperSlider(
            value = steppedValue,
            onChanged = { steppedValue = it },
            min = 0f, max = 5f,
            divisions = 5,
            showSegmentMarkers = showSegmentMarkers,
            modifier = Modifier.fillMaxWidth(),
            colors = HyperSliderDefaults.colors(
                activeTrackColor = Color(0.03f, 0.76f, 0.38f, 1f)
            )
        )

        HyperText(text = "只读分段 · 指定主刻度")
        HyperSlider(
            value = 3f,
            onChanged = {},
            readOnly = true,
            min = 0f, max = 5f,
            showSegmentMarkers = true,
            segmentValues = listOf(0f, 1f, 3f, 5f),
            modifier = Modifier.fillMaxWidth()
        )

        HyperText(text = "禁用状态")
        HyperSlider(
            value = 65f,
            onChanged = {},
            enabled = false,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

@Composable
private fun FieldLabel(text: String) {
    HyperText(
        text = text,
        color = LocalHyperContentColor.current,
        fontSize = 13.sp,
        lineHeight = 18.sp
    )
}

@Composable
private fun FieldPlaceholder(text: String) {
    HyperText(
        text = text,
        color = LocalHyperContentColor.current,
        fontSize = 16.sp,
        lineHeight = 22.sp
    )
}

@Composable
private fun FieldSupporting(text: String) {
    HyperText(
        text = text,
        color = LocalHyperContentColor.current,
        fontSize = 12.sp,
        lineHeight = 16.sp
    )
}
