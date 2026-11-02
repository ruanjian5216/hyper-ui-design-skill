/** 文件职责：统一嵌入、手机与桌面示例的视口、滚动归属及安全区。 */
package hyper_ui.docs.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.key
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import hyper_ui.docs.data.ComponentDemo

@Composable
internal fun ComponentPreviewViewport(
    demo: ComponentDemo,
    modifier: Modifier = Modifier,
    deviceSafeAreas: Boolean = false
) {
    // 切换组件时销毁旧的滚动位置和演示状态，避免短页面继承长页面的偏移。
    key(demo.id) {
        PreviewSceneBackdrop(modifier.fillMaxSize(), glassScene = demo.id.startsWith("tab-bar-") || demo.id in setOf("button", "slider", "switch", "dialog", "hyper_dialog",
            "checkbox", "radio", "date_picker", "tabs", "drawer", "dropdown", "toast", "progress", "level_capsule", "update_dialog")) {
            val top = if (deviceSafeAreas && !demo.fillsTopSafeArea) PreviewTopSafeArea else 0.dp
            // 与 Flutter 预览一致：手势条覆盖在整屏内容上，宿主不预留底部安全区。
            Box(Modifier.fillMaxSize().padding(top = top)) {
                if (demo.fullScreenPreview) {
                    // 页面示例获得有限的整屏约束；列表或正文自己管理滚动。
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.TopCenter) { demo.content() }
                } else {
                    Box(
                        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
                        contentAlignment = Alignment.TopCenter
                    ) { demo.content() }
                }
            }
        }
    }
}
