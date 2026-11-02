/** 文件职责：录制不包含玻璃前景的背景，供固定组件镜片采样。 */
package hyper_ui

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.Matrix
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.graphics.layer.GraphicsLayer
import androidx.compose.ui.graphics.layer.drawLayer
import androidx.compose.ui.graphics.rememberGraphicsLayer
import androidx.compose.ui.layout.LayoutCoordinates
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInWindow

@Stable
internal class HyperGlassSource(val layer: GraphicsLayer) {
    var coordinates: LayoutCoordinates? by mutableStateOf(null)
}

@Composable
internal fun rememberHyperGlassSource(): HyperGlassSource {
    val layer = rememberGraphicsLayer()
    return remember(layer) { HyperGlassSource(layer) }
}

internal val LocalHyperGlassSource = staticCompositionLocalOf<HyperGlassSource?> { null }

internal fun Modifier.hyperGlassSource(source: HyperGlassSource, tint: Color = Color.Unspecified): Modifier =
    onGloballyPositioned { source.coordinates = it }.drawWithContent {
        source.layer.record { this@drawWithContent.drawContent() }
        source.layer.colorFilter = if (tint == Color.Unspecified) null else ColorFilter.tint(tint)
        // 只对采样副本着色，不重复组合插槽，也不复制点击和语义节点。
        if (tint == Color.Unspecified) drawLayer(source.layer) else drawContent()
    }

/** 采样需包含源与镜片的完整变换，避免镜片弹性缩放时把标签重复放大或错位。 */
internal fun DrawScope.drawHyperGlassSource(source: HyperGlassSource, target: LayoutCoordinates, padding: Float = 0f) {
    val origin = source.coordinates?.takeIf { it.isAttached } ?: return
    val matrix = Matrix()
    try {
        target.transformFrom(origin, matrix)
    } catch (_: IllegalArgumentException) {
        // Dialog 等独立窗口不共享布局树，沿用窗口坐标回退，不影响既有弹窗采样链路。
        val offset = origin.positionInWindow() - target.positionInWindow()
        matrix.translate(offset.x, offset.y)
    }
    withTransform({ translate(padding, padding); transform(matrix) }) { drawLayer(source.layer) }
}
