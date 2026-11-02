/** 文件职责：Switch 的位置、按压、双轴弹性和速度形变；不提交业务状态。 */
package hyper_ui

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.runtime.*
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.util.VelocityTracker
import kotlin.math.abs
import kotlin.time.Clock

internal data class HyperSwitchMotion(
    val position: Float, val progress: Float, val scaleX: Float, val scaleY: Float
)

@Composable
internal fun rememberHyperSwitchMotion(target: Float, pressed: Boolean, enabled: Boolean): HyperSwitchMotion {
    val position = remember { Animatable(target, 0.001f) }
    val tracker = remember { VelocityTracker() }
    var targetVelocity by remember { mutableFloatStateOf(0f) }
    LaunchedEffect(pressed) { if (pressed) tracker.resetTracking() }
    LaunchedEffect(target, enabled) {
        if (enabled) position.animateTo(target, spring(1f, 1000f, 0.001f)) {
            tracker.addPosition(Clock.System.now().toEpochMilliseconds(), Offset(value,0f))
            targetVelocity = tracker.calculateVelocity().x
        } else { position.snapTo(target); targetVelocity = 0f }
    }
    // 松开后先等位置接近目标，再恢复大小，避免点击后镜片立刻缩回。
    val active = enabled && (pressed || abs(position.value - target) >= 0.025f)
    val progress by animateFloatAsState(if (active) 1f else 0f,
        spring(1f, 1000f, 0.001f), label = "SwitchPress")
    val scaleX by animateFloatAsState(if (active) 1.5f else 1f,
        spring(0.6f, 250f, 0.001f), label = "SwitchScaleX")
    val scaleY by animateFloatAsState(if (active) 1.5f else 1f,
        spring(0.7f, 250f, 0.001f), label = "SwitchScaleY")
    val velocity by animateFloatAsState(if (active) targetVelocity else 0f,
        spring(0.5f, 300f, 0.01f), label = "SwitchVelocity")
    return if (!enabled) HyperSwitchMotion(target, 0f, 1f, 1f) else HyperSwitchMotion(
        position.value, progress.coerceIn(0f, 1f),
        scaleX / (1f - (velocity / 50f * 0.75f).coerceIn(-0.2f, 0.2f)),
        scaleY * (1f - (velocity / 50f * 0.25f).coerceIn(-0.2f, 0.2f))
    )
}
