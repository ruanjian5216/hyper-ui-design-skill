/** 文件职责：文档 Preview 使用 Skia 执行与 Android 相同的折射源码。 */
package hyper_ui

import androidx.compose.ui.graphics.RenderEffect
import androidx.compose.ui.graphics.asComposeRenderEffect
import org.jetbrains.skia.FilterTileMode
import org.jetbrains.skia.ImageFilter
import org.jetbrains.skia.RuntimeEffect
import org.jetbrains.skia.RuntimeShaderBuilder

internal fun createHyperGlassShader(): HyperGlassShader = PreviewGlassShader()

private class PreviewGlassShader : HyperGlassShader {
    private val runtime = RuntimeEffect.makeForShader(HyperGlassShaderCode)
    private val builder = RuntimeShaderBuilder(runtime)
    private var previous: HyperGlassOptics? = null
    private var cached: RenderEffect? = null
    override fun effect(optics: HyperGlassOptics): RenderEffect? {
        if (previous == optics) return cached
        previous = optics
        builder.uniform("size", optics.width, optics.height)
        builder.uniform("padding", optics.padding)
        builder.uniform("radii", optics.radii.toFloatArray())
        builder.uniform("edge", optics.edge)
        builder.uniform("amount", optics.amount)
        builder.uniform("dispersion", optics.dispersion)
        builder.uniform("depth", optics.depth)
        builder.uniform("saturation", optics.saturation)
        builder.uniform("brightness", optics.brightness)
        builder.uniform("highlight", optics.highlight)
        builder.uniform("stroke", optics.stroke)
        val lens = ImageFilter.makeRuntimeShader(builder, "content", null)
        val combined = if (optics.blur > 0f) {
            val blur = ImageFilter.makeBlur(optics.blur, optics.blur, FilterTileMode.CLAMP)
            ImageFilter.makeCompose(lens, blur)
        } else lens
        cached = combined.asComposeRenderEffect()
        return cached
    }
    override fun close() { builder.close(); runtime.close() }
}
