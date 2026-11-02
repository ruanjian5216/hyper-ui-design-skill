/** 文件职责：统一悬浮、贴底导航与可重复触发的底部动作入口。 */
package hyper_ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import hyper_ui.core.interaction.hyperNoRippleClickable
import kotlin.math.roundToInt

class HyperTabBarItemScope internal constructor(val selected: Boolean)

/** 选择值由调用方持有；itemLabel 用于与参考实现相同的内容宽度测量。 */
@Composable
fun <T> HyperTabBar(
    items: List<T>,
    onChanged: (Int) -> Unit,
    selectedIndex: Int?,
    modifier: Modifier = Modifier,
    type: String = "multiple",
    itemLabel: (T) -> String = { "" },
    badgeCount: Int = 0,
    safeArea: Boolean = false,
    floating: Boolean = true,
    margin: PaddingValues = if (!floating || type == "single") PaddingValues(0.dp) else HyperTabBarDefaults.FloatingMargin,
    color: Color = HyperColors.accent,
    itemEnabled: (T) -> Boolean = { true },
    itemContent: @Composable HyperTabBarItemScope.(item: T) -> Unit
) {
    require(type in setOf("multiple", "single")) { "type 必须为 multiple 或 single" }
    require(if (type == "single") items.size == 1 else items.size in 2..5) { "single 需要 1 项，multiple 需要 2 至 5 项" }
    require(selectedIndex == null || selectedIndex in items.indices) { "selectedIndex 超出 items 范围" }
    require(floating || type == "multiple") { "非悬浮底栏使用 multiple 形态" }
    val density = androidx.compose.ui.platform.LocalDensity.current
    val textMeasurer = rememberTextMeasurer()
    val labelStyle = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Bold,
        fontFamily = HyperTheme.typography.bodyMedium.fontFamily)
    val itemWidth = items.maxOf { item ->
        with(density) { textMeasurer.measure(itemLabel(item), labelStyle).size.width.toDp() } + 32.dp
    }.coerceAtLeast(76.dp)
    val safeInsets = HyperTheme.systemSafeAreaInsets
    // 单动作固定为 48dp 圆形入口；只有多项按钮组按标签字体扩展默认高度。
    val height = if (type == "single") HyperTabBarDefaults.SingleDiameter else
        maxOf(HyperTabBarDefaults.Height, with(density) { 12.sp.toDp() } * 1.08f + 36.dp)
    val selectionHeight = height - 8.dp
    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    var dragPosition by remember(items.size, selectedIndex == null, floating, rtl) { mutableStateOf<Float?>(null) }
    var pressed by remember { mutableStateOf(false) }
    var pointerTravel by remember { mutableStateOf(0f) }
    val logicalSelected = selectedIndex
    val visualSelectedIndex = dragPosition ?: logicalSelected?.let { if (rtl) items.lastIndex - it else it }?.toFloat() ?: 0f
    val latestLogicalSelected by rememberUpdatedState(logicalSelected)
    val latestOnClick by rememberUpdatedState(onChanged)
    val latestItemEnabled by rememberUpdatedState(itemEnabled)
    // 贴底表面连同底部安全区由库绘制，调用方不再叠加底板或二次避让。
    Box(modifier.then(if (floating) Modifier else Modifier.fillMaxWidth().background(HyperColors.pageBackground))
        .then(if (safeArea) Modifier.windowInsetsPadding(safeInsets.only(WindowInsetsSides.Bottom)) else Modifier)
        .padding(margin)) {
        if (type == "single") {
            val pressProgress = animateFloatAsState(if (pressed) 1f else 0f,
                spring(dampingRatio = 1f, stiffness = 1000f), label = "HyperTabBarGlassPress")
            val item = items.single()
            val enabled = itemEnabled(item)
            Box(Modifier.size(height)
                .hyperObservePress(enabled) { pressed = it }
                .hyperControlSurface(RoundedCornerShape(height / 2), HyperControlSurfaceRole.Navigation,
                    progress = { pressProgress.value })
                .alpha(if (enabled) 1f else 0.4f)
                .hyperNoRippleClickable(enabled = enabled, onClick = { onChanged(0) }),
                contentAlignment = Alignment.Center) {
                CompositionLocalProvider(LocalHyperContentColor provides color, LocalHyperIconSize provides 22.dp,
                    LocalHyperTextStyle provides labelStyle.copy(lineHeight = 12.96.sp)) {
                    HyperTabBarItemScope(true).itemContent(item)
                }
            }
            if (badgeCount > 0) Box(Modifier.align(Alignment.TopEnd).offset(x = 5.dp, y = (-5).dp)
                .defaultMinSize(minWidth = 16.dp).height(16.dp)
                .hyperSolidSurface(HyperColors.danger, RoundedCornerShape(50), border = androidx.compose.foundation.BorderStroke(1.dp, HyperColors.pageBackground))
                .padding(horizontal = 5.dp), contentAlignment = Alignment.Center) {
                HyperText(if (badgeCount > 99) "99+" else "$badgeCount", color = Color(1f, 1f, 1f, 1f),
                    fontSize = 10.sp, lineHeight = 10.sp, fontWeight = FontWeight.SemiBold)
            }
        } else {
            val motion = rememberHyperTabBarMotion(visualSelectedIndex, items.size, pressed, pointerTravel)
            val panelSource = rememberHyperGlassSource()
            val labelsSource = rememberHyperGlassSource()
            val surfaceModifier = if (floating) {
                Modifier.width(itemWidth * items.size + 8.dp)
            } else Modifier.fillMaxWidth()
            val inset = if (floating) 4.dp else 0.dp
            BoxWithConstraints(surfaceModifier.height(height)
                .hyperTabBarPointer(items.size, rtl, with(density) { inset.toPx() },
                    enabled = { latestItemEnabled(items[it]) }) { down, travel ->
                    pressed = down
                    pointerTravel = travel
                }
                .pointerInput(items, rtl, floating, selectedIndex == null) {
                    // 动作模式没有选中项，不将横向滑动转换为后退、菜单等业务操作。
                    if (selectedIndex == null) return@pointerInput
                    fun previewPosition(x: Float) {
                        val next = ((x - inset.toPx()) / (size.width - inset.toPx() * 2).coerceAtLeast(1f)
                            * items.size - 0.5f).coerceIn(0f, items.lastIndex.toFloat())
                        val visual = next.roundToInt()
                        val logical = if (rtl) items.lastIndex - visual else visual
                        if (latestItemEnabled(items[logical])) dragPosition = next
                    }
                    detectHorizontalDragGestures(
                        onDragStart = { previewPosition(it.x) },
                        onHorizontalDrag = { change, _ -> previewPosition(change.position.x); change.consume() },
                        onDragCancel = { dragPosition = null },
                        onDragEnd = {
                            dragPosition?.roundToInt()?.let { visual ->
                                val logical = if (rtl) items.lastIndex - visual else visual
                                if (logical != latestLogicalSelected && latestItemEnabled(items[logical])) latestOnClick(logical)
                            }
                            dragPosition = null
                        }
                    )
                }) {
                val cellWidth = (maxWidth - inset * 2) / items.size
                val panelOffset = if (floating) motion.panelOffset(with(density) { maxWidth.toPx() },
                    with(density) { 4.dp.toPx() }) else 0f
                val panelScale = if (floating) 1f + 16.dp / maxWidth * motion.progress else 1f
                Box(Modifier.fillMaxSize()
                    .graphicsLayer { translationX = panelOffset; scaleX = panelScale; scaleY = panelScale }) {
                    // 背景不包含前景标签，镜片只合成一次标签副本，缩放时不会出现双重字形。
                    Box(Modifier.fillMaxSize().hyperGlassSource(panelSource)
                        .then(if (floating) Modifier.hyperControlSurface(RoundedCornerShape(height / 2),
                            HyperControlSurfaceRole.Navigation) else Modifier)
                        .hyperTabBarHighlight(motion.progress, motion.position, items.size, with(density) { inset.toPx() }))
                    Row(Modifier.fillMaxSize().hyperGlassSource(labelsSource, tint = color).padding(horizontal = inset)) {
                        items.forEachIndexed { index, item ->
                            val selected = index == selectedIndex
                            val enabled = itemEnabled(item)
                            Box(Modifier.weight(1f).fillMaxHeight()
                                .alpha(if (enabled) 1f else 0.4f)
                                .hyperNoRippleClickable(enabled = enabled, role = if (selectedIndex == null) Role.Button else Role.Tab, pressedScale = 1f,
                                    onClick = { if (index != selectedIndex) onChanged(index) })
                                .then(if (selectedIndex == null) Modifier else Modifier.semantics { this.selected = selected }), contentAlignment = Alignment.Center) {
                                CompositionLocalProvider(
                                    LocalHyperContentColor provides if (selected) color else HyperColors.primaryText,
                                    LocalHyperTextStyle provides labelStyle.copy(lineHeight = 12.96.sp,
                                        fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium),
                                    LocalHyperIconSize provides 23.dp
                                ) { HyperTabBarItemScope(selected).itemContent(item) }
                            }
                        }
                    }
                }
                if (selectedIndex != null) Box(Modifier.absoluteOffset(x = inset + 1.dp + cellWidth * motion.position,
                    y = (height - selectionHeight) / 2)
                    .width((cellWidth - 2.dp).coerceAtLeast(0.dp)).height(selectionHeight)
                    .graphicsLayer { translationX = panelOffset; scaleX = motion.scaleX; scaleY = motion.scaleY }
                    .hyperControlSurface(RoundedCornerShape(selectionHeight / 2), HyperControlSurfaceRole.Selection,
                        progress = { motion.progress }, sources = listOf(panelSource, labelsSource)))
            }
        }
    }
}

object HyperTabBarDefaults {
    /** 单独动作入口的固定直径，不与多项按钮组等高。 */
    val SingleDiameter = 48.dp
    /** 悬浮和贴底多项按钮组的默认内容高度，组件内可随字体扩展。 */
    val Height = 56.dp
    /** 组件视觉间距，与根布局系统安全区独立；并排入口由共同的 Row 只消费一次。 */
    val FloatingMargin = PaddingValues(start = 12.dp, top = 8.dp, end = 12.dp,
        bottom = HyperSafeAreaDefaults.MinimumBottomSpacing)
}
