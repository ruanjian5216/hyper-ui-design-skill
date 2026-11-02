/** 文件职责：背景与前景的覆盖组合，以及静态环境色画布。 */
package hyper_ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.compositeOver

@Composable
fun HyperBackdrop(
    modifier: Modifier = Modifier,
    background: @Composable BoxScope.() -> Unit = { HyperBackground(Modifier.matchParentSize()) },
    content: @Composable BoxScope.() -> Unit
) {
    val source = rememberHyperGlassSource()
    CompositionLocalProvider(LocalHyperGlassSource provides source) {
        Box(modifier) {
            Box(Modifier.matchParentSize().hyperGlassSource(source), content = background)
            content()
        }
    }
}

/** 对齐 HySoftBackground 的三段静态环境色；不添加装饰性循环动画。 */
@Composable
fun HyperBackground(
    modifier: Modifier = Modifier,
    intensity: Float = 1f,
    content: @Composable BoxScope.() -> Unit = {}
) {
    require(intensity in 0f..1f) { "intensity 必须在 0f..1f 内" }
    val alpha = kotlin.math.round(28 * intensity) / 255f
    val background = HyperColors.pageBackground
    Box(
        modifier.background(Brush.linearGradient(
            0f to HyperColors.accent.copy(alpha = alpha).compositeOver(background),
            0.52f to background,
            1f to rgba(154, 130, 215, alpha).compositeOver(background)
        )),
        content = content
    )
}
