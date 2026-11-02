/** 文件职责：在 hyper_ui 中负责维护 library/src/main/java/hyper_ui/theme/HyperStyle 的主题、样式与布局规范。
 *  自建主题体系：颜色 / 字体排版 / 形状 / 内容色 / 文本样式，全部基于 Compose 基础库（foundation/ui/runtime），不依赖外部设计组件库。 */
package hyper_ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

fun rgba(
    red: Int,
    green: Int,
    blue: Int,
    alpha: Float = 1f
): Color = Color(
    red = red.coerceIn(0, 255) / 255f,
    green = green.coerceIn(0, 255) / 255f,
    blue = blue.coerceIn(0, 255) / 255f,
    alpha = alpha.coerceIn(0f, 1f)
)

@Immutable
data class HyperThemeColors(
    val themeColor: Color = HyperStyleDefaults.DefaultThemeColor,
    val successColor: Color = HyperStyleDefaults.SuccessColor
)

private val LocalHyperThemeColors = staticCompositionLocalOf {
    HyperThemeColors()
}

internal val LocalHyperIsDark = staticCompositionLocalOf { false }

/** 字体排版体系：替代 系统 Typography 的对应槽位。 */
@Immutable
data class HyperTypography(
    val headlineSmall: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 24.sp,
        lineHeight = 32.sp,
    ),
    val bodyLarge: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.sp
    ),
    val bodyMedium: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.sp
    ),
    val bodySmall: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.sp
    ),
    val titleLarge: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp
    ),
    val titleMedium: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.sp
    ),
    val titleSmall: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.sp
    ),
    val labelMedium: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.sp
    ),
    val labelLarge: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.sp,
    ),
    val labelSmall: TextStyle = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.sp
    )
)

/** 形状体系：替代 系统 Shapes 的对应槽位。 */
@Immutable
data class HyperShapes(
    val extraSmall: Shape = RoundedCornerShape(7.dp),
    val small: Shape = RoundedCornerShape(16.dp),
    val medium: Shape = RoundedCornerShape(24.dp),
    val large: Shape = RoundedCornerShape(28.dp)
)

private val LocalHyperTypography = staticCompositionLocalOf { HyperTypography() }
private val LocalHyperShapes = staticCompositionLocalOf { HyperShapes() }
private val LocalHyperSurfaces = staticCompositionLocalOf { HyperSurfaceTokens.light() }

/** 全局内容色：替代 系统内容色。 */
val LocalHyperContentColor = staticCompositionLocalOf { HyperStyleDefaults.LightPrimaryText }

/** 全局默认文本样式：替代 系统文本样式。 */
val LocalHyperTextStyle = staticCompositionLocalOf { HyperTypography().bodyMedium.copy(lineHeight = 19.6.sp) }

@Composable
fun HyperThemeConfig(
    themeColor: Color = HyperStyleDefaults.DefaultThemeColor,
    successColor: Color = HyperStyleDefaults.SuccessColor,
    darkTheme: Boolean = isSystemInDarkTheme(),
    typography: HyperTypography = HyperStyleDefaults.Typography,
    shapes: HyperShapes = HyperStyleDefaults.Shapes,
    useSystemSafeArea: Boolean = false,
    content: @Composable () -> Unit
) {
    val defaultContentColor = if (darkTheme) {
        HyperStyleDefaults.DarkPrimaryText
    } else {
        HyperStyleDefaults.LightPrimaryText
    }
    CompositionLocalProvider(
        LocalHyperThemeColors provides HyperThemeColors(
            themeColor = themeColor,
            successColor = successColor
        ),
        LocalHyperIsDark provides darkTheme,
        LocalHyperUseSystemSafeArea provides useSystemSafeArea,
        LocalHyperTypography provides typography,
        LocalHyperShapes provides shapes,
        LocalHyperSurfaces provides if (darkTheme) HyperSurfaceTokens.dark() else HyperSurfaceTokens.light(),
        LocalHyperContentColor provides defaultContentColor,
        LocalHyperTextStyle provides typography.bodyMedium.copy(lineHeight = 19.6.sp),
        content = content
    )
}

object HyperTheme {
    internal val surfaces: HyperSurfaceTokens
        @Composable @ReadOnlyComposable
        get() = LocalHyperSurfaces.current

    val colors: HyperThemeColors
        @Composable @ReadOnlyComposable
        get() = LocalHyperThemeColors.current

    val typography: HyperTypography
        @Composable @ReadOnlyComposable
        get() = LocalHyperTypography.current

    val shapes: HyperShapes
        @Composable @ReadOnlyComposable
        get() = LocalHyperShapes.current

    val isDark: Boolean
        @Composable @ReadOnlyComposable
        get() = LocalHyperIsDark.current
}

object HyperStyleDefaults {
    val DefaultThemeColor = rgba(71, 111, 232, 1f)
    val SuccessColor = rgba(34, 197, 94, 1f)
    val InfoColor = rgba(59, 130, 246, 1f)
    val WarningColor = rgba(245, 158, 11, 1f)
    val DangerColor = rgba(239, 68, 68, 1f)
    const val DisabledAlpha = 0.38f
    val SmallCornerRadius = 16.dp
    val MediumCornerRadius = 24.dp
    val LargeCornerRadius = 24.dp
    val ExtraLargeCornerRadius = 28.dp

    val CardElevation = 12.dp

    val LightPrimaryText = rgba(26, 29, 38, 1f)
    val DarkPrimaryText = rgba(243, 244, 246, 1f)

    val Typography = HyperTypography()
    val Shapes = HyperShapes()
}

object HyperColors {
    val accent: Color
        @Composable @ReadOnlyComposable
        get() = HyperTheme.colors.themeColor

    val success: Color
        @Composable @ReadOnlyComposable
        get() = HyperTheme.colors.successColor

    val info: Color
        @Composable @ReadOnlyComposable
        get() = HyperStyleDefaults.InfoColor

    val warning: Color
        @Composable @ReadOnlyComposable
        get() = HyperStyleDefaults.WarningColor

    val danger: Color
        @Composable @ReadOnlyComposable
        get() = HyperStyleDefaults.DangerColor

    val isLight: Boolean
        @Composable @ReadOnlyComposable
        get() = !HyperTheme.isDark

    val pageBackground: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(241, 243, 247, 1f) else rgba(17, 19, 24, 1f)

    val cardContainer: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(255, 255, 255, 1f) else rgba(27, 31, 39, 1f)

    val softContainer: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(241, 243, 245, 1f) else rgba(39, 44, 53, 1f)

    val fieldContainer: Color
        @Composable @ReadOnlyComposable
        get() = hyperSurfaces.surfaceSubtle

    val elevatedContainer: Color
        @Composable @ReadOnlyComposable
        get() = cardContainer

    val disabledContainer: Color
        @Composable @ReadOnlyComposable
        get() = hyperSurfaces.controlTrack

    val primaryText: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) HyperStyleDefaults.LightPrimaryText else HyperStyleDefaults.DarkPrimaryText

    val secondaryText: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(107, 114, 128, 1f) else rgba(184, 192, 204, 1f)

    val disabledText: Color
        @Composable @ReadOnlyComposable
        get() = secondaryText.copy(alpha = 150 / 255f)

    val divider: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(17, 18, 22, 24 / 255f) else rgba(52, 59, 71, 1f)

    val fieldBorder: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(229, 231, 235, 1f) else rgba(52, 59, 71, 1f)

    val accentContainer: Color
        @Composable @ReadOnlyComposable
        get() = lerp(accent, softContainer, 0.84f)

    // 日期范围语义底色与 Flutter selectionBackground 一致，不跟随强调色透明混合。
    internal val selectionBackground: Color
        @Composable @ReadOnlyComposable
        get() = if (isLight) rgba(239, 246, 255, 1f) else rgba(20, 37, 68, 1f)

    val panelBorder: BorderStroke
        @Composable @ReadOnlyComposable
        get() = BorderStroke(
            width = 1.dp,
            color = divider
        )

}
