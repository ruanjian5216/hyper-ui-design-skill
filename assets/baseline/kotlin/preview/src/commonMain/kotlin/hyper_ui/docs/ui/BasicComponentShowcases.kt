/** 文件职责：在 hyper_ui 中负责提供 preview/src/commonMain/kotlin/hyper_ui/docs/ui/BasicComponentShowcases 可复用界面组件及交互封装。 */
package hyper_ui.docs.ui

import com.composables.icons.lucide.Lucide
import com.composables.icons.lucide.Check
import com.composables.icons.lucide.House
import com.composables.icons.lucide.Info
import com.composables.icons.lucide.Plus
import com.composables.icons.lucide.RefreshCw
import com.composables.icons.lucide.Search
import com.composables.icons.lucide.Settings
import com.composables.icons.lucide.Share2
import com.composables.icons.lucide.Trash2
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import hyper_ui.*

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ButtonDemo() {
    // 两端沿用 Kotlin 示例分组和 8/16dp 间距，默认按钮切换处理中状态以核对回调与加载拦截。
    var processing by remember { mutableStateOf(true) }
    Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            HyperButton(onPressed = { processing = !processing }, content = { HyperText("默认按钮") })
            HyperButton({ processing = true }, loading = processing) { HyperText("处理中") }
        }
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            HyperButton({}, type = "filled", colorStyle = "primary") { HyperText("Primary") }
            HyperButton({}, type = "filled", colorStyle = "success") { HyperText("Success") }
            HyperButton({}, type = "filled", colorStyle = "info") { HyperText("Info") }
            HyperButton({}, type = "filled", colorStyle = "warning") { HyperText("Warning") }
            HyperButton({}) { HyperIcon(Lucide.Share2, null); HyperText("导出") }
            HyperButton({}, type = "filled", colorStyle = "danger") { HyperIcon(Lucide.Trash2, null); HyperText("Danger") }
            HyperButton({}) { HyperIcon(Lucide.Settings, null); HyperText("带图标胶囊") }
        }
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            HyperButton({}, type = "icon") { HyperIcon(Lucide.Plus, "新建") }
            HyperButton({}, type = "icon") { HyperIcon(Lucide.RefreshCw, "刷新") }
            HyperButton({}, type = "icon") { HyperIcon(Lucide.Share2, "分享") }
            HyperButton({}, type = "icon", colorStyle = "danger") { HyperIcon(Lucide.Trash2, "删除") }
            HyperButton({}, type = "icon", loading = true) { HyperIcon(Lucide.RefreshCw, "加载中") }
        }
        HyperButton({}, enabled = false) { HyperText("不可用") }
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(null, "primary", "success", "info", "warning", "danger").forEach { colorStyle ->
                HyperButton({}, type = "filled", colorStyle = colorStyle, loading = true) { HyperText(colorStyle ?: "Default") }
            }
        }
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            HyperButton({}, colorStyle = "success") { HyperText("默认玻璃") }
            HyperButton({}, type = "filled", colorStyle = "success") { HyperText("填充") }
            HyperButton({}, type = "icon", colorStyle = "success") { HyperIcon(Lucide.Check, "成功") }
            HyperButton({}, type = "filled", colorStyle = "danger", color = HyperColors.accent) { HyperText("自定义颜色优先") }
        }
        HyperButton({}, Modifier.fillMaxWidth(), type = "filled", colorStyle = "primary") {
            HyperText("通栏按钮（expanded: true）")
        }
    }
}

@Composable
fun TextDemo() {
    var emphasis by remember { mutableStateOf(false) }
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        PreviewSectionLabel("统一文字规格")
        HyperText("默认文字 · 继承宿主排版")
        PreviewToggle("强调色", emphasis) { emphasis = it }
        HyperText("参考排版 · HyperUI", color = if (emphasis) HyperColors.accent else Color.Unspecified)
        HyperText("maxLines: 1 时超长文本自动省略：统一文字层级让界面在不同密度下保持稳定节奏。", maxLines = 1)
    }
}

@Composable
fun IconDemo() {
    var colored by remember { mutableStateOf(false) }
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        PreviewToggle("品牌色", colored) { colored = it }
        PreviewSectionLabel("统一图标规格")
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            listOf(Lucide.House, Lucide.Search, Lucide.Settings, Lucide.Check).forEach {
                HyperIcon(it, "图标示例", color = if (colored) HyperColors.accent else HyperColors.primaryText)
            }
        }
    }
}

@Composable
fun DividerDemo() {
    var dashed by remember { mutableStateOf(false) }
    var vertical by remember { mutableStateOf(false) }
    var inset by remember { mutableStateOf(false) }
    Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        PreviewSectionLabel("实线与虚线")
        HyperText("实线分隔")
        HyperDivider()
        HyperText("虚线分隔")
        HyperDivider(type = "dashed")
        PreviewSectionLabel("纵向分隔")
        Row(Modifier.height(58.dp), verticalAlignment = Alignment.CenterVertically) {
            HyperText("左侧", modifier = Modifier.weight(1f))
            HyperDivider(axis = "vertical")
            HyperText("右侧", modifier = Modifier.weight(1f).padding(start = 14.dp))
        }
        PreviewSectionLabel("可操作变体")
        PreviewToggle("虚线", dashed) { dashed = it }
        PreviewToggle("纵向", vertical) { vertical = it }
        PreviewToggle("缩进 14dp", inset) { inset = it }
        HyperDivider(type = if (dashed) "dashed" else "solid", axis = if (vertical) "vertical" else "horizontal",
            indent = if (inset) 14.dp else 0.dp, endIndent = if (inset) 14.dp else 0.dp,
            length = if (vertical) 80.dp else null)
    }
}
