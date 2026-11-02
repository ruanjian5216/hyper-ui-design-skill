/** 文件职责：在预览宿主的整个视口绘制可采样背景，不为单个组件增加内层画框。 */
package hyper_ui.docs.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import hyper_ui.HyperBackdrop
import hyper_ui.HyperBackground
import hyper_ui.docs.LocalThemeColor

/** 预览手机的顶部状态栏安全区。 */
internal val PreviewTopSafeArea = 52.dp

@Composable
internal fun PreviewSceneBackdrop(
    modifier: Modifier = Modifier,
    glassScene: Boolean = false,
    content: @Composable BoxScope.() -> Unit
) {
    val settings = LocalThemeColor.current
    HyperBackdrop(
        modifier = modifier,
        background = {
            if (settings.patternedBackground || glassScene) {
                HyperBackground(Modifier.matchParentSize())
                Canvas(Modifier.matchParentSize()) {
                    repeat(12) { index ->
                        drawCircle(
                            color = settings.color.copy(alpha = 0.3f),
                            radius = 42.dp.toPx(),
                            center = Offset(
                                size.width * index / 11f,
                                size.height * ((index % 4 + 0.5f) / 4f)
                            )
                        )
                    }
                }
            } else {
                // Flutter 普通示例的透明画布覆盖在白色手机屏幕上，深色屏幕为 11/13/17。
                val screen = if (settings.darkTheme) Color(11 / 255f, 13 / 255f, 17 / 255f, 1f)
                    else Color(1f, 1f, 1f, 1f)
                Box(Modifier.matchParentSize().background(screen))
            }
        },
        content = content
    )
}
