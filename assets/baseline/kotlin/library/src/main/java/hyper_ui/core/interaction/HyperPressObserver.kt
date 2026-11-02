/** 文件职责：液态控件共用的按下反馈；旁观手势，不消费正文或控件事件。 */
package hyper_ui

import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput

internal fun Modifier.hyperObservePress(enabled: Boolean = true, onPressed: (Boolean) -> Unit): Modifier =
    pointerInput(enabled) {
        if (!enabled) return@pointerInput
        try {
            awaitEachGesture {
                awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
                onPressed(true)
                do {
                    val event = awaitPointerEvent(PointerEventPass.Initial)
                } while (event.changes.any { it.pressed })
                onPressed(false)
            }
        } finally { onPressed(false) }
    }
