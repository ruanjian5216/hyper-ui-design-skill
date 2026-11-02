/** 文件职责：提供全屏模态宿主与液态面板，内容布局、遮罩和键盘避让保持独立。 */
package hyper_ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.exclude
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp

@Immutable
data class HyperDialogColors(
    val containerColor: Color
)

/** 使用稳定的全尺寸 Dialog 根节点；显示状态与关闭结果由调用方管理。 */
@Composable
fun HyperDialog(
    visible: Boolean,
    onClose: () -> Unit,
    modifier: Modifier = Modifier,
    maxWidth: androidx.compose.ui.unit.Dp = HyperDialogDefaults.MaxWidth,
    title: String? = null,
    shape: Shape = HyperDialogDefaults.Shape,
    colors: HyperDialogColors = HyperDialogDefaults.colors(),
    horizontalAlignment: Alignment.Horizontal = Alignment.Start,
    verticalArrangement: Arrangement.Vertical = Arrangement.spacedBy(HyperDialogDefaults.ContentSpacing),
    actionArrangement: Arrangement.Horizontal = Arrangement.spacedBy(
        HyperDialogDefaults.ActionSpacing,
        Alignment.End
    ),
    dismissOnBackPress: Boolean = true,
    dismissOnClickOutside: Boolean = true,
    showScrollIndicator: Boolean = HyperDialogDefaults.ShowScrollIndicator,
    actions: (@Composable RowScope.() -> Unit)? = null,
    border: BorderStroke? = null,
    contentPadding: androidx.compose.foundation.layout.PaddingValues = HyperDialogDefaults.ContentPadding,
    content: @Composable ColumnScope.() -> Unit
) {
    val dialogMaxWidth = maxWidth
    require(dialogMaxWidth > 0.dp && dialogMaxWidth.value.isFinite())
    val transitionProgress = hyperOverlayProgress(visible)
    if (!visible && transitionProgress == 0f) return

    val currentOnDismissRequest by rememberUpdatedState(onClose)
    val containerColor = colors.containerColor

    HyperDialogHost(
        onDismissRequest = onClose,
        dismissOnBackPress = dismissOnBackPress
    ) {
        BoxWithConstraints(
            modifier = Modifier.fillMaxSize()
                .background(hyperSurfaces.scrim.copy(alpha = hyperSurfaces.scrim.alpha * transitionProgress)),
            contentAlignment = Alignment.Center
        ) {
            if (dismissOnClickOutside) {
                Box(
                    modifier = Modifier
                        .matchParentSize()
                        .pointerInput(Unit) {
                            detectTapGestures { currentOnDismissRequest() }
                        }
                )
            }

            // 遮罩留在全屏根层；只有面板避让系统栏与 IME，长表单仍可滚动。
            BoxWithConstraints(
                modifier = Modifier.fillMaxSize()
                    .windowInsetsPadding(WindowInsets.safeDrawing.exclude(WindowInsets.ime))
                    .imePadding(),
                contentAlignment = Alignment.Center
            ) {
                // 必须读取宿主宽度；同名公开参数 maxWidth 只是面板上限，不能充当窗口尺寸。
                val availableWidth = (this.maxWidth - HyperDialogWindowPadding * 2)
                    .coerceAtLeast(0.dp)
                val availableHeight = (this.maxHeight - HyperDialogWindowPadding * 2)
                    .coerceAtLeast(0.dp)
                val resolvedMaxWidth = dialogMaxWidth.coerceAtMost(availableWidth)
                val resolvedMinWidth = HyperDialogDefaults.MinWidth.coerceAtMost(resolvedMaxWidth)

                HyperFloatingPanel(
                    title = title,
                    modifier = modifier
                        .hyperOverlayMotion(transitionProgress, beginScale = 0.96f)
                        .widthIn(
                            min = resolvedMinWidth,
                            max = resolvedMaxWidth
                        )
                        .heightIn(max = availableHeight)
                        // 注册面板命中区域，但不消费事件，避免空白处点击穿透到关闭层。
                        .pointerInput(Unit) {
                            awaitPointerEventScope {
                                while (true) awaitPointerEvent()
                            }
                        },
                    shape = shape,
                    containerColor = containerColor,
                    border = border,
                    contentPadding = contentPadding,
                    horizontalAlignment = horizontalAlignment,
                    verticalArrangement = verticalArrangement,
                    actionArrangement = actionArrangement,
                    showScrollIndicator = showScrollIndicator,
                    actions = actions,
                    dialogSurface = true,
                    content = content
                )
            }
        }
    }
}

private val HyperDialogWindowPadding = 24.dp

object HyperDialogDefaults {
    val MinWidth = 0.dp
    val MaxWidth = 420.dp
    val Shape: Shape = HyperFloatingPanelDefaults.Shape
    val ContentSpacing = HyperFloatingPanelDefaults.ContentSpacing
    val ContentPadding = HyperFloatingPanelDefaults.ContentPadding
    val ActionSpacing = HyperFloatingPanelDefaults.ActionSpacing
    const val ShowScrollIndicator = HyperFloatingPanelDefaults.ShowScrollIndicator

    @Composable
    fun colors(containerColor: Color = Color.Unspecified): HyperDialogColors = HyperDialogColors(
        containerColor = resolveHyperContainerColor(containerColor, hyperControlContainer(HyperControlSurfaceRole.Dialog))
    )

    @Composable
    fun border(color: Color = Color.Unspecified): BorderStroke = BorderStroke(1.dp, resolveHyperContainerColor(color, hyperSurfaces.border))
}
