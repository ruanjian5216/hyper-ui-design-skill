/** 文件职责：提供关闭窗口动画且禁用平台默认宽度的 Android Compose Dialog 宿主。 */
package hyper_ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.SideEffect
import android.view.WindowInsetsController
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.window.DialogWindowProvider

@Composable
internal fun HyperDialogHost(
    onDismissRequest: () -> Unit,
    dismissOnBackPress: Boolean,
    content: @Composable () -> Unit
) {
    Dialog(
        onDismissRequest = onDismissRequest,
        properties = DialogProperties(
            dismissOnBackPress = dismissOnBackPress,
            // 使用稳定的全宽宿主，避免 WRAP_CONTENT Window 首帧重新定位。
            dismissOnClickOutside = false,
            usePlatformDefaultWidth = false,
            // 模态遮罩始终占满窗口；安全区只约束面板内容，不裁短根画布。
            decorFitsSystemWindows = false,
        )
    ) {
        val view = LocalView.current
        val dialogWindow = (view.parent as? DialogWindowProvider)?.window
        val darkTheme = HyperTheme.isDark
        // 遮罩由 Compose 绘制，以便 Android 和 Preview 共用令牌和退出进度。
        SideEffect {
            dialogWindow?.let { window ->
                window.enableHyperEdgeToEdge()
                window.setDimAmount(0f)
                val lightBars = WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or
                    WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS
                window.insetsController?.setSystemBarsAppearance(if (darkTheme) 0 else lightBars, lightBars)
            }
        }
        remember(dialogWindow) {
            // 这里必须同步设置非零的空动画样式：0 会允许 PhoneWindow 回退到系统/厂商主题。
            dialogWindow?.setWindowAnimations(R.style.HyperDialogNoWindowAnimation)
            Unit
        }

        content()
    }
}
