/** 文件职责：受控选择控件；可视尺寸来自 Flutter，触摸尺寸与语义独立。 */
package hyper_ui

import com.composables.icons.lucide.Lucide
import com.composables.icons.lucide.Check
import com.composables.icons.lucide.Minus

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import hyper_ui.core.interaction.hyperNoRippleClickable
import androidx.compose.ui.semantics.disabled
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.toggleableState
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.state.ToggleableState

@Composable
fun HyperCheckbox(
    value: Boolean?,
    onChanged: ((Boolean?) -> Unit)? = null,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    tristate: Boolean = false,
    checkedColor: Color = Color.Unspecified,
    uncheckedColor: Color = Color.Unspecified,
    uncheckedBorderColor: Color = Color.Unspecified,
    checkmarkColor: Color = Color(1f, 1f, 1f, 1f),
    label: String? = null
) {
    if (label != null) {
        HyperListTile(type = "plain", modifier = modifier,
            // 整行承载点击，尾随方框只展示，避免 44dp 独立触摸区撑高标签行。
            title = { HyperText(label) }, trailing = { HyperCheckbox(value = value, modifier = Modifier.size(HyperCheckboxDefaults.BoxSize), enabled = enabled, tristate = tristate, checkedColor = checkedColor, uncheckedColor = uncheckedColor, uncheckedBorderColor = uncheckedBorderColor, checkmarkColor = checkmarkColor) },
            enabled = enabled && onChanged != null, showChevron = false,
            onPressed = { onChanged?.invoke(if (tristate) when (value) { true -> null; false -> true; null -> false } else value != true) })
        return
    }
    require(tristate || value != null) { "value = null 需要 tristate = true" }
    val selected = value == true || (tristate && value == null)
    val selectedColor = resolveHyperContainerColor(checkedColor, HyperColors.accent)
    val fill by animateColorAsState(if (selected) { if (checkedColor == Color.Unspecified && enabled) selectedColor.copy(alpha = 0.9f) else selectedColor } else resolveHyperContainerColor(uncheckedColor, if (enabled) Color(1f, 1f, 1f, if (HyperColors.isLight) 0.4f else 0.136f) else hyperSurfaces.controlTrack),
        tween(HyperMotionSpec.StateDuration, easing = HyperMotionSpec.SelectionCurve), label = "HyperCheckboxFill")
    val border by animateColorAsState(if (selected) selectedColor else resolveHyperContainerColor(uncheckedBorderColor, HyperColors.fieldBorder),
        tween(HyperMotionSpec.StateDuration, easing = HyperMotionSpec.SelectionCurve), label = "HyperCheckboxBorder")
    val markProgress by animateFloatAsState(if (selected) 1f else 0f,
        tween(HyperMotionSpec.StateDuration, easing = HyperMotionSpec.OverlayCurve), label = "HyperCheckboxMark")
    val shape = RoundedCornerShape(7.dp)
    Box(
        modifier.size(44.dp)
            .hyperNoRippleClickable(enabled && onChanged != null, Role.Checkbox, onClick = {
                onChanged?.invoke(if (tristate) when (value) { true -> null; false -> true; null -> false } else value != true)
            })
            .semantics { toggleableState = when (value) { true -> ToggleableState.On; false -> ToggleableState.Off; null -> ToggleableState.Indeterminate }; if (!enabled) disabled() },
        contentAlignment = Alignment.Center
    ) {
        Box(Modifier.size(21.dp).then(if (enabled) Modifier.hyperControlSurface(shape, HyperControlSurfaceRole.Compact,
            containerColor = fill, border = androidx.compose.foundation.BorderStroke(1.5.dp, border))
            else Modifier.clip(shape).background(fill).border(1.5.dp, border, shape)), contentAlignment = Alignment.Center) {
            CompositionLocalProvider(LocalHyperContentColor provides checkmarkColor) {
                val mark = Modifier.size(15.dp).graphicsLayer { alpha = markProgress; scaleX = 0.8f + 0.2f * markProgress; scaleY = scaleX }
                if (value == null) HyperIcon(Lucide.Minus, null, mark)
                else HyperIcon(Lucide.Check, null, mark)
            }
        }
    }
}

@Composable
fun <T> HyperRadio(
    value: T,
    groupValue: T?,
    onChanged: ((T) -> Unit)? = null,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    selectedColor: Color = Color.Unspecified,
    unselectedColor: Color = Color.Unspecified,
    unselectedBorderColor: Color = Color.Unspecified,
    innerDotColor: Color = Color.Unspecified,
    label: String? = null
) {
    if (label != null) {
        HyperListTile(type = "plain", modifier = modifier
            .hyperNoRippleClickable(enabled = enabled && onChanged != null, role = Role.RadioButton,
                pressedScale = 0.992f, onClick = { onChanged?.invoke(value) })
            .semantics { this.selected = value == groupValue },
            title = { HyperText(label, style = LocalHyperTextStyle.current) },
            // 标签行统一承载点击，尾随圆环只展示，避免重复触摸区撑高列表行。
            trailing = { HyperRadio(value = value, groupValue = groupValue, onChanged = null,
                modifier = Modifier.clearAndSetSemantics { }, enabled = enabled,
                selectedColor = selectedColor, unselectedColor = unselectedColor,
                unselectedBorderColor = unselectedBorderColor, innerDotColor = innerDotColor) },
            enabled = enabled && onChanged != null, showChevron = false)
        return
    }
    val selected = value == groupValue
    val active = resolveHyperContainerColor(selectedColor, HyperColors.accent)
    val targetRing = when {
        selected -> active
        else -> resolveHyperContainerColor(unselectedBorderColor, HyperColors.fieldBorder)
    }
    val ring by animateColorAsState(targetRing, tween(HyperMotionSpec.StateDuration, easing = HyperMotionSpec.SelectionCurve), label = "HyperRadioRing")
    val ringWidth by animateFloatAsState(if (selected) 6f else 1.5f, tween(HyperMotionSpec.StateDuration, easing = HyperMotionSpec.SelectionCurve), label = "HyperRadioWidth")
    // 只展示时按圆环的可视尺寸测量；独立交互时才保留完整触摸区。
    val controlSize = if (onChanged == null) HyperRadioDefaults.OuterSize else HyperRadioDefaults.TouchTargetSize
    Box(
        modifier.size(controlSize).then(if (onChanged != null) Modifier.hyperNoRippleClickable(
            enabled = enabled, role = Role.RadioButton, onClick = { onChanged(value) }
        ) else Modifier).semantics { this.selected = selected; if (!enabled || onChanged == null) disabled() },
        contentAlignment = Alignment.Center
    ) {
        val fill = resolveHyperContainerColor(if (selected) innerDotColor else unselectedColor,
            if (enabled) Color(1f, 1f, 1f, if (HyperColors.isLight) 0.4f else 0.136f) else hyperSurfaces.controlTrack)
        Box(Modifier.size(HyperRadioDefaults.OuterSize).then(if (enabled) Modifier.hyperControlSurface(
            CircleShape, HyperControlSurfaceRole.Compact, containerColor = fill,
            border = androidx.compose.foundation.BorderStroke(ringWidth.dp, ring))
            else Modifier.clip(CircleShape).background(fill).border(ringWidth.dp, ring, CircleShape)))
    }
}

object HyperCheckboxDefaults {
    val BoxSize = 21.dp
    val CornerRadius = 7.dp
    val BorderWidth = 1.5.dp
    val CheckmarkSize = 15.dp
}
object HyperRadioDefaults {
    val TouchTargetSize = 44.dp
    val OuterSize = 21.dp
    val InnerDotSize = 9.dp
    val BorderWidth = 1.5.dp
}
