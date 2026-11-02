/** 文件职责：受控开关布局与配色；手势、弹性和表面由独立模块绘制。 */
package hyper_ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.dropShadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.shadow.Shadow
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.*
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.unit.*

@Composable
fun HyperSwitch(
    value: Boolean, onChanged: ((Boolean) -> Unit)? = null,
    modifier: Modifier = Modifier, enabled: Boolean = true,
    checkedTrackColor: Color = Color.Unspecified,
    uncheckedTrackColor: Color = Color.Unspecified,
    checkedThumbColor: Color = Color(1f, 1f, 1f, 1f),
    uncheckedThumbColor: Color = Color.Unspecified,
    label: String? = null
) {
    val active = enabled && onChanged != null
    var rowPressed by remember { mutableStateOf(false) }
    val control: @Composable (Modifier) -> Unit = { controlModifier ->
        HyperSwitchControl(value, onChanged, controlModifier, active, rowPressed,
            checkedTrackColor, uncheckedTrackColor, checkedThumbColor, uncheckedThumbColor)
    }
    if (label != null) {
        HyperListTile(type = "plain", modifier = modifier.hyperObservePress(active) { rowPressed = it },
            title = { HyperText(label) }, trailing = { control(Modifier) }, enabled = active,
            showChevron = false, onPressed = { onChanged?.invoke(!value) })
    } else control(modifier)
}

@Composable
private fun HyperSwitchControl(
    value: Boolean, onChanged: ((Boolean) -> Unit)?, modifier: Modifier,
    active: Boolean, rowPressed: Boolean, checkedTrackColor: Color,
    uncheckedTrackColor: Color, checkedThumbColor: Color, uncheckedThumbColor: Color
) {
    val source = remember { MutableInteractionSource() }
    val interactionPressed by source.collectIsPressedAsState()
    var pointerPressed by remember { mutableStateOf(false) }
    var dragTarget by remember { mutableStateOf<Float?>(null) }
    val controlledTarget = if (value) 1f else 0f
    val target = if (active) dragTarget ?: controlledTarget else controlledTarget
    val motion = rememberHyperSwitchMotion(target, pointerPressed || rowPressed || interactionPressed, active)
    val fraction = motion.position.coerceIn(0f, 1f)
    val light = HyperColors.isLight
    val checked = resolveHyperContainerColor(checkedTrackColor,
        HyperColors.accent.copy(alpha = if (light) 0.74f else 0.64f))
    val unchecked = resolveHyperContainerColor(uncheckedTrackColor,
        Color(1f, 1f, 1f, if (light) 0.46f else 0.12f))
    val track = lerp(unchecked, if (active) checked else checked.copy(alpha = 90/255f), fraction)
    val thumb = lerp(resolveHyperContainerColor(uncheckedThumbColor, Color(1f,1f,1f,1f)),
        resolveHyperContainerColor(checkedThumbColor, Color(1f,1f,1f,1f)), fraction)
    val trackSource = rememberHyperGlassSource()
    val sources = listOfNotNull(LocalHyperGlassSource.current) + trackSource
    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    val travel = with(LocalDensity.current) { 20.dp.toPx() }
    Box(modifier.size(52.dp, 32.dp)
        .hyperSwitchGestures(active, rtl, travel, { if (value) 1f else 0f },
            { pointerPressed = it }, { dragTarget = it }, { onChanged?.invoke(it) })
        .clickable(source, indication = null, enabled = active, role = Role.Switch) { onChanged?.invoke(!value) }
        .semantics { toggleableState = if (value) ToggleableState.On else ToggleableState.Off; if (!active) disabled() },
        contentAlignment = Alignment.Center) {
        Box(Modifier.size(HyperSwitchDefaults.TrackWidth, HyperSwitchDefaults.TrackHeight)) {
            // 轨道复用 Button 的玻璃皮肤；录制轨道时只采样外部背景，绝不采样滑块自身。
            Box(Modifier.matchParentSize().hyperGlassSource(trackSource)
                .hyperControlSurface(CircleShape, HyperControlSurfaceRole.Button,
                    containerColor = track, sources = listOfNotNull(LocalHyperGlassSource.current)))
            Box(Modifier.align(Alignment.CenterStart)
                .offset(x = HyperSwitchDefaults.TrackPadding + 20.dp * motion.position)
                .size(HyperSwitchDefaults.ThumbSize)
                .graphicsLayer { scaleX = motion.scaleX; scaleY = motion.scaleY }
                .then(if (active) Modifier.hyperControlSurface(CircleShape, HyperControlSurfaceRole.SwitchThumb,
                    progress = { motion.progress }, containerColor = thumb, sources = sources,
                    sampleScale = { sample -> if (sample === trackSource)
                        Offset(2f/3f + motion.progress/12f, 0.75f*motion.progress) else Offset(1f,1f) })
                else Modifier.dropShadow(CircleShape, Shadow(3.dp, offset = DpOffset(0.dp, 1.dp),
                    color = hyperSurfaces.shadow.copy(alpha = hyperSurfaces.shadow.alpha*0.5f))).clip(CircleShape).background(thumb)))
        }
    }
}

object HyperSwitchDefaults {
    val TrackWidth = 52.dp
    val TrackHeight = 32.dp
    val TrackPadding = 5.dp
    val TrackElevation = 0.dp
    val TrackBorderWidth = 0.dp
    val ThumbSize = 22.dp
    val ThumbElevation = 0.dp
    val ThumbBorderWidth = 0.dp
}
