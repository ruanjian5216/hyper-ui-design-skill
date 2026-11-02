/** 文件职责：按钮布局、状态和语义；材质由 HyperButtonSurface 绘制。 */
package hyper_ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.LineHeightStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import hyper_ui.core.interaction.hyperNoRippleClickable

@Immutable
data class HyperButtonColors(
    val containerColor: Color,
    val contentColor: Color,
    val disabledContainerColor: Color,
    val disabledContentColor: Color
)

/** 受控动作按钮。loading 由调用方持有，加载期间阻止重复触发。 */
@Composable
fun HyperButton(
    onPressed: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    type: String? = null,
    color: Color = Color.Unspecified,
    colorStyle: String? = null,
    colors: HyperButtonColors? = null,
    border: BorderStroke? = HyperButtonDefaults.border(type, enabled && onPressed != null, color = color, colorStyle = colorStyle),
    shape: Shape = HyperButtonDefaults.shape(),
    contentPadding: PaddingValues = HyperButtonDefaults.contentPadding(),
    role: Role = Role.Button,
    horizontalArrangement: Arrangement.Horizontal = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
    verticalAlignment: Alignment.Vertical = Alignment.CenterVertically,
    content: @Composable RowScope.() -> Unit
) {
    val resolvedHeight = HyperButtonDefaults.height()
    require(type == null || type in setOf("filled", "icon")) {
        "不支持的 HyperButton type: $type"
    }
    require(colorStyle == null || colorStyle in setOf("primary", "success", "info", "warning", "danger")) {
        "不支持的 HyperButton colorStyle: $colorStyle"
    }
    val isIconType = type == "icon"
    val isEnabled = enabled && onPressed != null
    val resolvedColors = colors ?: HyperButtonDefaults.colors(type, color = color, colorStyle = colorStyle)
    val container = if (isEnabled) resolvedColors.containerColor else resolvedColors.disabledContainerColor
    val foreground = if (isEnabled) resolvedColors.contentColor else resolvedColors.disabledContentColor
    var pressed by remember { mutableStateOf(false) }
    val progress by animateFloatAsState(if (pressed && isEnabled && !loading) 1f else 0f,
        tween(if (pressed) HyperMotionSpec.PressInDuration else HyperMotionSpec.PressOutDuration,
            easing = HyperMotionSpec.OverlayCurve), label = "HyperButtonGlassPress")
    Row(
        modifier = modifier
            .then(
                if (isIconType) {
                    Modifier.size(resolvedHeight)
                } else {
                    Modifier
                        .defaultMinSize(minWidth = (68 + (resolvedHeight.value - 38) * 2.5f).coerceAtLeast(0f).dp)
                        .height(resolvedHeight)
                }
            )
            .hyperNoRippleClickable(enabled = isEnabled && !loading, role = role,
                onPressChanged = { pressed = it }, onClick = { onPressed?.invoke() })
            .hyperButtonSurface(container, shape, type, isEnabled, border,
                defaultContainer = colors == null, progress = { progress })
            .semantics { if (loading) stateDescription = "正在处理" }
            .then(if (isIconType) Modifier else Modifier.padding(contentPadding).padding(1.dp)),
        horizontalArrangement = horizontalArrangement,
        verticalAlignment = verticalAlignment
    ) {
        CompositionLocalProvider(
            LocalHyperContentColor provides foreground,
            LocalHyperTextStyle provides HyperButtonDefaults.textStyle(),
            LocalHyperIconSize provides HyperButtonDefaults.iconSize(isIconType)
        ) {
            if (loading) HyperProgress(
                type = "circular",
                showLabel = false,
                modifier = Modifier.size(if (isIconType)
                    (HyperButtonDefaults.iconSize(iconOnly = true) - 2.dp).coerceAtLeast(12.dp) else 16.dp),
                strokeWidth = 2.dp,
                colors = HyperProgressDefaults.colors(hyperSurfaces.controlTrack, foreground)
            )
            if (!isIconType || !loading) content()
        }
    }
}

object HyperButtonDefaults {
    val MinHeight = 38.dp
    val IconSize = 20.dp
    val ContentSpacing = 8.dp
    val ContentPadding = PaddingValues(horizontal = 14.dp)
    val Shape: Shape = RoundedCornerShape(percent = 50)

    fun shape(): Shape = RoundedCornerShape(height() / 2)

    fun iconSize(iconOnly: Boolean = false): Dp = if (iconOnly) 20.dp else 17.dp

    fun height(): Dp = MinHeight

    fun contentPadding(): PaddingValues = ContentPadding

    @Composable
    fun textStyle(): TextStyle = HyperTheme.typography.labelLarge.copy(
        fontSize = 13.sp, lineHeight = 15.6.sp,
        fontWeight = FontWeight.SemiBold, letterSpacing = 0.05.sp,
        // 单行保留声明的行框，避免裁掉首尾行距后按字体固有度量居中而使字形偏下。
        lineHeightStyle = LineHeightStyle(
            alignment = LineHeightStyle.Alignment.Proportional,
            trim = LineHeightStyle.Trim.None
        ),
    )

    @Composable
    fun colors(
        type: String? = null,
        containerColor: Color = Color.Unspecified,
        contentColor: Color = Color.Unspecified,
        disabledContainerColor: Color = Color.Unspecified,
        disabledContentColor: Color = Color.Unspecified,
        color: Color = Color.Unspecified,
        colorStyle: String? = null
    ): HyperButtonColors {
        val tone = tone(color, colorStyle)
        val hasTone = color != Color.Unspecified || colorStyle != null
        val fill = when (type) {
            "filled" -> tone
            "icon" -> hyperSurfaces.surface
            null -> hyperSurfaces.surfaceSubtle
            else -> error("不支持的 HyperButton type: $type")
        }
        val foreground = if (type == "filled" && hasTone) {
            if (tone.luminance() > 0.5f) HyperColors.primaryText else Color(1f, 1f, 1f, 1f)
        } else if (hasTone) tone else HyperColors.primaryText
        return HyperButtonColors(
            resolveHyperContainerColor(containerColor, fill),
            resolveHyperContainerColor(contentColor, foreground),
            resolveHyperContainerColor(disabledContainerColor, hyperSurfaces.controlTrack),
            resolveHyperContainerColor(disabledContentColor, HyperColors.secondaryText.copy(alpha = 150 / 255f))
        )
    }

    /** 自定义颜色优先于语义配色；省略两者采用默认白色表面（深色模式随主题）。 */
    @Composable
    internal fun tone(color: Color, colorStyle: String?): Color {
        val preset = when (colorStyle) {
            "primary" -> HyperColors.accent
            "success" -> HyperColors.success
            "info" -> HyperColors.info
            "warning" -> HyperColors.warning
            "danger" -> HyperColors.danger
            null -> hyperSurfaces.surfaceStrong
            else -> error("不支持的 HyperButton colorStyle: $colorStyle")
        }
        return resolveHyperContainerColor(color, preset)
    }

    @Composable
    fun border(
        type: String? = null,
        enabled: Boolean = true,
        color: Color = Color.Unspecified,
        colorStyle: String? = null
    ): BorderStroke? {
        val fallback = when {
            !enabled -> HyperColors.divider.copy(alpha = 110 / 255f)
            type == "filled" -> return null
            color != Color.Unspecified || colorStyle != null -> tone(color, colorStyle).copy(alpha = 0.35f)
            else -> return null
        }
        return if (fallback.alpha == 0f) null else BorderStroke(if (enabled) 0.5.dp else 1.dp, fallback)
    }
}
