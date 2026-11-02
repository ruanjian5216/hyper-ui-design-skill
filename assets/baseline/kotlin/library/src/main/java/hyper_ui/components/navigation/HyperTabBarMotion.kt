/** 文件职责：TabBar 的瞬时绘制动效；由 HyperTabBar 注入手势与受控目标，不提交选择状态。 */
package hyper_ui

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.spring
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import kotlin.math.abs
import kotlin.math.sign

internal data class HyperTabBarMotion(
    val position: Float,
    val progress: Float,
    val scaleX: Float,
    val scaleY: Float,
    val travel: Float
) {
    fun panelOffset(width: Float, maximum: Float): Float {
        val fraction = (travel / width.coerceAtLeast(1f)).coerceIn(-1f, 1f)
        return maximum * sign(fraction) * EaseOut.transform(abs(fraction))
    }
}

@Composable
internal fun rememberHyperTabBarMotion(
    target: Float, count: Int, pressed: Boolean, travel: Float
): HyperTabBarMotion {
    val position = remember(count) { Animatable(target) }
    LaunchedEffect(target, count) {
        position.animateTo(target, spring(1f, 1000f, visibilityThreshold = 0.001f))
    }
    // 与参考实现一致，镜片接近目的项后才释放按压，而非在 pointer-up 当帧突然缩回。
    val active = pressed || abs(position.value - target) > (count - 1) * 0.025f
    val progress by animateFloatAsState(if (active) 1f else 0f,
        spring(1f, 1000f, visibilityThreshold = 0.001f), label = "TabBarPress")
    val scaleX by animateFloatAsState(if (active) 78f / 56f else 1f,
        spring(0.6f, 250f, visibilityThreshold = 0.001f), label = "TabBarLensX")
    val scaleY by animateFloatAsState(if (active) 78f / 56f else 1f,
        spring(0.7f, 250f, visibilityThreshold = 0.001f), label = "TabBarLensY")
    val velocity by animateFloatAsState(if (active) position.velocity / (count - 1).coerceAtLeast(1) else 0f,
        spring(0.5f, 300f, visibilityThreshold = 0.01f), label = "TabBarVelocity")
    val panelTravel by animateFloatAsState(if (pressed) travel else 0f,
        if (pressed) snap() else spring(1f, 300f, visibilityThreshold = 0.5f), label = "TabBarTravel")
    return HyperTabBarMotion(position.value, progress,
        scaleX / (1f - (velocity / 10f * 0.75f).coerceIn(-0.2f, 0.2f)),
        scaleY * (1f - (velocity / 10f * 0.25f).coerceIn(-0.2f, 0.2f)), panelTravel)
}

/** 在 Initial pass 旁观首根手指，不消费点击或改变拖动提交时机。 */
internal fun Modifier.hyperTabBarPointer(
    count: Int, rtl: Boolean, inset: Float, enabled: (Int) -> Boolean,
    onPointer: (pressed: Boolean, travel: Float) -> Unit
): Modifier = composed {
    val latestEnabled by rememberUpdatedState(enabled)
    val latestOnPointer by rememberUpdatedState(onPointer)
    pointerInput(count, rtl, inset) {
        try {
            awaitEachGesture {
                val down = awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
                val visual = ((down.position.x - inset) / (size.width - inset * 2).coerceAtLeast(1f) * count)
                    .toInt().coerceIn(0, count - 1)
                if (latestEnabled(if (rtl) count - visual - 1 else visual)) {
                    latestOnPointer(true, 0f)
                    do {
                        val event = awaitPointerEvent(PointerEventPass.Initial)
                        val pointer = event.changes.firstOrNull { it.id == down.id }
                        val held = pointer?.pressed == true
                        latestOnPointer(held, if (held) pointer.position.x - down.position.x else 0f)
                    } while (held)
                }
            }
        } finally { latestOnPointer(false, 0f) }
    }
}

internal fun Modifier.hyperTabBarHighlight(progress: Float, position: Float, count: Int, inset: Float): Modifier =
    drawWithContent {
        if (progress > 0f) {
            val center = Offset(inset + (position + 0.5f) * (size.width - 2 * inset) / count, size.height / 2)
            drawRect(Color(1f, 1f, 1f, 0.08f * progress))
            drawRect(Brush.radialGradient(listOf(Color(1f, 1f, 1f, 0.15f * progress),
                Color(1f, 1f, 1f, 0f)), center, size.minDimension * 1.5f))
        }
        drawContent()
    }
