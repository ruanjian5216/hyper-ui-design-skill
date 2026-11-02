/** 文件职责：四类控件的固定玻璃绘制，不读取主题材质档位，不修改测量与命中范围。 */
package hyper_ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.dropShadow
import androidx.compose.ui.draw.innerShadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.layer.drawLayer
import androidx.compose.ui.layout.LayoutCoordinates
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import kotlin.math.ceil

internal enum class HyperControlSurfaceRole { Navigation, Button, Selection, Thumb, SwitchThumb, Dialog }

internal fun Modifier.hyperControlSurface(
    shape: Shape,
    role: HyperControlSurfaceRole,
    progress: () -> Float = { 0f },
    containerColor: Color = Color.Unspecified,
    border: BorderStroke? = null,
    sources: List<HyperGlassSource>? = null,
    sampleScale: ((HyperGlassSource) -> Offset)? = null
): Modifier = composed {
    val light = HyperColors.isLight
    val background = HyperColors.pageBackground
    val white = Color(1f, 1f, 1f, 1f)
    val black = Color(0f, 0f, 0f, 1f)
    val tint = if (light) white else white.copy(alpha = 0.34f)
    val backgroundSources = sources ?: listOfNotNull(LocalHyperGlassSource.current)
    val shader = remember { createHyperGlassShader() }
    val layer = rememberGraphicsLayer()
    var coordinates by remember { mutableStateOf<LayoutCoordinates?>(null) }
    DisposableEffect(shader) { onDispose { shader.close() } }
    val interactive = role == HyperControlSurfaceRole.Selection || role == HyperControlSurfaceRole.Thumb || role == HyperControlSurfaceRole.SwitchThumb
    val shadowRadius = when (role) {
        HyperControlSurfaceRole.Navigation -> HyperGlassStyles.Navigation.shadow
        HyperControlSurfaceRole.Dialog -> 16.dp
        HyperControlSurfaceRole.Thumb, HyperControlSurfaceRole.SwitchThumb -> 4.dp
        HyperControlSurfaceRole.Button -> HyperGlassStyles.button(progress().coerceIn(0f, 1f)).shadow
        else -> 8.dp
    }
    this.onGloballyPositioned { coordinates = it }.dropShadow(shape) {
        radius = shadowRadius.toPx()
        color = black.copy(alpha = if (light) 0.08f else 0.18f)
        alpha = if (role == HyperControlSurfaceRole.Selection) progress().coerceIn(0f, 1f) else 1f
    }.clip(shape).drawWithContent {
        if (size.width <= 0f || size.height <= 0f) return@drawWithContent
        val pressed = progress().coerceIn(0f, 1f)
        val strength = if (interactive) pressed else 1f
        val outline = shape.createOutline(size, layoutDirection, this)
        val actual = coordinates
        val controlStyle = if (role == HyperControlSurfaceRole.Button) HyperGlassStyles.button(pressed) else HyperGlassStyles.Navigation
        val blur = when (role) {
            HyperControlSurfaceRole.Navigation, HyperControlSurfaceRole.Button -> controlStyle.blur.toPx()
            HyperControlSurfaceRole.Selection -> 0f
            HyperControlSurfaceRole.Thumb, HyperControlSurfaceRole.SwitchThumb -> 8.dp.toPx() * (1f-pressed)
            HyperControlSurfaceRole.Dialog -> (if (light) 16.dp else 8.dp).toPx()
        }
        val edge = when (role) {
            HyperControlSurfaceRole.Navigation, HyperControlSurfaceRole.Button -> controlStyle.edge
            HyperControlSurfaceRole.Dialog -> 24.dp
            HyperControlSurfaceRole.SwitchThumb -> 5.dp
            else -> 10.dp
        }.toPx()*strength
        val amount = when (role) {
            HyperControlSurfaceRole.Navigation, HyperControlSurfaceRole.Button -> controlStyle.amount
            HyperControlSurfaceRole.Dialog -> 48.dp
            HyperControlSurfaceRole.SwitchThumb -> 10.dp
            else -> 14.dp
        }.toPx()*strength
        if (shader.supported && actual?.isAttached == true && backgroundSources.isNotEmpty()) {
            val padding = ceil(blur*3f+edge)
            val radii = if (outline is Outline.Rounded) with(outline.roundRect) {
                listOf(topLeftCornerRadius.x,topRightCornerRadius.x,bottomRightCornerRadius.x,bottomLeftCornerRadius.x)
            } else List(4) { 0f }
            layer.renderEffect = shader.effect(HyperGlassOptics(size.width,size.height,padding,radii,
                if (outline is Outline.Generic) 0f else edge,amount,if (interactive) pressed else 0f,
                if (role == HyperControlSurfaceRole.Dialog) 1f else 0f,blur,
                if (role == HyperControlSurfaceRole.Dialog) 1.5f else 1f,
                if (role == HyperControlSurfaceRole.Dialog && light) 0.2f else 0f,
                if (role == HyperControlSurfaceRole.Button) controlStyle.highlight * 2f else strength,0.5.dp.toPx()))
            layer.record(size = IntSize(ceil(size.width+padding*2).toInt(),ceil(size.height+padding*2).toInt())) {
                drawRect(background)
                backgroundSources.forEach { source ->
                    val origin = source.coordinates
                    if (origin?.isAttached == true) {
                        val factor = sampleScale?.invoke(source) ?: Offset(1f,1f)
                        if (factor.x > 0f && factor.y > 0f) scale(factor.x,factor.y) {
                            drawHyperGlassSource(source, actual, padding)
                        }
                    }
                }
            }
            translate(-padding,-padding) { drawLayer(layer) }
        } else if (role == HyperControlSurfaceRole.Selection && actual?.isAttached == true) {
            // 旧系统也重绘独立标签副本，镜片位于标签上层时不会遮挡文字。
            backgroundSources.forEach { source ->
                drawHyperGlassSource(source, actual)
            }
        }
        when (role) {
            HyperControlSurfaceRole.Navigation -> drawRect(if (containerColor != Color.Unspecified) containerColor else tint, alpha = 0.4f)
            HyperControlSurfaceRole.Button -> drawRect(if (containerColor != Color.Unspecified) containerColor else tint.copy(alpha = tint.alpha * 0.4f))
            HyperControlSurfaceRole.Selection -> {
                drawRect(if (light) black else white,alpha = 0.1f*(1f-pressed))
                drawRect(black,alpha = 0.03f*pressed)
            }
            HyperControlSurfaceRole.Thumb, HyperControlSurfaceRole.SwitchThumb ->
                drawRect(if (containerColor != Color.Unspecified) containerColor else white,alpha = 1f-pressed)
            HyperControlSurfaceRole.Dialog -> drawRect(if (containerColor != Color.Unspecified) containerColor else tint,
                alpha = if (containerColor != Color.Unspecified) 1f else if (light) 0.6f else 0.8f)
        }
        drawContent()
        val intensity = if (role == HyperControlSurfaceRole.Button) {
            if (border == null) controlStyle.highlight else 0f
        } else if (interactive) pressed else HyperGlassStyles.Navigation.highlight
        if (intensity > 0f) drawOutline(outline,Brush.linearGradient(listOf(
            white.copy(alpha = 0.6f*intensity),white.copy(alpha = 0.04f*intensity),white.copy(alpha = 0.5f*intensity)),
            Offset.Zero,Offset(size.width,size.height)),style = Stroke(0.5.dp.toPx()))
    }.then(if (interactive) Modifier.innerShadow(shape) {
        val pressed = progress().coerceIn(0f,1f)
        radius = (if (role == HyperControlSurfaceRole.Selection) 8.dp else 4.dp).toPx()*pressed
        color = black.copy(alpha = 0.12f)
        alpha = pressed
    } else Modifier).then(if (border != null) Modifier.border(border,shape) else Modifier)
}

@Composable
internal fun hyperControlContainer(role: HyperControlSurfaceRole): Color = Color.Unspecified
