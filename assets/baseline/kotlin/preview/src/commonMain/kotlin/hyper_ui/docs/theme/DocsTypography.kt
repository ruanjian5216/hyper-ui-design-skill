/** 文件职责：在 hyper_ui 中负责承载 preview/src/commonMain/kotlin/hyper_ui/docs/theme/DocsTypography 模块实现，并集中维护其依赖协作与核心逻辑。 */
package hyper_ui.docs.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import hyper_ui.HyperTypography
import hyper_ui.docs.generated.resources.Res
import hyper_ui.docs.generated.resources.hyper_ui_preview
import org.jetbrains.compose.resources.Font

/**
 * 单一字体合并 Flutter Web 的 Roboto 与 Noto Sans SC，避免 Wasm 中文回退失效。
 */
@Composable
internal fun docsTextStyle(): TextStyle {
    return TextStyle(fontFamily = docsFontFamily(), fontSize = 14.sp, lineHeight = 19.6.sp)
}

@Composable
private fun docsFontFamily(): FontFamily {
    return FontFamily(
        Font(Res.font.hyper_ui_preview, weight = FontWeight.Normal)
    )
}

/** 将 CJK 字体注入完整组件排版体系，避免内部按钮等显式样式退回 Wasm 默认字体。 */
@Composable
internal fun docsTypography(): HyperTypography {
    val family = docsFontFamily()
    val base = HyperTypography()
    return base.copy(
        headlineSmall = base.headlineSmall.copy(fontFamily = family),
        bodyLarge = base.bodyLarge.copy(fontFamily = family),
        bodyMedium = base.bodyMedium.copy(fontFamily = family),
        bodySmall = base.bodySmall.copy(fontFamily = family),
        titleLarge = base.titleLarge.copy(fontFamily = family),
        titleMedium = base.titleMedium.copy(fontFamily = family),
        titleSmall = base.titleSmall.copy(fontFamily = family),
        labelLarge = base.labelLarge.copy(fontFamily = family),
        labelMedium = base.labelMedium.copy(fontFamily = family),
        labelSmall = base.labelSmall.copy(fontFamily = family)
    )
}
