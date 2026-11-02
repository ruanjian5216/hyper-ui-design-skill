/** 文件职责：提供支持连续、等距吸附与可配置分段标记的受控滑块。 */
package hyper_ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.semantics.disabled
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.setProgress
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

@Immutable
data class HyperSliderColors(
    val trackColor: Color,
    val activeTrackColor: Color,
    val segmentMarkerColor: Color,
    val thumbColor: Color,
    val disabledTrackColor: Color,
    val disabledActiveTrackColor: Color,
    val disabledSegmentMarkerColor: Color,
    val disabledThumbColor: Color
)

/**
 * 可点击、可拖动的 HyperUI 受控滑块。
 *
 * `divisions` 只负责等距吸附；`showSegmentMarkers` 与 `segmentValues` 只负责分段点视觉，
 * 两者可以独立使用。`readOnly` 保留正常配色和进度语义，但不响应用户输入。
 */
@Composable
fun HyperSlider(
    value: Float,
    onChanged: ((Float) -> Unit)? = null,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    readOnly: Boolean = false,
    min: Float = 0f,
    max: Float = 100f,
    showValue: Boolean = true,
    divisions: Int? = null,
    showSegmentMarkers: Boolean = false,
    segmentValues: List<Float> = emptyList(),
    onChangeStart: ((Float) -> Unit)? = null,
    onChangeEnd: ((Float) -> Unit)? = null,
    minimumTouchHeight: Dp = HyperSliderDefaults.MinTouchHeight,
    trackHeight: Dp = HyperSliderDefaults.TrackHeight,
    thumbSize: Dp = HyperSliderDefaults.ThumbSize,
    segmentMarkerSize: Dp = HyperSliderDefaults.SegmentMarkerSize,
    trackShape: Shape = HyperSliderDefaults.TrackShape,
    thumbShape: Shape = HyperSliderDefaults.ThumbShape,
    colors: HyperSliderColors = HyperSliderDefaults.colors(),
    trackBorder: BorderStroke? = null,
    thumbBorder: BorderStroke? = null
) {
    val valueRange = min..max
    val divisionCount = divisions ?: 0
    require(divisions == null || divisions > 0) { "divisions 必须大于 0" }
    require(valueRange.start.isFinite() && valueRange.endInclusive.isFinite()) {
        "min 与 max 必须是有限数值"
    }
    require(valueRange.endInclusive > valueRange.start) {
        "max 必须大于 min"
    }
    require(minimumTouchHeight >= 0.dp) { "minimumTouchHeight 不能小于 0.dp" }
    require(trackHeight >= 0.dp) { "trackHeight 不能小于 0.dp" }
    require(thumbSize > 0.dp) { "thumbSize 必须大于 0.dp" }
    require(segmentMarkerSize >= 0.dp) { "segmentMarkerSize 不能小于 0.dp" }

    val currentOnValueChange by rememberUpdatedState(onChanged)
    val currentOnValueChangeStarted by rememberUpdatedState(onChangeStart)
    val currentOnValueChangeFinished by rememberUpdatedState(onChangeEnd)
    var isDragging by remember { mutableStateOf(false) }
    var pressed by remember { mutableStateOf(false) }
    val pressProgress = animateFloatAsState(if (pressed) 1f else 0f,
        spring(dampingRatio = 1f, stiffness = 1000f), label = "HyperSliderGlassPress")
    var interactionValue by remember { mutableStateOf(value) }
    fun dispatchValue(next: Float) { interactionValue = next; currentOnValueChange?.invoke(next) }

    val coercedValue = if (value.isFinite()) {
        value.coerceIn(valueRange.start, valueRange.endInclusive)
    } else {
        valueRange.start
    }
    androidx.compose.runtime.SideEffect { if (!isDragging) interactionValue = coercedValue }
    val animatedFraction by animateFloatAsState(valueToFraction(coercedValue, valueRange),
        spring(dampingRatio = 1f, stiffness = 1000f), label = "HyperSliderPosition")
    val valueFraction = if (isDragging) valueToFraction(coercedValue, valueRange) else animatedFraction
    val markerValues = remember(showSegmentMarkers, segmentValues, valueRange, divisionCount) {
        resolveSegmentMarkerValues(
            showSegmentMarkers = showSegmentMarkers,
            segmentValues = segmentValues,
            valueRange = valueRange,
            divisionCount = divisionCount
        )
    }
    val interactionEnabled = enabled && !readOnly && onChanged != null
    val resolvedTrackColor = if (enabled) colors.trackColor else colors.disabledTrackColor
    val resolvedActiveTrackColor = if (enabled) {
        colors.activeTrackColor
    } else {
        colors.disabledActiveTrackColor
    }
    val resolvedSegmentMarkerColor = if (enabled) {
        colors.segmentMarkerColor
    } else {
        colors.disabledSegmentMarkerColor
    }
    val resolvedThumbColor = if (enabled) colors.thumbColor else colors.disabledThumbColor
    val interactionModifier = Modifier
        .pointerInput(
            interactionEnabled,
            valueRange.start,
            valueRange.endInclusive,
            divisionCount
        ) {
            if (!interactionEnabled) return@pointerInput

            detectDragGestures(
                onDragStart = { offset ->
                    isDragging = true
                    currentOnValueChangeStarted?.invoke(interactionValue)
                    dispatchValue(
                        pointerPositionToValue(
                            pointerX = offset.x,
                            widthPx = size.width.toFloat(),
                            valueRange = valueRange,
                            divisionCount = divisionCount
                        )
                    )
                },
                onDragEnd = {
                    isDragging = false
                    currentOnValueChangeFinished?.invoke(interactionValue)
                },
                onDragCancel = {
                    isDragging = false
                    currentOnValueChangeFinished?.invoke(interactionValue)
                },
                onDrag = { change, _ ->
                    dispatchValue(
                        pointerPositionToValue(
                            pointerX = change.position.x,
                            widthPx = size.width.toFloat(),
                            valueRange = valueRange,
                            divisionCount = divisionCount
                        )
                    )
                    change.consume()
                }
            )
        }
        .pointerInput(
            interactionEnabled,
            valueRange.start,
            valueRange.endInclusive,
            divisionCount
        ) {
            if (!interactionEnabled) return@pointerInput

            detectTapGestures { offset ->
                if (!isDragging) {
                    currentOnValueChangeStarted?.invoke(interactionValue)
                    dispatchValue(
                        pointerPositionToValue(
                            pointerX = offset.x,
                            widthPx = size.width.toFloat(),
                            valueRange = valueRange,
                            divisionCount = divisionCount
                        )
                    )
                    currentOnValueChangeFinished?.invoke(interactionValue)
                }
            }
        }

    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        // 参考轨道使用物理左坐标；外层数值仍跟随调用方的布局方向。
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
            BoxWithConstraints(
                modifier = Modifier.weight(1f)
                    .height(maxOf(minimumTouchHeight, thumbSize))
                    .hyperObservePress(interactionEnabled) { pressed = it }
                    .then(interactionModifier)
                    .semantics {
                        if (!enabled) disabled()
                        progressBarRangeInfo = ProgressBarRangeInfo(coercedValue, valueRange, (divisionCount - 1).coerceAtLeast(0))
                        if (interactionEnabled) setProgress { targetValue ->
                            currentOnValueChangeStarted?.invoke(interactionValue)
                            dispatchValue(snapValueToSteps(targetValue, valueRange, divisionCount))
                            currentOnValueChangeFinished?.invoke(interactionValue)
                            true
                        }
                    },
                contentAlignment = Alignment.CenterStart
            ) {
                val availableTrackWidth = maxWidth
                val trackSource = rememberHyperGlassSource()
                val thumbSources = listOfNotNull(LocalHyperGlassSource.current) + trackSource
                Box(Modifier.align(Alignment.Center).hyperGlassSource(trackSource).width(availableTrackWidth).height(trackHeight)
                    .hyperSurface(resolvedTrackColor, trackShape, border = trackBorder)) {
                    Box(Modifier.fillMaxHeight().fillMaxWidth(valueFraction)
                        .hyperSurface(resolvedActiveTrackColor, trackShape))
                }
                markerValues.forEach { markerValue ->
                    val markerFraction = valueToFraction(markerValue, valueRange)
                    Box(Modifier.align(Alignment.CenterStart)
                        .offset(x = (availableTrackWidth * markerFraction - segmentMarkerSize / 2)
                            .coerceIn(0.dp, (availableTrackWidth - segmentMarkerSize).coerceAtLeast(0.dp)))
                        .size(segmentMarkerSize).background(resolvedSegmentMarkerColor, CircleShape))
                }
                Box(Modifier.offset(x = (availableTrackWidth * valueFraction - thumbSize / 2)
                    .coerceIn(0.dp, (availableTrackWidth - thumbSize).coerceAtLeast(0.dp)))
                    .size(thumbSize)
                    .then(if (enabled) Modifier.hyperControlSurface(thumbShape, HyperControlSurfaceRole.Thumb,
                        progress = { pressProgress.value }, containerColor = resolvedThumbColor,
                        border = thumbBorder, sources = thumbSources)
                    else Modifier.hyperSurface(resolvedThumbColor, thumbShape, border = thumbBorder)))
            }
        }
        if (showValue) HyperText(coercedValue.roundToInt().toString(),
            Modifier.absolutePadding(left = 12.dp), fontSize = 14.sp)
    }
}

object HyperSliderDefaults {
    val MinTouchHeight = 44.dp
    val TrackHeight = 6.dp
    val ThumbSize = 20.dp
    val SegmentMarkerSize = 5.dp
    val TrackShape: Shape = RoundedCornerShape(percent = 50)
    val ThumbShape: Shape = CircleShape

    @Composable
    fun colors(
        trackColor: Color = Color.Unspecified,
        activeTrackColor: Color = Color.Unspecified,
        segmentMarkerColor: Color = Color.Unspecified,
        thumbColor: Color = Color.Unspecified,
        disabledTrackColor: Color = Color.Unspecified,
        disabledActiveTrackColor: Color = Color.Unspecified,
        disabledSegmentMarkerColor: Color = Color.Unspecified,
        disabledThumbColor: Color = Color.Unspecified
    ): HyperSliderColors {
        val accent = HyperColors.accent
        val resolvedActiveTrackColor = resolveHyperContainerColor(activeTrackColor, accent)
        val defaultMarkerColor = HyperColors.primaryText.copy(alpha = 0.56f)
        return HyperSliderColors(
            trackColor = resolveHyperContainerColor(trackColor, hyperSurfaces.controlTrack),
            activeTrackColor = resolvedActiveTrackColor,
            segmentMarkerColor = resolveHyperContainerColor(
                segmentMarkerColor,
                defaultMarkerColor
            ),
            thumbColor = resolveHyperContainerColor(
                thumbColor,
                hyperControlContainer(HyperControlSurfaceRole.Thumb)
            ),
            disabledTrackColor = resolveHyperContainerColor(
                disabledTrackColor,
                HyperColors.disabledContainer
            ),
            disabledActiveTrackColor = resolveHyperContainerColor(
                disabledActiveTrackColor,
                resolvedActiveTrackColor
            ),
            disabledSegmentMarkerColor = resolveHyperContainerColor(
                disabledSegmentMarkerColor,
                HyperColors.disabledText.copy(alpha = 0.72f)
            ),
            disabledThumbColor = resolveHyperContainerColor(
                disabledThumbColor,
                HyperColors.softContainer
            )
        )
    }

    @Composable
    fun trackBorder(color: Color = Color.Unspecified): BorderStroke = hyperPanelBorder(color)

    @Composable
    fun thumbBorder(color: Color = Color.Unspecified): BorderStroke =
        BorderStroke(2.dp, resolveHyperContainerColor(color, HyperColors.accent))
}

private fun pointerPositionToValue(
    pointerX: Float,
    widthPx: Float,
    valueRange: ClosedFloatingPointRange<Float>,
    divisionCount: Int
): Float {
    val availableTrackWidth = widthPx.coerceAtLeast(1f)
    val fraction = (pointerX / availableTrackWidth)
        .coerceIn(0f, 1f)
    val rawValue = valueRange.start + fraction * (valueRange.endInclusive - valueRange.start)
    return snapValueToSteps(rawValue, valueRange, divisionCount)
}

private fun valueToFraction(
    value: Float,
    valueRange: ClosedFloatingPointRange<Float>
): Float = ((value - valueRange.start) / (valueRange.endInclusive - valueRange.start))
    .coerceIn(0f, 1f)

private fun snapValueToSteps(
    value: Float,
    valueRange: ClosedFloatingPointRange<Float>,
    divisionCount: Int
): Float {
    val coercedValue = value.coerceIn(valueRange.start, valueRange.endInclusive)
    if (divisionCount == 0) return coercedValue

    val intervals = divisionCount
    val fraction = valueToFraction(coercedValue, valueRange)
    val snappedFraction = (fraction * intervals).roundToInt() / intervals.toFloat()
    return valueRange.start + snappedFraction * (valueRange.endInclusive - valueRange.start)
}

private fun resolveSegmentMarkerValues(
    showSegmentMarkers: Boolean,
    segmentValues: List<Float>,
    valueRange: ClosedFloatingPointRange<Float>,
    divisionCount: Int
): List<Float> {
    if (!showSegmentMarkers) return emptyList()

    val values = if (segmentValues.isNotEmpty()) {
        segmentValues
    } else if (divisionCount > 0) {
        val intervals = divisionCount
        List(intervals + 1) { index ->
            valueRange.start +
                (valueRange.endInclusive - valueRange.start) * index / intervals.toFloat()
        }
    } else {
        emptyList()
    }

    return values
        .asSequence()
        .filter { value -> value.isFinite() }
        .filter { value -> value in valueRange }
        .distinct()
        .sorted()
        .toList()
}
