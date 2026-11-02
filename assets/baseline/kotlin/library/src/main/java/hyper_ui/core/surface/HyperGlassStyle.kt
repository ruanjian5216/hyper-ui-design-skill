/** 文件职责：小型交互表面的玻璃参数；按钮与导航共用绘制器，不向业务暴露材质档位。 */
package hyper_ui

import androidx.compose.runtime.Immutable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Immutable
internal data class HyperGlassStyle(
    val blur: Dp,
    val edge: Dp,
    val amount: Dp,
    val shadow: Dp,
    val highlight: Float
)

internal object HyperGlassStyles {
    val Navigation = HyperGlassStyle(8.dp, 24.dp, 24.dp, 8.dp, 0.5f)

    /** 38dp 按钮使用更浅的透镜；按压降低浮起，文字始终在采样层上方保持清晰。 */
    fun button(progress: Float) = HyperGlassStyle(
        blur = (8f - 2f * progress).dp,
        edge = (12f + 2f * progress).dp,
        amount = (16f + 2f * progress).dp,
        shadow = (6f - 1.5f * progress).dp,
        highlight = 0.5f + 0.5f * progress
    )
}
