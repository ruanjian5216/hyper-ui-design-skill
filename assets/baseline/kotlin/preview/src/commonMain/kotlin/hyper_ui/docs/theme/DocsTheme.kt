/** 文件职责：在 hyper_ui 中负责维护 preview/src/commonMain/kotlin/hyper_ui/docs/theme/DocsTheme 的主题、样式与布局规范。 */
package hyper_ui.docs.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import hyper_ui.HyperThemeConfig
import hyper_ui.LocalHyperContentColor
import hyper_ui.LocalHyperTextStyle
import hyper_ui.rgba

internal val DocsBackground = rgba(241, 243, 247, 1f)
internal val DocsSidebar = rgba(255, 255, 255, 1f)
internal val DocsBorder = rgba(229, 229, 234, 1f)
internal val DocsCodeBackground = rgba(17, 24, 39, 1f)
internal val DocsCodeText = rgba(229, 236, 247, 1f)
internal val DocsPreviewBackground = rgba(241, 243, 247, 1f)

internal val DefaultDocsThemeColor = rgba(71, 111, 232, 1f)



// 文档浅色主题的固定语义色，替代原 系统浅色语义色 的对应槽位。
internal val DocsOnBackground = rgba(28, 28, 30, 1f)
internal val DocsOnSurface = rgba(28, 28, 30, 1f)
internal val DocsOnSurfaceVariant = rgba(142, 142, 147, 1f)
internal val DocsSecondary = rgba(5, 150, 105, 1f)
internal val DocsSecondaryContainer = rgba(204, 232, 220, 1f)
internal val DocsOnSecondaryContainer = rgba(0, 32, 26, 1f)
internal val DocsTertiaryContainer = rgba(255, 220, 194, 1f)
internal val DocsOnTertiaryContainer = rgba(58, 40, 0, 1f)
internal val DocsError = rgba(220, 38, 38, 1f)
internal val DocsOnError = rgba(255, 255, 255, 1f)
internal val DocsErrorContainer = rgba(254, 226, 226, 1f)
internal val DocsInverseSurface = rgba(44, 44, 46, 1f)
internal val DocsInverseOnSurface = rgba(241, 243, 247, 1f)

/** 文档主题语义色集合：替代原 系统颜色方案 的对应槽位，随主题色动态生成。 */
internal data class DocsColorScheme(
    val background: Color,
    val onBackground: Color,
    val surface: Color,
    val onSurface: Color,
    val surfaceVariant: Color,
    val onSurfaceVariant: Color,
    val primary: Color,
    val onPrimary: Color,
    val primaryContainer: Color,
    val onPrimaryContainer: Color,
    val secondary: Color,
    val secondaryContainer: Color,
    val onSecondaryContainer: Color,
    val tertiaryContainer: Color,
    val onTertiaryContainer: Color,
    val error: Color,
    val onError: Color,
    val errorContainer: Color,
    val outlineVariant: Color,
    val inverseSurface: Color,
    val inverseOnSurface: Color,
)

internal val LocalDocsColorScheme = staticCompositionLocalOf {
    DocsColorScheme(
        background = DocsBackground,
        onBackground = DocsOnBackground,
        surface = DocsSidebar,
        onSurface = DocsOnSurface,
        surfaceVariant = DocsPreviewBackground,
        onSurfaceVariant = DocsOnSurfaceVariant,
        primary = DefaultDocsThemeColor,
        onPrimary = rgba(255, 255, 255, 1f),
        primaryContainer = rgba(255, 233, 214, 1f),
        onPrimaryContainer = rgba(61, 24, 0, 1f),
        secondary = DocsSecondary,
        secondaryContainer = DocsSecondaryContainer,
        onSecondaryContainer = DocsOnSecondaryContainer,
        tertiaryContainer = DocsTertiaryContainer,
        onTertiaryContainer = DocsOnTertiaryContainer,
        error = DocsError,
        onError = DocsOnError,
        errorContainer = DocsErrorContainer,
        outlineVariant = DocsBorder,
        inverseSurface = DocsInverseSurface,
        inverseOnSurface = DocsInverseOnSurface,
    )
}

internal fun Color.blendWith(white: Color, ratio: Float): Color {
    val r = red * (1f - ratio) + white.red * ratio
    val g = green * (1f - ratio) + white.green * ratio
    val b = blue * (1f - ratio) + white.blue * ratio
    return Color(
        red = r.coerceIn(0f, 1f),
        green = g.coerceIn(0f, 1f),
        blue = b.coerceIn(0f, 1f),
        alpha = 1f
    )
}

internal fun Color.darken(ratio: Float): Color {
    return Color(
        red = (red * (1f - ratio)).coerceIn(0f, 1f),
        green = (green * (1f - ratio)).coerceIn(0f, 1f),
        blue = (blue * (1f - ratio)).coerceIn(0f, 1f),
        alpha = 1f
    )
}

/**
 * 文档主题：基于 hyper-ui 自有主题体系（HyperThemeConfig + 文档语义色 + 默认字体样式），
 * 替代原 系统主题包裹 包裹。
 */
@Composable
fun HyperDocsTheme(
    themeColor: Color = DefaultDocsThemeColor,
    darkTheme: Boolean = isSystemInDarkTheme(),
    patternedBackground: Boolean = false,
    content: @Composable () -> Unit
) {
    val isLightTheme = themeColor.luminance() < 0.7f
    val onPrimaryColor = if (themeColor.luminance() > 0.6f) {
        rgba(28, 28, 30, 1f)
    } else {
        rgba(255, 255, 255, 1f)
    }
    val primaryContainerColor = themeColor.blendWith(rgba(255, 255, 255, 1f), 0.78f)
    val onPrimaryContainerColor = if (isLightTheme) {
        themeColor.darken(0.55f)
    } else {
        themeColor.blendWith(rgba(255, 255, 255, 1f), 0.2f)
    }

    val scheme = LocalDocsColorScheme.current.copy(
        background = when {
            darkTheme -> rgba(17, 19, 24, 1f)
            patternedBackground -> rgba(232, 236, 246, 1f)
            else -> DocsBackground
        },
        onBackground = if (darkTheme) rgba(243, 244, 246, 1f) else DocsOnBackground,
        surface = if (darkTheme) rgba(27, 31, 39, 1f) else DocsSidebar,
        onSurface = if (darkTheme) rgba(243, 244, 246, 1f) else DocsOnSurface,
        surfaceVariant = if (darkTheme) rgba(39, 44, 53, 1f) else DocsPreviewBackground,
        onSurfaceVariant = if (darkTheme) rgba(184, 192, 204, 1f) else DocsOnSurfaceVariant,
        outlineVariant = if (darkTheme) rgba(52, 59, 71, 1f) else DocsBorder,
        primary = themeColor,
        onPrimary = onPrimaryColor,
        primaryContainer = primaryContainerColor,
        onPrimaryContainer = onPrimaryContainerColor,
    )

    HyperThemeConfig(
        themeColor = themeColor,
        darkTheme = darkTheme,
        typography = docsTypography()
    ) {
        CompositionLocalProvider(
            LocalDocsColorScheme provides scheme,
            LocalHyperContentColor provides scheme.onSurface,
            LocalHyperTextStyle provides docsTextStyle(),
        ) {
            content()
        }
    }
}
