/** 文件职责：参考 Ambient 高光的独立前景层，复用着色器后端与真实轮廓。 */
package hyper_ui

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.layer.drawLayer
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import kotlin.math.ceil

internal fun Modifier.hyperSwitchHighlight(shape: Shape, progress: () -> Float): Modifier = composed {
    val shader = remember { createHyperGlassShader() }
    val layer = rememberGraphicsLayer()
    DisposableEffect(shader) { onDispose { shader.close() } }
    drawWithContent {
        drawContent()
        val p = progress().coerceIn(0f,1f)
        if (p <= 0f || size.minDimension <= 0f) return@drawWithContent
        val outline = shape.createOutline(size, layoutDirection, this)
        val width = ceil((0.5.dp/1.5f).toPx())*2f
        val radii = if (outline is Outline.Rounded) with(outline.roundRect) {
            listOf(topLeftCornerRadius.x,topRightCornerRadius.x,bottomRightCornerRadius.x,bottomLeftCornerRadius.x)
        } else List(4) { size.minDimension/2f }
        layer.alpha = p
        layer.renderEffect = if (shader.supportsAmbient) shader.effect(HyperGlassOptics(
            size.width,size.height,1f,radii,0f,0f,0f,0f,(0.25.dp/1.5f).toPx(),1f,0f,0f,width,1f))
            else BlurEffect(radiusX = (0.25.dp/1.5f).toPx(), radiusY = (0.25.dp/1.5f).toPx())
        layer.record(size = IntSize(ceil(size.width).toInt()+2,ceil(size.height).toInt()+2)) {
            translate(1f,1f) {
                drawOutline(outline, Color(1f,1f,1f,0.38f), style = Stroke(width))
            }
        }
        translate(-1f,-1f) { drawLayer(layer) }
    }
}
