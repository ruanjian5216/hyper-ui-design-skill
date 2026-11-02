/** 文件职责：Switch 的横向拖动；点击仍由 clickable 处理，取消不提交值。 */
package hyper_ui

import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import kotlin.math.abs

internal fun Modifier.hyperSwitchGestures(
    enabled: Boolean, rtl: Boolean, travel: Float,
    value: () -> Float, onPressed: (Boolean) -> Unit,
    onTarget: (Float?) -> Unit, onCommit: (Boolean) -> Unit
): Modifier = composed {
    val latestValue by rememberUpdatedState(value)
    val latestPressed by rememberUpdatedState(onPressed)
    val latestTarget by rememberUpdatedState(onTarget)
    val latestCommit by rememberUpdatedState(onCommit)
    pointerInput(enabled, rtl, travel) {
        if (!enabled) return@pointerInput
        awaitEachGesture {
            val down = awaitFirstDown(false, PointerEventPass.Initial)
            val initial = latestValue()
            var dragging = false
            var fraction = initial
            latestPressed(true)
            try {
                // Initial 与 Main 属于同一个 down；先越过 Main down，不能把 clickable
                // 消费按下事件误判为拖动被取消，后续 move 才进入消费/方向检查。
                awaitFirstDown(false, PointerEventPass.Main)
                while (true) {
                    val event = awaitPointerEvent()
                    val change = event.changes.firstOrNull { it.id == down.id } ?: break
                    val delta = change.position - down.position
                    if (!change.pressed) {
                        if (dragging && !change.isConsumed) {
                            change.consume()
                            latestCommit(fraction >= 0.5f)
                        }
                        break
                    }
                    if (change.isConsumed) break
                    if (!dragging && abs(delta.y) > viewConfiguration.touchSlop && abs(delta.y) > abs(delta.x)) break
                    if (!dragging && abs(delta.x) > 0f && abs(delta.x) >= abs(delta.y)) dragging = true
                    if (dragging) {
                        change.consume()
                        fraction = (initial + delta.x / travel * if (rtl) -1f else 1f).coerceIn(0f, 1f)
                        latestTarget(fraction)
                    }
                }
            } finally {
                latestPressed(false)
                latestTarget(null)
            }
        }
    }
}
