/** 文件职责：所有轻量点击控件共享 HyPressable 的按压反馈与键盘语义。 */
package hyper_ui.core.interaction

import hyper_ui.HyperMotionSpec

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.Role

internal fun Modifier.hyperNoRippleClickable(
    enabled: Boolean = true,
    role: Role? = null,
    interactionSource: MutableInteractionSource? = null,
    onPressChanged: ((Boolean) -> Unit)? = null,
    pressedScale: Float = 0.975f,
    onLongClick: (() -> Unit)? = null,
    onClick: () -> Unit
): Modifier = composed {
    val source = interactionSource ?: remember { MutableInteractionSource() }
    val interactionPressed by source.collectIsPressedAsState()
    var pointerPressed by remember { mutableStateOf(false) }
    val currentOnPressChanged by rememberUpdatedState(onPressChanged)
    val pressed = enabled && (pointerPressed || interactionPressed)
    val progress by animateFloatAsState(
        targetValue = if (pressed) 1f else 0f,
        animationSpec = tween(if (pressed) HyperMotionSpec.PressInDuration else HyperMotionSpec.PressOutDuration, easing = HyperMotionSpec.OverlayCurve),
        label = "HyperPress"
    )
    Modifier.graphicsLayer {
        scaleX = 1f - (1f - pressedScale) * progress
        scaleY = scaleX
        alpha = 1f - 0.08f * progress
    }.pointerInput(enabled) {
        if (!enabled) return@pointerInput
        awaitEachGesture {
            try {
                // Initial pass 先于 clickable 观察 down，滚动容器内也能立即显示按压反馈。
                awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
                pointerPressed = true
                currentOnPressChanged?.invoke(true)
                waitForUpOrCancellation()
            } finally {
                pointerPressed = false
                currentOnPressChanged?.invoke(false)
            }
        }
    }.then(if (onLongClick == null) {
        Modifier.clickable(interactionSource = source, indication = null, enabled = enabled, role = role, onClick = onClick)
    } else {
        Modifier.combinedClickable(interactionSource = source, indication = null, enabled = enabled, role = role,
            onLongClick = onLongClick, onClick = onClick)
    })
}
