/** 文件职责：提供 Flutter 浮层曲线 Cubic(0.23,1,0.32,1) 与组件指定时长，显隐动画可从当前值中断。 */
package hyper_ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer

@Composable
internal fun hyperOverlayProgress(visible: Boolean, durationMillis: Int = HyperMotionSpec.ModalDuration): Float {
    var target by remember { mutableStateOf(false) }
    LaunchedEffect(visible) { target = visible }
    val progress by animateFloatAsState(
        if (target) 1f else 0f,
        tween(durationMillis, easing = HyperMotionSpec.OverlayCurve),
        label = "HyperOverlay"
    )
    return progress
}

internal fun Modifier.hyperOverlayMotion(progress: Float, beginScale: Float = 1f): Modifier = graphicsLayer {
    alpha = progress
    scaleX = beginScale + (1f - beginScale) * progress
    scaleY = scaleX
}
